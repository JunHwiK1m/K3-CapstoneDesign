package com.leafy.service;

import com.leafy.dto.auth.LoginRequest;
import com.leafy.dto.auth.SignUpRequest;
import com.leafy.dto.auth.TokenResponse;
import com.leafy.entity.User;
import com.leafy.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;

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
        SignUpRequest request = new SignUpRequest();
        setPrivateField(request, "email", "new@leafy.com");
        setPrivateField(request, "password", "pass123");
        setPrivateField(request, "nickname", "testuser");

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
        SignUpRequest signUpRequest = new SignUpRequest();
        setPrivateField(signUpRequest, "email", "login@leafy.com");
        setPrivateField(signUpRequest, "password", "pass123");
        setPrivateField(signUpRequest, "nickname", "loginuser");
        authService.signUp(signUpRequest);

        LoginRequest loginRequest = new LoginRequest();
        setPrivateField(loginRequest, "email", "login@leafy.com");
        setPrivateField(loginRequest, "password", "pass123");

        // When
        TokenResponse response = authService.login(loginRequest);

        // Then
        assertThat(response.getAccessToken()).isNotNull();
        assertThat(response.getEmail()).isEqualTo("login@leafy.com");
    }

    // Helper to set private fields in DTOs (since they don't have setters and use @Getter)
    private void setPrivateField(Object target, String fieldName, Object value) {
        try {
            java.lang.reflect.Field field = target.getClass().getDeclaredField(fieldName);
            field.setAccessible(true);
            field.set(target, value);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
