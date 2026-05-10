package com.leafy.dto.user;

import com.leafy.entity.PersonaStyle;
import com.leafy.entity.UsagePurpose;
import com.leafy.entity.UserSettings;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalTime;

@Getter
@Builder
@Schema(description = "사용자 설정 조회 응답")
public class UserSettingsResponse {

    @Schema(description = "리마인더 시간", example = "09:00:00")
    private LocalTime reminderTime;

    @Schema(description = "사용 목적", example = "MENTAL_CARE")
    private UsagePurpose usagePurpose;

    @Schema(description = "페르소나 스타일", example = "FRIENDLY")
    private PersonaStyle personaStyle;

    @Schema(description = "생년월일", example = "1995-01-01")
    private LocalDate birthDate;

    @Schema(description = "설정 완료 여부 (초기 설정 페이지 유도용)", example = "true")
    private boolean isConfigured;

    public static UserSettingsResponse from(UserSettings settings) {
        if (settings == null) {
            return null;
        }
        
        // 필수 값(리마인더 시간, 생년월일)이 모두 존재하면 설정 완료로 판단
        boolean configured = settings.getReminderTime() != null && settings.getBirthDate() != null;

        return UserSettingsResponse.builder()
                .reminderTime(settings.getReminderTime())
                .usagePurpose(settings.getUsagePurpose())
                .personaStyle(settings.getPersonaStyle())
                .birthDate(settings.getBirthDate())
                .isConfigured(configured)
                .build();
    }
}
