import numpy as np
import pandas as pd
import pims
import cv2
import os
from ast import literal_eval
from drawer import CircleDrawer, PolygonDrawer
from shapely.geometry import Point
from shapely.geometry import box
from shapely.geometry import Polygon
from joblib import Parallel, delayed


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


def dlc_to_anymaze_output(csv_path, bodypart='center'):
    """Converts DLC output to anymaze output using analysis_rois.csv file"""

    folder, csv = os.path.split(csv_path)
    analysis_rois = pd.read_csv(os.path.join(folder, 'analysis_rois.csv'), index_col=0)

    # Create shapely ROI objects
    social = literal_eval(analysis_rois.loc[csv, '0:circle'])
    social = Point(social[0]).buffer(social[1])
    drinking = literal_eval(analysis_rois.loc[csv, '1:circle'])
    drinking = Point(drinking[0]).buffer(drinking[1])
    marble = literal_eval(analysis_rois.loc[csv, '2:rectangle'])
    marble = box(marble[0], marble[1], marble[0] + marble[2], marble[1] + marble[3])
    nest = literal_eval(analysis_rois.loc[csv, '3:rectangle'])
    nest = box(nest[0], nest[1], nest[0] + nest[2], nest[1] + nest[3])
    eating = literal_eval(analysis_rois.loc[csv, '4:rectangle'])
    eating = box(eating[0], eating[1], eating[0] + eating[2], eating[1] + eating[3])

    # Process each DataFrame
    dlc_df = pd.read_csv(csv_path, header=[1, 2])
    dlc_df = dlc_df[bodypart]   # Taking only one bodypart
    for frame in dlc_df.index:
        mouse_center = Point(dlc_df.loc[frame, 'x'], dlc_df.loc[frame, 'y'])
        dlc_df.loc[frame, 'social'] = mouse_center.intersects(social)
        dlc_df.loc[frame, 'drinking'] = mouse_center.intersects(drinking)
        dlc_df.loc[frame, 'marble'] = mouse_center.intersects(marble)
        dlc_df.loc[frame, 'nest'] = mouse_center.intersects(nest)
        dlc_df.loc[frame, 'eating'] = mouse_center.intersects(eating)
    dlc_df.to_csv(os.path.join(folder, csv[:-4] + '_ROIs.csv'))  # [:-4] is to remove '.csv' from the filename


def get_anymaze_outputs(folder, n_jobs=8):
    Parallel(n_jobs=n_jobs)(delayed(dlc_to_anymaze_output)(os.path.join(folder, csv))
                            for csv in os.listdir(folder) if (csv.endswith('.csv') and not csv.startswith('analysis')))