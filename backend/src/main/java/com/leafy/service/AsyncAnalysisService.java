package com.leafy.service;

import com.leafy.client.AiServerClient;
import com.leafy.dto.ai.EmotionAnalysisRequest;
import com.leafy.dto.ai.FullAnalysisResponse;
import com.leafy.entity.AnalysisStatus;
import com.leafy.entity.Emotion;
import com.leafy.entity.Journal;
import com.leafy.entity.PersonaStyle;
import com.leafy.repository.EmotionRepository;
import com.leafy.repository.JournalRepository;
import com.leafy.repository.UserSettingsRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class AsyncAnalysisService {

    private final AiServerClient aiServerClient;
    private final JournalRepository journalRepository;
    private final EmotionRepository emotionRepository;
    private final UserSettingsRepository userSettingsRepository;
    private final RecommendationService recommendationService;

    @Async
    @Transactional
    public void analyzeJournal(Long journalId) {
        log.info("Starting background full analysis for journalId: {}", journalId);
        
        Journal journal = journalRepository.findById(journalId)
                .orElseThrow(() -> new IllegalArgumentException("Journal not found: " + journalId));

        journal.updateStatus(AnalysisStatus.PROCESSING);
        journalRepository.save(journal);

        try {
            String personaStyle = userSettingsRepository.findByUserId(journal.getUser().getId())
                    .map(s -> s.getPersonaStyle().name())
                    .orElse(PersonaStyle.BASIC.name());

            EmotionAnalysisRequest request = EmotionAnalysisRequest.builder()
                    .journalId(journal.getId())
                    .content(journal.getContent())
                    .voiceUrl(journal.getVoiceUrl())
                    .personaStyle(personaStyle)
                    .build();

            // 통합 엔드포인트 호출 (분석 + 추천)
            FullAnalysisResponse response = aiServerClient.analyzeFull(request);

            // 1. 감정 분석 결과 저장
            Emotion emotion = Emotion.builder()
                    .journal(journal)
                    .joyScore(response.joyScore())
                    .sadnessScore(response.sadnessScore())
                    .stressLevel(response.stressLevel())
                    .emotionSummary(response.emotionSummary())
                    .build();

            emotionRepository.save(emotion);
            
            // 2. 추천 활동 저장
            if (response.recommendations() != null && !response.recommendations().isEmpty()) {
                recommendationService.saveRecommendations(journal, response.recommendations());
            }
            
            journal.updateStatus(AnalysisStatus.COMPLETED);
            log.info("Full analysis and recommendations completed for journalId: {}", journalId);
        } catch (Exception e) {
            log.error("Full analysis failed for journalId: {}", journalId, e);
            journal.updateStatus(AnalysisStatus.FAILED);
        }
        
        journalRepository.save(journal);
    }
}
