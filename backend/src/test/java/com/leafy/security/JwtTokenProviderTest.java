package com.leafy.security;

import io.jsonwebtoken.Claims;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@ActiveProfiles("test")
class JwtTokenProviderTest {

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Test
    @DisplayName("JWT 토큰 생성 및 파싱 테스트")
    void createAndParseTokenTest() {
        // Given
        Long userId = 1L;
        String email = "test@leafy.com";
        String role = "ROLE_USER";

        // When
        String token = jwtTokenProvider.createToken(userId, email, role);
        Claims claims = jwtTokenProvider.getClaims(token);

        // Then
        assertThat(token).isNotNull();
        assertThat(claims.getSubject()).isEqualTo(email);
        assertThat(claims.get("userId", Long.class)).isEqualTo(userId);
        assertThat(claims.get("role", String.class)).isEqualTo(role);
    }

    @Test
    @DisplayName("JWT 토큰 유효성 검증 테스트")
    void validateTokenTest() {
        // Given
        String token = jwtTokenProvider.createToken(1L, "test@leafy.com", "ROLE_USER");

        // When
        boolean isValid = jwtTokenProvider.validateToken(token);
        boolean isInvalid = jwtTokenProvider.validateToken("invalid-token");

        // Then
        assertThat(isValid).isTrue();
        assertThat(isInvalid).isFalse();
    }
}
