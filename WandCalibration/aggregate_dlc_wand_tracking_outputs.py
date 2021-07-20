import os
import numpy as np
import pandas as pd
from time import time


def parse_h5(h5_path, likelihood_threshold=0.97, scale=1, offset_x=0.0, offset_y=0.0):
    cam = 'Cam_' + os.path.split(h5_path)[1].split('_')[1]
    data = pd.read_hdf(h5_path)
    data = data.droplevel(level=0, axis=1)
    keypoints, coordinates = data.columns.levels

    # Filter for low likelihood and less than and equal to zero coordinates
    for keypoint in keypoints:
        below_threshold = data.loc[:, (keypoint, 'likelihood')] < likelihood_threshold
        data.loc[below_threshold, :] = np.nan
        for coordinate in coordinates:
            negative = data.loc[:, (keypoint, coordinate)] <= 0
            data.loc[negative, :] = np.nan

    data = data[data.columns.drop('likelihood', level=1)]
    data.columns = ['__'.join(col) for col in data.columns]
    data.columns = pd.MultiIndex.from_product([[cam], data.columns])
    data.columns = ['__'.join(col) for col in data.columns]

    # Scale and correct for offsets
    data = data * scale
    for col in data.columns:
        if col.endswith('x'):
            data.loc[:, col] = data.loc[:, col] + offset_x
        elif col.endswith('y'):
            data.loc[:, col] = data.loc[:, col] + offset_y

    return data


if __name__ == "__main__":
    import sys
    from time import time

    folder = sys.argv[1]  # Folder containing DLC outputs for wand tracking
    scale = int(sys.argv[2])  # Correction factor (if downsized videos were used for wand tracking)
    offset_x = float(sys.argv[3])  # Offset correction (x) for camera ROI (in metadata.csv)
    offset_y = float(sys.argv[4])  # Offset correction (y) for camera ROI (in metadata.csv)

    start = time()
    aggregate = [
        parse_h5(
            h5_path=os.path.join(folder, h5),
            likelihood_threshold=0.97,
            scale=scale,
            offset_x=offset_x,
            offset_y=offset_y
        )
        for h5 in os.listdir(folder) if h5.endswith('.h5')
    ]
    data = pd.concat(aggregate, axis=1)

    cams = []
    tracks = []
    coords = []
    for colname in data.columns:
        cam, track, coord = colname.split('__')
        cams.append(cam)
        tracks.append(track)
        coords.append(coord)

    data.columns = pd.MultiIndex.from_arrays([cams, tracks, coords])
    data.columns = data.columns.swaplevel(0, 1)
    data.columns = ['__'.join(col) for col in data.columns]
    data = data.reindex(sorted(data.columns), axis=1)
    data.to_csv(os.path.join(folder, 'aggregated_xypts.csv'), index=False)

    print('wand_aggregated_xypts.csv is saved into: {}'.format(folder))
    print('Completed! Elapsed wall-time: {} seconds'.format(time() - start))
    print('Please do not forget to sort the columns with the track/cam/coordinate order if needed!')
