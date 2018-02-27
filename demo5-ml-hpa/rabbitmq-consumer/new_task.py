#!/usr/bin/env python
import pika
import sys
import random
import os

host = os.environ.get('RABBITMQ_HOST', 'localhost')
port = os.environ.get('RABBITMQ_PORT', 5672)
username = os.environ.get('RABBITMQ_USERNAME', 'guest')
password = os.environ.get('RABBITMQ_PASSWORD', 'guest')

pnums = int(sys.argv[1]) if len(sys.argv) > 1 else 10000    # number of mesages to be generated
psize = int(sys.argv[2]) if len(sys.argv) > 2 else 100000   # max number in random message generation

print host
print port
print username
print password
print pnums
print psize

print

connection = pika.BlockingConnection(
    pika.ConnectionParameters(
        host=host,
        port=port,
        credentials=pika.PlainCredentials(username=username, password=password)
    )
)

channel = connection.channel()
channel.queue_declare(queue='task_queue', durable=True)


for x in range(0, pnums):
  message = str(random.randint(1, psize))

  channel.basic_publish(exchange='',
                      routing_key='task_queue',
                      body=message,
                      properties=pika.BasicProperties(
                         delivery_mode = 2, # make message persistent
                      ))
  print(" [x] Sent %r" % message)

connection.close()