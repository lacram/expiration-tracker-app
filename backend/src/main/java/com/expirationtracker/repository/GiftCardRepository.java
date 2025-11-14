package com.expirationtracker.repository;

import com.expirationtracker.entity.CardStatus;
import com.expirationtracker.entity.Category;
import com.expirationtracker.entity.GiftCard;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface GiftCardRepository extends JpaRepository<GiftCard, Long> {

    // 상태별 조회
    List<GiftCard> findByStatus(CardStatus status);

    // 카테고리별 조회
    List<GiftCard> findByCategory(Category category);

    // 유효기간 임박 조회 (N일 이내)
    @Query("SELECT g FROM GiftCard g WHERE g.status = 'ACTIVE' AND g.expirationDate BETWEEN :today AND :endDate ORDER BY g.expirationDate ASC")
    List<GiftCard> findExpiringSoon(@Param("today") LocalDate today, @Param("endDate") LocalDate endDate);

    // 만료된 카드 조회
    @Query("SELECT g FROM GiftCard g WHERE g.status = 'ACTIVE' AND g.expirationDate < :today")
    List<GiftCard> findExpiredCards(@Param("today") LocalDate today);

    // 사용자별 조회 (추후 인증 구현 시 사용)
    List<GiftCard> findByUserId(String userId);

    // 상태별 개수
    long countByStatus(CardStatus status);

    // 유효기간 임박 개수
    @Query("SELECT COUNT(g) FROM GiftCard g WHERE g.status = 'ACTIVE' AND g.expirationDate BETWEEN :today AND :endDate")
    long countExpiringSoon(@Param("today") LocalDate today, @Param("endDate") LocalDate endDate);
}
