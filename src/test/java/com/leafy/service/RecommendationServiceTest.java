package com.leafy.service;

import com.leafy.client.AiServerClient;
import com.leafy.dto.ai.ActionRecommendationResponse;
import com.leafy.entity.Emotion;
import com.leafy.entity.Journal;
import com.leafy.entity.RecommendationCategory;
import com.leafy.repository.RecommendationRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class RecommendationServiceTest {

    @InjectMocks
    private RecommendationService recommendationService;

    @Mock
    private AiServerClient aiServerClient;

    @Mock
    private RecommendationRepository recommendationRepository;

    @Spy
    private DeepLinkBuilder deepLinkBuilder;

    @Test
    @DisplayName("추천 항목 생성 및 저장 테스트")
    void generateRecommendationsTest() {
        // Given
        Journal journal = Journal.builder().id(1L).build();
        Emotion emotion = Emotion.builder()
                .joyScore(new BigDecimal("0.8"))
                .sadnessScore(new BigDecimal("0.1"))
                .stressLevel(new BigDecimal("0.2"))
                .build();

        ActionRecommendationResponse.RecommendationItem item = ActionRecommendationResponse.RecommendationItem.builder()
                .category("MUSIC")
                .contentText("Test Music")
                .externalLink("id123")
                .build();

        ActionRecommendationResponse response = ActionRecommendationResponse.builder()
                .recommendations(List.of(item))
                .build();

        given(aiServerClient.recommendAction(any())).willReturn(response);

        // When
        recommendationService.generateRecommendations(journal, emotion);

        // Then
        verify(aiServerClient, times(1)).recommendAction(any());
        verify(deepLinkBuilder, times(1)).build(any(), any());
        verify(recommendationRepository, times(1)).saveAll(any());
    }
}
