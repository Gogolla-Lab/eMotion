import os
import numpy as np
import pandas as pd
from argus_gui import uv_to_xyz
from tqdm import tqdm
from joblib import Parallel, delayed


def load_csv_as_multiindex(csv_path):
    df = pd.read_csv(csv_path)
    column_names = np.array([col.split("__") for col in df.columns])
    keypoints = column_names[:, 0]
    cams = column_names[:, 1]
    coords = column_names[:, 2]
    index_tuples = list(zip(keypoints, cams, coords))
    df.columns = pd.MultiIndex.from_tuples(tuples=index_tuples, names=['keypoint', 'cam', 'coord'])
    return df


def triangulate_keypoints(data: pd.DataFrame, camera_profiles, dlt):
    result = []
    for keypoint in tqdm(data.columns.levels[0]):
        points = data.loc[:, keypoint].as_matrix()
        xyz = uv_to_xyz(pts=points, profs=camera_profiles, dlt=dlt)
        result.append(pd.DataFrame(data=xyz, columns=pd.MultiIndex.from_product([[keypoint], ['x', 'y', 'z']])))
    result = pd.concat(result, axis=1)
    return result


def single_csv(csv_path, camera_profiles, dlt):
    folder, name = os.path.split(csv_path)
    new_name = '3D__' + name
    data = load_csv_as_multiindex(csv_path)
    try:
        data = triangulate_keypoints(data, camera_profiles, dlt)
        data.to_csv(os.path.join(folder, new_name))
    except Exception as err:
        print(err)

if __name__ == "__main__":
    import sys
    from time import time

    start = time()

    dlt = sys.argv[1]
    camera_profiles = sys.argv[2]
    dlc_outputs_folder = sys.argv[3]

    dlt = np.loadtxt(dlt, delimiter=',').T
    camera_profiles = pd.read_csv(camera_profiles, delimiter=' ', index_col=0, header=None)
    camera_profiles = camera_profiles.drop(columns=[2, 3, 6]).as_matrix()

    files_count = len([csv for csv in os.listdir(dlc_outputs_folder) if csv.endswith('.csv')])

    if files_count < 30:
        n_jobs = files_count
    else:
        n_jobs = 16

    Parallel(
        n_jobs=n_jobs, verbose=100
    )(
        delayed(single_csv
                )(
            os.path.join(dlc_outputs_folder, csv), camera_profiles, dlt
        )
        for csv in os.listdir(dlc_outputs_folder) if (csv.endswith(".csv") and not csv.startswith('3D__'))
    )
    print('Completed! Elapsed wall-time: {} seconds'.format(time() - start))
    print('Triangulation results are saved into: {}'.format(dlc_outputs_folder))
