import os
import numpy as np
import pandas as pd
import pims
from drawer import LineDrawer

def collect_lenghts(folder):

    videos = [mp4 for mp4 in os.listdir(folder) if (mp4.endswith(".mp4"))]

    if not os.path.exists(os.path.join(folder, 'lenghts.csv')):
        df = pd.DataFrame(index=videos, columns=['line', 'known_length_px', 'known_length_cm', 'frame_shape'])
        df.to_csv(os.path.join(folder, 'lenghts.csv'))

    df = pd.read_csv(os.path.join(folder, 'lenghts.csv'), index_col=0)
    for vid in df.index:
        if pd.isnull(df.loc[vid, 'line']):
            video = pims.Video(os.path.join(folder, vid))
            ld = LineDrawer("Draw a LINE, RIGHT click when you're ready!")
            line = (ld.run(thickness=1))
            df.loc[vid, 'line'] = line