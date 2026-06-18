from fastapi import FastAPI

app = FastAPI(title="Backend Service")


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/")
def root():
    return {"service": "backend", "version": "1.0.0"}
