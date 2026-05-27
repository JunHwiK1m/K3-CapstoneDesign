package com.leafy.service;

import com.leafy.entity.RecommendationCategory;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class DeepLinkBuilderTest {

    private final DeepLinkBuilder deepLinkBuilder = new DeepLinkBuilder();

    @Test
    @DisplayName("음악 카테고리 딥링크 생성 테스트")
    void buildMusicLinkTest() {
        // Given
        String rawId = "spotify123";

        // When
        DeepLinkBuilder.DeepLinkPair result = deepLinkBuilder.build(RecommendationCategory.MUSIC, rawId);

        // Then
        assertThat(result.deepLink()).isEqualTo("spotify:track:spotify123");
        assertThat(result.fallbackUrl()).isEqualTo("https://open.spotify.com/track/spotify123");
    }

    @Test
    @DisplayName("음식 카테고리 딥링크 생성 테스트")
    void buildFoodLinkTest() {
        // Given
        String rawId = "rest456";

        // When
        DeepLinkBuilder.DeepLinkPair result = deepLinkBuilder.build(RecommendationCategory.FOOD, rawId);

        // Then
        assertThat(result.deepLink()).isEqualTo("baemin://restaurant?id=rest456");
        assertThat(result.fallbackUrl()).isEqualTo("https://www.baemin.com/");
    }
}
