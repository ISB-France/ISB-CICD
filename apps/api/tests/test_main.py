from httpx import Client, ASGITransport
from src.main import app


def test_health():
    transport = ASGITransport(app=app)
    with Client(transport=transport, base_url="http://test") as client:
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json() == {"status": "ok"}


def test_get_data():
    transport = ASGITransport(app=app)
    with Client(transport=transport, base_url="http://test") as client:
        response = client.get("/api/v1/data")
        assert response.status_code == 200
        assert len(response.json()["items"]) == 3
