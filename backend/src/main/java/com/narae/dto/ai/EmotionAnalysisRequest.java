package com.narae.dto.ai;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@NoArgsConstructor(access = AccessLevel.PRIVATE)
public class EmotionAnalysisRequest {

    private Long journalId;

    private String content;

    private String voiceUrl;

    private String personaStyle;

    private String musicStyle;
}
