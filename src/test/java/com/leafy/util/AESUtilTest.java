package com.leafy.util;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@ActiveProfiles("test")
class AESUtilTest {

    @Autowired
    private AESUtil aesUtil;

    @Test
    @DisplayName("데이터 암호화 및 복호화 테스트")
    void encryptDecryptTest() {
        // Given
        String originalData = "This is a secret diary content.";

        // When
        String encryptedData = aesUtil.encrypt(originalData);
        String decryptedData = aesUtil.decrypt(encryptedData);

        // Then
        assertThat(encryptedData).isNotEqualTo(originalData);
        assertThat(decryptedData).isEqualTo(originalData);
    }
}
