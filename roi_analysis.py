import numpy as np
import pandas as pd
import pims
import cv2
import os
from ast import literal_eval
from drawer import CircleDrawer, PolygonDrawer
from shapely.geometry import Point
from shapely.geometry import box
# from shapely.geometry import Polygon
from joblib import Parallel, delayed


def collect_ROIs(folder):
    df_index = [mp4 for mp4 in os.listdir(folder) if
                (mp4.endswith(".mp4") and not mp4.startswith('analysis'))]
    df = pd.DataFrame(index=df_index)

    how_many_rois = int(input("Enter how many ROIs you want to add (an integer number) and press enter: \n"))
    for i in range(how_many_rois):
        roitype = \
            str(input(
                "ROI nr. {}, please enter the roi type ('circle', 'rectangle' or 'polygon')".format(i + 1)))
        df[str(i) + ':' + roitype] = np.NaN

    df.to_csv(os.path.join(folder, 'analysis_rois.csv'))
    print(os.path.join(folder, 'analysis_rois.csv'), 'created!')


def draw_ROIs(folder):
    df = pd.read_csv(os.path.join(folder, 'analysis_rois.csv'), index_col=0)

    for col in df.columns:
        for i in range(5):
            print('new column!')
        for vid in df.index:
            roinr = col[:2]
            roitype = col[2:]
            if pd.isnull(df.loc[vid, col]):
                video = pims.Video(os.path.join(folder, vid))
                if roitype == 'rectangle' or roitype == 'rect':
                    roi = str(cv2.selectROI('Select a rectangular ROI for ROI nr. {}'.format(roinr), video[0]))
                    cv2.destroyWindow('Select a rectangular ROI for ROI nr. {}'.format(roinr))
                elif roitype == 'polygon':
                    pgd = PolygonDrawer('Draw a POLYGON', video[0])
                    roi = str(pgd.run())
                elif roitype == 'circle':
                    cd = CircleDrawer('Draw a CIRCLE ROI for ROI nr. {}'.format(roinr), video[0])
                    roi = str(cd.run(fill=False))
                else:
                    print(roinr, roitype)
                    raise BaseException
                df.loc[vid, col] = roi
                df.to_csv(os.path.join(folder, 'analysis_rois.csv'))
                print(os.path.join(folder, 'analysis_rois.csv'), 'updated!')


def dlc_to_anymaze_output(csv_path, bodypart='center'):
    """Converts DLC output to anymaze output using analysis_rois.csv file"""
# todo: needs to be made compatible with the above functions (above functions are changed so that the analysis_rois have videonames as indexes instead of csv names!)
    folder, csv = os.path.split(csv_path)
    analysis_rois = pd.read_csv(os.path.join(folder, 'analysis_rois.csv'), index_col=0)

    # Create shapely ROI objects
    social = literal_eval(analysis_rois.loc[csv, '4:circle'])
    social = Point(social[0]).buffer(social[1])
    drinking = literal_eval(analysis_rois.loc[csv, '2:circle'])
    drinking = Point(drinking[0]).buffer(drinking[1])
    marble = literal_eval(analysis_rois.loc[csv, '0:rectangle'])
    marble = box(marble[0], marble[1], marble[0] + marble[2], marble[1] + marble[3])
    nest = literal_eval(analysis_rois.loc[csv, '1:rectangle'])
    nest = box(nest[0], nest[1], nest[0] + nest[2], nest[1] + nest[3])
    black_circle = literal_eval(analysis_rois.loc[csv, '3:circle'])
    black_circle = Point(black_circle[0]).buffer(black_circle[1])


    # Process each DataFrame
    dlc_df = pd.read_csv(csv_path, header=[1, 2])
    dlc_df = dlc_df[bodypart]  # Take only one body part
    for frame in dlc_df.index:
        mouse_center = Point(dlc_df.loc[frame, 'x'], dlc_df.loc[frame, 'y'])
        dlc_df.loc[frame, 'social'] = int(mouse_center.intersects(social))
        dlc_df.loc[frame, 'drinking'] = int(mouse_center.intersects(drinking))
        dlc_df.loc[frame, 'marble'] = int(mouse_center.intersects(marble))
        dlc_df.loc[frame, 'nest'] = int(mouse_center.intersects(nest))
        dlc_df.loc[frame, 'black_circle'] = int(mouse_center.intersects(black_circle))
    dlc_df.to_csv(os.path.join(folder, csv[:-4] + '_ROIs.csv'))  # [:-4] is to remove '.csv' from the filename
    # ToDo: if average likelihood of all bodyparts are below a certain threshold, the mouse must be in the eating zone!
    # Todo: maximum likelihood can be used!

def get_anymaze_outputs(folder, n_jobs=16):
    Parallel(n_jobs=n_jobs)(delayed(dlc_to_anymaze_output)(os.path.join(folder, csv))
                            for csv in os.listdir(folder) if (csv.endswith('.csv') and not csv.startswith('analysis')))


if __name__ == "__main__":
    import sys

    folder = sys.argv[1]
    array_task_id = int(sys.argv[2])
    csv_paths = [os.path.join(folder, c) for c in os.listdir(folder) if
                 (c.endswith('.csv') and not c.startswith('analysis'))]
    csv_path = csv_paths[array_task_id]
    dlc_to_anymaze_output(csv_path=csv_path, bodypart='center')
