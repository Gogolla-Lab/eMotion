import numpy as np
import pandas as pd
import shapely
import pims
import cv2
import os
from drawer import CircleDrawer, PolygonDrawer

folder = "J:\Alja Podgornik\Multimaze arena\Cohort 1_June 2020\\temporary\\temp_roi_analysis"


def collect_ROIs(folder):
    df_index = [csv for csv in os.listdir(folder) if (csv.endswith(".csv") and not csv.startswith('analysis'))]
    df = pd.DataFrame(index=df_index)

    how_many_rois = int(input("Enter how many ROIs you want to add (an integer number) and press enter: \n"))
    for i in range(how_many_rois):
        roitype = str(input("ROI nr. {}, please enter the roi type ('circle', 'rectangle' or 'polygon')".format(i + 1)))
        df[str(i) + ':' + roitype] = np.NaN

    df.to_csv(os.path.join(folder, 'analysis_rois.csv'))
    print(os.path.join(folder, 'analysis_rois.csv'), 'created!')


def draw_ROIs(folder):
    df = pd.read_csv(os.path.join(folder, 'analysis_rois.csv'), index_col=0)

    for i in df.index:
        for col in df.columns:
            videoname = i[:i.find('DLC')]+'.mp4'
            roitype = col[2:]
            roinr = int(col[:1])
            if pd.isnull(df.loc[i, col]):
                video = pims.Video(os.path.join(folder, videoname))
                if roitype == 'rectangle':
                    roi = str(cv2.selectROI('Select a rectangular ROI', video[0]))
                    cv2.destroyWindow('Select a rectangular ROI')
                elif roitype == 'polygon':
                    pgd = PolygonDrawer('Draw a POLYGON', video[0])
                    roi = str(pgd.run())
                elif roitype == 'circle':
                    cd = CircleDrawer('Draw a CIRCLE', video[0])
                    roi = str(cd.run())
                else:
                    raise BaseException
                df.loc[i, col] = roi
                df.to_csv(os.path.join(folder, 'analysis_rois.csv'))
                print(os.path.join(folder, 'analysis_rois.csv'), 'updated!')