package com.leafy.client;

import com.leafy.config.FeignConfig;
import com.leafy.dto.ai.ActionRecommendationRequest;
import com.leafy.dto.ai.ActionRecommendationResponse;
import com.leafy.dto.ai.EmotionAnalysisRequest;
import com.leafy.dto.ai.EmotionAnalysisResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(name = "aiServerClient", url = "${ai.server.url}", configuration = FeignConfig.class)
public interface AiServerClient {

    @PostMapping("/analyze/emotion")
    EmotionAnalysisResponse analyzeEmotion(@RequestBody EmotionAnalysisRequest request);

    @PostMapping("/recommend/action")
    ActionRecommendationResponse recommendAction(@RequestBody ActionRecommendationRequest request);
}
