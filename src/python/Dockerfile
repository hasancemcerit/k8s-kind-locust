FROM python:alpine3.18

WORKDIR /app

COPY . /app

RUN pip install -r requirements.txt

EXPOSE 80

CMD ["gunicorn", "wsgi:app", "--bind", "0.0.0.0:80", "--workers", "4", "--preload"]