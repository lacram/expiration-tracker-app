package com.expirationtracker.service;

import com.expirationtracker.dto.GiftCardRequest;
import com.expirationtracker.entity.CardStatus;
import com.expirationtracker.entity.Category;
import com.expirationtracker.entity.GiftCard;
import com.expirationtracker.repository.GiftCardRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class GiftCardService {

    private final GiftCardRepository giftCardRepository;

    // 전체 조회
    public List<GiftCard> getAllCards() {
        return giftCardRepository.findAll();
    }

    // ID로 조회
    public GiftCard getCardById(Long id) {
        return giftCardRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("카드를 찾을 수 없습니다: " + id));
    }

    // 상태별 조회
    public List<GiftCard> getCardsByStatus(CardStatus status) {
        return giftCardRepository.findByStatus(status);
    }

    // 카테고리별 조회
    public List<GiftCard> getCardsByCategory(Category category) {
        return giftCardRepository.findByCategory(category);
    }

    // 유효기간 임박 조회 (N일 이내)
    public List<GiftCard> getExpiringSoonCards(int days) {
        LocalDate today = LocalDate.now();
        LocalDate endDate = today.plusDays(days);
        return giftCardRepository.findExpiringSoon(today, endDate);
    }

    // 만료된 카드 조회
    public List<GiftCard> getExpiredCards() {
        return giftCardRepository.findExpiredCards(LocalDate.now());
    }

    // 생성
    @Transactional
    public GiftCard createCard(GiftCardRequest request) {
        GiftCard card = GiftCard.builder()
                .name(request.getName())
                .category(request.getCategory())
                .expirationDate(request.getExpirationDate())
                .imageBase64(request.getImageBase64())
                .barcode(request.getBarcode())
                .memo(request.getMemo())
                .userId(request.getUserId())
                .status(CardStatus.ACTIVE)
                .build();

        return giftCardRepository.save(card);
    }

    // 수정
    @Transactional
    public GiftCard updateCard(Long id, GiftCardRequest request) {
        GiftCard card = getCardById(id);

        card.setName(request.getName());
        card.setCategory(request.getCategory());
        card.setExpirationDate(request.getExpirationDate());
        card.setImageBase64(request.getImageBase64());
        card.setBarcode(request.getBarcode());
        card.setMemo(request.getMemo());

        return giftCardRepository.save(card);
    }

    // 삭제
    @Transactional
    public void deleteCard(Long id) {
        GiftCard card = getCardById(id);
        giftCardRepository.delete(card);
    }

    // 사용 완료 처리
    @Transactional
    public GiftCard markAsUsed(Long id) {
        GiftCard card = getCardById(id);
        card.markAsUsed();
        return giftCardRepository.save(card);
    }

    // 만료 처리 (스케줄러에서 사용)
    @Transactional
    public void updateExpiredCards() {
        List<GiftCard> expiredCards = getExpiredCards();
        expiredCards.forEach(GiftCard::markAsExpired);
        giftCardRepository.saveAll(expiredCards);
        log.info("만료된 카드 {}개 업데이트 완료", expiredCards.size());
    }

    // 통계 - 유효기간 임박 개수
    public long countExpiringSoon(int days) {
        LocalDate today = LocalDate.now();
        LocalDate endDate = today.plusDays(days);
        return giftCardRepository.countExpiringSoon(today, endDate);
    }

    // 통계 - 상태별 개수
    public long countByStatus(CardStatus status) {
        return giftCardRepository.countByStatus(status);
    }
}
