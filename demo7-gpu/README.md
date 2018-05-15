# Nvidia YOLO Demo

## SSH into the machine that will run the docker: 
```
ssh -L PORT:localhost:PORT user@IP  #Replace the PORT to create a tunnel to a specific port
```
Note: using an ssh tunnel has been slow in my experience. I downloaded sshuttle instead and used it to create a tunnel.

```
sudo apt-get install sshuttle 
```
Then to create a tunnel using sshuttle use
```
sshuttle --no-latency-control -N -v -r user@ip localhost:PORT localhost:PORT
```

## If you want to pull from docker hub
1. Once port tunnel is created pull the docker container from docker hub: 
```
docker pull kublr/demo-gpu:gpu
```
or
```
docker pull kublr/demo-gpu:cpu
```

## If you want to build the docker manually after cloning from github:
1. Clone repo
2. cd into darknet directory
3. Download weights for the neural network
```
wget https://pjreddie.com/media/files/yolov3.weights
```
4. Build docker
```
docker build -t kublr/demo-gpu:gpu
```
or
```
docker build -t kublr/demo-gpu:cpu
```
## Run docker:
```
nvidia-docker run -it -p PORT:PORT kublr/demo-gpu:gpu
```
or 
```
nvidia-docker run -it -p PORT:PORT kublr/demo-gpu:cpu
```
1. Inside docker navigate to /opt/volume.
2. Open Makefile and make sure GPU=1 if you want GPU support or GPU=0 if you don't want GPU support
3. Run this to clean and remake everything
```
make clean
make
```
4. Navigate to /opt/volume/python
```
cd opt/volume/python
```

5. Run
```
python darknet.py vid/path/vid.mp4 PORT COMPRESSION_PERCENT
```
Note: a sample video was already included in the opt/volume/python dir. So to run you can use this command:
```
python darknet.py vid.mp4 PORT COMPRESSION_PERCENT
```

Arguments are:
-video path and name
-port which has a tunnel
-compression percentage. For example 40 will compress the image and keep 40% of the quality. 10 will keep 10% of the quality


