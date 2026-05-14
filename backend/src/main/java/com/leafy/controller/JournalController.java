package com.leafy.controller;

import com.leafy.common.CommonResponse;
import com.leafy.dto.journal.JournalCreateRequest;
import com.leafy.dto.journal.JournalDetailResponse;
import com.leafy.security.JwtTokenProvider;
import com.leafy.service.JournalService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Journal", description = "일기 관련 API")
@RestController
@RequestMapping("/api/journals")
@RequiredArgsConstructor
public class JournalController {

    private final JournalService journalService;
    private final JwtTokenProvider jwtTokenProvider;

    @Operation(summary = "일기 작성", description = "텍스트, 음성, 이미지 URL을 포함한 일기를 작성합니다.")
    @PostMapping
    public CommonResponse<Long> createJournal(
            @Valid @RequestBody JournalCreateRequest request,
            Authentication authentication) {
        Long userId = getUserId(authentication);
        return CommonResponse.success("일기가 등록되었습니다. 분석이 시작됩니다.", journalService.createJournal(userId, request));
    }

    @Operation(summary = "내 일기 목록 조회", description = "로그인한 사용자의 모든 일기 목록을 최신순으로 조회합니다.")
    @GetMapping
    public CommonResponse<List<JournalDetailResponse>> getMyJournals(Authentication authentication) {
        Long userId = getUserId(authentication);
        return CommonResponse.success(journalService.getMyJournals(userId));
    }

    @Operation(summary = "일기 상세 조회", description = "특정 일기의 상세 내용과 분석 상태를 조회합니다.")
    @GetMapping("/{journalId}")
    public CommonResponse<JournalDetailResponse> getJournal(
            @PathVariable Long journalId,
            Authentication authentication) {
        Long userId = getUserId(authentication);
        return CommonResponse.success(journalService.getJournal(userId, journalId));
    }

    private Long getUserId(Authentication authentication) {
        // Token resolve from authentication object (principal name is email, but we stored userId in claims)
        // In a real scenario, we might use a custom Resolver or get it from CustomUserDetails
        // For simplicity here, we use JwtTokenProvider directly if needed or parse from principal
        // Actually, we can get it from the token in the request header via jwtTokenProvider
        // But the filter already set the authentication.
        // Let's assume we cast principal to CustomUserDetails if we had one.
        // For now, I'll use a placeholder logic or fetch from provider using the token.
        String token = (String) authentication.getCredentials();
        return jwtTokenProvider.getUserId(token);
    }
}
