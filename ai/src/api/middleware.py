import time
import uuid
import logging
import json
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from pythonjsonlogger import jsonlogger

# JSON 로거 설정
logger = logging.getLogger("ai_server")
logger.setLevel(logging.INFO)

if not logger.handlers:
    logHandler = logging.StreamHandler()
    formatter = jsonlogger.JsonFormatter('%(timestamp)s %(level)s %(correlation_id)s %(message)s')
    logHandler.setFormatter(formatter)
    logger.addHandler(logHandler)

def mask_sensitive_data(data: dict) -> dict:
    """민감 정보(예: content, API Key 등) 마스킹"""
    masked_data = data.copy()
    sensitive_keys = ["content", "voice_url", "api_key", "password"]
    for key in sensitive_keys:
        if key in masked_data and isinstance(masked_data[key], str):
            masked_data[key] = "***MASKED***"
    return masked_data

class CorrelationIdMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        correlation_id = request.headers.get("X-Correlation-ID", str(uuid.uuid4()))
        request.state.correlation_id = correlation_id
        
        start_time = time.time()
        
        # Logging start
        logger.info(
            "Request started",
            extra={
                "correlation_id": correlation_id,
                "method": request.method,
                "url": str(request.url),
                "timestamp": time.time()
            }
        )
        
        response = await call_next(request)
        
        process_time = time.time() - start_time
        response.headers["X-Correlation-ID"] = correlation_id
        
        # Logging end
        logger.info(
            "Request completed",
            extra={
                "correlation_id": correlation_id,
                "method": request.method,
                "url": str(request.url),
                "status_code": response.status_code,
                "latency_sec": process_time,
                "timestamp": time.time()
            }
        )
        
        return response
