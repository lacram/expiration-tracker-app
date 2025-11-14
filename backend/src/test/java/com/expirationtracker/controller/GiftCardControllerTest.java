package com.expirationtracker.controller;

import com.expirationtracker.dto.GiftCardRequest;
import com.expirationtracker.entity.CardStatus;
import com.expirationtracker.entity.Category;
import com.expirationtracker.entity.GiftCard;
import com.expirationtracker.service.GiftCardService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;

import static org.hamcrest.Matchers.hasSize;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(GiftCardController.class)
@DisplayName("GiftCardController 통합 테스트")
class GiftCardControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private GiftCardService giftCardService;

    private GiftCard testCard;

    @BeforeEach
    void setUp() {
        testCard = GiftCard.builder()
                .id(1L)
                .name("스타벅스 아메리카노")
                .category(Category.GIFTCARD)
                .expirationDate(LocalDate.of(2025, 12, 31))
                .status(CardStatus.ACTIVE)
                .barcode("1234567890123")
                .memo("테스트 메모")
                .build();
    }

    @Test
    @DisplayName("GET /api/cards - 전체 카드 조회")
    void getAllCards() throws Exception {
        // given
        List<GiftCard> cards = Arrays.asList(testCard);
        when(giftCardService.getAllCards()).thenReturn(cards);

        // when & then
        mockMvc.perform(get("/api/cards"))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].name").value("스타벅스 아메리카노"))
                .andExpect(jsonPath("$[0].category").value("GIFTCARD"))
                .andExpect(jsonPath("$[0].status").value("ACTIVE"));
    }

    @Test
    @DisplayName("GET /api/cards/{id} - 개별 카드 조회")
    void getCardById() throws Exception {
        // given
        when(giftCardService.getCardById(1L)).thenReturn(testCard);

        // when & then
        mockMvc.perform(get("/api/cards/1"))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("스타벅스 아메리카노"))
                .andExpect(jsonPath("$.barcode").value("1234567890123"));
    }

    @Test
    @DisplayName("GET /api/cards/status/{status} - 상태별 카드 조회")
    void getCardsByStatus() throws Exception {
        // given
        List<GiftCard> activeCards = Arrays.asList(testCard);
        when(giftCardService.getCardsByStatus(CardStatus.ACTIVE)).thenReturn(activeCards);

        // when & then
        mockMvc.perform(get("/api/cards/status/ACTIVE"))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].status").value("ACTIVE"));
    }

    @Test
    @DisplayName("GET /api/cards/category/{category} - 카테고리별 카드 조회")
    void getCardsByCategory() throws Exception {
        // given
        List<GiftCard> giftCards = Arrays.asList(testCard);
        when(giftCardService.getCardsByCategory(Category.GIFTCARD)).thenReturn(giftCards);

        // when & then
        mockMvc.perform(get("/api/cards/category/GIFTCARD"))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].category").value("GIFTCARD"));
    }

    @Test
    @DisplayName("GET /api/cards/expiring-soon - 유효기간 임박 카드 조회")
    void getExpiringSoonCards() throws Exception {
        // given
        List<GiftCard> expiringSoonCards = Arrays.asList(testCard);
        when(giftCardService.getExpiringSoonCards(7)).thenReturn(expiringSoonCards);

        // when & then
        mockMvc.perform(get("/api/cards/expiring-soon")
                        .param("days", "7"))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)));
    }

    @Test
    @DisplayName("GET /api/cards/expiring-soon - 기본값 7일")
    void getExpiringSoonCards_DefaultDays() throws Exception {
        // given
        List<GiftCard> expiringSoonCards = Arrays.asList(testCard);
        when(giftCardService.getExpiringSoonCards(7)).thenReturn(expiringSoonCards);

        // when & then
        mockMvc.perform(get("/api/cards/expiring-soon"))
                .andDo(print())
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("GET /api/cards/expired - 만료된 카드 조회")
    void getExpiredCards() throws Exception {
        // given
        GiftCard expiredCard = GiftCard.builder()
                .id(2L)
                .name("만료된 카드")
                .category(Category.COUPON)
                .expirationDate(LocalDate.now().minusDays(1))
                .status(CardStatus.EXPIRED)
                .build();
        List<GiftCard> expiredCards = Arrays.asList(expiredCard);
        when(giftCardService.getExpiredCards()).thenReturn(expiredCards);

        // when & then
        mockMvc.perform(get("/api/cards/expired"))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].status").value("EXPIRED"));
    }

    @Test
    @DisplayName("POST /api/cards - 카드 생성")
    void createCard() throws Exception {
        // given
        GiftCardRequest request = new GiftCardRequest();
        request.setName("CU 편의점 상품권");
        request.setCategory(Category.VOUCHER);
        request.setExpirationDate(LocalDate.of(2025, 12, 31));
        request.setBarcode("9876543210987");
        request.setMemo("테스트 생성");

        GiftCard createdCard = GiftCard.builder()
                .id(2L)
                .name(request.getName())
                .category(request.getCategory())
                .expirationDate(request.getExpirationDate())
                .barcode(request.getBarcode())
                .memo(request.getMemo())
                .status(CardStatus.ACTIVE)
                .build();

        when(giftCardService.createCard(any(GiftCardRequest.class))).thenReturn(createdCard);

        // when & then
        mockMvc.perform(post("/api/cards")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andDo(print())
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name").value("CU 편의점 상품권"))
                .andExpect(jsonPath("$.category").value("VOUCHER"))
                .andExpect(jsonPath("$.status").value("ACTIVE"));
    }

    @Test
    @DisplayName("POST /api/cards - 유효성 검증 실패 (이름 없음)")
    void createCard_ValidationFailed() throws Exception {
        // given
        GiftCardRequest request = new GiftCardRequest();
        // name이 null
        request.setCategory(Category.VOUCHER);
        request.setExpirationDate(LocalDate.of(2025, 12, 31));

        // when & then
        mockMvc.perform(post("/api/cards")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andDo(print())
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("PUT /api/cards/{id} - 카드 수정")
    void updateCard() throws Exception {
        // given
        GiftCardRequest request = new GiftCardRequest();
        request.setName("수정된 카드 이름");
        request.setCategory(Category.TICKET);
        request.setExpirationDate(LocalDate.of(2026, 1, 15));
        request.setBarcode("1111111111111");
        request.setMemo("수정된 메모");

        GiftCard updatedCard = GiftCard.builder()
                .id(1L)
                .name(request.getName())
                .category(request.getCategory())
                .expirationDate(request.getExpirationDate())
                .barcode(request.getBarcode())
                .memo(request.getMemo())
                .status(CardStatus.ACTIVE)
                .build();

        when(giftCardService.updateCard(eq(1L), any(GiftCardRequest.class))).thenReturn(updatedCard);

        // when & then
        mockMvc.perform(put("/api/cards/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("수정된 카드 이름"))
                .andExpect(jsonPath("$.category").value("TICKET"));
    }

    @Test
    @DisplayName("DELETE /api/cards/{id} - 카드 삭제")
    void deleteCard() throws Exception {
        // when & then
        mockMvc.perform(delete("/api/cards/1"))
                .andDo(print())
                .andExpect(status().isNoContent());
    }

    @Test
    @DisplayName("PUT /api/cards/{id}/use - 사용 완료 처리")
    void markAsUsed() throws Exception {
        // given
        GiftCard usedCard = GiftCard.builder()
                .id(1L)
                .name("스타벅스 아메리카노")
                .category(Category.GIFTCARD)
                .expirationDate(LocalDate.of(2025, 12, 31))
                .status(CardStatus.USED)
                .barcode("1234567890123")
                .build();
        usedCard.markAsUsed();

        when(giftCardService.markAsUsed(1L)).thenReturn(usedCard);

        // when & then
        mockMvc.perform(put("/api/cards/1/use"))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("USED"));
    }

    @Test
    @DisplayName("GET /api/cards/stats - 통계 조회")
    void getStats() throws Exception {
        // given
        when(giftCardService.countByStatus(CardStatus.ACTIVE)).thenReturn(10L);
        when(giftCardService.countByStatus(CardStatus.EXPIRED)).thenReturn(3L);
        when(giftCardService.countByStatus(CardStatus.USED)).thenReturn(5L);
        when(giftCardService.countExpiringSoon(7)).thenReturn(2L);
        when(giftCardService.countExpiringSoon(30)).thenReturn(7L);

        // when & then
        mockMvc.perform(get("/api/cards/stats"))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.total").value(18))
                .andExpect(jsonPath("$.active").value(10))
                .andExpect(jsonPath("$.expired").value(3))
                .andExpect(jsonPath("$.used").value(5))
                .andExpect(jsonPath("$.expiringSoon7").value(2))
                .andExpect(jsonPath("$.expiringSoon30").value(7));
    }
}
