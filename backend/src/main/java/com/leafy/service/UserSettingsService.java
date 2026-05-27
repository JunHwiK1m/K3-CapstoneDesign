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

        // 여러 장르 리스트를 콤마로 구분된 하나의 문자열로 합침
        String musicStyleString = null;
        if (request.musicStyles() != null && !request.musicStyles().isEmpty()) {
            musicStyleString = String.join(",", request.musicStyles());
        }

        settings.update(
                request.diaryTime(),
                request.wakeUpTime(),
                request.usagePurpose(),
                request.nickname(),
                request.profileImage(),
                request.birthDate(),
                request.adviceTone(),
                musicStyleString,
                request.personaStyle(),
                request.isAiAnalysisEnabled()
        );
    }

    @Transactional
    public void updateAiAnalysisSetting(String email, boolean enabled) {
        User user = findUserByEmail(email);
        UserSettings settings = userSettingsRepository.findByUserId(user.getId())
                .orElseGet(() -> createDefaultSettings(user));
        settings.updateAiAnalysis(enabled);
    }

    @Transactional
    public void updateFcmToken(String email, String token) {
        User user = findUserByEmail(email);
        user.updateFcmToken(token);
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
