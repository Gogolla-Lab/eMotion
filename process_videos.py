import os
import cv2
import numpy as np
import pandas as pd
import imageio
import pims
from drawer import CircleDrawer
from maskROIs import maskFrame_circle
from ast import literal_eval
from joblib import Parallel, delayed


def crop_frame(frame, crop):
    """Generic function for cropping an image/frame."""
    r = crop

    return frame[int(r[1]):int(r[1] + r[3]), int(r[0]):int(r[0] + r[2])]


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


def append_mask_and_crop_ROIs(folder, shape='circle'):
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
                                  img=vid[df.loc[video, 'start'] * df.loc[video, 'fps']])
                df.loc[video, shape] = str(cd.run())
            df.to_csv(os.path.join(folder, 'process.csv'))

        # add the crop roi if it doesn't exist in the df
        if 'crop' not in df.columns:
            df['crop'] = np.NaN
            df.to_csv(os.path.join(folder, 'process.csv'))
        if df.loc[video, 'crop'] == '(0, 0, 0, 0)' or pd.isnull(df.loc[video, 'crop']):
            df.loc[video, 'crop'] = str(cv2.selectROI('Select the region to be CROPPED',
                                                      vid[df.loc[video, 'start'] * df.loc[video, 'fps']]))
            cv2.destroyWindow('Select the region to be CROPPED')
            df.to_csv(os.path.join(folder, 'process.csv'))

    print(os.path.join(folder, 'process.csv'), "created with all required entries!")


def trimVideo(videoPath, outputFolder, use_imageio=True):

    print('trimVideo called with: ', videoPath, outputFolder)
    outputFilename = os.path.join(outputFolder, os.path.split(videoPath)[-1].strip(".mp4") + "_trimmed.mp4")
    if os.path.exists(outputFilename):
        print(outputFilename, "already exists. Terminating!")
        return None

    # get the required data from the process.csv file
    df = pd.read_csv(os.path.join(os.path.split(videoPath)[0], "trims.csv"), index_col=0)
    start = df.loc[os.path.split(videoPath)[-1], 'start']
    end = df.loc[os.path.split(videoPath)[-1], 'end']

    # Shorten processed videos to 1h
    if end - start > 3600:
        end = 3600 + start

    if use_imageio:
        video = pims.ImageIOReader(videoPath)
        fps = video.frame_rate
    else:
        video = pims.Video(videoPath)
        fps = video.frame_rate

    # writing to disk
    try:
        os.mkdir(outputFolder)
    except OSError:
        print(outputFolder, "already exists! Continuing with the process without creating it.")

    start_frame = int(start * fps)
    end_frame = int(end * fps)
    imageio.mimwrite(outputFilename, video[start_frame:end_frame], fps=fps)
    print('Completed: processVideo with parameters: ', videoPath, outputFolder)


def processVideo(videoPath, outputFolder, shape='circle'):
    """
    Pipeline containing function to trim, mask and crop a video (provided by the process.csv file)
    shape: 'circle' or 'polygon'
    """

    print('processVideo called with: ', videoPath, outputFolder)
    outputFilename = os.path.join(outputFolder, os.path.split(videoPath)[-1].strip(".mp4") + "_processed.mp4")
    if os.path.exists(outputFilename):
        print(outputFilename, "already exists. Terminating!")
        return None

    # get the required data from the process.csv file
    df = pd.read_csv(os.path.join(os.path.split(videoPath)[0], "process.csv"), index_col=0)
    start = df.loc[os.path.split(videoPath)[-1], 'start']
    end = df.loc[os.path.split(videoPath)[-1], 'end']

    # Shorten processed videos to 1h
    if end - start > 3600:
        end = 3600 + start

    if shape == 'circle':
        circle = literal_eval(df.loc[os.path.split(videoPath)[-1], 'circle'])
    # elif shape == 'polygon':
    #     vertices = np.array(literal_eval(df.loc[os.path.split(videoPath)[-1], 'vertices']))
    crop = literal_eval(df.loc[os.path.split(videoPath)[-1], 'crop'])

    video = pims.ImageIOReader(videoPath)
    fps = video.frame_rate

    # pipelines
    # masking pipeline
    masking_pipeline = pims.pipeline(maskFrame_circle)
    masking_kwargs = dict(circle=circle)
    masked_video = masking_pipeline(video, **masking_kwargs)
    # cropping pipeline
    cropping_pipeline = pims.pipeline(crop_frame)
    cropping_kwargs = dict(crop=crop)
    cropped_video = cropping_pipeline(masked_video, **cropping_kwargs)

    # writing to disk
    try:
        os.mkdir(outputFolder)
    except OSError:
        print(outputFolder, "already exists! Continuing with the process without creating it.")

    start_frame = int(start * fps)
    end_frame = int(end * fps)
    imageio.mimwrite(outputFilename, cropped_video[start_frame:end_frame], fps=fps)
    print('Completed: processVideo with parameters: ', videoPath, outputFolder)


def processVideos(folderPath, outputFolder, shape='circle', n_jobs=16):
    """This function will process all videos in a given folder using the above described functions and the csv file
    containing metadata (process.csv)"""

    Parallel(n_jobs=n_jobs, verbose=100)(delayed(processVideo)(os.path.join(folderPath, v), outputFolder, shape)
                                         for v in os.listdir(folderPath) if v.endswith(".mp4"))


def trimVideos(folderPath, outputFolder, use_imageio=False, n_jobs=20):
    """This function will process all videos in a given folder using the above described functions and the csv file
    containing metadata (process.csv)"""

    Parallel(n_jobs=n_jobs, verbose=100)(delayed(trimVideo)(os.path.join(folderPath, v),
                                                            outputFolder, use_imageio=use_imageio)
                                         for v in os.listdir(folderPath) if v.endswith(".mp4"))


if __name__ == "__main__":
    import sys

    print("Initiating processVideos with args: ", sys.argv)
    processVideos(sys.argv[1], sys.argv[2], n_jobs=int(sys.argv[3]))

# # test
# folder = "C:/Users/serce/Desktop/temp"
# outputFolder = os.path.join(folder, "outputs")
# create_trims_df(folder)
# append_mask_and_crop_ROIs(folder)
# processVideos(folder, outputFolder, n_jobs=3)
