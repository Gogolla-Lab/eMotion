import cv2
import pims
import imageio
import numpy as np
import pandas as pd
import os
from joblib import Parallel, delayed
from drawer import PolygonDrawer
from ast import literal_eval

# ToDo: Update getMaskROIs to be compatible with shape 'circle'
def getMaskROIs(folder, shape, frame_no=0, save=True):
    """Utility function to get ROIs from multiple videos. Grabs a frame from each video, asks for the ROI,
    saves the video paths and ROIs as a csv file for the downstream processes
    :shape: 'rectangular' or 'polygon'
    """

    videos = []
    rois = []

    for video in os.listdir(folder):
        if video.endswith('.mp4'):
            vid = pims.Video(os.path.join(folder, video))

            if shape == "rectangular":
                roi = cv2.selectROI("Select ROI", vid[frame_no])
                cv2.destroyWindow("Select ROI")
                videos.append(video)
                rois.append(roi)

            if shape == "polygon":
                pgd = PolygonDrawer("PolygonDrawer", img=vid[frame_no])
                # cv2.destroyWindow("PolygonDrawer")
                roi = pgd.run()
                videos.append(video)
                rois.append(roi)
    if save:
        df = pd.DataFrame(data=rois, index=videos)
        df.to_csv(os.path.join(folder, "maskROIs.csv"))
        print("maskROIs.csv saved to:", os.path.join(folder, "maskROIs.csv"))
    else:
        return videos, rois


def maskFrame_rect(frame, maskCoords=[]):
    """Utility function which masks (blackens) all pixels in the ROI as defined
    by maskCoords argument, expected to be output of cv2.selectROI  function."""

    r = maskCoords
    frame[int(r[1]):int(r[1] + r[3]), int(r[0]):int(r[0] + r[2])] = 0

    return frame


def maskFrame_poly(frame, vertices):
    cv2.fillPoly(frame, [vertices], 0)

    return frame


def maskFrame_circle(frame, circle):
    canvas = np.zeros(frame.shape, dtype=frame.dtype)
    cv2.circle(canvas, center=circle[0], radius=circle[1], color=(255, 255, 255), thickness=-1)
    result = cv2.subtract(frame, canvas)

    return result


def maskVideo_rect(videoPath, outputFolder, reader='ImageIO'):
    """Function containing a pipeline which masks a desired ROI in a given video (provided by the maskROIs.csv file)
    and saves the result"""

    # get the maskCoords from the csv file
    df = pd.read_csv(os.path.join(os.path.split(videoPath)[0], "maskROIs.csv"), index_col=0)
    maskCoords = tuple(df.loc[os.path.split(videoPath)[-1]])

    # reader
    if reader == 'ImageIO':
        video = pims.ImageIOReader(videoPath)
    elif reader == 'PyAV':
        video = pims.Video(videoPath)

    fps = video.frame_rate

    # pipeline
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


def maskVideo_poly(videoPath, outputFolder, reader='ImageIO'):
    """Function containing a pipeline which masks a desired polygon in a given video (provided by the maskROIs.csv file)
    and saves the result"""

    # get the vertices from the csv file
    df = pd.read_csv(os.path.join(os.path.split(videoPath)[0], "maskROIs.csv"), index_col=0)
    vertices = np.array([list(literal_eval(r)) for r in df.loc[os.path.split(videoPath)[-1]].dropna()])

    # reader
    if reader == 'ImageIO':
        video = pims.ImageIOReader(videoPath)
    elif reader == 'PyAV':
        video = pims.Video(videoPath)

    fps = video.frame_rate

    # pipeline
    masking_pipeline = pims.pipeline(maskFrame_poly)
    kwargs = dict(vertices=vertices)
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


def maskVideos_poly(folderPath, outputFolder, n_jobs=4):
    """This function will process all videos in a given folder using the above described functions and the csv file
    containing rectangular ROIs (maskROIs.csv)"""

    Parallel(n_jobs=n_jobs)(delayed(maskVideo_poly)(os.path.join(folderPath, v), outputFolder)
                            for v in os.listdir(folderPath) if v.endswith(".mp4"))


# extra function for post-hoc masking labeled images
def maskImages_poly(folder, csv):
    """Function for masking labeled images (of a particular video folder e.g Hr1_Day3). Uses the given csv file
    to look up video name and and polygon vertices"""

    df = pd.read_csv(csv, index_col=0)
    vertices = np.array([list(literal_eval(r)) for r in df.loc[os.path.split(folder)[-1] + '.mp4'].dropna()])

    for file in os.listdir(folder):
        if file.endswith(".png"):
            img = imageio.imread(os.path.join(folder, file))
            img = maskFrame_poly(img, vertices)
            imageio.imwrite(os.path.join(folder, file), img, format='.png')

# if __name__ == "__main__":
#     import sys
#     maskVideos_poly(sys.argv[1], sys.argv[2], int(sys.argv[3]))
