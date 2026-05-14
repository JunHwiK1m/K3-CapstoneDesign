package com.leafy.service;

import com.leafy.entity.Emotion;
import com.leafy.repository.EmotionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class RiskAnalysisService {

    private final EmotionRepository emotionRepository;
    
    // 임계치 정의 (Analysis Report AM2 반영)
    private static final BigDecimal DEPRESSION_THRESHOLD = new BigDecimal("0.8");

    /**
     * 최근 4주간의 감정 데이터를 분석하여 고위험군 여부를 판단합니다.
     */
    public boolean checkHighRisk(Long userId) {
        LocalDateTime since = LocalDateTime.now().minusWeeks(4);
        List<Emotion> recentEmotions = emotionRepository.findAllByUserIdAndAnalyzedAtAfter(userId, since);

        if (recentEmotions.isEmpty()) {
            return false;
        }

        // 평균 슬픔(우울) 수치 계산
        BigDecimal totalSadness = recentEmotions.stream()
                .map(Emotion::getSadnessScore)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal averageSadness = totalSadness.divide(
                BigDecimal.valueOf(recentEmotions.size()), 4, RoundingMode.HALF_UP);

        log.info("User {} average sadness for last 4 weeks: {}", userId, averageSadness);

        return averageSadness.compareTo(DEPRESSION_THRESHOLD) >= 0;
    }
}
