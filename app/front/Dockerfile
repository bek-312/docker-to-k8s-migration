FROM python:3.6

WORKDIR /app

COPY requirements.txt /app

RUN pip install -r /app/requirements.txt

COPY . /app

EXPOSE 3001

CMD ["python", "front.py"]