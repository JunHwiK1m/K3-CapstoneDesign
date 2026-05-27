package com.leafy.dto.ai;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.math.BigDecimal;
import java.util.List;

/**
 * 감정 분석과 추천 활동을 모두 포함하는 통합 응답 DTO
 */
public record FullAnalysisResponse(
    @JsonProperty("journal_id")
    Long journalId,

    @JsonProperty("joy_score")
    BigDecimal joyScore,

    @JsonProperty("sadness_score")
    BigDecimal sadnessScore,

    @JsonProperty("stress_level")
    BigDecimal stressLevel,

    @JsonProperty("emotion_summary")
    String emotionSummary,

    List<RecommendationItem> recommendations
) {
    public record RecommendationItem(
        String category,

        @JsonProperty("content_text")
        String contentText,

        @JsonProperty("external_link")
        String externalLink // AI 서버가 제공하는 원본 식별 ID
    ) {}
}
