CREATE TABLE IF NOT EXISTS measurements (
    id SERIAL PRIMARY KEY,
    temperature FLOAT,
    humidity FLOAT,
    pressure FLOAT,
    timestamp TIMESTAMP DEFAULT NOW()
);
