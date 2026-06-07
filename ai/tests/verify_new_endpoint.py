from fastapi.testclient import TestClient
from src.main import app

client = TestClient(app)

def test_daily_message():
    response = client.get("/api/ai/daily-message")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    print(f"\n[Test Success] Received Message: {data['message']}")

if __name__ == "__main__":
    test_daily_message()
