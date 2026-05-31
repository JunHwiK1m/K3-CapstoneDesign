package com.leafy.dto.ai;

import java.math.BigDecimal;
import java.util.List;

/**
 * 감정 분석과 추천 활동을 모두 포함하는 통합 응답 DTO
 */
public record FullAnalysisResponse(
    Long journalId,

    BigDecimal joyScore,

    BigDecimal sadnessScore,

    BigDecimal stressLevel,

    String emotionSummary,

    List<RecommendationItem> recommendations
) {
    public record RecommendationItem(
        String category,

        String contentText,

        String externalLink // AI 서버가 제공하는 원본 식별 ID
    ) {}
}
