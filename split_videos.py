import os
import pims
import pandas as pd
import imageio
import cv2
from joblib import Parallel, delayed

def get_split_ROIs(folder):
    """Utility function to get ROIs from multiple videos. Grabs a frame from each video, asks for the ROI,
    saves the video paths and ROIs as a csv file for the downstream processes"""

    videos = []
    rois = []
    region = []

    for video in os.listdir(folder):
        if video.endswith('.mp4'):
            vid = pims.Video(os.path.join(folder, video))

            for i in range(2):
                if i == 0:
                    roi = cv2.selectROI("Select LEFT crop", img=vid[0])
                    cv2.destroyWindow("Select LEFT crop")
                    videos.append(video)
                    rois.append(roi)
                    region.append('L')
                elif i == 1:
                    roi = cv2.selectROI("Select RIGHT crop", img=vid[0])
                    cv2.destroyWindow("Select RIGHT crop")
                    videos.append(video)
                    rois.append(roi)
                    region.append('R')

    df = pd.DataFrame(data=rois, index=[videos, region])
    df.to_csv(os.path.join(folder, "splitROIs.csv"))
    print("splitROIs.csv saved to:", os.path.join(folder, "splitROIs.csv"))


def split_video(video_path, outputFolder):

    vid_name = os.path.split(video_path)[-1]

    # get coords
    df = pd.read_csv(os.path.join(os.path.split(video_path)[0], "splitROIs.csv"), index_col=[0,1])
    coord_L = tuple(df.loc[os.path.split(video_path)[-1], "L"])
    coord_R = tuple(df.loc[os.path.split(video_path)[-1], "R"])

    try:
        os.mkdir(outputFolder)
    except OSError:
        print(outputFolder, "already exists! Continuing with the process without creating it.")

    for reg in ["L", "R"]:
        if reg == "L":
            reader = imageio.get_reader(video_path)
            fps = reader.get_meta_data()['fps']
            writer = imageio.get_writer(os.path.join(outputFolder, vid_name.strip('.mp4')+"_crop_L.mp4"), fps=fps)
            r = coord_L

            for im in reader:
                writer.append_data(im[int(r[1]):int(r[1] + r[3]), int(r[0]):int(r[0] + r[2])])
            writer.close()
        elif reg == "R":
            reader = imageio.get_reader(video_path)
            fps = reader.get_meta_data()['fps']
            writer = imageio.get_writer(os.path.join(outputFolder, vid_name.strip('.mp4') + "_crop_R.mp4"), fps=fps)
            r = coord_R

            for im in reader:
                writer.append_data(im[int(r[1]):int(r[1] + r[3]), int(r[0]):int(r[0] + r[2])])
            writer.close()


def splitVideos(folderPath, outputFolder, n_jobs=4):
    """This function will process all videos in a given folder using the above described functions and the csv file
    containing rectangular ROIs (maskROIs.csv)"""

    Parallel(n_jobs=n_jobs)(delayed(split_video)(os.path.join(folderPath, v), outputFolder)
                            for v in os.listdir(folderPath) if v.endswith(".mp4"))

if __name__ == "__main__":
    import sys
    splitVideos(sys.argv[1], sys.argv[2], int(sys.argv[3]))