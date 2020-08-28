import numpy as np
import pandas as pd
import pims
import cv2
import os
import tqdm
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


def analyze_ROIs_on_dlc_output(h5_path, save=True):
    """Appends ROI analysis to the DLC output using analysis_rois.csv file"""

    # Read in analysis_rois.csv data, determine the folder and the video
    folder, video = os.path.split(h5_path)
    video = video[:video.find('DLC')] + '.mp4'
    analysis_rois = pd.read_csv(os.path.join(folder, 'analysis_rois.csv'), index_col=0)

    # Create shapely ROI objects
    social = literal_eval(analysis_rois.loc[video, '4:circle'])
    social = Point(social[0]).buffer(social[1])
    drinking = literal_eval(analysis_rois.loc[video, '2:circle'])
    drinking = Point(drinking[0]).buffer(drinking[1])
    marble = literal_eval(analysis_rois.loc[video, '0:rectangle'])
    marble = box(marble[0], marble[1], marble[0] + marble[2], marble[1] + marble[3])
    nest = literal_eval(analysis_rois.loc[video, '1:rectangle'])
    nest = box(nest[0], nest[1], nest[0] + nest[2], nest[1] + nest[3])
    mask_circle = literal_eval(analysis_rois.loc[video, '3:circle'])
    mask_circle = Point(mask_circle[0]).buffer(mask_circle[1])

    # Read in DLC tracking data (.h5)
    dlc_df = pd.read_hdf(h5_path)
    dlc_df.columns = dlc_df.columns.droplevel(0)

    # Computational block
    bodypart_dfs = []
    dtypes = {'social': 'bool', 'drinking': 'bool', 'marble': 'bool', 'nest': 'bool', 'mask_circle': 'bool',
              'zones_sum': 'int'}
    pd.options.mode.chained_assignment = None  # default='warn', this is to suppress Pandas warnings.
    print('Analyzing', len(dlc_df.columns.get_level_values(0).unique()), 'bodyparts..')
    for bodypart in tqdm.tqdm(dlc_df.columns.get_level_values(0).unique()):  # loop over bodyparts
        bodypart_df = dlc_df.loc[:, bodypart]  # take the bodypart x, y, likelihood as a separate df
        for frame in bodypart_df.index:
            bodypart_obj = Point(bodypart_df.loc[frame, 'x'], bodypart_df.loc[frame, 'y'])
            bodypart_df.loc[frame, 'drinking'] = int(bodypart_obj.intersects(drinking))
            bodypart_df.loc[frame, 'social'] = int(bodypart_obj.intersects(social))
            bodypart_df.loc[frame, 'marble'] = int(bodypart_obj.intersects(marble))
            bodypart_df.loc[frame, 'nest'] = int(bodypart_obj.intersects(nest))
            bodypart_df.loc[frame, 'mask_circle'] = int(bodypart_obj.intersects(mask_circle))
        bodypart_df['zones_sum'] = bodypart_df['drinking'] + bodypart_df['social'] + bodypart_df['marble'] + \
                                   bodypart_df['nest'] + bodypart_df['mask_circle']
        bodypart_df = bodypart_df.astype(dtypes)  # convert dtypes
        bodypart_df.columns = pd.MultiIndex.from_product([[bodypart], bodypart_df.columns])  # return to multiindex
        bodypart_dfs.append(bodypart_df)

    dlc_df = pd.concat(bodypart_dfs, axis=1)
    dlc_df.columns = dlc_df.columns.set_names(['bodyparts', 'coords'])

    # Writing to disk & returning
    if save:
        dlc_df.to_hdf(path_or_buf=os.path.join(folder, video[:-4] + '_withROIs.h5'), key="withROIs")
    return dlc_df


def analyze_ROIs_on_multiple_dlc_outputs(folder, n_jobs=16):
    Parallel(n_jobs=n_jobs)(delayed(analyze_ROIs_on_dlc_output)(os.path.join(folder, h5))
                            for h5 in os.listdir(folder) if (h5.endswith('.h5') and not h5.startswith('analysis')))


if __name__ == "__main__":
    import sys

    folder = sys.argv[1]
    array_task_id = int(sys.argv[2])
    h5_paths = [os.path.join(folder, h5) for h5 in os.listdir(folder) if
                (h5.endswith('.h5') and not (h5.startswith('analysis') or 'ROIs' in h5))]
    h5_path = h5_paths[array_task_id]
    analyze_ROIs_on_dlc_output(h5_path, save=True)
