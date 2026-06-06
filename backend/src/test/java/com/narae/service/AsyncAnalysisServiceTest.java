package com.narae.service;

import com.narae.client.AiServerClient;
import com.narae.dto.ai.FullAnalysisResponse;
import com.narae.entity.AnalysisStatus;
import com.narae.entity.Journal;
import com.narae.entity.Provider;
import com.narae.entity.User;
import com.narae.repository.EmotionRepository;
import com.narae.repository.JournalRepository;
import com.narae.repository.UserSettingsRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Collections;
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
    @DisplayName("일기 통합 분석 비동기 처리 성공 테스트")
    void analyzeJournalSuccessTest() {
        // Given
        User user = User.builder().id(1L).email("test@test.com").provider(Provider.LOCAL).name("test").build();
        Journal journal = Journal.builder().id(1L).user(user).content("Happy day").build();
        
        given(journalRepository.findById(1L)).willReturn(Optional.of(journal));
        given(userSettingsRepository.findByUserId(1L)).willReturn(Optional.empty());
        
        FullAnalysisResponse response = new FullAnalysisResponse(
                1L,
                new BigDecimal("0.9"),
                new BigDecimal("0.1"),
                new BigDecimal("0.2"),
                "Great",
                Collections.emptyList()
        );
        given(aiServerClient.analyzeFull(any())).willReturn(response);

        // When
        asyncAnalysisService.analyzeJournal(1L);

        // Then
        assertThat(journal.getAnalysisStatus()).isEqualTo(AnalysisStatus.COMPLETED);
        verify(emotionRepository, times(1)).save(any());
        verify(aiServerClient, times(1)).analyzeFull(any());
        verify(journalRepository, times(2)).save(any()); // PROCESSING -> COMPLETED
    }
}
