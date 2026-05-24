import os
import whisper
import speech_recognition as sr
from openai import OpenAI
from src.config.ai_config import ai_config
from pydub import AudioSegment
import winsound
import warnings
import time

warnings.filterwarnings("ignore")

class AudioService:
    """대화 호흡을 길게 가져가는 윈도우 최적화 오디오 서비스"""
    
    def __init__(self):
        self.client = OpenAI(api_key=ai_config.api_key)
        self.recognizer = sr.Recognizer()
        
        # --- 침묵 감지 파라미터 대폭 완화 ---
        self.recognizer.pause_threshold = 2.5        # 말이 끝나고 2.5초간 침묵해야 인식을 마침
        self.recognizer.phrase_threshold = 0.5      # 최소 0.5초 이상의 소리만 인지
        self.recognizer.non_speaking_duration = 1.0  # 말 사이의 짧은 공백 허용 시간
        # ------------------------------------
        
        self.stt_model = None
        self.microphone = None
        
        try:
            self.microphone = sr.Microphone()
            with self.microphone as source:
                self.recognizer.adjust_for_ambient_noise(source, duration=1.0)
            self.microphone_available = True
        except Exception:
            self.microphone_available = False

        print("[시스템] Whisper 모델 로드 중...")
        self.stt_model = whisper.load_model("base")
        print("✅ 시스템 준비 완료")
        
    def listen_live(self) -> str:
        """여유 있는 호흡으로 말씀을 듣습니다."""
        if not self.microphone: return ""
        try:
            with self.microphone as source:
                print("\n👂 듣고 있어요... (충분히 말씀하신 뒤 잠시 기다려 주세요)")
                audio_data = self.recognizer.listen(source, timeout=None, phrase_time_limit=None)
            
            temp_file = "temp_input.wav"
            with open(temp_file, "wb") as f:
                f.write(audio_data.get_wav_data())
            
            result = self.stt_model.transcribe(temp_file, fp16=False)
            if os.path.exists(temp_file): os.remove(temp_file)
            
            text = result["text"].strip()
            if text: print(f"👤 나: {text}")
            return text
        except Exception:
            return ""

    def speak_live(self, text: str):
        """AI 목소리 출력"""
        print(f"\n🤖 AI: {text}")
        temp_mp3, temp_wav = "temp_voice.mp3", "temp_voice.wav"
        try:
            response = self.client.audio.speech.create(model="tts-1", voice="nova", input=text)
            response.stream_to_file(temp_mp3)
            AudioSegment.from_file(temp_mp3, format="mp3").export(temp_wav, format="wav")
            winsound.PlaySound(temp_wav, winsound.SND_FILENAME)
            if os.path.exists(temp_mp3): os.remove(temp_mp3)
            if os.path.exists(temp_wav): os.remove(temp_wav)
        except Exception as e:
            print(f"🔊 (음성 재생 오류: {e})")
