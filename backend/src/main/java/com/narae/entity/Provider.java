package com.narae.entity;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum Provider {
    LOCAL("local"),
    GOOGLE("google"),
    NAVER("naver"),
    KAKAO("kakao");

    private final String registrationId;
}
