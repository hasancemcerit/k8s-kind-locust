ARG VERSION=alpine3.20
FROM python:${VERSION}

WORKDIR /py-app

COPY . /py-app

RUN pip install -r requirements.txt

ENV FLASK_RUN_PORT=6000

EXPOSE $FLASK_RUN_PORT

CMD ["sh", "-c", "gunicorn wsgi:app --bind 0.0.0.0:`echo $FLASK_RUN_PORT` --workers 4 --preload"]