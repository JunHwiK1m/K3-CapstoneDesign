package com.narae.service;

import com.narae.dto.ai.FullAnalysisResponse;
import com.narae.entity.Journal;
import com.narae.repository.RecommendationRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class RecommendationServiceTest {

    @InjectMocks
    private RecommendationService recommendationService;

    @Mock
    private RecommendationRepository recommendationRepository;

    @Spy
    private DeepLinkBuilder deepLinkBuilder;

    @Test
    @DisplayName("추천 항목 저장 테스트")
    void saveRecommendationsTest() {
        // Given
        Journal journal = Journal.builder().id(1L).build();

        FullAnalysisResponse.RecommendationItem item = new FullAnalysisResponse.RecommendationItem(
                "MUSIC",
                "Test Music",
                "id123"
        );

        // When
        recommendationService.saveRecommendations(journal, List.of(item));

        // Then
        verify(deepLinkBuilder, times(1)).build(any(), any());
        verify(recommendationRepository, times(1)).saveAll(any());
    }
}
