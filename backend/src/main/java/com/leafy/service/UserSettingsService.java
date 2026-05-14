package com.leafy.service;

import com.leafy.dto.user.UserSettingsResponse;
import com.leafy.dto.user.UserSettingsUpdateRequest;
import com.leafy.entity.PersonaStyle;
import com.leafy.entity.UsagePurpose;
import com.leafy.entity.User;
import com.leafy.entity.UserSettings;
import com.leafy.exception.BusinessException;
import com.leafy.exception.ErrorCode;
import com.leafy.repository.UserRepository;
import com.leafy.repository.UserSettingsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserSettingsService {

    private final UserSettingsRepository userSettingsRepository;
    private final UserRepository userRepository;

    public UserSettingsResponse getSettings(String email) {
        User user = findUserByEmail(email);
        UserSettings settings = userSettingsRepository.findByUserId(user.getId())
                .orElseGet(() -> createDefaultSettings(user));
        return UserSettingsResponse.from(settings);
    }

    @Transactional
    public void updateSettings(String email, UserSettingsUpdateRequest request) {
        User user = findUserByEmail(email);
        UserSettings settings = userSettingsRepository.findByUserId(user.getId())
                .orElseGet(() -> createDefaultSettings(user));

        settings.update(
                request.diaryTime(),
                request.wakeUpTime(),
                request.usagePurpose(),
                request.nickname(),
                request.profileImage(),
                request.birthDate(),
                request.adviceTone(),
                request.musicStyle(),
                request.personaStyle()
        );
    }

    private User findUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));
    }

    private UserSettings createDefaultSettings(User user) {
        UserSettings settings = UserSettings.builder()
                .user(user)
                .personaStyle(PersonaStyle.BASIC)
                .usagePurpose(UsagePurpose.RECORDING)
                .build();
        return userSettingsRepository.save(settings);
    }
}
