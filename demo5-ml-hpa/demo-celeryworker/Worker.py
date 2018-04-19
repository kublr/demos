# To run
# celery -A Worker worker --loglevel=info
# "Worker" has to be the name of the file and the name passed
import os
from celery import Celery
import sklearn
import sklearn.ensemble
import sklearn.metrics
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split

username = os.environ['RABBITMQ_USERNAME']
password = os.environ['RABBITMQ_PASSWORD']
host = os.environ['RABBITMQ_HOST']
port = os.environ['RABBITMQ_PORT']

dataset = os.environ['DATASET']


app = Celery('Worker', broker=('amqp://' + username + ':' + password + '@' + host + ':' + port + '/'))

# app.conf.task_default_queue = 'tasks'
# app.conf.task_default_routing_key = 'tasks'
# app.conf.task_default_exchange_type = 'x-random'

# File path
FILE_SYSTEM = ""
TRAIN_DATASET_NAME = "/opt/data/" + dataset


# Create the df containing data and edit it
df = pd.read_csv(FILE_SYSTEM + TRAIN_DATASET_NAME)


@app.task
def result_handler(n_estimators, min_samples_leaf, result):
    return 1

@app.task
def predict(n_estimators, min_samples_leaf):
    print("%d | %d" % (n_estimators, min_samples_leaf))
    # Create Y set One hot
    y = pd.get_dummies(df['churn'])

    # Drop not needed cols
    x = df.drop(columns=['churn', 'voice mail plan', 'international plan', 'phone number', 'state'])

    # Concat one hot encoding for year and location
    x = pd.concat([x, pd.DataFrame(df['voice mail plan'].astype('category').cat.codes, columns=['voice mail plan']),
                   pd.DataFrame(df['international plan'].astype('category').cat.codes, columns=['international plan']),
                   pd.DataFrame(df['state'].astype('category').cat.codes, columns=['state'])],
                   axis=1)

    x = np.array(x)

    X_train, X_test, Y_train, Y_test = train_test_split(x, y, test_size=0.20, random_state=42)


    # Print shapes
    #print('X_train {} X_test {}'.format(np.shape(X_train), np.shape(X_test)))
    #print('Y_train {} Y_test {}'.format(np.shape(Y_train), np.shape(Y_test)))

    rf = sklearn.ensemble.RandomForestClassifier(n_estimators=n_estimators, max_features='sqrt', min_samples_leaf=min_samples_leaf,
                                                 oob_score=True)
    rf.fit(X_train, Y_train)

    pred = rf.predict_proba(X_test)

    # Put result in handler_queue
    result_handler.apply_async(args=[n_estimators, min_samples_leaf, sklearn.metrics.accuracy_score(Y_test, rf.predict(X_test))], queue = 'handler_queue') 

    return sklearn.metrics.accuracy_score(Y_test, rf.predict(X_test))


# this is a needed setup step in order to make sure 
# that handler_queue can be created at runtime
CELERY_CREATE_MISSING_QUEUES = True