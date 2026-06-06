package com.narae.service;

import com.narae.dto.journal.JournalCreateRequest;
import com.narae.dto.journal.JournalDetailResponse;
import com.narae.entity.Emotion;
import com.narae.entity.Journal;
import com.narae.entity.User;
import com.narae.exception.BusinessException;
import com.narae.exception.ErrorCode;
import com.narae.repository.EmotionRepository;
import com.narae.repository.JournalRepository;
import com.narae.repository.UserRepository;
import com.narae.util.AESUtil;
import com.narae.util.LogMasker;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class JournalService {

    private final JournalRepository journalRepository;
    private final UserRepository userRepository;
    private final EmotionRepository emotionRepository;
    private final AsyncAnalysisService asyncAnalysisService;
    private final AESUtil aesUtil;

    @Transactional
    public Long createJournal(Long userId, JournalCreateRequest request) {
        log.info("Creating journal for user: {}. Masked content: {}", userId, LogMasker.mask(request.getContent()));
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        String encryptedContent = aesUtil.encrypt(request.getContent());

        Journal journal = Journal.builder()
                .user(user)
                .content(encryptedContent)
                .voiceUrl(request.getVoiceUrl())
                .imageUrls(request.getImageUrls() != null ? request.getImageUrls() : List.of())
                .build();

        Journal savedJournal = journalRepository.save(journal);
        
        // Trigger asynchronous analysis after the transaction has successfully committed
        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
            @Override
            public void afterCommit() {
                asyncAnalysisService.analyzeJournal(savedJournal.getId());
            }
        });
        
        return savedJournal.getId();
    }

    public List<JournalDetailResponse> getMyJournals(Long userId) {
        return journalRepository.findAllByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(this::convertToDetailResponse)
                .collect(Collectors.toList());
    }

    public JournalDetailResponse getJournal(Long userId, Long journalId) {
        Journal journal = journalRepository.findById(journalId)
                .orElseThrow(() -> new BusinessException(ErrorCode.JOURNAL_NOT_FOUND));

        // Ownership validation (Constitution 제4조 1항 준수)
        if (!journal.getUser().getId().equals(userId)) {
            throw new BusinessException(ErrorCode.ACCESS_DENIED);
        }

        return convertToDetailResponse(journal);
    }

    private JournalDetailResponse convertToDetailResponse(Journal journal) {
        String decryptedContent = aesUtil.decrypt(journal.getContent());

        JournalDetailResponse.JournalDetailResponseBuilder builder = JournalDetailResponse.builder()
                .id(journal.getId())
                .content(decryptedContent)
                .voiceUrl(journal.getVoiceUrl())
                .imageUrls(new ArrayList<>(journal.getImageUrls()))
                .analysisStatus(journal.getAnalysisStatus())
                .createdAt(journal.getCreatedAt());

        emotionRepository.findByJournalId(journal.getId())
                .ifPresent(emotion -> builder.emotionResult(
                        JournalDetailResponse.EmotionResponse.builder()
                                .joyScore(emotion.getJoyScore())
                                .sadnessScore(emotion.getSadnessScore())
                                .stressLevel(emotion.getStressLevel())
                                .emotionSummary(emotion.getEmotionSummary())
                                .build()
                ));

        return builder.build();
    }
}
