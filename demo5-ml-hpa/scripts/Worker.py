#This defines a worker that receives result msgs from other workers
#Will run on local computer and put together the result 
#Runs on its own handler_gueue
import os
from celery import Celery
import pandas as pd
from celery.signals import worker_shutting_down
from celery.signals import worker_init

username = os.environ['RABBITMQ_USERNAME']
password = os.environ['RABBITMQ_PASSWORD']
host = os.environ['RABBITMQ_HOST']
port = os.environ['RABBITMQ_PORT']


app = Celery('Worker', broker=('amqp://' + username + ':' + password + '@' + host + ':' + port + '/'))


@app.task()
def result_handler(n_estimators, min_samples_leaf, result):
	df = pd.DataFrame([[n_estimators, min_samples_leaf, result]], columns=["n_estimators", "min_samples_leaf", "accuracy"])
	df_open = pd.read_csv("/opt/volume/Results.csv")
	df_open = df_open.append(df)
	df_open.to_csv("/opt/volume/Results.csv", index=False, columns=["n_estimators", "min_samples_leaf", "accuracy"])
	return result

@worker_init.connect
def worker_init(**kwargs):
	df = pd.DataFrame(columns=["n_estimators", "min_samples_leaf", "accuracy"])
	df.to_csv("/opt/volume/Results.csv", columns=["n_estimators", "min_samples_leaf", "accuracy"], index=False)
