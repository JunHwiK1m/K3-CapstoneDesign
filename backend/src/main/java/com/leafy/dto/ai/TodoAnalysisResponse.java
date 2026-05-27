package com.leafy.dto.ai;

import com.fasterxml.jackson.annotation.JsonProperty;

public record TodoAnalysisResponse(
    @JsonProperty("feedback_message")
    String feedbackMessage
) {
}
