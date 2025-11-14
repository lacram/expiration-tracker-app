package com.expirationtracker.controller;

import com.expirationtracker.dto.GiftCardRequest;
import com.expirationtracker.entity.CardStatus;
import com.expirationtracker.entity.Category;
import com.expirationtracker.entity.GiftCard;
import com.expirationtracker.service.GiftCardService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/cards")
@RequiredArgsConstructor
public class GiftCardController {

    private final GiftCardService giftCardService;

    @GetMapping
    public ResponseEntity<List<GiftCard>> getAllCards() {
        return ResponseEntity.ok(giftCardService.getAllCards());
    }

    @GetMapping("/{id}")
    public ResponseEntity<GiftCard> getCardById(@PathVariable Long id) {
        return ResponseEntity.ok(giftCardService.getCardById(id));
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<List<GiftCard>> getCardsByStatus(@PathVariable CardStatus status) {
        return ResponseEntity.ok(giftCardService.getCardsByStatus(status));
    }

    @GetMapping("/category/{category}")
    public ResponseEntity<List<GiftCard>> getCardsByCategory(@PathVariable Category category) {
        return ResponseEntity.ok(giftCardService.getCardsByCategory(category));
    }

    @GetMapping("/expiring-soon")
    public ResponseEntity<List<GiftCard>> getExpiringSoonCards(
            @RequestParam(defaultValue = "7") int days) {
        return ResponseEntity.ok(giftCardService.getExpiringSoonCards(days));
    }

    @GetMapping("/expired")
    public ResponseEntity<List<GiftCard>> getExpiredCards() {
        return ResponseEntity.ok(giftCardService.getExpiredCards());
    }

    @PostMapping
    public ResponseEntity<GiftCard> createCard(@Valid @RequestBody GiftCardRequest request) {
        GiftCard created = giftCardService.createCard(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<GiftCard> updateCard(
            @PathVariable Long id,
            @Valid @RequestBody GiftCardRequest request) {
        return ResponseEntity.ok(giftCardService.updateCard(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCard(@PathVariable Long id) {
        giftCardService.deleteCard(id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}/use")
    public ResponseEntity<GiftCard> markAsUsed(@PathVariable Long id) {
        return ResponseEntity.ok(giftCardService.markAsUsed(id));
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getStats() {
        Map<String, Object> stats = Map.of(
                "total", giftCardService.countByStatus(CardStatus.ACTIVE) +
                        giftCardService.countByStatus(CardStatus.EXPIRED) +
                        giftCardService.countByStatus(CardStatus.USED),
                "active", giftCardService.countByStatus(CardStatus.ACTIVE),
                "expired", giftCardService.countByStatus(CardStatus.EXPIRED),
                "used", giftCardService.countByStatus(CardStatus.USED),
                "expiringSoon7", giftCardService.countExpiringSoon(7),
                "expiringSoon30", giftCardService.countExpiringSoon(30)
        );
        return ResponseEntity.ok(stats);
    }
}
