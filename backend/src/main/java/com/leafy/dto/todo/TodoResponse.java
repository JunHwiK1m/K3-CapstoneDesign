package com.leafy.dto.todo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
@Schema(description = "할 일 상세 응답")
public class TodoResponse {

    @Schema(description = "할 일 ID")
    private Long id;

    @Schema(description = "태스크명")
    private String taskName;

    @Schema(description = "완료 여부")
    private boolean isCompleted;

    @Schema(description = "마감 기한")
    private LocalDateTime dueDate;

    @Schema(description = "완료 일시")
    private LocalDateTime completedAt;
}
