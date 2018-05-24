from __future__ import unicode_literals
import youtube_dl
import sys

def my_hook(d):
    if d['status'] == 'finished':
        print('Done downloading, now converting ...')


def down(url, quality = '720'):
	ydl_opts = {   
	    'progress_hooks': [my_hook], 
	    'outtmpl': 'vid.mp4',
	    'format': '(mp4)[height <=?'+ quality + ']' 
	}

	with youtube_dl.YoutubeDL(ydl_opts) as ydl:
		ydl.download([url])




# if __name__ == "__main__":
# 	VIDEO_URL = sys.argv[1]
# 	vid = down(VIDEO_URL)

# 	#https://www.youtube.com/watch?v=9bZkp7q19f0