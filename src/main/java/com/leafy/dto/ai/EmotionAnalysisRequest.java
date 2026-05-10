package com.leafy.dto.ai;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@NoArgsConstructor(access = AccessLevel.PRIVATE)
public class EmotionAnalysisRequest {

    @JsonProperty("journal_id")
    private Long journalId;

    private String content;

    @JsonProperty("voice_url")
    private String voiceUrl;

    @JsonProperty("persona_style")
    private String personaStyle;
}
