import os
import time
from contextlib import asynccontextmanager

import asyncpg
from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

load_dotenv()

DB_HOST     = os.getenv("DB_HOST", "localhost")
DB_PORT     = int(os.getenv("DB_PORT", 5432))
DB_NAME     = os.getenv("DB_NAME", "devops_training")
DB_USER     = os.getenv("DB_USER", "devops_user")
DB_PASSWORD = os.getenv("DB_PASSWORD", "devops_password")
PORT        = int(os.getenv("PORT", 3000))

START_TIME  = time.time()
pool: asyncpg.Pool | None = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    global pool
    pool = await asyncpg.create_pool(
        host=DB_HOST, port=DB_PORT,
        database=DB_NAME, user=DB_USER, password=DB_PASSWORD,
        min_size=2, max_size=10,
    )
    print(f"Kết nối PostgreSQL thành công! ({DB_HOST}:{DB_PORT}/{DB_NAME})")
    yield
    await pool.close()


app = FastAPI(title="DevOps Training API", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/api/health")
async def health():
    return {"status": "ok", "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())}


@app.get("/api/message")
async def get_message():
    row = await pool.fetchrow("SELECT content FROM messages ORDER BY id LIMIT 1")
    msg = row["content"] if row else "Chào mừng bạn đến với khoá DevOps Training!"
    return {"message": msg}


@app.get("/api/info")
async def info():
    import sys, platform
    row = await pool.fetchrow("SELECT version()")
    return {
        "app":             "DevOps Training App",
        "version":         "1.0.0",
        "python_version":  sys.version,
        "platform":        platform.system(),
        "db_version":      row["version"],
        "uptime_seconds":  int(time.time() - START_TIME),
    }
