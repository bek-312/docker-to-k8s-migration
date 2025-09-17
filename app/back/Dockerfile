# app/back/Dockerfile
FROM python:3.6-slim

# add build tooling and headers needed for cffi/cryptography
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc libffi-dev libssl-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt /app
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY back.py /app
EXPOSE 3000
CMD ["python", "back.py"]