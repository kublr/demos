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
# Check if port is ok.
while lsof -Pi :$OUTPUT_PORT -sTCP:LISTEN -t >/dev/null; do
    echo "Port ${OUTPUT_PORT} is busy. +1"
    let OUTPUT_PORT=OUTPUT_PORT+1
done
echo "Port found: ${OUTPUT_PORT}"

# Run script
python darknet.py $VIDEO_LINK $OUTPUT_PORT $VIDEO_OUTPUT_COMPRESSION
