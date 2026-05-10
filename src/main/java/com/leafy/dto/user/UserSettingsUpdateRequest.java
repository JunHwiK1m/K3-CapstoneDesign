package com.leafy.dto.user;

import com.leafy.entity.PersonaStyle;
import com.leafy.entity.UsagePurpose;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;

@Getter
@NoArgsConstructor
@Schema(description = "사용자 설정 수정 요청")
public class UserSettingsUpdateRequest {

    @Schema(description = "리마인더 시간", example = "09:00:00")
    private LocalTime reminderTime;

    @Schema(description = "사용 목적", example = "MENTAL_CARE")
    private UsagePurpose usagePurpose;

    @Schema(description = "페르소나 스타일", example = "FRIENDLY")
    private PersonaStyle personaStyle;

    @Schema(description = "생년월일", example = "1995-01-01")
    private LocalDate birthDate;
}
