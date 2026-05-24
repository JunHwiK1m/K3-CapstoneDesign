import pytest
from unittest.mock import patch, MagicMock
from src.ai.stt_service import STTService

def test_stt_transcribe():
    """STT 변환 단위 테스트"""
    with patch("src.ai.stt_service.whisper") as mock_whisper:
        mock_model = MagicMock()
        mock_model.transcribe.return_value = {"text": "안녕하세요 반갑습니다."}
        mock_whisper.load_model.return_value = mock_model
        mock_whisper.is_none = False # whisper가 있는 것처럼 동작
        
        # 실제 파일 존재 여부 체크를 우회하기 위해 patch
        with patch("src.ai.stt_service.os.path.exists", return_value=True):
            service = STTService()
            # service.model이 None이 되지 않도록 강제 설정 (테스트용)
            service.model = mock_model
            result = service.transcribe("fake_audio.wav")
            
            assert result == "안녕하세요 반갑습니다."
