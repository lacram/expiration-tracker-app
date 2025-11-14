package com.expirationtracker.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "gift_cards")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GiftCard {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "카드 이름은 필수입니다")
    @Column(nullable = false)
    private String name;

    @Enumerated(EnumType.STRING)
    @NotNull(message = "카테고리는 필수입니다")
    @Column(nullable = false)
    private Category category;

    @NotNull(message = "유효기간은 필수입니다")
    @Column(nullable = false)
    private LocalDate expirationDate;

    @Enumerated(EnumType.STRING)
    @NotNull
    @Column(nullable = false)
    @Builder.Default
    private CardStatus status = CardStatus.ACTIVE;

    @Column(columnDefinition = "TEXT")
    private String imageBase64;  // Base64 인코딩된 이미지

    @Column(length = 100)
    private String barcode;  // 바코드 번호

    @Column(length = 500)
    private String memo;  // 메모

    @Column(length = 100)
    private String userId;  // 사용자 ID (추후 인증 구현 시 사용)

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;

    @Column
    private LocalDateTime usedAt;  // 사용 완료 시간

    // 비즈니스 로직
    public boolean isExpired() {
        return LocalDate.now().isAfter(expirationDate);
    }

    public long getDaysUntilExpiration() {
        return java.time.temporal.ChronoUnit.DAYS.between(LocalDate.now(), expirationDate);
    }

    public boolean isExpiringSoon(int days) {
        long daysUntil = getDaysUntilExpiration();
        return daysUntil >= 0 && daysUntil <= days;
    }

    public void markAsUsed() {
        this.status = CardStatus.USED;
        this.usedAt = LocalDateTime.now();
    }

    public void markAsExpired() {
        this.status = CardStatus.EXPIRED;
    }
}
