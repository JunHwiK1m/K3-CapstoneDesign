package com.leafy.controller;

import com.leafy.common.CommonResponse;
import com.leafy.dto.user.UserSettingsResponse;
import com.leafy.dto.user.UserSettingsUpdateRequest;
import com.leafy.service.UserSettingsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "User Settings", description = "사용자 설정 관련 API")
@RestController
@RequestMapping("/api/users/settings")
@RequiredArgsConstructor
public class UserSettingsController {

    private final UserSettingsService userSettingsService;

    @Operation(summary = "사용자 설정 조회", description = "현재 로그인한 사용자의 설정 정보를 조회합니다.")
    @GetMapping
    public CommonResponse<UserSettingsResponse> getSettings(@AuthenticationPrincipal UserDetails userDetails) {
        return CommonResponse.success("사용자 설정 조회 성공", userSettingsService.getSettings(userDetails.getUsername()));
    }

    @Operation(summary = "사용자 설정 수정", description = "현재 로그인한 사용자의 설정 정보를 수정합니다.")
    @PatchMapping
    public CommonResponse<Void> updateSettings(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody UserSettingsUpdateRequest request) {
        userSettingsService.updateSettings(userDetails.getUsername(), request);
        return CommonResponse.success("사용자 설정 수정 성공", null);
    }

    @Operation(summary = "AI 분석 활성화 설정 수정", description = "AI가 일기를 분석할지 여부를 설정합니다.")
    @PutMapping("/ai-analysis")
    public CommonResponse<Void> updateAiAnalysis(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam boolean enabled) {
        userSettingsService.updateAiAnalysisSetting(userDetails.getUsername(), enabled);
        return CommonResponse.success("AI 분석 설정 수정 성공", null);
    }

    @Operation(summary = "FCM 토큰 업데이트", description = "푸시 알림 수신을 위한 FCM 토큰을 저장 또는 갱신합니다.")
    @PatchMapping("/fcm-token")
    public CommonResponse<Void> updateFcmToken(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam String token) {
        userSettingsService.updateFcmToken(userDetails.getUsername(), token);
        return CommonResponse.success("FCM 토큰이 업데이트되었습니다.", null);
    }
}
