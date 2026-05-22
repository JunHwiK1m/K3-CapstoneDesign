package com.leafy.service;

import com.leafy.client.AiServerClient;
import com.leafy.dto.ai.FullAnalysisResponse;
import com.leafy.dto.journal.JournalCreateRequest;
import com.leafy.entity.*;
import com.leafy.repository.*;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import java.math.BigDecimal;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;

@SpringBootTest
@ActiveProfiles("test")
public class JournalIntegrationTest {

    @Autowired
    private JournalService journalService;

    @Autowired
    private AsyncAnalysisService asyncAnalysisService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JournalRepository journalRepository;

    @Autowired
    private EmotionRepository emotionRepository;

    @Autowired
    private RecommendationRepository recommendationRepository;

    @MockitoBean
    private AiServerClient aiServerClient;

    @AfterEach
    void tearDown() {
        recommendationRepository.deleteAll();
        emotionRepository.deleteAll();
        journalRepository.deleteAll();
        userRepository.deleteAll();
    }

    @Test
    @DisplayName("일기 작성부터 AI 분석 결과 저장까지의 전체 흐름 테스트")
    void fullJournalProcessTest() throws InterruptedException {
        // 1. 테스트용 사용자 생성
        User user = User.builder()
                .email("tester@leafy.com")
                .name("테스터")
                .provider(Provider.LOCAL)
                .build();
        userRepository.save(user);

        // 2. 가짜 AI 서버 응답 설정
        FullAnalysisResponse mockResponse = new FullAnalysisResponse(
                null,
                new BigDecimal("0.8500"),
                new BigDecimal("0.1000"),
                new BigDecimal("0.2000"),
                "정말 멋진 하루를 보내셨네요!",
                List.of(
                    new FullAnalysisResponse.RecommendationItem("MUSIC", "신나는 음악", "track_id_123"),
                    new FullAnalysisResponse.RecommendationItem("FOOD", "맛있는 피자", "pizza_shop_456")
                )
        );
        given(aiServerClient.analyzeFull(any())).willReturn(mockResponse);

        // 3. 일기 작성 서비스 호출
        // (주의: createJournal 내부에서 @Async로 analyzeJournal이 호출되지만, 
        //  비결정적인 스레드 실행을 피하기 위해 여기서는 무시하고 수동으로 호출하여 검증합니다.)
        JournalCreateRequest request = JournalCreateRequest.builder()
                .content("오늘 날씨가 너무 좋아서 행복했다.")
                .build();
        Long journalId = journalService.createJournal(user.getId(), request);

        // 4. 비동기 분석 서비스 직접 호출 (동기적으로 실행하여 결과 확인)
        // 실제 운영 환경의 @Async 스레드와 충돌할 수 있으므로 잠시 대기하거나 직접 호출
        Thread.sleep(500); // 자동 실행된 @Async 작업이 끝날 때까지 대기하거나 실패하게 둠
        asyncAnalysisService.analyzeJournal(journalId);

        // 5. 결과 검증
        Journal journal = journalRepository.findById(journalId).orElseThrow();
        assertThat(journal.getAnalysisStatus()).isEqualTo(AnalysisStatus.COMPLETED);

        Emotion emotion = emotionRepository.findByJournalId(journalId).orElseThrow();
        assertThat(emotion.getJoyScore()).isEqualByComparingTo("0.8500");
        assertThat(emotion.getEmotionSummary()).contains("멋진 하루");

        List<Recommendation> recommendations = recommendationRepository.findAllByJournalId(journalId);
        assertThat(recommendations).hasSize(2);
        
        Recommendation musicRec = recommendations.stream()
                .filter(r -> r.getCategory() == RecommendationCategory.MUSIC)
                .findFirst().orElseThrow();
        assertThat(musicRec.getExternalLink()).isEqualTo("spotify:track:track_id_123");
    }
}
