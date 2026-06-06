package com.narae.service;

import com.narae.dto.auth.LoginRequest;
import com.narae.dto.auth.SignUpRequest;
import com.narae.dto.auth.TokenResponse;
import com.narae.entity.Provider;
import com.narae.entity.Role;
import com.narae.entity.User;
import com.narae.exception.BusinessException;
import com.narae.exception.ErrorCode;
import com.narae.repository.UserRepository;
import com.narae.security.JwtTokenProvider;
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
                .orElseThrow(() -> new BusinessException(ErrorCode.LOGIN_FAILED));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new BusinessException(ErrorCode.LOGIN_FAILED);
        }

        String role = user.getRoles().iterator().next().name();
        String token = jwtTokenProvider.createToken(user.getId(), user.getEmail(), "ROLE_" + role);

        return TokenResponse.builder()
                .accessToken(token)
                .email(user.getEmail())
                .build();
    }
}
