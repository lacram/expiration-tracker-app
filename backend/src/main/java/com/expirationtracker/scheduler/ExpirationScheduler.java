package com.expirationtracker.scheduler;

import com.expirationtracker.service.GiftCardService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class ExpirationScheduler {

    private final GiftCardService giftCardService;

    /**
     * 매일 자정에 만료된 카드 상태 업데이트
     */
    @Scheduled(cron = "0 0 0 * * ?")  // 매일 00:00:00
    public void updateExpiredCards() {
        log.info("만료 카드 업데이트 스케줄러 실행");
        giftCardService.updateExpiredCards();
    }

    /**
     * 매일 오전 9시에 유효기간 임박 알림 (FCM 구현 시 사용)
     */
    @Scheduled(cron = "0 0 9 * * ?")  // 매일 09:00:00
    public void sendExpirationNotifications() {
        log.info("유효기간 임박 알림 스케줄러 실행");
        // TODO: FCM 알림 전송 로직 구현
        long expiringSoonCount = giftCardService.countExpiringSoon(7);
        log.info("7일 이내 만료 예정 카드: {}개", expiringSoonCount);
    }
}
