import os
import numpy as np
import pandas as pd
from scipy.signal import savgol_filter
from joblib import Parallel, delayed


def apply_savgol_filter(df, window_length=15, polyorder=3, mode='nearest'):
    bodyparts = df.columns.get_level_values(0).unique()

    for bp in bodyparts:
        df[(bp, 'x')] = savgol_filter(x=df[(bp, 'x')], window_length=window_length, polyorder=polyorder, mode=mode)
        df[(bp, 'y')] = savgol_filter(x=df[(bp, 'y')], window_length=window_length, polyorder=polyorder, mode=mode)

    return df


def insert_zones(df):
    choices = ['nest', 'marble', 'social', 'drinking', 'mask_circle']

    bodyparts = df.columns.get_level_values(0).unique()

    for bp in bodyparts:
        conditions = [
            (df[(bp, 'nest')].eq(1) & df[(bp, 'zones_sum')].eq(1)),
            (df[(bp, 'marble')].eq(1) & df[(bp, 'zones_sum')].eq(1)),
            (df[(bp, 'social')].eq(1) & df[(bp, 'zones_sum')].eq(1)),
            (df[(bp, 'drinking')].eq(1) & df[(bp, 'zones_sum')].eq(1)),
            (df[(bp, 'mask_circle')].eq(1) & df[(bp, 'zones_sum')].eq(1)),
        ]

        df[(bp, 'zone')] = np.select(conditions, choices, default='unclassified')

    return df


def insert_speed(df):
    bodyparts = df.columns.get_level_values(0).unique()

    for bp in bodyparts:
        x = df[(bp, 'x')]
        shifted_x = x.shift(-1)
        diff_x_squared = np.square(shifted_x - x)
        y = df[(bp, 'y')]
        shifted_y = y.shift(-1)
        diff_y_squared = np.square(shifted_y - y)
        df[(bp, 'speed')] = np.sqrt(diff_x_squared + diff_y_squared)

    return df


def drop_low_likelihoods(df):
    pass


def process_h5_file(h5_path, save=True):
    folder, h5_name = os.path.split(h5_path)
    splitted_name = h5_name.rsplit(sep='_')
    if len(splitted_name) == 3:
        animal = splitted_name[0]
        day = int(splitted_name[1][-1])
        if animal.startswith('chr'):
            group = 'chr'
        elif animal.startswith('hr'):
            group = 'hr'
        elif animal.startswith('ctrl'):
            group = 'ctrl'
        h5df = pd.read_hdf(os.path.join(folder, h5_path))
        h5df = apply_savgol_filter(h5df)
        h5df = insert_speed(h5df)
        h5df = insert_zones(h5df)
        h5df['animal'] = animal
        h5df['group'] = group
        h5df['day'] = day
        h5df = h5df.reset_index().rename(columns={'index': 'time'})
        h5df['time'] = h5df['time'] / 30

    if save:
        h5df.to_hdf(os.path.join(folder, h5_name[:-3] + '-processed.h5'), key='processed')

    return h5df


def process_all_h5s(folder, n_jobs=32):

    Parallel(n_jobs=n_jobs, verbose=100)(delayed(process_h5_file)(os.path.join(folder, h5))
                                         for h5 in os.listdir(folder) if
                                         (h5.endswith('withROIs.h5') and len(h5.rsplit(sep='_')) == 3)
                                         and not h5.startswith('accumulated'))


if __name__ == "__main__":
    import sys
    import time

    folder = sys.argv[1]
    t0 = time.time()
    process_all_h5s(folder)
    t1 = time.time()
    print("Script successfully executed and finished in", round(t1-t0, 3), 'seconds!!!')