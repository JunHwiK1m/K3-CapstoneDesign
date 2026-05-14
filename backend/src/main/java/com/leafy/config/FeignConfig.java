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
        // Read Timeout: 60s (per Constitution and Analysis Report)
        return new Request.Options(
                5000, TimeUnit.MILLISECONDS, // Connect Timeout: 5s
                60000, TimeUnit.MILLISECONDS, // Read Timeout: 60s
                true // followRedirects
        );
    }

    @Bean
    public Retryer retryer() {
        // No retry for now to keep it simple, or custom retryer if needed
        return Retryer.NEVER_RETRY;
    }
}
