from fastapi.testclient import TestClient
from src.main import app

client = TestClient(app)


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_get_data():
    response = client.get("/api/v1/data")
    assert response.status_code == 200
    assert len(response.json()["items"]) == 3
