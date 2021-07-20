import os
import numpy as np
import pandas as pd
from time import time
from tqdm import tqdm


def parse_dlc_output(path: os.path, suffix: str, likelihood_threshold=0.6):
    """path: path to dlc h5 output
    example suffix='DLC_resnet152_emotiposeMay10shuffle5_120000_el.h5'"""
    data = pd.read_hdf(path)
    full_name = os.path.split(path[:path.find(suffix)])[-1]
    splitted_name = full_name.split('_')
    cam = splitted_name[0] + '_' + splitted_name[1]
    date = splitted_name[2]
    rec = '_'.join(splitted_name[3:])

    data = data.droplevel(level=0, axis=1)
    data = data.droplevel(level=0, axis=1)
    keypoints, coordinates = data.columns.levels

    # Filter for low likelihood and less than and equal to zero coordinates
    for keypoint in keypoints:
        below_threshold = data.loc[:, (keypoint, 'likelihood')] < likelihood_threshold
        data.loc[below_threshold, :] = np.nan

    data = data[data.columns.drop('likelihood', level=1)]
    data.columns = ['__'.join(col) for col in data.columns]
    data.columns = pd.MultiIndex.from_product([[cam], data.columns])
    data.columns = ['__'.join(col) for col in data.columns]
    data.columns = pd.MultiIndex.from_product([['__'.join([date, rec])], data.columns])
    data.columns = ['__'.join(col) for col in data.columns]

    return data


def parse_dlc_outputs(folder: os.path, suffix: str, likelihood_threshold=0.6, scale=1, offset_x=0.0, offset_y=0.0):
    """Given a folder and a suffix, prepares the DLC outputs into a dictionary.
    example suffix='DLC_resnet152_emotiposeMay10shuffle5_120000_el.h5'"""
    h5s = [
        parse_dlc_output(
            path=os.path.join(folder, h5),
            suffix=suffix,
            likelihood_threshold=likelihood_threshold
        )
        for h5 in os.listdir(folder) if h5.endswith(suffix)
    ]

    aggregate = pd.concat(h5s, axis=1)

    print('Scaling and correcting for offsets')
    if scale != 1:
        aggregate = aggregate * scale
    for col in tqdm(aggregate.columns):
        if offset_x != 0.0 and col.endswith("_x"):
            aggregate.loc[:, col] = aggregate.loc[:, col] + offset_x
        elif offset_y != 0.0 and col.endswith('_y'):
            aggregate.loc[:, col] = aggregate.loc[:, col] + offset_y

    dates = []
    recs = []
    cams = []
    keypoints = []
    coords = []
    for colname in aggregate.columns:
        date, rec, cam, keypt, coord = colname.split("__")
        dates.append(date)
        recs.append(date + "_" + rec)
        cams.append(cam)
        keypoints.append(keypt)
        coords.append(coord)

    aggregate.columns = pd.MultiIndex.from_arrays([recs, keypoints, cams, coords])

    print('Writing .csv files in: {}'.format(folder))
    for rec in tqdm(aggregate.columns.get_level_values(0).unique()):
        data = aggregate.loc[:, rec]
        data.columns = ['__'.join(col) for col in data.columns]
        data = data.reindex(sorted(data.columns), axis=1)
        data.to_csv(os.path.join(folder, rec + ".csv"), index=False)


if __name__ == "__main__":
    import sys
    from time import time

    folder = sys.argv[1]  # Folder containing DLC tracking outputs
    suffix = sys.argv[2]  # DLC suffix (e.g. "DLC_resnet152_emotiposeMay10shuffle5_120000_el.h5")
    likelihood_threshold = float(sys.argv[3])  # Points below that threshold will not be used
    scale = int(sys.argv[4])  # Scaling factor (in case of a downsampled video tracking, use 1 for default)
    offset_x = float(sys.argv[5])  # Offset correction for camera ROI (in metadata.csv)
    offset_y = float(sys.argv[6])  # Offset correction for camera ROI (in metadata.csv)

    start = time()
    parse_dlc_outputs(
        folder=folder,
        suffix=suffix,
        likelihood_threshold=likelihood_threshold,
        scale=scale,
        offset_x=offset_x,
        offset_y=offset_y
    )
    print('Completed! Elapsed wall-time: {} seconds'.format(time() - start))
