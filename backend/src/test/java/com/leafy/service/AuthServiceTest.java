package com.leafy.service;

import com.leafy.dto.auth.LoginRequest;
import com.leafy.dto.auth.SignUpRequest;
import com.leafy.dto.auth.TokenResponse;
import com.leafy.entity.User;
import com.leafy.exception.BusinessException;
import com.leafy.exception.ErrorCode;
import com.leafy.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class AuthServiceTest {

    @Autowired
    private AuthService authService;

    @Autowired
    private UserRepository userRepository;

    @Test
    @DisplayName("회원가입 성공 테스트")
    void signUpTest() {
        // Given
        SignUpRequest request = SignUpRequest.builder()
                .email("new@leafy.com")
                .password("pass123")
                .nickname("testuser")
                .build();

        // When
        Long userId = authService.signUp(request);

        // Then
        User user = userRepository.findById(userId).orElseThrow();
        assertThat(user.getEmail()).isEqualTo("new@leafy.com");
    }

    @Test
    @DisplayName("로그인 성공 테스트")
    void loginTest() {
        // Given
        SignUpRequest signUpRequest = SignUpRequest.builder()
                .email("login@leafy.com")
                .password("pass123")
                .nickname("loginuser")
                .build();
        authService.signUp(signUpRequest);

        LoginRequest loginRequest = LoginRequest.builder()
                .email("login@leafy.com")
                .password("pass123")
                .build();

        // When
        TokenResponse response = authService.login(loginRequest);

        // Then
        assertThat(response.getAccessToken()).isNotNull();
        assertThat(response.getEmail()).isEqualTo("login@leafy.com");
    }

    @Test
    @DisplayName("로그인 실패 테스트 - 존재하지 않는 회원")
    void loginFailUserNotFoundTest() {
        // Given
        LoginRequest loginRequest = LoginRequest.builder()
                .email("notfound@leafy.com")
                .password("pass123")
                .build();

        // When & Then
        assertThatThrownBy(() -> authService.login(loginRequest))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("errorCode", ErrorCode.LOGIN_FAILED);
    }

    @Test
    @DisplayName("로그인 실패 테스트 - 비밀번호 불일치")
    void loginFailWrongPasswordTest() {
        // Given
        SignUpRequest signUpRequest = SignUpRequest.builder()
                .email("wrongpass@leafy.com")
                .password("correct123")
                .nickname("user")
                .build();
        authService.signUp(signUpRequest);

        LoginRequest loginRequest = LoginRequest.builder()
                .email("wrongpass@leafy.com")
                .password("wrong123")
                .build();

        // When & Then
        assertThatThrownBy(() -> authService.login(loginRequest))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("errorCode", ErrorCode.LOGIN_FAILED);
    }
}
