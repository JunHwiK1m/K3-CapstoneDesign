package com.leafy.dto.ai;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;

import java.math.BigDecimal;

@Builder
public record TodoAnalysisRequest(
    @JsonProperty("total_count")
    long totalCount,

    @JsonProperty("completed_count")
    long completedCount,

    @JsonProperty("completion_rate")
    BigDecimal completionRate,

    @JsonProperty("persona_style")
    String personaStyle,

    @JsonProperty("recent_emotion")
    String recentEmotion
) {
}
