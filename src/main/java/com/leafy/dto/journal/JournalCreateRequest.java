package com.leafy.dto.journal;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@Schema(description = "일기 작성 요청")
public class JournalCreateRequest {

    @NotBlank
    @Schema(description = "일기 내용", example = "오늘 하루는 정말 보람찼다. 프로젝트 베이스를 다 깔았다.")
    private String content;

    @Schema(description = "음성 파일 URL", example = "https://storage.leafy.com/voice/123.mp3")
    private String voiceUrl;

    @Schema(description = "이미지 파일 URL", example = "https://storage.leafy.com/img/123.jpg")
    private String imgUrl;
}
