package com.leafy.service;

import com.leafy.dto.user.UserSettingsResponse;
import com.leafy.dto.user.UserSettingsUpdateRequest;
import com.leafy.entity.PersonaStyle;
import com.leafy.entity.Provider;
import com.leafy.entity.UsagePurpose;
import com.leafy.entity.User;
import com.leafy.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class UserSettingsServiceTest {

    @Autowired
    private UserSettingsService userSettingsService;

    @Autowired
    private UserRepository userRepository;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = User.builder()
                .email("test@leafy.com")
                .name("testuser")
                .passwordHash("password")
                .provider(Provider.LOCAL)
                .build();
        userRepository.save(testUser);
    }

    @Test
    @DisplayName("사용자 설정 조회 시, 설정이 없으면 기본값으로 생성하여 반환한다")
    void getSettingsCreateDefaultTest() {
        // When
        UserSettingsResponse response = userSettingsService.getSettings("test@leafy.com");

        // Then
        assertThat(response).isNotNull();
        assertThat(response.personaStyle()).isEqualTo(PersonaStyle.BASIC);
        assertThat(response.usagePurpose()).isEqualTo(UsagePurpose.RECORDING);
    }

    @Test
    @DisplayName("사용자 설정 수정 테스트")
    void updateSettingsTest() {
        // Given
        LocalTime diaryTime = LocalTime.of(10, 30);
        LocalDate birthDate = LocalDate.of(1990, 5, 20);
        List<String> musicStyles = List.of("Lo-fi", "Jazz");
        
        UserSettingsUpdateRequest request = new UserSettingsUpdateRequest(
                diaryTime,
                LocalTime.of(7, 0),
                UsagePurpose.GOD_SAENG,
                "리피",
                "https://example.com/profile.png",
                birthDate,
                null,
                musicStyles,
                PersonaStyle.FRIENDLY,
                true
        );

        // When
        userSettingsService.updateSettings("test@leafy.com", request);

        // Then
        UserSettingsResponse response = userSettingsService.getSettings("test@leafy.com");
        assertThat(response.diaryTime()).isEqualTo(diaryTime);
        assertThat(response.usagePurpose()).isEqualTo(UsagePurpose.GOD_SAENG);
        assertThat(response.personaStyle()).isEqualTo(PersonaStyle.FRIENDLY);
        assertThat(response.birthDate()).isEqualTo(birthDate);
        assertThat(response.musicStyles()).containsExactlyInAnyOrder("Lo-fi", "Jazz");
        assertThat(response.isAiAnalysisEnabled()).isTrue();
    }
}
