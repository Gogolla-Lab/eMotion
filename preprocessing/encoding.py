import os
import sys
from time import time
from subprocess import run
from joblib import Parallel, delayed


def encode_single(video_path):
    out = video_path[:-4] + '_encoded.avi'  # Change the file name
    args = ['ffmpeg', '-i', video_path, '-c:v', 'h264_nvenc', '-profile:v', 'high', '-preset', 'slow', '-an', out]
    result = run(args, capture_output=True, text=True)
    print('stdout:', result.stdout)
    print('stderr:', result.stderr)


def encode_all(folder_path, n_jobs='default'):
    videos = [os.path.join(folder_path, video) for video in os.listdir(folder_path) if video.endswith('.avi')]

    if n_jobs == 'default':
        if len(videos) > 3:
            n_jobs = 3
        else:
            n_jobs = len(videos)

    Parallel(n_jobs=n_jobs, verbose=100)(
        delayed(encode_single)(os.path.join(folder_path, video)) for video in os.listdir(folder_path) if
        video.endswith('.avi'))


if __name__ == '__main__':
    start = time()

    if sys.argv[2] == 'single':
        encode_single(sys.argv[1])
    elif sys.argv[2] == 'multi':
        try:
            encode_all(sys.argv[1], n_jobs=sys.argv[3])
        except IndexError:
            print("calling encode_all with n_jobs='default'")
            encode_all(sys.argv[1])
    else:
        raise ValueError("Second argument must be either 'single' or 'multi'")

    print('encoding.py took', time()-start, 'seconds!')
