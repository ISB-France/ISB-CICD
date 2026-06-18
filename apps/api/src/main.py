from fastapi import FastAPI

app = FastAPI(title="API Service")


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/api/v1/data")
def get_data():
    return {"items": ["item1", "item2", "item3"]}
