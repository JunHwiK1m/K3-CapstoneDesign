package com.leafy.controller;

import com.leafy.common.CommonResponse;
import com.leafy.dto.todo.TodoRequest;
import com.leafy.dto.todo.TodoResponse;
import com.leafy.security.JwtTokenProvider;
import com.leafy.service.TodoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Todo", description = "할 일 관리 API")
@RestController
@RequestMapping("/api/todos")
@RequiredArgsConstructor
public class TodoController {

    private final TodoService todoService;
    private final JwtTokenProvider jwtTokenProvider;

    @Operation(summary = "할 일 생성", description = "새로운 태스크를 생성합니다.")
    @PostMapping
    public CommonResponse<Long> createTodo(@Valid @RequestBody TodoRequest request, Authentication authentication) {
        Long userId = getUserId(authentication);
        return CommonResponse.success("태스크가 생성되었습니다.", todoService.createTodo(userId, request));
    }

    @Operation(summary = "내 할 일 목록 조회", description = "사용자의 모든 할 일 목록을 조회합니다.")
    @GetMapping
    public CommonResponse<List<TodoResponse>> getMyTodos(Authentication authentication) {
        Long userId = getUserId(authentication);
        return CommonResponse.success(todoService.getMyTodos(userId));
    }

    @Operation(summary = "할 일 수정", description = "태스크명 또는 마감 기한을 수정합니다.")
    @PutMapping("/{todoId}")
    public CommonResponse<Void> updateTodo(
            @PathVariable Long todoId,
            @Valid @RequestBody TodoRequest request,
            Authentication authentication) {
        Long userId = getUserId(authentication);
        todoService.updateTodo(userId, todoId, request);
        return CommonResponse.success("태스크가 수정되었습니다.", null);
    }

    @Operation(summary = "할 일 완료 처리", description = "태스크를 완료 상태로 변경합니다.")
    @PatchMapping("/{todoId}/complete")
    public CommonResponse<Void> completeTodo(@PathVariable Long todoId, Authentication authentication) {
        Long userId = getUserId(authentication);
        todoService.completeTodo(userId, todoId);
        return CommonResponse.success("태스크를 완료했습니다.", null);
    }

    @Operation(summary = "할 일 삭제", description = "태스크를 삭제합니다.")
    @DeleteMapping("/{todoId}")
    public CommonResponse<Void> deleteTodo(@PathVariable Long todoId, Authentication authentication) {
        Long userId = getUserId(authentication);
        todoService.deleteTodo(userId, todoId);
        return CommonResponse.success("태스크가 삭제되었습니다.", null);
    }

    private Long getUserId(Authentication authentication) {
        String token = (String) authentication.getCredentials();
        return jwtTokenProvider.getUserId(token);
    }
}
