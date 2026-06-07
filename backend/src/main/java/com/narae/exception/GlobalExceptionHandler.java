package com.narae.exception;

import com.narae.common.CommonResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    protected ResponseEntity<CommonResponse<Void>> handleBusinessException(BusinessException e) {
        log.error("handleBusinessException: {}", e.getErrorCode());
        ErrorCode errorCode = e.getErrorCode();
        return ResponseEntity
                .status(errorCode.getStatus())
                .body(CommonResponse.fail(errorCode.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    protected ResponseEntity<CommonResponse<Void>> handleMethodArgumentNotValidException(MethodArgumentNotValidException e) {
        log.error("handleMethodArgumentNotValidException: {}", e.getMessage());
        return ResponseEntity
                .status(ErrorCode.INVALID_INPUT_VALUE.getStatus())
                .body(CommonResponse.fail(ErrorCode.INVALID_INPUT_VALUE.getMessage()));
    }

    @ExceptionHandler(Exception.class)
    protected ResponseEntity<CommonResponse<Void>> handleException(Exception e) {
        log.error("handleException", e);
        return ResponseEntity
                .status(ErrorCode.INTERNAL_SERVER_ERROR.getStatus())
                .body(CommonResponse.fail(ErrorCode.INTERNAL_SERVER_ERROR.getMessage()));
    }
}
