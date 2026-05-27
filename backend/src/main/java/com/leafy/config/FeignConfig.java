package com.leafy.config;

import feign.Logger;
import feign.Request;
import feign.Retryer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.concurrent.TimeUnit;

@Configuration
public class FeignConfig {

    @Bean
    public Logger.Level feignLoggerLevel() {
        return Logger.Level.FULL;
    }

    @Bean
    public Request.Options requestOptions() {
        // Connect Timeout: 5s, Read Timeout: 120s (increased to handle complex AI analysis)
        return new Request.Options(
                5000, TimeUnit.MILLISECONDS,
                120000, TimeUnit.MILLISECONDS,
                true
        );
    }

    @Bean
    public Retryer retryer() {
        // No retry for now to keep it simple, or custom retryer if needed
        return Retryer.NEVER_RETRY;
    }
}
