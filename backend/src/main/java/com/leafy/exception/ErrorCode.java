package com.leafy.exception;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum ErrorCode {

    // Common
    INVALID_INPUT_VALUE(HttpStatus.BAD_REQUEST, "C001", "잘못된 입력값입니다."),
    METHOD_NOT_ALLOWED(HttpStatus.METHOD_NOT_ALLOWED, "C002", "지원하지 않는 HTTP 메서드입니다."),
    INTERNAL_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "C003", "서버 내부 오류가 발생했습니다."),
    
    // Auth
    UNAUTHORIZED(HttpStatus.UNAUTHORIZED, "A001", "인증되지 않은 사용자입니다."),
    ACCESS_DENIED(HttpStatus.FORBIDDEN, "A002", "접근 권한이 없습니다."),
    LOGIN_FAILED(HttpStatus.BAD_REQUEST, "A003", "이메일 또는 비밀번호가 일치하지 않습니다."),
    
    // Domain
    USER_NOT_FOUND(HttpStatus.NOT_FOUND, "U001", "사용자를 찾을 수 없습니다."),
    JOURNAL_NOT_FOUND(HttpStatus.NOT_FOUND, "J001", "일기를 찾을 수 없습니다.");

    private final HttpStatus status;
    private final String code;
    private final String message;
}
