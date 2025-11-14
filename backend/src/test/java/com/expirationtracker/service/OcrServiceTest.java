package com.expirationtracker.service;

import com.expirationtracker.dto.OcrResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDate;
import java.util.Base64;

import static org.assertj.core.api.Assertions.assertThat;

@DisplayName("OcrService 단위 테스트")
class OcrServiceTest {

    private OcrService ocrService;

    @BeforeEach
    void setUp() {
        ocrService = new OcrService();
    }

    @Test
    @DisplayName("OCR API 미설정 시 실패 응답 반환")
    void processImage_ApiNotConfigured() {
        // given
        String dummyImage = "data:image/jpeg;base64," + Base64.getEncoder().encodeToString("test".getBytes());

        // when
        OcrResponse response = ocrService.processImage(dummyImage);

        // then
        assertThat(response).isNotNull();
        assertThat(response.isSuccess()).isFalse();
        assertThat(response.getMessage()).contains("OCR API가 설정되지 않았습니다");
    }

    @Test
    @DisplayName("OCR API 설정되어 있지만 잘못된 이미지 - 오류 처리")
    void processImage_InvalidImage() {
        // given
        ReflectionTestUtils.setField(ocrService, "clovaOcrUrl", "http://fake-url.com");
        ReflectionTestUtils.setField(ocrService, "clovaOcrSecret", "fake-secret");

        String invalidImage = "invalid-base64-string";

        // when
        OcrResponse response = ocrService.processImage(invalidImage);

        // then
        assertThat(response).isNotNull();
        assertThat(response.isSuccess()).isFalse();
        assertThat(response.getMessage()).contains("오류가 발생했습니다");
    }

    @Test
    @DisplayName("날짜 추출 테스트 - YYYY-MM-DD 형식")
    void extractExpirationDate_HyphenFormat() throws Exception {
        // given
        String testText = "스타벅스 아메리카노\n유효기간: 2025-12-31\n1234567890123";

        // when
        LocalDate date = invokePrivateMethod("extractExpirationDate", testText);

        // then
        assertThat(date).isNotNull();
        assertThat(date).isEqualTo(LocalDate.of(2025, 12, 31));
    }

    @Test
    @DisplayName("날짜 추출 테스트 - YYYY.MM.DD 형식")
    void extractExpirationDate_DotFormat() throws Exception {
        // given
        String testText = "CU 편의점 상품권\n2025.06.15\n9876543210987";

        // when
        LocalDate date = invokePrivateMethod("extractExpirationDate", testText);

        // then
        assertThat(date).isNotNull();
        assertThat(date).isEqualTo(LocalDate.of(2025, 6, 15));
    }

    @Test
    @DisplayName("날짜 추출 테스트 - YYYYMMDD 형식")
    void extractExpirationDate_NoSeparatorFormat() throws Exception {
        // given
        String testText = "CGV 영화 관람권\n20260101\n5555555555555";

        // when
        LocalDate date = invokePrivateMethod("extractExpirationDate", testText);

        // then
        assertThat(date).isNotNull();
        assertThat(date).isEqualTo(LocalDate.of(2026, 1, 1));
    }

    @Test
    @DisplayName("날짜 추출 실패 - 유효하지 않은 형식")
    void extractExpirationDate_InvalidFormat() throws Exception {
        // given
        String testText = "날짜 없는 텍스트\n상품권";

        // when
        LocalDate date = invokePrivateMethod("extractExpirationDate", testText);

        // then
        assertThat(date).isNull();
    }

    @Test
    @DisplayName("바코드 추출 테스트 - 13자리")
    void extractBarcode_13Digits() throws Exception {
        // given
        String testText = "스타벅스 아메리카노\n1234567890123\n유효기간: 2025-12-31";

        // when
        String barcode = invokePrivateMethod("extractBarcode", testText);

        // then
        assertThat(barcode).isNotNull();
        assertThat(barcode).isEqualTo("1234567890123");
    }

    @Test
    @DisplayName("바코드 추출 테스트 - 12자리")
    void extractBarcode_12Digits() throws Exception {
        // given
        String testText = "CU 편의점 상품권\n123456789012\n2025.06.15";

        // when
        String barcode = invokePrivateMethod("extractBarcode", testText);

        // then
        assertThat(barcode).isNotNull();
        assertThat(barcode).isEqualTo("123456789012");
    }

    @Test
    @DisplayName("바코드 추출 실패 - 10자리 미만")
    void extractBarcode_TooShort() throws Exception {
        // given
        String testText = "상품권\n123456789\n2025.06.15";

        // when
        String barcode = invokePrivateMethod("extractBarcode", testText);

        // then
        assertThat(barcode).isNull();
    }

    @Test
    @DisplayName("카드 이름 추출 테스트")
    void extractCardName_Success() throws Exception {
        // given
        String testText = "스타벅스 아메리카노 Tall\n유효기간: 2025-12-31\n1234567890123";

        // when
        String name = invokePrivateMethod("extractCardName", testText);

        // then
        assertThat(name).isNotNull();
        assertThat(name).isEqualTo("스타벅스 아메리카노 Tall");
    }

    @Test
    @DisplayName("카드 이름 추출 실패 - 빈 텍스트")
    void extractCardName_EmptyText() throws Exception {
        // given
        String testText = "";

        // when
        String name = invokePrivateMethod("extractCardName", testText);

        // then
        assertThat(name).isNull();
    }

    // Helper method to invoke private methods for testing
    @SuppressWarnings("unchecked")
    private <T> T invokePrivateMethod(String methodName, String param) throws Exception {
        java.lang.reflect.Method method = OcrService.class.getDeclaredMethod(methodName, String.class);
        method.setAccessible(true);
        return (T) method.invoke(ocrService, param);
    }
}
