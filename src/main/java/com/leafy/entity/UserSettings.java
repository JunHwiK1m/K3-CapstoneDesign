package com.leafy.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;

@Entity
@Table(name = "user_settings")
@Getter
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

    @Column(name = "reminder_time")
    private LocalTime reminderTime;

    @Enumerated(EnumType.STRING)
    @Column(name = "usage_purpose")
    private UsagePurpose usagePurpose;

    @Enumerated(EnumType.STRING)
    @Column(name = "persona_style")
    private PersonaStyle personaStyle;

    @Column(name = "birth_date")
    private LocalDate birthDate;

    public void update(LocalTime reminderTime, UsagePurpose usagePurpose, PersonaStyle personaStyle, LocalDate birthDate) {
        this.reminderTime = reminderTime;
        this.usagePurpose = usagePurpose;
        this.personaStyle = personaStyle;
        this.birthDate = birthDate;
    }
}
