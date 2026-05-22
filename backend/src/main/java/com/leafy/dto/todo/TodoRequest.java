package com.leafy.dto.todo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
@Schema(description = "할 일 생성/수정 요청")
public class TodoRequest {

    @NotBlank
    @Schema(description = "태스크명", example = "명상하기")
    private String taskName;

    @Schema(description = "마감 기한", example = "2026-05-10T18:00:00")
    private LocalDateTime dueDate;
}
