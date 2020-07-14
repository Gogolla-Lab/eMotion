import cv2
import pims
import imageio
import pandas as pd
import os
from joblib import Parallel, delayed


def getMaskROIs(folder):
    """Utility function to get masking ROIs of multiple videos. Grabs a frame from each video, asks for the ROI,
    saves the video paths and ROIs as a csv file for the downstream processes"""

    videos = []
    rois = []

    for video in os.listdir(folder):
        if video.endswith('.mp4'):
            vid = pims.Video(os.path.join(folder, video))
            roi = cv2.selectROI("Select ROI", vid[0])
            cv2.destroyWindow("Select ROI")
            videos.append(os.path.join(folder, video))
            rois.append(roi)

    df = pd.DataFrame(data=rois, index=videos)
    df.to_csv(os.path.join(folder, "maskROIs.csv"))
    print("maskROIs.csv saved to:", os.path.join(folder, "maskROIs.csv"))


def maskFrame_rect(frame, maskCoords=[]):
    """Utility function which masks (blackens) all pixels in the ROI as defined
    by maskCoords argument, expected to be output of cv2.selectROI  function."""

    r = maskCoords
    frame[int(r[1]):int(r[1] + r[3]), int(r[0]):int(r[0] + r[2])] = 0

    return frame


def maskVideo_rect(videoPath, outputFolder, fps=30.0):
    """Function containing a pipeline which masks a desired ROI in a given video (provided by the maskROIs.csv file)
    and saves the result"""

    # get the maskCoords from the csv file
    df = pd.read_csv(os.path.join(os.path.split(videoPath)[0], "maskROIs.csv"), index_col=0)
    maskCoords = tuple(df.loc[videoPath])

    # pipeline
    video = pims.Video(videoPath)
    r = maskCoords
    masking_pipeline = pims.pipeline(maskFrame_rect)
    kwargs = dict(maskCoords=r)
    processed_video = masking_pipeline(video, **kwargs)

    # writing to disk
    try:
        os.mkdir(outputFolder)
    except OSError:
        print(outputFolder, "already exists! Continuing with the process without creating it.")

    outputFilename = os.path.join(outputFolder, os.path.split(videoPath)[-1].strip(".mp4") + "_masked.mp4")
    imageio.mimwrite(outputFilename, processed_video, fps=fps)


def maskVideos_rect(folderPath, outputFolder, n_jobs=4):
    """This function will process all videos in a given folder using the above described functions and the csv file
    containing rectangular ROIs (maskROIs.csv)"""

    Parallel(n_jobs=n_jobs)(delayed(maskVideo_rect)(os.path.join(folderPath, v), outputFolder)
                            for v in os.listdir(folderPath) if v.endswith(".mp4"))
