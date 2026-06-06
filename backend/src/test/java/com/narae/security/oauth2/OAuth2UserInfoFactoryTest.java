package com.narae.security.oauth2;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.HashMap;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

class OAuth2UserInfoFactoryTest {

    @Test
    @DisplayName("구글 사용자 정보 파싱 테스트")
    void googleUserInfoTest() {
        Map<String, Object> attributes = new HashMap<>();
        attributes.put("sub", "12345");
        attributes.put("name", "Google User");
        attributes.put("email", "google@test.com");
        attributes.put("picture", "http://photo.com");

        OAuth2UserInfo userInfo = OAuth2UserInfoFactory.getOAuth2UserInfo("google", attributes);

        assertThat(userInfo).isInstanceOf(GoogleOAuth2UserInfo.class);
        assertThat(userInfo.getId()).isEqualTo("12345");
        assertThat(userInfo.getName()).isEqualTo("Google User");
    }

    @Test
    @DisplayName("네이버 사용자 정보 파싱 테스트")
    void naverUserInfoTest() {
        Map<String, Object> response = new HashMap<>();
        response.put("id", "67890");
        response.put("nickname", "Naver User");
        response.put("email", "naver@test.com");
        response.put("profile_image", "http://photo.com");

        Map<String, Object> attributes = new HashMap<>();
        attributes.put("response", response);

        OAuth2UserInfo userInfo = OAuth2UserInfoFactory.getOAuth2UserInfo("naver", attributes);

        assertThat(userInfo).isInstanceOf(NaverOAuth2UserInfo.class);
        assertThat(userInfo.getId()).isEqualTo("67890");
        assertThat(userInfo.getName()).isEqualTo("Naver User");
    }
}
