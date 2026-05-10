package com.leafy.service;

import com.leafy.client.AiServerClient;
import com.leafy.dto.ai.EmotionAnalysisRequest;
import com.leafy.dto.ai.EmotionAnalysisResponse;
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
        log.info("Starting background analysis for journalId: {}", journalId);
        
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

            EmotionAnalysisResponse response = aiServerClient.analyzeEmotion(request);

            Emotion emotion = Emotion.builder()
                    .journal(journal)
                    .joyScore(response.getJoyScore())
                    .sadnessScore(response.getSadnessScore())
                    .stressLevel(response.getStressLevel())
                    .emotionSummary(response.getEmotionSummary())
                    .build();

            emotionRepository.save(emotion);
            
            // Trigger Recommendations (Phase 5)
            recommendationService.generateRecommendations(journal, emotion);
            
            journal.updateStatus(AnalysisStatus.COMPLETED);
            
            log.info("Analysis and recommendations completed for journalId: {}", journalId);
        } catch (Exception e) {
            log.error("Analysis failed for journalId: {}", journalId, e);
            journal.updateStatus(AnalysisStatus.FAILED);
        }
        
        journalRepository.save(journal);
    }
}
