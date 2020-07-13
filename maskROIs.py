import cv2
import pims
import imageio
import pandas as pd
import os

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

