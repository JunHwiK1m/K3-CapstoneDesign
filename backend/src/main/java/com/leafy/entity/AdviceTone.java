package com.leafy.entity;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * AI 조언 말투
 */
@Getter
@RequiredArgsConstructor
public enum AdviceTone {
    DIRECT("직설적"),
    FRIENDLY("친근한"),
    EMPATHETIC("공감적");

    private final String description;
}
