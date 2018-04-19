
helm upgrade -i worker --set Rabbitmq.host=rabbitmq-app-rabbitmq \
                       --set Rabbitmq.port = 5672 \
                       --set Rabbitmq.username=$RABBITMQ_USERNAME \
                       --set Rabbitmq.password=$RABBITMQ_PASSWORD \
                    demo-celeryworker/charts/demo-celeryworker

docker run -it --rm -v $(pwd)/ToTrainDataset.csv:/opt/volume/ToTrainDataset.csv \
    -e RABBITMQ_HOST=$RABBITMQ_HOST \
    -e RABBITMQ_PORT=$RABBITMQ_PORT \
    -e RABBITMQ_USERNAME=$RABBITMQ_USERNAME \
    -e RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD \
    -e DATASET=ToTrainDataset.csv \
    alex202/demo-celeryworker:latest celery -A Worker worker --concurrency=1 --loglevel=info -n worker@%n