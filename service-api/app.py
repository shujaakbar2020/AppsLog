from flask import Flask, render_template, jsonify, request
import requests
import os
import pwd
import tzlocal
from flask_cors import CORS
import psycopg2


app = Flask(__name__)
CORS(app)

# --- PostgreSQL Connection Config ---
DB_CONFIG = {
    "host": os.getenv("DB_HOST"),
    "port": os.getenv("DB_PORT"),
    "dbname": os.getenv("POSTGRES_DB"),
    "user": os.getenv("POSTGRES_USER"),
    "password": os.getenv("POSTGRES_PASSWORD")
}

def get_db_connection():
    return psycopg2.connect(**DB_CONFIG)

@app.route("/")
def hello():
    with open("/etc/hostname", "r") as f:
        container_id = f.read().strip()
    container_username = pwd.getpwuid(os.getuid()).pw_name
    availability_zone = 'UTC'
    meta = {
        'container_id': container_id,
        'container_username': container_username,
        'availability_zone': availability_zone
    }

    # return render_template("index.html", meta=meta)
    return jsonify(meta)

@app.route("/save", methods=["POST"])
def save():
    print("Data inserted...")
    data = request.get_json()
    container_id = data.get("container_id")
    container_username = data.get("container_username")
    availability_zone = data.get("availability_zone")

    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            """
            INSERT INTO container_data (container_id, container_username, availability_zone)
            VALUES (%s, %s, %s)
            """,
            (container_id, container_username, availability_zone)
        )
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"status": "success", "message": "Data saved to PostgreSQL!"})
    except Exception as e:
        print("Database error:", e)
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)