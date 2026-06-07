package com.narae.service;

import com.narae.entity.Emotion;
import com.narae.repository.EmotionRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;

@ExtendWith(MockitoExtension.class)
class RiskAnalysisServiceTest {

    @InjectMocks
    private RiskAnalysisService riskAnalysisService;

    @Mock
    private EmotionRepository emotionRepository;

    @Test
    @DisplayName("고위험군 탐지 테스트 - 평균 슬픔 수치 임계치 초과")
    void checkHighRiskTrueTest() {
        // Given
        Long userId = 1L;
        Emotion e1 = Emotion.builder().sadnessScore(new BigDecimal("0.9")).build();
        Emotion e2 = Emotion.builder().sadnessScore(new BigDecimal("0.8")).build();
        
        given(emotionRepository.findAllByUserIdAndAnalyzedAtAfter(eq(userId), any()))
                .willReturn(List.of(e1, e2));

        // When
        boolean result = riskAnalysisService.checkHighRisk(userId);

        // Then
        assertThat(result).isTrue();
    }

    @Test
    @DisplayName("고위험군 탐지 테스트 - 정상 범위")
    void checkHighRiskFalseTest() {
        // Given
        Long userId = 1L;
        Emotion e1 = Emotion.builder().sadnessScore(new BigDecimal("0.3")).build();
        Emotion e2 = Emotion.builder().sadnessScore(new BigDecimal("0.4")).build();
        
        given(emotionRepository.findAllByUserIdAndAnalyzedAtAfter(eq(userId), any()))
                .willReturn(List.of(e1, e2));

        // When
        boolean result = riskAnalysisService.checkHighRisk(userId);

        // Then
        assertThat(result).isFalse();
    }
}
