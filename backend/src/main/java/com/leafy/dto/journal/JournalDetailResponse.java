package com.leafy.dto.journal;

import com.leafy.entity.AnalysisStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

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

    @Schema(description = "이미지 URL")
    private String imgUrl;

    @Schema(description = "분석 상태")
    private AnalysisStatus analysisStatus;

    @Schema(description = "작성 일시")
    private LocalDateTime createdAt;
}
