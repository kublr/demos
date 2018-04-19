import os
from celery import Celery
from celery.signals import task_success
import time


username = os.environ['RABBITMQ_USERNAME']
password = os.environ['RABBITMQ_PASSWORD']
host = os.environ['RABBITMQ_HOST']
port = os.environ['RABBITMQ_PORT']

app = Celery('Worker',
             broker=('amqp://' + username + ':' + password + '@' + host + ':' + port + '/'),
            )

# app.conf.task_default_queue = 'random'
# app.conf.task_default_routing_key = 'random'
# app.conf.task_default_exchange = 'random'
# app.conf.task_default_exchange_type = 'x-random'

@app.task
def predict(n_estimators, min_samples_leaf):
    return 1

# @task_success.connect(sender='tasks.predict')
# def task_success(result, **args):
# 	print(result.get())

listOfResponces = []
for i in reversed(range(200)):
    for j in range(100):
        n_estimators = 10 + i
        min_samples_leaf = 5 + j
        res = predict.delay(n_estimators, min_samples_leaf)
        listOfResponces.append(res)

    #print(res.get())
