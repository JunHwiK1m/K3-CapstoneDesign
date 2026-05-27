package com.leafy.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@Tag(name = "OAuth2 Success Redirect", description = "소셜 로그인 성공 후 리다이렉트 처리 API")
@RestController
public class OAuth2RedirectController {

    @Operation(summary = "소셜 로그인 성공 핸들러", description = "OAuth2 로그인 성공 시 생성된 토큰을 반환합니다.")
    @GetMapping("/login-success")
    public ResponseEntity<Map<String, String>> loginSuccess(@RequestParam("token") String token) {
        // 실제 운영 환경에서는 프론트엔드 URL로 리다이렉트하거나 토큰을 처리하는 로직이 들어갈 수 있습니다.
        // 현재는 API 테스트 및 확인을 위해 JSON 형태로 토큰을 반환합니다.
        return ResponseEntity.ok(Map.of(
                "message", "OAuth2 login successful",
                "token", token
        ));
    }
}
