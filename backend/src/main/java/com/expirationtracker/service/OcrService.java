package com.expirationtracker.service;

import com.expirationtracker.dto.OcrResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Base64;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
@Slf4j
public class OcrService {

    @Value("${naver.clova.ocr.url:}")
    private String clovaOcrUrl;

    @Value("${naver.clova.ocr.secret:}")
    private String clovaOcrSecret;

    private final WebClient webClient;

    public OcrService() {
        this.webClient = WebClient.builder().build();
    }

    /**
     * Naver Clova OCR API를 호출하여 이미지에서 텍스트 추출
     */
    public OcrResponse processImage(String imageBase64) {
        // OCR API 미설정 시 더미 응답 반환
        if (clovaOcrUrl == null || clovaOcrUrl.isEmpty() ||
            clovaOcrSecret == null || clovaOcrSecret.isEmpty()) {
            log.warn("Naver Clova OCR API 설정이 없습니다. 더미 데이터를 반환합니다.");
            return OcrResponse.builder()
                    .success(false)
                    .message("OCR API가 설정되지 않았습니다. application.yml에 naver.clova.ocr.url과 secret을 설정하세요.")
                    .build();
        }

        try {
            // Base64 이미지를 바이트 배열로 변환
            byte[] imageBytes = Base64.getDecoder().decode(imageBase64.split(",")[imageBase64.contains(",") ? 1 : 0]);

            // Naver Clova OCR API 호출
            Map<String, Object> requestBody = Map.of(
                    "version", "V2",
                    "requestId", java.util.UUID.randomUUID().toString(),
                    "timestamp", System.currentTimeMillis(),
                    "images", java.util.List.of(Map.of(
                            "format", "jpg",
                            "name", "giftcard",
                            "data", Base64.getEncoder().encodeToString(imageBytes)
                    ))
            );

            String response = webClient.post()
                    .uri(clovaOcrUrl)
                    .header("X-OCR-SECRET", clovaOcrSecret)
                    .header("Content-Type", "application/json")
                    .bodyValue(requestBody)
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            log.info("OCR API 응답: {}", response);

            // 응답 파싱 및 정보 추출
            return parseOcrResponse(response);

        } catch (Exception e) {
            log.error("OCR 처리 중 오류 발생", e);
            return OcrResponse.builder()
                    .success(false)
                    .message("OCR 처리 중 오류가 발생했습니다: " + e.getMessage())
                    .build();
        }
    }

    /**
     * OCR 응답에서 기프티콘 정보 추출
     */
    private OcrResponse parseOcrResponse(String response) {
        OcrResponse.OcrResponseBuilder builder = OcrResponse.builder();

        try {
            // Naver Clova OCR JSON 응답 파싱
            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            com.fasterxml.jackson.databind.JsonNode root = mapper.readTree(response);

            // General OCR: images[0].fields[].inferText에서 텍스트 추출
            StringBuilder inferTextBuilder = new StringBuilder();
            if (root.has("images") && root.get("images").isArray() && root.get("images").size() > 0) {
                com.fasterxml.jackson.databind.JsonNode firstImage = root.get("images").get(0);

                // General OCR의 경우 fields 배열에서 텍스트 추출
                if (firstImage.has("fields") && firstImage.get("fields").isArray()) {
                    for (com.fasterxml.jackson.databind.JsonNode field : firstImage.get("fields")) {
                        if (field.has("inferText")) {
                            String text = field.get("inferText").asText();
                            inferTextBuilder.append(text);
                            // lineBreak가 true이면 줄바꿈 추가
                            if (field.has("lineBreak") && field.get("lineBreak").asBoolean()) {
                                inferTextBuilder.append("\n");
                            } else {
                                inferTextBuilder.append(" ");
                            }
                        }
                    }
                }
                // Template OCR의 경우 (하위 호환성)
                else if (firstImage.has("title") && firstImage.get("title").has("inferText")) {
                    inferTextBuilder.append(firstImage.get("title").get("inferText").asText());
                }
            }

            String inferText = inferTextBuilder.toString().trim();
            log.info("OCR 인식 텍스트: {}", inferText);

            // 추출된 텍스트가 없으면 실패
            if (inferText.isEmpty()) {
                builder.success(false);
                builder.message("OCR에서 텍스트를 인식하지 못했습니다");
                return builder.build();
            }

            // 유효기간 추출
            LocalDate expirationDate = extractExpirationDate(inferText);
            if (expirationDate != null) {
                builder.expirationDate(expirationDate);
            }

            // 바코드 추출
            String barcode = extractBarcode(inferText);
            if (barcode != null) {
                builder.barcode(barcode);
            }

            // 카드 이름은 첫 번째 텍스트 라인으로 추정
            String name = extractCardName(inferText);
            if (name != null) {
                builder.name(name);
            }

            builder.success(expirationDate != null || barcode != null || name != null);
            builder.message(builder.build().isSuccess() ? "OCR 성공" : "정보를 추출할 수 없습니다");

        } catch (Exception e) {
            log.error("OCR 응답 파싱 실패", e);
            builder.success(false);
            builder.message("OCR 응답 파싱 중 오류 발생: " + e.getMessage());
        }

        return builder.build();
    }

    private LocalDate extractExpirationDate(String text) {
        // 유효기간 범위 패턴 (시작일 ~ 종료일) - 종료일 추출
        Pattern rangePattern = Pattern.compile("(\\d{4})[-./](\\d{1,2})[-./](\\d{1,2})\\s*[~-]\\s*(\\d{4})[-./](\\d{1,2})[-./](\\d{1,2})");
        Matcher rangeMatcher = rangePattern.matcher(text);
        if (rangeMatcher.find()) {
            try {
                // 종료일 추출 (group 4, 5, 6)
                int year = Integer.parseInt(rangeMatcher.group(4));
                int month = Integer.parseInt(rangeMatcher.group(5));
                int day = Integer.parseInt(rangeMatcher.group(6));
                log.info("유효기간 범위 감지: 종료일 {}-{}-{} 추출", year, month, day);
                return LocalDate.of(year, month, day);
            } catch (Exception e) {
                log.debug("날짜 범위 파싱 실패: {}", rangeMatcher.group());
            }
        }

        // 단일 날짜 패턴
        Pattern[] patterns = {
                Pattern.compile("유효기간[:\\s]*(\\d{4})[-./](\\d{1,2})[-./](\\d{1,2})"),
                Pattern.compile("(\\d{4})[-./](\\d{1,2})[-./](\\d{1,2})"),
                Pattern.compile("(\\d{4})(\\d{2})(\\d{2})"),
        };

        for (Pattern pattern : patterns) {
            Matcher matcher = pattern.matcher(text);
            if (matcher.find()) {
                try {
                    int year = Integer.parseInt(matcher.group(1));
                    int month = Integer.parseInt(matcher.group(2));
                    int day = Integer.parseInt(matcher.group(3));
                    return LocalDate.of(year, month, day);
                } catch (Exception e) {
                    log.debug("날짜 파싱 실패: {}", matcher.group());
                }
            }
        }
        return null;
    }

    private String extractBarcode(String text) {
        // 10-15자리 연속 숫자 (바코드로 추정)
        Pattern pattern = Pattern.compile("\\b(\\d{10,15})\\b");
        Matcher matcher = pattern.matcher(text);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

    private String extractCardName(String text) {
        // 첫 번째 텍스트 라인 (보통 상품명)
        if (text == null || text.trim().isEmpty()) {
            return null;
        }
        String[] lines = text.split("\\n");
        if (lines.length > 0 && !lines[0].trim().isEmpty()) {
            return lines[0].trim();
        }
        return null;
    }
}
