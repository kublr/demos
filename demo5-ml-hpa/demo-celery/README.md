
# Consumer


docker build -t alex202/demo-celeryhandler .

docker run -it --rm  -v $(pwd)/scripts:/usr/src/app \
    -e RABBITMQ_HOST=$RABBITMQ_HOST \
    -e RABBITMQ_PORT=$RABBITMQ_PORT \
    -e RABBITMQ_USERNAME=$RABBITMQ_USERNAME \
    -e RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD \
    alex202/demo-celery python Scheduler.py
    
docker run -it --rm -v $(pwd)/res1:/opt/volume \
    -e RABBITMQ_HOST=$RABBITMQ_HOST \
    -e RABBITMQ_PORT=$RABBITMQ_PORT \
    -e RABBITMQ_USERNAME=$RABBITMQ_USERNAME \
    -e RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD \
    alex202/demo-celeryhandler:latest celery -A Worker worker -Q handler_queue --concurrency=1 --loglevel=info -n handler@%n
    
      