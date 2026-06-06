package com.narae.repository;

import com.narae.entity.UserSettings;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

public interface UserSettingsRepository extends JpaRepository<UserSettings, Long> {
    Optional<UserSettings> findByUserId(Long userId);
    List<UserSettings> findAllByDiaryTime(LocalTime diaryTime);
    List<UserSettings> findAllByWakeUpTime(LocalTime wakeUpTime);
}
