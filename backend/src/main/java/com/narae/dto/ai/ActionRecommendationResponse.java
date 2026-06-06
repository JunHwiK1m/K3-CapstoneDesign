package com.narae.dto.ai;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@Builder
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@NoArgsConstructor(access = AccessLevel.PRIVATE)
public class ActionRecommendationResponse {

    private List<RecommendationItem> recommendations;

    @Getter
    @Builder
    @AllArgsConstructor(access = AccessLevel.PRIVATE)
    @NoArgsConstructor(access = AccessLevel.PRIVATE)
    public static class RecommendationItem {
        private String category;

        @JsonProperty("content_text")
        private String contentText;

        @JsonProperty("external_link")
        private String externalLink;

        @JsonProperty("fallback_url")
        private String fallbackUrl;
    }
}
