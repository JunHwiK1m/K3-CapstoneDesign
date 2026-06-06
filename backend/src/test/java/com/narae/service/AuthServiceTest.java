package com.narae.service;

import com.narae.dto.auth.LoginRequest;
import com.narae.dto.auth.SignUpRequest;
import com.narae.dto.auth.TokenResponse;
import com.narae.entity.User;
import com.narae.exception.BusinessException;
import com.narae.exception.ErrorCode;
import com.narae.repository.UserRepository;
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
                .email("new@narae.com")
                .password("pass123")
                .nickname("testuser")
                .build();

        // When
        Long userId = authService.signUp(request);

        // Then
        User user = userRepository.findById(userId).orElseThrow();
        assertThat(user.getEmail()).isEqualTo("new@narae.com");
    }

    @Test
    @DisplayName("로그인 성공 테스트")
    void loginTest() {
        // Given
        SignUpRequest signUpRequest = SignUpRequest.builder()
                .email("login@narae.com")
                .password("pass123")
                .nickname("loginuser")
                .build();
        authService.signUp(signUpRequest);

        LoginRequest loginRequest = LoginRequest.builder()
                .email("login@narae.com")
                .password("pass123")
                .build();

        // When
        TokenResponse response = authService.login(loginRequest);

        // Then
        assertThat(response.getAccessToken()).isNotNull();
        assertThat(response.getEmail()).isEqualTo("login@narae.com");
    }

    @Test
    @DisplayName("로그인 실패 테스트 - 존재하지 않는 회원")
    void loginFailUserNotFoundTest() {
        // Given
        LoginRequest loginRequest = LoginRequest.builder()
                .email("notfound@narae.com")
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
                .email("wrongpass@narae.com")
                .password("correct123")
                .nickname("user")
                .build();
        authService.signUp(signUpRequest);

        LoginRequest loginRequest = LoginRequest.builder()
                .email("wrongpass@narae.com")
                .password("wrong123")
                .build();

        // When & Then
        assertThatThrownBy(() -> authService.login(loginRequest))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("errorCode", ErrorCode.LOGIN_FAILED);
    }
}
