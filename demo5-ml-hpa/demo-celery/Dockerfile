FROM python:3-slim

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

VOLUME "/opt/volume"

#ENTRYPOINT ["python"]
#CMD celery -A Worker worker -Q handler_queue --concurrency=1 --loglevel=info -n handler@%n