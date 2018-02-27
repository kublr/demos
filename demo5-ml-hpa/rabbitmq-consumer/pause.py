#!/usr/bin/env python
import pika
import time
import sys
import math
import os
from threading import Timer

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

def timeout():
    return

def callback(ch, method, properties, body):
    t = Timer(1.0, timeout)
    t.start()
    print(" [x] %s Received %r" % (time.strftime('%H:%M:%S'), body))
    ch.basic_ack(delivery_tag = method.delivery_tag)
    time.sleep(1.0) # 1 sec
    if t.is_alive():
        t.cancel()


channel.basic_qos(prefetch_count=1)
channel.basic_consume(callback, queue='task_queue')

channel.start_consuming()