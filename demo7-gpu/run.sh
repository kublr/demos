#!/bin/bash
if hash nvcc > /dev/null; then # If cuda is installed
    # Compile using GPU
    echo "CUDA found. Making for GPU"
    var="1"
else 
    # Compile using CPU
    echo "CUDA not found. Making for CPU"
    var="0"
fi

sed -i "1s/.*/GPU=$var/" darknet/Makefile
cd darknet
make clean
make

# Download YOLO weights if doesn't exist
if [ ! -f yolov3.weights ]; then
    echo "Wights not found. Downloading yolov3.weights"
    wget https://pjreddie.com/media/files/yolov3.weights
fi

cd python
# Run script
python darknet.py $VIDEO_LINK $OUTPUT_PORT $VIDEO_OUTPUT_COMPRESSION 
