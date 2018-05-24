

## Install Java

## Install Spark

Download spark-2.3.0-bin-hadoop2.7.tgz from https://spark.apache.org/downloads.html
and unpack to /usr/local/share/spark

## Install scala and sbt

...

```bash
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
sudo apt-get update
sudo apt-get install sbt
```


## Build project

cd example/stackoverflow/
sbt clean package

Copy target/scala-2.11/bigdata-stackoverflow_2.11-0.1-SNAPSHOT.jar to docker/ folder

## Build Docker image

cd /usr/local/share/spark
bin/docker-image-tool.sh -r docker.io/alex202 -t v2.3.0 build
bin/docker-image-tool.sh -r docker.io/alex202 -t v2.3.0 push 

cd -
cd example/stackoverflow/docker/
docker build -t alex202/spark-example:2.3.0 .
docker push alex202/spark-example:2.3.0


## Run example

Please change --master to valid kubernetes api server address

Create spark namespace 

    kubectl create ns spark

```bash
cd /usr/local/share/spark

bin/spark-submit \
  --master k8s://https://34.195.146.153 \
  --deploy-mode cluster \
  --name stackoverflow \
  --class stackoverflow.StackOverflow \
  --conf spark.kubernetes.namespace=spark \
  --conf spark.kubernetes.container.image.pullPolicy=Always \
  --conf spark.kubernetes.node.selector.kublr.io/node-group=workers \
  --conf spark.executor.instances=16 \
  --conf spark.kubernetes.container.image=alex202/spark-example:2.3.0 \
  local:///opt/spark/work-dir/bigdata-stackoverflow_2.11-0.1-SNAPSHOT.jar
```

After a several minutes go to kubernetes dashboard and see newly created spark-worker pod and look at its log for the results

