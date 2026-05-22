package com.leafy.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalTime;

/**
 * 사용자 설정 엔티티
 */
@Entity
@Table(name = "user_settings")
@Getter
@Setter // 요구사항에 포함됨
@Builder
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserSettings {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "setting_id")
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "diary_time")
    private LocalTime diaryTime; // 일기 작성 권장 시간

    @Column(name = "wake_up_time")
    private LocalTime wakeUpTime; // 기상 시간

    @Enumerated(EnumType.STRING)
    @Column(name = "usage_purpose")
    private UsagePurpose usagePurpose; // 서비스 사용 용도

    @Column(name = "nickname")
    private String nickname; // 사용자 닉네임

    @Column(name = "profile_image")
    private String profileImage; // 프로필 사진 URL

    @Column(name = "birth_date")
    private LocalDate birthDate; // 생년월일

    @Enumerated(EnumType.STRING)
    @Column(name = "advice_tone")
    private AdviceTone adviceTone; // AI 조언 말투

    @Column(name = "music_style")
    private String musicStyle; // 선호하는 음악 종류

    @Enumerated(EnumType.STRING)
    @Column(name = "persona_style")
    private PersonaStyle personaStyle; // 기존 필드 유지

    @Column(name = "is_ai_analysis_enabled", nullable = false)
    @Builder.Default
    private boolean isAiAnalysisEnabled = true; // AI 분석 활성화 여부

    public void update(LocalTime diaryTime, LocalTime wakeUpTime, UsagePurpose usagePurpose, 
                       String nickname, String profileImage, LocalDate birthDate, 
                       AdviceTone adviceTone, String musicStyle, PersonaStyle personaStyle,
                       Boolean isAiAnalysisEnabled) {
        this.diaryTime = diaryTime;
        this.wakeUpTime = wakeUpTime;
        this.usagePurpose = usagePurpose;
        this.nickname = nickname;
        this.profileImage = profileImage;
        this.birthDate = birthDate;
        this.adviceTone = adviceTone;
        this.musicStyle = musicStyle;
        this.personaStyle = personaStyle;
        if (isAiAnalysisEnabled != null) {
            this.isAiAnalysisEnabled = isAiAnalysisEnabled;
        }
    }

    public void updateAiAnalysis(boolean isAiAnalysisEnabled) {
        this.isAiAnalysisEnabled = isAiAnalysisEnabled;
    }
}
