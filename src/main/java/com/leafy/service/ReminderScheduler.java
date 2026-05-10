package com.leafy.service;

import com.leafy.entity.User;
import com.leafy.entity.UserSettings;
import com.leafy.repository.JournalRepository;
import com.leafy.repository.UserSettingsRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class ReminderScheduler {

    private final UserSettingsRepository userSettingsRepository;
    private final JournalRepository journalRepository;

    /**
     * 사용자가 설정한 리마인더 시간에 맞춰 알림을 발송합니다.
     * 매 분 정각에 실행되며, 현재 시간(시:분)과 일치하는 설정값을 가진 사용자 중
     * 오늘 아직 일기를 작성하지 않은 사용자에게 알림을 보냅니다.
     */
    @Scheduled(cron = "0 * * * * *")
    @Transactional(readOnly = true)
    public void sendPersonalizedReminders() {
        // 초를 제외한 현재 시간 (시:분)
        LocalTime now = LocalTime.now().withSecond(0).withNano(0);
        log.debug("Checking for reminders at {}", now);

        // 1. 현재 시간이 리마인더 시간인 모든 설정 조회
        List<UserSettings> targetSettings = userSettingsRepository.findAllByReminderTime(now);

        if (targetSettings.isEmpty()) {
            return;
        }

        log.info("Found {} users with reminder time {}", targetSettings.size(), now);

        for (UserSettings settings : targetSettings) {
            User user = settings.getUser();
            
            // 2. 오늘(00:00:00 이후) 일기를 이미 작성했는지 확인
            boolean alreadyWritten = journalRepository.existsByUserIdAndCreatedAtAfter(
                    user.getId(), 
                    LocalDate.now().atStartOfDay()
            );

            if (!alreadyWritten) {
                sendFcmNotification(user);
            } else {
                log.debug("User {} already wrote a journal today. Skipping reminder.", user.getEmail());
            }
        }
    }

    private void sendFcmNotification(User user) {
        // FCM 발송 로직 시뮬레이션
        log.info("FCM Reminder sent to user {}: '설정하신 시간이 되었습니다. 오늘 하루는 어떠셨나요? Leafy에 기록해보세요.'", user.getEmail());
    }
}
