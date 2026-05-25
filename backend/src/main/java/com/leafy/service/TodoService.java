package com.leafy.service;

import com.leafy.client.AiServerClient;
import com.leafy.dto.ai.TodoAnalysisRequest;
import com.leafy.dto.ai.TodoAnalysisResponse;
import com.leafy.dto.todo.TodoRequest;
import com.leafy.dto.todo.TodoResponse;
import com.leafy.dto.todo.TodoStatsResponse;
import com.leafy.entity.AnalysisStatus;
import com.leafy.entity.PersonaStyle;
import com.leafy.entity.Todo;
import com.leafy.entity.User;
import com.leafy.exception.BusinessException;
import com.leafy.exception.ErrorCode;
import com.leafy.repository.EmotionRepository;
import com.leafy.repository.JournalRepository;
import com.leafy.repository.TodoRepository;
import com.leafy.repository.UserRepository;
import com.leafy.repository.UserSettingsRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TodoService {

    private final TodoRepository todoRepository;
    private final UserRepository userRepository;
    private final UserSettingsRepository userSettingsRepository;
    private final JournalRepository journalRepository;
    private final EmotionRepository emotionRepository;
    private final AiServerClient aiServerClient;

    @Transactional
    public Long createTodo(Long userId, TodoRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        Todo todo = Todo.builder()
                .user(user)
                .taskName(request.getTaskName())
                .dueDate(request.getDueDate())
                .build();

        return todoRepository.save(todo).getId();
    }

    public List<TodoResponse> getMyTodos(Long userId) {
        return todoRepository.findAllByUserIdOrderByDueDateAsc(userId).stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public TodoStatsResponse getTodoStats(Long userId) {
        List<Todo> todos = todoRepository.findAllByUserIdOrderByDueDateAsc(userId);
        long totalCount = todos.size();
        long completedCount = todos.stream().filter(Todo::isCompleted).count();
        
        BigDecimal rate = totalCount == 0 ? BigDecimal.ZERO : 
            BigDecimal.valueOf(completedCount).divide(BigDecimal.valueOf(totalCount), 4, java.math.RoundingMode.HALF_UP);

        String feedback = getAiFeedback(userId, totalCount, completedCount, rate);
        
        return TodoStatsResponse.of(totalCount, completedCount, feedback);
    }

    private String getAiFeedback(Long userId, long total, long completed, BigDecimal rate) {
        try {
            // 1. 페르소나 스타일 조회
            String personaStyle = userSettingsRepository.findByUserId(userId)
                    .map(s -> s.getPersonaStyle().name())
                    .orElse(PersonaStyle.BASIC.name());

            // 2. 가장 최근의 분석 완료된 일기 감정 조회
            String recentEmotion = journalRepository.findAllByUserIdOrderByCreatedAtDesc(userId).stream()
                    .filter(j -> j.getAnalysisStatus() == AnalysisStatus.COMPLETED)
                    .findFirst()
                    .flatMap(j -> emotionRepository.findByJournalId(j.getId()))
                    .map(e -> {
                        if (e.getJoyScore().compareTo(e.getSadnessScore()) >= 0) return "JOY";
                        return "SADNESS";
                    })
                    .orElse("NEUTRAL");

            // 3. AI 서버 요청
            TodoAnalysisRequest request = TodoAnalysisRequest.builder()
                    .totalCount(total)
                    .completedCount(completed)
                    .completionRate(rate)
                    .personaStyle(personaStyle)
                    .recentEmotion(recentEmotion)
                    .build();

            TodoAnalysisResponse response = aiServerClient.analyzeTodo(request);
            return response.feedbackMessage();
        } catch (Exception e) {
            log.error("Failed to get AI feedback for todo stats. userId: {}", userId, e);
            return "오늘 하루도 수고 많으셨어요. 당신의 성장을 리피가 응원합니다! 🌿";
        }
    }

    @Transactional
    public void updateTodo(Long userId, Long todoId, TodoRequest request) {
        Todo todo = findAndValidateOwner(userId, todoId);
        todo.updateTask(request.getTaskName(), request.getDueDate());
    }

    @Transactional
    public void completeTodo(Long userId, Long todoId) {
        Todo todo = findAndValidateOwner(userId, todoId);
        todo.complete();
    }

    @Transactional
    public void deleteTodo(Long userId, Long todoId) {
        Todo todo = findAndValidateOwner(userId, todoId);
        todoRepository.delete(todo);
    }

    private Todo findAndValidateOwner(Long userId, Long todoId) {
        Todo todo = todoRepository.findById(todoId)
                .orElseThrow(() -> new BusinessException(ErrorCode.INVALID_INPUT_VALUE));

        if (!todo.getUser().getId().equals(userId)) {
            throw new BusinessException(ErrorCode.ACCESS_DENIED);
        }
        return todo;
    }

    private TodoResponse convertToResponse(Todo todo) {
        return TodoResponse.builder()
                .id(todo.getId())
                .taskName(todo.getTaskName())
                .isCompleted(todo.isCompleted())
                .dueDate(todo.getDueDate())
                .completedAt(todo.getCompletedAt())
                .build();
    }
}
