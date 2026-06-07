package com.narae.dto.ai;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Getter
@Builder
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@NoArgsConstructor(access = AccessLevel.PRIVATE)
public class EmotionAnalysisResponse {

    @JsonProperty("journal_id")
    private Long journalId;

    @JsonProperty("joy_score")
    private BigDecimal joyScore;

    @JsonProperty("sadness_score")
    private BigDecimal sadnessScore;

    @JsonProperty("stress_level")
    private BigDecimal stressLevel;

    @JsonProperty("emotion_summary")
    private String emotionSummary;
}
