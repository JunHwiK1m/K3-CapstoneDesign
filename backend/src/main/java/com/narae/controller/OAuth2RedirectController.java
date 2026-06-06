package com.narae.controller;

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

    @Operation(summary = "소셜 로그인 성공 핸들러", description = "OAuth2 로그인 성공 시 생성된 토큰을 앱으로 리다이렉트합니다.")
    @GetMapping("/login-success")
    public ResponseEntity<Void> loginSuccess(@RequestParam("token") String token) {
        return ResponseEntity.status(302)
                .location(java.net.URI.create("narae://login-success?token=" + token))
                .build();
    }
}
