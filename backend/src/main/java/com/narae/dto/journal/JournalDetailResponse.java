package com.narae.dto.journal;

import com.narae.entity.AnalysisStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Builder
@Schema(description = "일기 상세 응답")
public class JournalDetailResponse {

    @Schema(description = "일기 ID")
    private Long id;

    @Schema(description = "일기 내용")
    private String content;

    @Schema(description = "음성 URL")
    private String voiceUrl;

    @Schema(description = "이미지 URL 리스트")
    private List<String> imageUrls;

    @Schema(description = "분석 상태")
    private AnalysisStatus analysisStatus;

    @Schema(description = "감정 분석 결과")
    private EmotionResponse emotionResult;

    @Schema(description = "작성 일시")
    private LocalDateTime createdAt;

    @Getter
    @Builder
    @Schema(description = "감정 분석 결과 상세")
    public static class EmotionResponse {
        @Schema(description = "기쁨 점수", example = "0.8500")
        private BigDecimal joyScore;

        @Schema(description = "슬픔 점수", example = "0.0500")
        private BigDecimal sadnessScore;

        @Schema(description = "스트레스 지수", example = "0.1500")
        private BigDecimal stressLevel;

        @Schema(description = "감정 분석 요약", example = "성취감을 느끼며 매우 긍정적인 상태입니다.")
        private String emotionSummary;
    }
}
