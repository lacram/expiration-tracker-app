package com.expirationtracker.service;

import com.expirationtracker.dto.GiftCardRequest;
import com.expirationtracker.entity.CardStatus;
import com.expirationtracker.entity.Category;
import com.expirationtracker.entity.GiftCard;
import com.expirationtracker.repository.GiftCardRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("GiftCardService 단위 테스트")
class GiftCardServiceTest {

    @Mock
    private GiftCardRepository giftCardRepository;

    @InjectMocks
    private GiftCardService giftCardService;

    private GiftCard testCard;

    @BeforeEach
    void setUp() {
        testCard = GiftCard.builder()
                .id(1L)
                .name("스타벅스 아메리카노")
                .category(Category.GIFTCARD)
                .expirationDate(LocalDate.now().plusDays(30))
                .status(CardStatus.ACTIVE)
                .barcode("1234567890123")
                .memo("테스트 메모")
                .build();
    }

    @Test
    @DisplayName("전체 카드 조회 성공")
    void getAllCards_Success() {
        // given
        List<GiftCard> cards = Arrays.asList(testCard);
        when(giftCardRepository.findAll()).thenReturn(cards);

        // when
        List<GiftCard> result = giftCardService.getAllCards();

        // then
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getName()).isEqualTo("스타벅스 아메리카노");
        verify(giftCardRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("ID로 카드 조회 성공")
    void getCardById_Success() {
        // given
        when(giftCardRepository.findById(1L)).thenReturn(Optional.of(testCard));

        // when
        GiftCard result = giftCardService.getCardById(1L);

        // then
        assertThat(result).isNotNull();
        assertThat(result.getName()).isEqualTo("스타벅스 아메리카노");
        verify(giftCardRepository, times(1)).findById(1L);
    }

    @Test
    @DisplayName("ID로 카드 조회 실패 - 카드 없음")
    void getCardById_NotFound() {
        // given
        when(giftCardRepository.findById(999L)).thenReturn(Optional.empty());

        // when & then
        assertThatThrownBy(() -> giftCardService.getCardById(999L))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("카드를 찾을 수 없습니다");
        verify(giftCardRepository, times(1)).findById(999L);
    }

    @Test
    @DisplayName("상태별 카드 조회 성공")
    void getCardsByStatus_Success() {
        // given
        List<GiftCard> activeCards = Arrays.asList(testCard);
        when(giftCardRepository.findByStatus(CardStatus.ACTIVE)).thenReturn(activeCards);

        // when
        List<GiftCard> result = giftCardService.getCardsByStatus(CardStatus.ACTIVE);

        // then
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getStatus()).isEqualTo(CardStatus.ACTIVE);
        verify(giftCardRepository, times(1)).findByStatus(CardStatus.ACTIVE);
    }

    @Test
    @DisplayName("카테고리별 카드 조회 성공")
    void getCardsByCategory_Success() {
        // given
        List<GiftCard> giftCards = Arrays.asList(testCard);
        when(giftCardRepository.findByCategory(Category.GIFTCARD)).thenReturn(giftCards);

        // when
        List<GiftCard> result = giftCardService.getCardsByCategory(Category.GIFTCARD);

        // then
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getCategory()).isEqualTo(Category.GIFTCARD);
        verify(giftCardRepository, times(1)).findByCategory(Category.GIFTCARD);
    }

    @Test
    @DisplayName("유효기간 임박 카드 조회 성공")
    void getExpiringSoonCards_Success() {
        // given
        LocalDate today = LocalDate.now();
        LocalDate endDate = today.plusDays(7);
        List<GiftCard> expiringSoonCards = Arrays.asList(testCard);
        when(giftCardRepository.findExpiringSoon(today, endDate)).thenReturn(expiringSoonCards);

        // when
        List<GiftCard> result = giftCardService.getExpiringSoonCards(7);

        // then
        assertThat(result).hasSize(1);
        verify(giftCardRepository, times(1)).findExpiringSoon(any(LocalDate.class), any(LocalDate.class));
    }

    @Test
    @DisplayName("만료된 카드 조회 성공")
    void getExpiredCards_Success() {
        // given
        GiftCard expiredCard = GiftCard.builder()
                .id(2L)
                .name("만료된 카드")
                .category(Category.COUPON)
                .expirationDate(LocalDate.now().minusDays(1))
                .status(CardStatus.EXPIRED)
                .build();
        List<GiftCard> expiredCards = Arrays.asList(expiredCard);
        when(giftCardRepository.findExpiredCards(any(LocalDate.class))).thenReturn(expiredCards);

        // when
        List<GiftCard> result = giftCardService.getExpiredCards();

        // then
        assertThat(result).hasSize(1);
        verify(giftCardRepository, times(1)).findExpiredCards(any(LocalDate.class));
    }

    @Test
    @DisplayName("카드 생성 성공")
    void createCard_Success() {
        // given
        GiftCardRequest request = new GiftCardRequest();
        request.setName("CU 편의점 상품권");
        request.setCategory(Category.VOUCHER);
        request.setExpirationDate(LocalDate.now().plusDays(60));
        request.setBarcode("9876543210987");

        GiftCard newCard = GiftCard.builder()
                .id(2L)
                .name(request.getName())
                .category(request.getCategory())
                .expirationDate(request.getExpirationDate())
                .barcode(request.getBarcode())
                .status(CardStatus.ACTIVE)
                .build();

        when(giftCardRepository.save(any(GiftCard.class))).thenReturn(newCard);

        // when
        GiftCard result = giftCardService.createCard(request);

        // then
        assertThat(result).isNotNull();
        assertThat(result.getName()).isEqualTo("CU 편의점 상품권");
        assertThat(result.getStatus()).isEqualTo(CardStatus.ACTIVE);
        verify(giftCardRepository, times(1)).save(any(GiftCard.class));
    }

    @Test
    @DisplayName("카드 수정 성공")
    void updateCard_Success() {
        // given
        GiftCardRequest request = new GiftCardRequest();
        request.setName("수정된 카드 이름");
        request.setCategory(Category.TICKET);
        request.setExpirationDate(LocalDate.now().plusDays(15));
        request.setBarcode("1111111111111");
        request.setMemo("수정된 메모");

        when(giftCardRepository.findById(1L)).thenReturn(Optional.of(testCard));
        when(giftCardRepository.save(any(GiftCard.class))).thenReturn(testCard);

        // when
        GiftCard result = giftCardService.updateCard(1L, request);

        // then
        assertThat(result).isNotNull();
        verify(giftCardRepository, times(1)).findById(1L);
        verify(giftCardRepository, times(1)).save(any(GiftCard.class));
    }

    @Test
    @DisplayName("카드 삭제 성공")
    void deleteCard_Success() {
        // given
        when(giftCardRepository.findById(1L)).thenReturn(Optional.of(testCard));
        doNothing().when(giftCardRepository).delete(any(GiftCard.class));

        // when
        giftCardService.deleteCard(1L);

        // then
        verify(giftCardRepository, times(1)).findById(1L);
        verify(giftCardRepository, times(1)).delete(testCard);
    }

    @Test
    @DisplayName("카드 사용 완료 처리 성공")
    void markAsUsed_Success() {
        // given
        when(giftCardRepository.findById(1L)).thenReturn(Optional.of(testCard));
        when(giftCardRepository.save(any(GiftCard.class))).thenReturn(testCard);

        // when
        GiftCard result = giftCardService.markAsUsed(1L);

        // then
        assertThat(result).isNotNull();
        assertThat(result.getStatus()).isEqualTo(CardStatus.USED);
        assertThat(result.getUsedAt()).isNotNull();
        verify(giftCardRepository, times(1)).findById(1L);
        verify(giftCardRepository, times(1)).save(any(GiftCard.class));
    }

    @Test
    @DisplayName("만료 카드 업데이트 성공")
    void updateExpiredCards_Success() {
        // given
        GiftCard expiredCard = GiftCard.builder()
                .id(3L)
                .name("만료 예정 카드")
                .category(Category.COUPON)
                .expirationDate(LocalDate.now().minusDays(1))
                .status(CardStatus.ACTIVE)
                .build();

        List<GiftCard> expiredCards = Arrays.asList(expiredCard);
        when(giftCardRepository.findExpiredCards(any(LocalDate.class))).thenReturn(expiredCards);
        when(giftCardRepository.saveAll(anyList())).thenReturn(expiredCards);

        // when
        giftCardService.updateExpiredCards();

        // then
        verify(giftCardRepository, times(1)).findExpiredCards(any(LocalDate.class));
        verify(giftCardRepository, times(1)).saveAll(anyList());
    }

    @Test
    @DisplayName("유효기간 임박 카드 개수 조회 성공")
    void countExpiringSoon_Success() {
        // given
        when(giftCardRepository.countExpiringSoon(any(LocalDate.class), any(LocalDate.class))).thenReturn(5L);

        // when
        long count = giftCardService.countExpiringSoon(7);

        // then
        assertThat(count).isEqualTo(5L);
        verify(giftCardRepository, times(1)).countExpiringSoon(any(LocalDate.class), any(LocalDate.class));
    }

    @Test
    @DisplayName("상태별 카드 개수 조회 성공")
    void countByStatus_Success() {
        // given
        when(giftCardRepository.countByStatus(CardStatus.ACTIVE)).thenReturn(10L);

        // when
        long count = giftCardService.countByStatus(CardStatus.ACTIVE);

        // then
        assertThat(count).isEqualTo(10L);
        verify(giftCardRepository, times(1)).countByStatus(CardStatus.ACTIVE);
    }
}
