package com.leafy.service;

import com.leafy.client.AiServerClient;
import com.leafy.dto.ai.EmotionAnalysisResponse;
import com.leafy.entity.AnalysisStatus;
import com.leafy.entity.Journal;
import com.leafy.entity.Provider;
import com.leafy.entity.User;
import com.leafy.repository.EmotionRepository;
import com.leafy.repository.JournalRepository;
import com.leafy.repository.UserRepository;
import com.leafy.repository.UserSettingsRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class AsyncAnalysisServiceTest {

    @InjectMocks
    private AsyncAnalysisService asyncAnalysisService;

    @Mock
    private AiServerClient aiServerClient;

    @Mock
    private JournalRepository journalRepository;

    @Mock
    private EmotionRepository emotionRepository;

    @Mock
    private UserSettingsRepository userSettingsRepository;

    @Mock
    private RecommendationService recommendationService;

    @Test
    @DisplayName("일기 분석 비동기 처리 성공 테스트")
    void analyzeJournalSuccessTest() {
        // Given
        User user = User.builder().id(1L).email("test@test.com").provider(Provider.LOCAL).nickname("test").build();
        Journal journal = Journal.builder().id(1L).user(user).content("Happy day").build();
        
        given(journalRepository.findById(1L)).willReturn(Optional.of(journal));
        given(userSettingsRepository.findByUserId(1L)).willReturn(Optional.empty());
        
        EmotionAnalysisResponse response = EmotionAnalysisResponse.builder()
                .joyScore(new BigDecimal("0.9"))
                .sadnessScore(new BigDecimal("0.1"))
                .stressLevel(new BigDecimal("0.2"))
                .emotionSummary("Great")
                .build();
        given(aiServerClient.analyzeEmotion(any())).willReturn(response);

        // When
        asyncAnalysisService.analyzeJournal(1L);

        // Then
        assertThat(journal.getAnalysisStatus()).isEqualTo(AnalysisStatus.COMPLETED);
        verify(emotionRepository, times(1)).save(any());
        verify(recommendationService, times(1)).generateRecommendations(eq(journal), any());
        verify(journalRepository, times(2)).save(any()); // PROCESSING -> COMPLETED
    }
}
