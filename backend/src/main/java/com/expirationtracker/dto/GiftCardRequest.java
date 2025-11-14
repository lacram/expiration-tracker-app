package com.expirationtracker.dto;

import com.expirationtracker.entity.CardStatus;
import com.expirationtracker.entity.Category;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
public class GiftCardRequest {

    @NotBlank(message = "카드 이름은 필수입니다")
    private String name;

    @NotNull(message = "카테고리는 필수입니다")
    private Category category;

    @NotNull(message = "유효기간은 필수입니다")
    private LocalDate expirationDate;

    private String imageBase64;

    private String barcode;

    private String memo;

    private String userId;

    // Flutter에서 보낼 수 있지만, 생성 시에는 무시되고 서버에서 자동으로 ACTIVE로 설정됨
    private CardStatus status;
}
