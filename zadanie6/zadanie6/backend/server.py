from fastapi import FastAPI
from pydantic import BaseModel
import time
import uuid

app = FastAPI()

class PayRequest(BaseModel):
    full_name: str
    card_number: str
    expiry: str
    cvc: str
    amount: str

class PayResponse(BaseModel):
    status: str
    transaction_id: str
    message: str

@app.post("/pay", response_model=PayResponse)
def pay(req: PayRequest):
    time.sleep(0.6)

    digits = "".join([c for c in req.card_number if c.isdigit()])
    if len(digits) < 12:
        return PayResponse(status="failed", transaction_id="", message="Card number too short")

    return PayResponse(status="success", transaction_id=str(uuid.uuid4()), message="Approved")
