import os
import pandas as pd
import pims
from preprocessing.drawer import LineDrawer
from math import sqrt


def collect_lengths(folder):
    videos = [mp4 for mp4 in os.listdir(folder) if (mp4.endswith(".mp4"))]

    if not os.path.exists(os.path.join(folder, 'lengths.csv')):
        df = pd.DataFrame(index=videos, columns=['line', 'frame_shape', 'known_length_px', 'known_length_cm'])
        df.to_csv(os.path.join(folder, 'lengths.csv'))

    df = pd.read_csv(os.path.join(folder, 'lengths.csv'), index_col=0)
    for vid in df.index:
        if pd.isnull(df.loc[vid, 'line']):
            video = pims.Video(os.path.join(folder, vid))
            frame_shape = video.frame_shape
            df.loc[vid, 'frame_shape'] = str(frame_shape)
            ld = LineDrawer("Draw a LINE, RIGHT click when you're ready!", video[0])
            line = ld.run(thickness=1)
            df.loc[vid, 'line'] = str(line)
            known_length_px = sqrt((line[1][1] - line[0][1])**2 + (line[1][0] - line[0][0])**2)    # Euclidean distance
            df.loc[vid, 'known_length_px'] = known_length_px

            df.to_csv(os.path.join(folder, 'lengths.csv'))
    df.to_csv(os.path.join(folder, 'lengths.csv'))

folder = r"J:\Alja Podgornik\Multimaze arena\Cohort 1_June 2020\all_videos\processed"
collect_lengths(folder)