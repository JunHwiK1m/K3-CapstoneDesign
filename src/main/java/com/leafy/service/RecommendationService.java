package com.leafy.service;

import com.leafy.client.AiServerClient;
import com.leafy.dto.ai.ActionRecommendationRequest;
import com.leafy.dto.ai.ActionRecommendationResponse;
import com.leafy.entity.Emotion;
import com.leafy.entity.Journal;
import com.leafy.entity.Recommendation;
import com.leafy.entity.RecommendationCategory;
import com.leafy.repository.RecommendationRepository;
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

    private final AiServerClient aiServerClient;
    private final RecommendationRepository recommendationRepository;
    private final DeepLinkBuilder deepLinkBuilder;

    @Transactional
    public void generateRecommendations(Journal journal, Emotion emotion) {
        log.info("Requesting recommendations for journalId: {}", journal.getId());

        ActionRecommendationRequest request = ActionRecommendationRequest.builder()
                .journalId(journal.getId())
                .joyScore(emotion.getJoyScore())
                .sadnessScore(emotion.getSadnessScore())
                .stressLevel(emotion.getStressLevel())
                .build();

        try {
            ActionRecommendationResponse response = aiServerClient.recommendAction(request);

            List<Recommendation> recommendations = response.getRecommendations().stream()
                    .map(item -> {
                        RecommendationCategory category = RecommendationCategory.valueOf(item.getCategory());
                        // externalLink in response is used as rawId for builder
                        DeepLinkBuilder.DeepLinkPair links = deepLinkBuilder.build(category, item.getExternalLink());

                        return Recommendation.builder()
                                .journal(journal)
                                .category(category)
                                .contentText(item.getContentText())
                                .externalLink(links.deepLink())
                                .fallbackUrl(links.fallbackUrl())
                                .build();
                    })
                    .collect(Collectors.toList());

            recommendationRepository.saveAll(recommendations);
            log.info("Saved {} recommendations for journalId: {}", recommendations.size(), journal.getId());
        } catch (Exception e) {
            log.error("Failed to generate recommendations for journalId: {}", journal.getId(), e);
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
