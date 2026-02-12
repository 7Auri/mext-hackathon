FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY product_analysis_agent.py .
COPY test_input_valid.json .

EXPOSE 8080

ENTRYPOINT ["python", "product_analysis_agent.py"]
