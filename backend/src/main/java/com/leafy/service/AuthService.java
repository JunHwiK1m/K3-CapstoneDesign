package com.leafy.service;

import com.leafy.dto.auth.LoginRequest;
import com.leafy.dto.auth.SignUpRequest;
import com.leafy.dto.auth.TokenResponse;
import com.leafy.entity.Provider;
import com.leafy.entity.Role;
import com.leafy.entity.User;
import com.leafy.exception.BusinessException;
import com.leafy.exception.ErrorCode;
import com.leafy.repository.UserRepository;
import com.leafy.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    @Transactional
    public Long signUp(SignUpRequest request) {
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE); // Email already exists
        }

        User user = User.builder()
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .name(request.getNickname())
                .provider(Provider.LOCAL)
                .build();
        user.addRole(Role.USER);

        return userRepository.save(user).getId();
    }

    public TokenResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED);
        }

        String role = user.getRoles().iterator().next().name();
        String token = jwtTokenProvider.createToken(user.getId(), user.getEmail(), "ROLE_" + role);

        return TokenResponse.builder()
                .accessToken(token)
                .email(user.getEmail())
                .build();
    }
}
