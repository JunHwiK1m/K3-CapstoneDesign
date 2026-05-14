package com.leafy.service;

import com.leafy.dto.journal.JournalCreateRequest;
import com.leafy.dto.journal.JournalDetailResponse;
import com.leafy.entity.Journal;
import com.leafy.entity.User;
import com.leafy.exception.BusinessException;
import com.leafy.repository.JournalRepository;
import com.leafy.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class JournalServiceTest {

    @InjectMocks
    private JournalService journalService;

    @Mock
    private JournalRepository journalRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private AsyncAnalysisService asyncAnalysisService;

    @Mock
    private com.leafy.util.AESUtil aesUtil;

    @Test
    @DisplayName("일기 생성 및 분석 요청 테스트")
    void createJournalTest() {
        // Given
        Long userId = 1L;
        User user = User.builder().id(userId).build();
        JournalCreateRequest request = new JournalCreateRequest();
        setPrivateField(request, "content", "Test Content");
        
        Journal journal = Journal.builder().id(100L).user(user).content("encrypted").build();
        
        given(userRepository.findById(userId)).willReturn(Optional.of(user));
        given(aesUtil.encrypt("Test Content")).willReturn("encrypted");
        given(journalRepository.save(any(Journal.class))).willReturn(journal);

        // When
        Long journalId = journalService.createJournal(userId, request);

        // Then
        assertThat(journalId).isEqualTo(100L);
        verify(asyncAnalysisService, times(1)).analyzeJournal(100L);
    }

    @Test
    @DisplayName("타인의 일기 조회 시 예외 발생 테스트")
    void getOtherUserJournalTest() {
        // Given
        Long userId = 1L;
        Long otherUserId = 2L;
        User otherUser = User.builder().id(otherUserId).build();
        Journal journal = Journal.builder().id(100L).user(otherUser).build();
        
        given(journalRepository.findById(100L)).willReturn(Optional.of(journal));

        // When & Then
        assertThatThrownBy(() -> journalService.getJournal(userId, 100L))
                .isInstanceOf(BusinessException.class);
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
