import os
import sys
import time
from src.models.db_entities import Journal
from src.service.orchestrator import Orchestrator

def run_realtime_call_mode(orchestrator):
    """실시간 대화 + 대화 종료 후 종합 분석 모드"""
    print("\n" + "📞"*20)
    print("      🌟 AI 감정 케어 실시간 통화 🌟")
    print("      (종료하려면 '그만' 혹은 '종료'라고 말씀하세요)")
    print("📞"*20 + "\n")

    # 대화 내용을 담을 버퍼
    conversation_history = []

    # 1. 인사
    orchestrator.audio_service.speak_live("안녕하세요! 오늘 하루는 어떠셨나요? 무슨 일이 있었는지 편하게 들려주세요.")

    while True:
        try:
            # 2. 말씀 듣기
            user_text = orchestrator.audio_service.listen_live()
            if not user_text or not user_text.strip(): continue
            
            # 대화 기록에 저장
            conversation_history.append(f"사용자: {user_text}")

            # 3. 종료 조건 확인 (오타 및 유사어 대폭 추가)
            end_keywords = [
                "그만", "종료", "중료", "안녕", "잘 가", "끝내자", 
                "수고", "바이", "다음에", "여기까지", "고마워", "됐어"
            ]
            if any(word in user_text for word in end_keywords):
                orchestrator.audio_service.speak_live("오늘 이야기 들려주셔서 감사해요. 방금 나눈 대화를 바탕으로 리포트를 작성해 드릴게요.")
                break

            # 4. 실시간 응답
            ai_reply = orchestrator.emotion_analyzer.chat(user_text)
            conversation_history.append(f"AI: {ai_reply}")
            orchestrator.audio_service.speak_live(ai_reply)

            # 만약 AI가 작별 인사를 했다면 자동으로 종료
            if any(word in ai_reply for word in ["잘 가요", "편히 쉬세요", "안녕히"]):
                print("\n[알림] AI가 대화가 끝난 것으로 판단했습니다.")
                break

        except Exception as e:
            print(f"⚠️ 대화 중 오류 발생: {e}")
            break

    # 5. [중요] 통화 종료 후 종합 분석 실행
    if conversation_history:
        print("\n" + "="*50)
        print("📊 [오늘의 대화 종합 분석 리포트]")
        print("="*50)
        
        full_context = "\n".join(conversation_history)
        # 전체 대화 내용을 Journal 객체로 변환하여 분석 요청
        final_journal = Journal(content=full_context)
        result = orchestrator.run_analysis(final_journal, categories=["MUSIC", "FOOD", "MOVIE"])

        if result["status"] == "COMPLETED":
            emotion = result["emotion"]
            print(f"\n📈 감정 흐름 지표")
            print(f"- 기쁨: {emotion.get('joy_score', 0):.2f} | 슬픔: {emotion.get('sadness_score', 0):.2f} | 스트레스: {emotion.get('stress_level', 0):.2f}")
            print(f"\n📝 AI의 종합 소견")
            print(f"> {emotion.get('emotion_summary', '')}")
            
            print(f"\n🎁 추천하는 마음 선물")
            for item in result["recommendation"].get("recommendations", []):
                link = f" ({item['external_link']})" if item.get('external_link') else ""
                print(f"  {item['category']}: {item['content_text']}{link}")
        else:
            print("❌ 최종 분석 리포트 작성에 실패했습니다.")
        
        print("\n" + "="*50)
        print("👋 통화가 완전히 종료되었습니다. 편안한 시간 되세요!")

def run_interactive_demo():
    orchestrator = Orchestrator()
    print("\n========================================")
    print("   🌟 능동형 AI 감정 케어 에이전트 🌟")
    print("========================================\n")
    print("1. 일반 모드 (텍스트 입력)")
    print("2. 실시간 대화 모드 (대화 후 분석)")
    print("선택: ", end="")
    mode = sys.stdin.readline().strip()
    if mode == "2":
        run_realtime_call_mode(orchestrator)
    else:
        print("\n텍스트 모드는 준비 중입니다. 2번을 선택해 보세요!")

if __name__ == "__main__":
    run_interactive_demo()
