import time
import random
import requests

BACKEND_URL = "http://backend:5000/insert"

def generate_measurement():
    return {
        "temperature": random.uniform(15, 30),
        "humidity": random.uniform(0.30, 0.80),
        "pressure": random.uniform(990, 1040),
    }

def main():
    print("Ingestion running..")

    while True:
        data = generate_measurement()
        try:
            r = requests.post(BACKEND_URL, json=data)
            print("Sent:", data, "| Backend response:", r.status_code, flush=True)
        except Exception as e:
            print("Error:", e, flush=True)
        time.sleep(1)

if __name__ == "__main__":
    main()
