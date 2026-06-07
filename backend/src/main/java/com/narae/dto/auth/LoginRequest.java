package com.narae.dto.auth;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "로그인 요청")
public class LoginRequest {

    @NotBlank
    @Email
    @Schema(description = "이메일", example = "test@narae.com")
    private String email;

    @NotBlank
    @Schema(description = "비밀번호", example = "password123")
    private String password;
}
