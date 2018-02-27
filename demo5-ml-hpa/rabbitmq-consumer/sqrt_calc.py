#!/usr/bin/env python
import pika
import time
import sys
import math
import os

host = os.environ['RABBITMQ_HOST'] or 'localhost'
port = os.environ['RABBITMQ_PORT'] or 5672
username = os.environ['RABBITMQ_USERNAME'] or 'guest'
password = os.environ['RABBITMQ_PASSWORD'] or 'guest'

connection = pika.BlockingConnection(
    pika.ConnectionParameters(
        host=host,
        port=port,
        credentials=pika.PlainCredentials(username=username, password=password)
    )
)
channel = connection.channel()

channel.queue_declare(queue='task_queue', durable=True)
print(' [*] Waiting for messages. To exit press CTRL+C')

def callback(ch, method, properties, body):
    print(" [x] Received %r" % body)
    #time.sleep(body.count(b'.'))
    count  = int(body)
    num = 0.0
    for x in range(1, count):
        num += math.sqrt(x)
    print(" [x] Found %.2f .Done" % num)
    ch.basic_ack(delivery_tag = method.delivery_tag)

channel.basic_qos(prefetch_count=1)
channel.basic_consume(callback,
                      queue='task_queue')

channel.start_consuming()