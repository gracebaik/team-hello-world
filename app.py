import os
import psycopg2
from psycopg2.extras import RealDictCursor
from flask import Flask, render_template, request
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

def get_db_connection():
    db_url = os.getenv("DATABASE_URL")
    if not db_url:
        raise ValueError("DATABASE_URL environment variable is missing.")
    return psycopg2.connect(db_url)

@app.route("/", methods=["GET", "POST"])
def index():
    selected_precinct = request.form.get("precinct", "")
    
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=RealDictCursor)

    # 1. Derived Metric: Total complaint count
    cur.execute("SELECT COUNT(*) AS total_complaints FROM nypd_complaints;")
    total_count = cur.fetchone()["total_complaints"]

    # 2. Derived Metric: Count by Law Category
    cur.execute("""
        SELECT law_category, COUNT(*) as count 
        FROM nypd_complaints 
        GROUP BY law_category 
        ORDER BY count DESC;
    """)
    category_stats = cur.fetchall()

    # 3. User Input Query: Filter complaints by Precinct if selected
    filtered_complaints = []
    if selected_precinct:
        cur.execute("""
            SELECT complaint_id, complaint_date, offense, law_category, premises 
            FROM nypd_complaints 
            WHERE precinct = %s;
        """, (selected_precinct,))
        filtered_complaints = cur.fetchall()

    # Get list of unique precincts for dropdown selection
    cur.execute("SELECT DISTINCT precinct FROM nypd_complaints ORDER BY precinct;")
    precincts = [row["precinct"] for row in cur.fetchall() if row["precinct"] is not None]

    cur.close()
    conn.close()

    return render_template(
        "index.html",
        total_count=total_count,
        category_stats=category_stats,
        precincts=precincts,
        selected_precinct=selected_precinct,
        filtered_complaints=filtered_complaints
    )

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)