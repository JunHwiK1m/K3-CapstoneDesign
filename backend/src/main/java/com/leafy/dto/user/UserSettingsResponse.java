package com.leafy.dto.user;

import com.leafy.entity.AdviceTone;
import com.leafy.entity.PersonaStyle;
import com.leafy.entity.UsagePurpose;
import com.leafy.entity.UserSettings;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

import java.time.LocalDate;
import java.time.LocalTime;

@Builder
@Schema(description = "사용자 설정 조회 응답")
public record UserSettingsResponse(
    @Schema(description = "일기 작성 권장 시간", example = "21:00:00")
    LocalTime diaryTime,

    @Schema(description = "기상 시간", example = "07:00:00")
    LocalTime wakeUpTime,

    @Schema(description = "사용 목적", example = "MENTAL_CARE")
    UsagePurpose usagePurpose,

    @Schema(description = "닉네임", example = "리피")
    String nickname,

    @Schema(description = "프로필 이미지 URL", example = "https://example.com/profile.png")
    String profileImage,

    @Schema(description = "생년월일", example = "1995-01-01")
    LocalDate birthDate,

    @Schema(description = "AI 조언 말투", example = "FRIENDLY")
    AdviceTone adviceTone,

    @Schema(description = "선호하는 음악 종류", example = "Lo-fi")
    String musicStyle,

    @Schema(description = "페르소나 스타일", example = "BASIC")
    PersonaStyle personaStyle,

    @Schema(description = "설정 완료 여부", example = "true")
    boolean isConfigured
) {
    public static UserSettingsResponse from(UserSettings settings) {
        if (settings == null) {
            return null;
        }
        
        // 필수 값(일기 시간, 생년월일, 닉네임)이 존재하면 설정 완료로 판단
        boolean configured = settings.getDiaryTime() != null && 
                             settings.getBirthDate() != null && 
                             settings.getNickname() != null;

        return UserSettingsResponse.builder()
                .diaryTime(settings.getDiaryTime())
                .wakeUpTime(settings.getWakeUpTime())
                .usagePurpose(settings.getUsagePurpose())
                .nickname(settings.getNickname())
                .profileImage(settings.getProfileImage())
                .birthDate(settings.getBirthDate())
                .adviceTone(settings.getAdviceTone())
                .musicStyle(settings.getMusicStyle())
                .personaStyle(settings.getPersonaStyle())
                .isConfigured(configured)
                .build();
    }
}
