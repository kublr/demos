#!/bin/bash
echo "CUDA not found. Making for CPU"
var="1"

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
