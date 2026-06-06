package com.narae.entity;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * 서비스 사용 용도
 */
@Getter
@RequiredArgsConstructor
public enum UsagePurpose {
    RECORDING("기록용"),
    PLANNING("계획용"),
    MENTAL_CARE("멘탈관리용"),
    GOD_SAENG("갓생용");

    private final String description;
}
