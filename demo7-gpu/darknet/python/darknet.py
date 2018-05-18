import time
from ctypes import *
import math
import random
import sys
import cv2
import numpy as np
from flask import Flask, render_template, Response
from threading import Thread
import yt_down

VIDEO_NAME = 'vid.mp4'

running = True
stream_frames = []
ready_frames = []

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/video_feed')
def video_feed():
    return Response(sender_thread(), mimetype='multipart/x-mixed-replace; boundary=frame')

def sender_thread():
    frame_num = 0
    start_time = time.time()
    fps = 0
    count = 1
    while True:
        if len(stream_frames) > 0:
            frame = stream_frames.pop(0)
            end_time = time.time()
            fps = fps * 0.9 + 1/(end_time - start_time) * 0.1
            start_time = end_time

            #frame_info = 'Frame: {0}, FPS: {1:.2f}'.format(count, fps)
            #cv2.putText(frame, frame_info, (10, frame.shape[0]-10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 1)

            #frame = np.concatenate((frame[0], frame[1]), axis=1)

            yield (b'--frame\r\n'b'Content-Type: image/jpeg\r\n\r\n' +frame + b'\r\n')




def sample(probs):
    s = sum(probs)
    probs = [a/s for a in probs]
    r = random.uniform(0, 1)
    for i in range(len(probs)):
        r = r - probs[i]
        if r <= 0:
            return i
    return len(probs)-1

def c_array(ctype, values):
    new_values = values.ctypes.data_as(POINTER(ctype))
    return new_values

def array_to_image(arr):
    import numpy as np
    # need to return old values to avoid python freeing memory
    arr = arr.transpose(2,0,1)
    c = arr.shape[0]
    h = arr.shape[1]
    w = arr.shape[2]
    arr = np.ascontiguousarray(arr.flat, dtype=np.float32) / 255.0
    data = arr.ctypes.data_as(POINTER(c_float))
    im = IMAGE(w,h,c,data)
    return im, arr


class BOX(Structure):
    _fields_ = [("x", c_float),
                ("y", c_float),
                ("w", c_float),
                ("h", c_float)]

class DETECTION(Structure):
    _fields_ = [("bbox", BOX),
                ("classes", c_int),
                ("prob", POINTER(c_float)),
                ("mask", POINTER(c_float)),
                ("objectness", c_float),
                ("sort_class", c_int)]


class IMAGE(Structure):
    _fields_ = [("w", c_int),
                ("h", c_int),
                ("c", c_int),
                ("data", POINTER(c_float))]

class METADATA(Structure):
    _fields_ = [("classes", c_int),
                ("names", POINTER(c_char_p))]


#lib = CDLL("/home/pjreddie/documents/darknet/libdarknet.so", RTLD_GLOBAL)
lib = CDLL("../libdarknet.so", RTLD_GLOBAL)
lib.network_width.argtypes = [c_void_p]
lib.network_width.restype = c_int
lib.network_height.argtypes = [c_void_p]
lib.network_height.restype = c_int

predict = lib.network_predict
predict.argtypes = [c_void_p, POINTER(c_float)]
predict.restype = POINTER(c_float)

set_gpu = lib.cuda_set_device
set_gpu.argtypes = [c_int]

make_image = lib.make_image
make_image.argtypes = [c_int, c_int, c_int]
make_image.restype = IMAGE

get_network_boxes = lib.get_network_boxes
get_network_boxes.argtypes = [c_void_p, c_int, c_int, c_float, c_float, POINTER(c_int), c_int, POINTER(c_int)]
get_network_boxes.restype = POINTER(DETECTION)

make_network_boxes = lib.make_network_boxes
make_network_boxes.argtypes = [c_void_p]
make_network_boxes.restype = POINTER(DETECTION)

free_detections = lib.free_detections
free_detections.argtypes = [POINTER(DETECTION), c_int]

free_ptrs = lib.free_ptrs
free_ptrs.argtypes = [POINTER(c_void_p), c_int]

network_predict = lib.network_predict
network_predict.argtypes = [c_void_p, POINTER(c_float)]

reset_rnn = lib.reset_rnn
reset_rnn.argtypes = [c_void_p]

load_net = lib.load_network
load_net.argtypes = [c_char_p, c_char_p, c_int]
load_net.restype = c_void_p

do_nms_obj = lib.do_nms_obj
do_nms_obj.argtypes = [POINTER(DETECTION), c_int, c_int, c_float]

do_nms_sort = lib.do_nms_sort
do_nms_sort.argtypes = [POINTER(DETECTION), c_int, c_int, c_float]

free_image = lib.free_image
free_image.argtypes = [IMAGE]

letterbox_image = lib.letterbox_image
letterbox_image.argtypes = [IMAGE, c_int, c_int]
letterbox_image.restype = IMAGE

load_meta = lib.get_metadata
lib.get_metadata.argtypes = [c_char_p]
lib.get_metadata.restype = METADATA

load_image = lib.load_image_color
load_image.argtypes = [c_char_p, c_int, c_int]
load_image.restype = IMAGE

rgbgr_image = lib.rgbgr_image
rgbgr_image.argtypes = [IMAGE]

predict_image = lib.network_predict_image
predict_image.argtypes = [c_void_p, IMAGE]
predict_image.restype = POINTER(c_float)

def classify(net, meta, im):
    out = predict_image(net, im)
    res = []
    for i in range(meta.classes):
        res.append((meta.names[i], out[i]))
    res = sorted(res, key=lambda x: -x[1])
    return res


def detect(net, meta, image, thresh=.5, hier_thresh=.5, nms=.45):
    im = image
    num = c_int(0)
    pnum = pointer(num)
    predict_image(net, im)
    dets = get_network_boxes(net, im.w, im.h, thresh, hier_thresh, None, 0, pnum)
    num = pnum[0]
    if (nms): do_nms_obj(dets, num, meta.classes, nms);

    res = []
    for j in range(num):
        for i in range(meta.classes):
            if dets[j].prob[i] > 0:
                b = dets[j].bbox
                res.append((meta.names[i], dets[j].prob[i], (b.x, b.y, b.w, b.h)))
    res = sorted(res, key=lambda x: -x[1])
    #free_image(im)
    #free_detections(dets, num)
    return res
    

def detect_numpy(net, meta, image, thresh=.5, hier_thresh=.5, nms=.45):
    im, arr = array_to_image(image)
    num = c_int(0)
    pnum = pointer(num)
    predict_image(net, im)
    dets = get_network_boxes(net, im.w, im.h, thresh, hier_thresh, None, 0, pnum)
    num = pnum[0]
    if (nms): do_nms_obj(dets, num, meta.classes, nms);

    res = []
    for j in range(num):
        for i in range(meta.classes):
            if dets[j].prob[i] > 0:
                b = dets[j].bbox
                res.append((meta.names[i], dets[j].prob[i], (b.x, b.y, b.w, b.h)))
    res = sorted(res, key=lambda x: -x[1])
    free_detections(dets, num)
    return res



video_frames = []
class PrepVideo(Thread):
    
    def __init__(self, videoName, FPS):
        Thread.__init__(self)
        self.sleep = float(1/FPS)
        self.videoName = videoName
        self.running = True


    def run(self):
        global video_frames
        vid = cv2.VideoCapture(self.videoName)
        while self.running:
            if len(video_frames) < 400:
                ret, frame = vid.read()
                if not ret:
                    print "End of video or cant open file."
                    running = False
                    break

                # Put image into process array and frames into frames
                video_frames.append(frame)
            # fleep
            time.sleep(self.sleep)


evaluated_frames = []
class EvalFrame(Thread):
    def __init__(self, net, meta):
        Thread.__init__(self)
        self.net = net
        self.meta = meta
        self.running = True

    def run(self):
        global video_frames
        global evaluated_frames
        count = 0
        start_time = time.time()
        fps = 0
        while self.running:
            if len(video_frames) > 0:
                count +=1

                frame = video_frames.pop(0)

                frame_c = np.copy(frame)

                r = detect_numpy(net, meta, frame_c)

                frame_info = 'Frame: {0}, FPS: {1:.2f}'.format(count, fps)
                evaluated_frames.append([frame, r, frame_info])

                end_time = time.time()
                fps = fps * 0.9 + 1/(end_time - start_time) * 0.1
                start_time = end_time

                print frame_info


class OutputPrep(Thread):

    def __init__(self, compression):
        Thread.__init__(self)
        self.running = True
        self.names_for_color = []
        self.colors = []
        self.compression = compression

    def run(self):

        def rescale_frame(frame, percent=75):
            width = int(frame.shape[1] * percent/ 100)
            height = int(frame.shape[0] * percent/ 100)
            dim = (width, height)
            return cv2.resize(frame, dim, interpolation =cv2.INTER_AREA)


        global stream_frames
        while self.running:
            if len(stream_frames) < 400 and len(evaluated_frames) > 0:
                temp = evaluated_frames.pop(0)

                frame = temp[0]
                r = temp[1]
                frame_info = temp[2]

                frame_edited = np.copy(frame)

                # Parse data and add rect to img
                for i in r:
                    # Get or create color for frame
                    color_rgb = (0, 0, 0)
                    class_name = i[0]
                    if class_name not in self.names_for_color:
                        color_rgb = tuple(np.random.choice(range(256), size=3))
                        self.colors.append(color_rgb)
                        self.names_for_color.append(i[0])
                    else:
                        color_rgb = self.colors[self.names_for_color.index(class_name)]

                    #get coords for the box
                    acc = i[1]

                    # get coords for rect (centerX, centerY, width, height)
                    coords = i[2]

                    # Draw box
                    cv2.rectangle(frame_edited, (int(coords[0]-coords[2]/2), int(coords[1]-coords[3]/2)), (int(coords[0]+coords[2]/2), int(coords[1] + coords[3]/2)), color_rgb, 2)

                    # Draw label
                    (test_width, text_height), baseline = cv2.getTextSize(
                        class_name, cv2.FONT_HERSHEY_SIMPLEX, 0.75, 1)
                    cv2.rectangle(frame_edited, (int(coords[0] - coords[2]/2), int(coords[1]-coords[3]/2)), (int(coords[0] - coords[2]/2)+test_width, int(coords[1]-coords[3]/2)-text_height-baseline), 
                        color_rgb, thickness=cv2.FILLED)
                    cv2.putText(frame_edited, class_name, (int(coords[0] - coords[2]/2), int(coords[1]-coords[3]/2)), cv2.FONT_HERSHEY_SIMPLEX, 0.75, (0, 0, 0), 1)

                cv2.putText(frame_edited, frame_info, (10, frame_edited.shape[0]-10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 1)
                print (frame_info)

                    #frame = rescale_frame(frame, 50)
                    #frame_edited = rescale_frame(frame_edited, 50)

                frame_done = np.concatenate((frame, frame_edited), axis=1)
                stream_frames.append(cv2.imencode('.jpg', frame_done, [int(cv2.IMWRITE_JPEG_QUALITY), compression])[1].tostring())
                #stream_frames.append(cv2.imencode('.jpg', frame_done)[1].tostring())




if __name__ == "__main__":

    threads = []

    set_gpu(0)
    net = load_net("../cfg/yolov3.cfg", "../yolov3.weights", 0)
    meta = load_meta("../cfg/coco.data")
    VIDEO_URL = sys.argv[1]
    port = int(sys.argv[2])
    compression = int(sys.argv[3])

    yt_down.down(VIDEO_URL)

    # Thread to read video frame by frame and prepare it for predict
    read_vid_thread = PrepVideo('vid.mp4', 50)
    read_vid_thread.deamon = True
    read_vid_thread.start()
    threads.append(read_vid_thread)
    
    eval_thread = EvalFrame(net, meta)
    eval_thread.deamon = True
    eval_thread.start()
    threads.append(eval_thread)

    prep_out_thread = OutputPrep(compression)
    prep_out_thread.deamon = True
    prep_out_thread.start()
    threads.append(prep_out_thread)

    app.run(host='0.0.0.0', port=port)

    def has_live_threads(threads):
        return True in [t.isAlive() for t in threads]

    while has_live_threads(threads):
        try:
            # synchronization timeout of threads kill
            [t.join(1) for t in threads if t is not None and t.isAlive()]
        except KeyboardInterrupt:
            # Ctrl-C handling and send kill to threads
            print "Sending kill to threads..."
            for t in threads:
                t.running = False
    print "Exited"
   
    
    
        
        

    
    

