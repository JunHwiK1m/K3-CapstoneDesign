package com.narae.dto.auth;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@AllArgsConstructor
@Schema(description = "로그인 응답")
public class TokenResponse {

    @Schema(description = "JWT 엑세스 토큰")
    private String accessToken;

    @Schema(description = "사용자 이메일")
    private String email;
}
