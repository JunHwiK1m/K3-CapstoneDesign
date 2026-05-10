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
                .nickname("testuser")
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
        assertThat(response.getPersonaStyle()).isEqualTo(PersonaStyle.BASIC);
        assertThat(response.getUsagePurpose()).isEqualTo(UsagePurpose.MENTAL_CARE);
    }

    @Test
    @DisplayName("사용자 설정 수정 테스트")
    void updateSettingsTest() {
        // Given
        UserSettingsUpdateRequest request = new UserSettingsUpdateRequest();
        LocalTime reminderTime = LocalTime.of(10, 30);
        LocalDate birthDate = LocalDate.of(1990, 5, 20);
        
        setPrivateField(request, "reminderTime", reminderTime);
        setPrivateField(request, "usagePurpose", UsagePurpose.SIMPLE_DIARY);
        setPrivateField(request, "personaStyle", PersonaStyle.FRIENDLY);
        setPrivateField(request, "birthDate", birthDate);

        // When
        userSettingsService.updateSettings("test@leafy.com", request);

        // Then
        UserSettingsResponse response = userSettingsService.getSettings("test@leafy.com");
        assertThat(response.getReminderTime()).isEqualTo(reminderTime);
        assertThat(response.getUsagePurpose()).isEqualTo(UsagePurpose.SIMPLE_DIARY);
        assertThat(response.getPersonaStyle()).isEqualTo(PersonaStyle.FRIENDLY);
        assertThat(response.getBirthDate()).isEqualTo(birthDate);
    }

    private void setPrivateField(Object target, String fieldName, Object value) {
        try {
            java.lang.reflect.Field field = target.getClass().getDeclaredField(fieldName);
            field.setAccessible(true);
            field.set(target, value);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
