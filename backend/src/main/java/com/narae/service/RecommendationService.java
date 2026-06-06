package com.narae.service;

import com.narae.dto.ai.FullAnalysisResponse;
import com.narae.entity.Journal;
import com.narae.entity.Recommendation;
import com.narae.entity.RecommendationCategory;
import com.narae.repository.RecommendationRepository;
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
public class RecommendationService {

    private final RecommendationRepository recommendationRepository;
    private final DeepLinkBuilder deepLinkBuilder;

    /**
     * AI 서버에서 받은 추천 항목들을 딥링크와 함께 저장합니다.
     */
    @Transactional
    public void saveRecommendations(Journal journal, List<FullAnalysisResponse.RecommendationItem> items) {
        log.info("Saving {} recommendations for journalId: {}", items.size(), journal.getId());

        try {
            List<Recommendation> recommendations = items.stream()
                    .map(item -> {
                        RecommendationCategory category = RecommendationCategory.valueOf(item.category());
                        // externalLink를 rawId로 사용하여 딥링크 쌍 생성
                        DeepLinkBuilder.DeepLinkPair links = deepLinkBuilder.build(category, item.externalLink());

                        return Recommendation.builder()
                                .journal(journal)
                                .category(category)
                                .contentText(item.contentText())
                                .externalLink(links.deepLink())
                                .fallbackUrl(links.fallbackUrl())
                                .build();
                    })
                    .collect(Collectors.toList());

            recommendationRepository.saveAll(recommendations);
        } catch (Exception e) {
            log.error("Failed to save recommendations for journalId: {}", journal.getId(), e);
        }
    }

    @Transactional
    public void markAsClicked(Long recommendationId) {
        Recommendation recommendation = recommendationRepository.findById(recommendationId)
                .orElseThrow(() -> new IllegalArgumentException("Recommendation not found: " + recommendationId));
        recommendation.markAsClicked();
    }

    public List<Recommendation> getRecommendationsByJournal(Long journalId) {
        return recommendationRepository.findAllByJournalId(journalId);
    }
}
