from flask import Flask, request, jsonify
import psycopg2
import pandas as pd

app = Flask(__name__)

def connect_db():
    return psycopg2.connect(
        host="db",
        port=5432,
        user="postgres",
        password="postgres",
        database="measurements"
    )

@app.route("/insert", methods=["POST"])
def insert():
    data = request.json
    try:
        with connect_db() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    INSERT INTO measurements (temperature, humidity, pressure)
                    VALUES (%s, %s, %s)
                """, (data["temperature"], data["humidity"], data["pressure"]))
        return jsonify({"status": "ok"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/latest", methods=["GET"])
def latest():
    """Vrací posledních 10 měření jako JSON seznam."""
    try:
        conn = connect_db()
        df = pd.read_sql_query(
            "SELECT * FROM measurements ORDER BY timestamp DESC LIMIT 10",
            conn
        )
        return jsonify(df.to_dict(orient="records"))
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/health")
def health():
    return jsonify({"status": "backend ok"})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
