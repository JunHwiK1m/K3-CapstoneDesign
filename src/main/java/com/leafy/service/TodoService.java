package com.leafy.service;

import com.leafy.dto.todo.TodoRequest;
import com.leafy.dto.todo.TodoResponse;
import com.leafy.entity.Todo;
import com.leafy.entity.User;
import com.leafy.exception.BusinessException;
import com.leafy.exception.ErrorCode;
import com.leafy.repository.TodoRepository;
import com.leafy.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TodoService {

    private final TodoRepository todoRepository;
    private final UserRepository userRepository;

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
