package com.narae.common;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class CommonResponseTest {

    @Test
    @DisplayName("성공 응답 생성 테스트")
    void successResponseTest() {
        String data = "test data";
        CommonResponse<String> response = CommonResponse.success(data);

        assertThat(response.isSuccess()).isTrue();
        assertThat(response.getData()).isEqualTo(data);
        assertThat(response.getMessage()).isEqualTo("요청이 성공적으로 처리되었습니다.");
    }

    @Test
    @DisplayName("실패 응답 생성 테스트")
    void failResponseTest() {
        String message = "error message";
        CommonResponse<Void> response = CommonResponse.fail(message);

        assertThat(response.isSuccess()).isFalse();
        assertThat(response.getMessage()).isEqualTo(message);
        assertThat(response.getData()).isNull();
    }
}
