import streamlit as st
import requests
import pandas as pd

BACKEND_URL = "http://backend:5000/latest"

st.title("Measurement Dashboard")

st.write("Poslední měření (přes backend API):")

def load_measurements():
    r = requests.get(BACKEND_URL)
    if r.status_code == 200:
        return pd.DataFrame(r.json())
    else:
        raise Exception(f"Backend error {r.status_code}: {r.text}")

try:
    df = load_measurements()
    column_order = ["id", "timestamp", "temperature", "humidity", "pressure"]
    df = df[column_order]   # reorder columns

    st.table(df)
except Exception as e:
    st.error(f"Nelze načíst data: {e}")
