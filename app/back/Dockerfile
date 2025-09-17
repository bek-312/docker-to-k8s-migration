# app/back/Dockerfile
FROM python:3.6
WORKDIR /app
COPY requirements.txt /app
RUN pip install -r requirements.txt
COPY back.py /app
EXPOSE 3000
CMD ["python", "back.py"]