from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import secrets

app = FastAPI()

USERS = {
    "admin@admin.com": "admin",
    "jakub@gmail.com": "123qwe"
}

SESSIONS = {}

class LoginRequest(BaseModel):
    email: str
    password: str

@app.get("/")
def root():
    return {"ok": True, "message": "Backend dziala"}

@app.post("/login")
def login(body: LoginRequest):
    email = body.email.strip().lower()
    password = body.password

    if email not in USERS or USERS[email] != password:
        raise HTTPException(status_code=401, detail="Niepoprawny email lub hasło")

    token = secrets.token_hex(16)
    SESSIONS[token] = email
    return {"token": token}
