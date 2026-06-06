package com.narae.controller;

import com.narae.common.CommonResponse;
import com.narae.dto.auth.LoginRequest;
import com.narae.dto.auth.SignUpRequest;
import com.narae.dto.auth.TokenResponse;
import com.narae.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Authentication", description = "인증 관련 API")
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @Operation(summary = "회원가입", description = "이메일과 비밀번호를 사용하여 회원가입을 진행합니다.")
    @PostMapping("/signup")
    public CommonResponse<Long> signUp(@Valid @RequestBody SignUpRequest request) {
        return CommonResponse.success("회원가입이 완료되었습니다.", authService.signUp(request));
    }

    @Operation(summary = "로그인", description = "이메일과 비밀번호를 사용하여 로그인을 진행합니다.")
    @PostMapping("/login")
    public CommonResponse<TokenResponse> login(@Valid @RequestBody LoginRequest request) {
        return CommonResponse.success("로그인에 성공하였습니다.", authService.login(request));
    }
}
