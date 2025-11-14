package com.expirationtracker.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OcrResponse {
    private String name;           // 인식된 카드 이름
    private LocalDate expirationDate;  // 인식된 유효기간
    private String barcode;        // 인식된 바코드
    private boolean success;       // OCR 성공 여부
    private String message;        // 오류 메시지
}
