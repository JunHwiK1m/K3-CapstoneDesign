from fastapi import FastAPI
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from src.api.routes import router as api_router
from src.api.middleware import CorrelationIdMiddleware

limiter = Limiter(key_func=get_remote_address, default_limits=["120/minute"])

app = FastAPI(title="AI Emotional Care API")

# Rate Limiter 설정
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Middleware 설정
app.add_middleware(CorrelationIdMiddleware)

app.include_router(api_router)
