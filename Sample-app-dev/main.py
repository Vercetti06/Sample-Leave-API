import os
import psycopg2
from fastapi import FastAPI

app = FastAPI()

# Read the database URL from an environment variable.
# os.getenv() looks for a variable named DATABASE_URL in the environment.
# If it's not set, it falls back to the default value (the string after the comma).
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:password@localhost:5432/leavedb"
)

@app.get("/health")
def health():
    # Try to connect to the database.
    # If it works, report healthy. If it fails, report what went wrong.
    try:
        conn = psycopg2.connect(DATABASE_URL)
        conn.close()
        return {"status": "ok", "database": "reachable"}
    except Exception as e:
        return {"status": "degraded", "database": str(e)}

@app.get("/leaves")
def leaves():
    return [
        {"type": "general", "days": 12},
        {"type": "earned", "days": 8.5},
        {"type": "festival", "days": 5}
    ]
