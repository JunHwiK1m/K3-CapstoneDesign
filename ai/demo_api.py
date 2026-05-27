import httpx
import asyncio
import json
import time

async def main():
    async with httpx.AsyncClient(base_url="http://localhost:8000/api/ai") as client:
        print("=== 1. 일기 분석(Journal Analysis) 테스트 ===")
        journal_payload = {
            "journal_id": 101,
            "content": "오늘 정말 피곤한 하루였어. 너무 늦게까지 일했거든. 내일은 푹 쉬고 싶다.",
            "persona_style": "FRIENDLY"
        }
        start = time.time()
        res1 = await client.post("/journals", json=journal_payload)
        latency1 = time.time() - start
        
        print(f"Status: {res1.status_code}, Latency: {latency1:.2f}s")
        print(json.dumps(res1.json(), indent=2, ensure_ascii=False))

        print("\n=== 2. Todo 피드백(Todo Feedback) 테스트 ===")
        todo_payload = {
            "totalCount": 10,
            "completedCount": 8,
            "completionRate": 0.8,
            "personaStyle": "STRICT",
            "recentEmotion": "STRESS"
        }
        start = time.time()
        res2 = await client.post("/todos/feedback", json=todo_payload)
        latency2 = time.time() - start
        
        print(f"Status: {res2.status_code}, Latency: {latency2:.2f}s")
        print(json.dumps(res2.json(), indent=2, ensure_ascii=False))

if __name__ == "__main__":
    asyncio.run(main())
