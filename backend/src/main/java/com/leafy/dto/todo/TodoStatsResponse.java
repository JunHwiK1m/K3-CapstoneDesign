package com.leafy.dto.todo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;

@Getter
@Builder
@Schema(description = "Todo 통계 응답")
public class TodoStatsResponse {
    
    @Schema(description = "전체 할 일 개수", example = "10")
    private long totalCount;
    
    @Schema(description = "완료된 할 일 개수", example = "8")
    private long completedCount;
    
    @Schema(description = "완료율 (0.00 ~ 1.00)", example = "0.8000")
    private BigDecimal completionRate;

    @Schema(description = "AI 성취도 피드백 메시지")
    private String feedbackMessage;

    public static TodoStatsResponse of(long total, long completed, String feedbackMessage) {
        BigDecimal rate = total == 0 ? BigDecimal.ZERO : 
            BigDecimal.valueOf(completed).divide(BigDecimal.valueOf(total), 4, java.math.RoundingMode.HALF_UP);
            
        return TodoStatsResponse.builder()
                .totalCount(total)
                .completedCount(completed)
                .completionRate(rate)
                .feedbackMessage(feedbackMessage)
                .build();
    }
}
