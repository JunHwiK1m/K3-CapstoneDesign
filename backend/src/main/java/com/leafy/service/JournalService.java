package com.leafy.service;

import com.leafy.dto.journal.JournalCreateRequest;
import com.leafy.dto.journal.JournalDetailResponse;
import com.leafy.entity.Journal;
import com.leafy.entity.User;
import com.leafy.exception.BusinessException;
import com.leafy.exception.ErrorCode;
import com.leafy.repository.JournalRepository;
import com.leafy.repository.UserRepository;
import com.leafy.util.AESUtil;
import com.leafy.util.LogMasker;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class JournalService {

    private final JournalRepository journalRepository;
    private final UserRepository userRepository;
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
                .imgUrl(request.getImgUrl())
                .build();

        Journal savedJournal = journalRepository.save(journal);
        
        // Trigger asynchronous analysis
        asyncAnalysisService.analyzeJournal(savedJournal.getId());
        
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
        
        return JournalDetailResponse.builder()
                .id(journal.getId())
                .content(decryptedContent)
                .voiceUrl(journal.getVoiceUrl())
                .imgUrl(journal.getImgUrl())
                .analysisStatus(journal.getAnalysisStatus())
                .createdAt(journal.getCreatedAt())
                .build();
    }
}
