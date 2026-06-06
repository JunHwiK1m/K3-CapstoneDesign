package com.narae.dto.user;

import com.narae.entity.AdviceTone;
import com.narae.entity.PersonaStyle;
import com.narae.entity.UsagePurpose;
import com.narae.entity.UserSettings;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

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

    @Schema(description = "선호하는 음악 종류 리스트", example = "[\"Lo-fi\", \"Jazz\"]")
    List<String> musicStyles,

    @Schema(description = "페르소나 스타일", example = "BASIC")
    PersonaStyle personaStyle,

    @Schema(description = "AI 분석 활성화 여부", example = "true")
    boolean isAiAnalysisEnabled,

    @Schema(description = "설정 완료 여부", example = "true")
    boolean isConfigured
) {
    public static UserSettingsResponse from(UserSettings settings) {
        if (settings == null) {
            return null;
        }
        
        boolean configured = settings.getDiaryTime() != null && 
                             settings.getBirthDate() != null && 
                             settings.getNickname() != null;

        List<String> musicStyles = Collections.emptyList();
        if (settings.getMusicStyle() != null && !settings.getMusicStyle().isBlank()) {
            musicStyles = Arrays.stream(settings.getMusicStyle().split(","))
                    .map(String::trim)
                    .collect(Collectors.toList());
        }

        return UserSettingsResponse.builder()
                .diaryTime(settings.getDiaryTime())
                .wakeUpTime(settings.getWakeUpTime())
                .usagePurpose(settings.getUsagePurpose())
                .nickname(settings.getNickname())
                .profileImage(settings.getProfileImage())
                .birthDate(settings.getBirthDate())
                .adviceTone(settings.getAdviceTone())
                .musicStyles(musicStyles)
                .personaStyle(settings.getPersonaStyle())
                .isAiAnalysisEnabled(settings.isAiAnalysisEnabled())
                .isConfigured(configured)
                .build();
    }
}
