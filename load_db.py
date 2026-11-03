import os
import psycopg2
from dotenv import load_dotenv

# Load variables from .env
load_dotenv()
db_url = os.getenv("DATABASE_URL")

if not db_url:
    raise ValueError("DATABASE_URL is missing from your .env file!")

print("Connecting to Railway Postgres database...")
conn = psycopg2.connect(db_url)
cur = conn.cursor()

print("Executing schema.sql...")
with open("schema.sql", "r") as f:
    cur.execute(f.read())

conn.commit()
print("Success! Schema deployed and sample data loaded into Railway.")

cur.close()
conn.close()