package com.narae.service;

import com.narae.dto.journal.JournalCreateRequest;
import com.narae.entity.Journal;
import com.narae.entity.User;
import com.narae.exception.BusinessException;
import com.narae.repository.JournalRepository;
import com.narae.repository.UserRepository;
import com.narae.util.AESUtil;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
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
    private AESUtil aesUtil;

    @Test
    @DisplayName("일기 생성 및 분석 요청 테스트")
    void createJournalTest() {
        // Given
        Long userId = 1L;
        User user = User.builder().id(userId).build();
        JournalCreateRequest request = JournalCreateRequest.builder()
                .content("Test Content")
                .imageUrls(List.of("http://example.com/image.jpg"))
                .build();
        
        Journal journal = Journal.builder()
                .id(100L)
                .user(user)
                .content("encrypted")
                .imageUrls(List.of("http://example.com/image.jpg"))
                .build();
        
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
}
