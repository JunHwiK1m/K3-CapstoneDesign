package com.narae.controller;

import com.narae.common.CommonResponse;
import com.narae.entity.Recommendation;
import com.narae.service.RecommendationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Recommendation", description = "추천 관련 API")
@RestController
@RequestMapping("/api/recommendations")
@RequiredArgsConstructor
public class RecommendationController {

    private final RecommendationService recommendationService;

    @Operation(summary = "일기별 추천 목록 조회", description = "특정 일기에 대해 생성된 맞춤형 추천 목록을 조회합니다.")
    @GetMapping
    public CommonResponse<List<Recommendation>> getRecommendations(@RequestParam Long journalId) {
        return CommonResponse.success(recommendationService.getRecommendationsByJournal(journalId));
    }

    @Operation(summary = "추천 클릭 상태 업데이트", description = "사용자가 추천 링크를 클릭했을 때 상태를 업데이트합니다.")
    @PatchMapping("/{recommendationId}/click")
    public CommonResponse<Void> markAsClicked(@PathVariable Long recommendationId) {
        recommendationService.markAsClicked(recommendationId);
        return CommonResponse.success("클릭 상태가 업데이트되었습니다.", null);
    }
}
