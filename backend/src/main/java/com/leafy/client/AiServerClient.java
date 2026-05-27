package com.leafy.client;

import com.leafy.config.FeignConfig;
import com.leafy.dto.ai.EmotionAnalysisRequest;
import com.leafy.dto.ai.FullAnalysisResponse;
import com.leafy.dto.ai.TodoAnalysisRequest;
import com.leafy.dto.ai.TodoAnalysisResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(name = "aiServerClient", url = "${ai.server.url}", configuration = FeignConfig.class)
public interface AiServerClient {

    /**
     * 감정 분석과 추천 활동을 한 번의 호출로 모두 받아옵니다.
     */
    @PostMapping("/analyze/full")
    FullAnalysisResponse analyzeFull(@RequestBody EmotionAnalysisRequest request);

    /**
     * Todo 성취도에 대한 맞춤형 피드백을 받아옵니다.
     */
    @PostMapping("/analyze/todo")
    TodoAnalysisResponse analyzeTodo(@RequestBody TodoAnalysisRequest request);
}
