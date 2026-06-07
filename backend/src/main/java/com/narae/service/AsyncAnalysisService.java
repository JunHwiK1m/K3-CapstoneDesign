package com.narae.service;

import com.narae.client.AiServerClient;
import com.narae.dto.ai.EmotionAnalysisRequest;
import com.narae.dto.ai.FullAnalysisResponse;
import com.narae.entity.AnalysisStatus;
import com.narae.entity.Emotion;
import com.narae.entity.Journal;
import com.narae.entity.PersonaStyle;
import com.narae.repository.EmotionRepository;
import com.narae.repository.JournalRepository;
import com.narae.repository.UserSettingsRepository;
import com.narae.util.AESUtil;
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
    private final AESUtil aesUtil;

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
                    
            String musicStyle = userSettingsRepository.findByUserId(journal.getUser().getId())
                    .map(s -> s.getMusicStyle())
                    .orElse(null);

            // DB에 저장된 암호화된 일기 내용을 AI 분석을 위해 복호화합니다.
            String decryptedContent = aesUtil.decrypt(journal.getContent());

            EmotionAnalysisRequest request = EmotionAnalysisRequest.builder()
                    .journalId(journal.getId())
                    .content(decryptedContent)
                    .voiceUrl(journal.getVoiceUrl())
                    .personaStyle(personaStyle)
                    .musicStyle(musicStyle)
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
