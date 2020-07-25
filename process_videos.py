import os
import cv2
import numpy as np
import pandas as pd
import imageio
import pims
from drawer import CircleDrawer
from maskROIs import maskFrame_poly
from ast import literal_eval
from joblib import Parallel, delayed

def create_trims_df(folder):

    videos = []
    fps = []
    start = []
    end = []

    for video in os.listdir(folder):
        if video.endswith('.mp4') or video.endswith('.MP4'):
            print('Working on video: ', video)
            vid = pims.Video(os.path.join(folder, video))
            videos.append(video)
            fps.append(round(vid.frame_rate, 3))
            start.append(0.0)
            end.append(vid.duration)

    df = pd.DataFrame(data=np.array([fps, start, end]).T, index=videos, columns=['fps', 'start', 'end'])
    df.to_csv(os.path.join(folder, 'trims.csv'))
    print(os.path.join(folder, 'trims.csv'), "created!")


def append_mask_and_crop_ROIs(folder, shape = 'circle'):

    # Check if 'process.csv' exist to continue from where the user left the process
    if os.path.exists(os.path.join(folder, 'process.csv')):
        df = pd.read_csv(os.path.join(folder, 'process.csv'), index_col=0)
    else:
        df = pd.read_csv(os.path.join(folder, 'trims.csv'), index_col=0)

    for video in df.index:
        vid = pims.Video(os.path.join(folder, video))

        # add the masking roi if it doesn't exist in the df
        if shape not in df.columns:
            df[shape] = np.NaN
            df.to_csv(os.path.join(folder, 'process.csv'))
        if pd.isnull(df.loc[video, shape]):
            if shape == 'circle':
                cd = CircleDrawer('Draw a circle, right click when done.',
                                 img=vid[df.loc[video, 'start']*df.loc[video, 'fps']])
                df.loc[video, shape] = str(cd.run())
            df.to_csv(os.path.join(folder, 'process.csv'))

        # add the crop roi if it doesn't exist in the df
        if 'crop' not in df.columns:
            df['crop'] = np.NaN
            df.to_csv(os.path.join(folder, 'process.csv'))
        if df.loc[video, 'crop'] == '(0, 0, 0, 0)' or pd.isnull(df.loc[video, 'crop']):
            df.loc[video, 'crop'] = str(cv2.selectROI('Select the region to be CROPPED',
                                                      vid[df.loc[video, 'start']*df.loc[video, 'fps']]))
            cv2.destroyWindow('Select the region to be CROPPED')
            df.to_csv(os.path.join(folder, 'process.csv'))

    print(os.path.join(folder, 'process.csv'), "created with all required entries!")


def processVideo(videoPath, outputFolder):
    """Pipeline containing function to trim, mask and crop a video (provided by the process.csv file)"""

    # get the required data from the process.csv file
    df = pd.read_csv(os.path.join(os.path.split(videoPath)[0], "process.csv"), index_col=0)
    start = df.loc[os.path.split(videoPath)[-1], 'start']
    end = df.loc[os.path.split(videoPath)[-1], 'end']
    vertices = np.array(literal_eval(df.loc[os.path.split(videoPath)[-1], 'vertices']))
    crop = literal_eval(df.loc[os.path.split(videoPath)[-1], 'crop'])
    r = crop

    # create the output folder
    try:
        os.mkdir(outputFolder)
    except OSError:
        print(outputFolder, "already exists! Continuing with the process without creating it.")

    # reader & writer
    reader = imageio.get_reader(videoPath)
    fps = reader.get_meta_data()['fps']
    outputFilename = os.path.join(outputFolder, os.path.split(videoPath)[-1].strip(".mp4") + "_processed.mp4")
    writer = imageio.get_writer(outputFilename, fps=fps)

    # writing to disk
    start_frame = start * fps
    end_frame = end * fps

    for i, im in enumerate(reader):
        if i >= start_frame and i <= end_frame:
            masked = maskFrame_poly(im, vertices)
            cropped = masked[int(r[1]):int(r[1] + r[3]), int(r[0]):int(r[0] + r[2])]
            writer.append_data(cropped)
    writer.close()


def processVideos(folderPath, outputFolder, n_jobs=16):
    """This function will process all videos in a given folder using the above described functions and the csv file
    containing metadata (process.csv)"""

    Parallel(n_jobs=n_jobs)(delayed(processVideo)(os.path.join(folderPath, v), outputFolder)
                            for v in os.listdir(folderPath) if v.endswith(".mp4"))


if __name__ == "__main__":
    import sys
    processVideos(sys.argv[1], sys.argv[2], int(sys.argv[3]))