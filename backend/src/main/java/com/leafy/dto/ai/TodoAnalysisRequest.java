package com.leafy.dto.ai;

import lombok.Builder;

import java.math.BigDecimal;

@Builder
public record TodoAnalysisRequest(
    long totalCount,

    long completedCount,

    BigDecimal completionRate,

    String personaStyle,

    String recentEmotion
) {
}
