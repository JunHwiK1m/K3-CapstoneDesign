package com.narae.service;

import com.narae.entity.RecommendationCategory;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class DeepLinkBuilder {

    /**
     * AI 서버에서 전달받은 원본 링크 정보를 바탕으로 앱 전용 딥링크와 웹 Fallback URL을 생성합니다.
     * 예시: category=MUSIC, rawLink="60SdxuWpCSTZHvCg9XmS81" -> spotify:track:60SdxuWpCSTZHvCg9XmS81 | https://open.spotify.com/track/60SdxuWpCSTZHvCg9XmS81
     */
    public DeepLinkPair build(RecommendationCategory category, String rawId) {
        return switch (category) {
            case MUSIC -> DeepLinkPair.of(
                    "spotify:playlist:" + rawId,
                    "https://open.spotify.com/playlist/" + rawId
            );
            case FOOD -> {
                String encodedKeyword = rawId;
                try {
                    encodedKeyword = java.net.URLEncoder.encode(rawId, java.nio.charset.StandardCharsets.UTF_8.toString());
                } catch (Exception e) {
                    log.error("URL Encoding error", e);
                }
                yield DeepLinkPair.of(
                        "baemin://search?keyword=" + encodedKeyword,
                        "https://www.baemin.com/"
                );
            }
            case MOVIE -> DeepLinkPair.of(
                    "netflix://title/" + rawId,
                    "https://www.netflix.com/title/" + rawId
            );
            default -> DeepLinkPair.of(rawId, rawId); // 기본값은 원본 유지
        };
    }

    public record DeepLinkPair(String deepLink, String fallbackUrl) {
        public static DeepLinkPair of(String deepLink, String fallbackUrl) {
            return new DeepLinkPair(deepLink, fallbackUrl);
        }
    }
}
