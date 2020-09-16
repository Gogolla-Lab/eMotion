import os
import numpy as np
import pandas as pd
from joblib import Parallel, delayed

pd.options.mode.chained_assignment = None  # default='warn'

# h5_path = r"J:\Alja Podgornik\Multimaze arena\Cohort 1_June 2020\all_videos\processed\withROIs\hr8_day5_withROIs-processed.h5"
def imputation(h5_path, bodypart_to_use='center', likelihood_threshold=0.25, dist_threshold_in_cm=0.1):
    main_df = pd.read_hdf(h5_path)
    videoname = os.path.split(h5_path)[-1][:-22] + '.mp4'

    # Convert speeds
    lengths = pd.read_csv(os.path.join(os.path.split(h5_path)[0], 'lengths.csv'), index_col=0)
    known_length_px = lengths.loc[videoname, 'known_length_px']
    known_length_cm = lengths.loc[videoname, 'known_length_cm']
    one_px = known_length_cm / known_length_px
    for speedcol in main_df.loc[:, main_df.columns.get_level_values(1) == 'speed']:
        main_df.loc[:, speedcol] = main_df.loc[:, speedcol] * one_px  # Convert dV/dt to cm/s

    # Zone classification
    consider = main_df.columns.get_level_values(0).unique()[1:8]

    unvisible = main_df.loc[:, main_df.columns.get_level_values(1) == 'likelihood'].loc[:, consider].mean(axis=1).le(
        0.10)
    mostly_visible = main_df.loc[:, main_df.columns.get_level_values(1) == 'likelihood'].loc[:, consider].mean(
        axis=1).gt(0.40)
    center_visible = main_df.loc[:, ('center', 'likelihood')] > 0.8
    visible = mostly_visible | center_visible

    snout_max = main_df.loc[:, main_df.columns.get_level_values(1) == 'likelihood'].idxmax(axis=1) == (
    'snout', 'likelihood')
    snout_in_social = main_df.loc[:, ('snout', 'social')]
    snout_in_drinking = main_df.loc[:, ('snout', 'drinking')]
    snout_unvisible = main_df.loc[:, ('snout', 'likelihood')].le(0.25)
    left_ear_in_social = main_df.loc[:, ('left_ear', 'social')]
    right_ear_in_social = main_df.loc[:, ('right_ear', 'social')]

    center_unclassified = main_df.loc[:, ('center', 'zone')].eq('unclassified')

    conditions = [(snout_in_drinking & visible), (unvisible & center_unclassified),
                  (visible & center_unclassified), (snout_max & snout_in_social),
                  (snout_unvisible & left_ear_in_social & right_ear_in_social)]
    choices = ['drinking', 'eating', 'interzone', 'social', 'social']
    main_df['zone'] = np.select(conditions, choices, default=main_df[('center', 'zone')])

    print('Unique zones are:', main_df['zone'].unique())
    unclassified = main_df[main_df['zone'] == 'unclassified']
    print(len(unclassified), 'frames in this video are unclassified')
    # unclassified_likelihoods = main_df[main_df['zone'] == 'unclassified'].loc[:, main_df.columns.get_level_values(1) == 'likelihood']
    # unclassified_likelihoods.plot.density()
    # plt.show()

    # Label periods and opto
    conditions = [
        main_df['time'].le(15 * 60),
        (main_df['time'].gt(15 * 60) & main_df['time'].le(30 * 60)),
        (main_df['time'].gt(30 * 60) & main_df['time'].le(45 * 60)),
        main_df['time'].gt(45 * 60)
    ]
    choices = ['q1', 'q2', 'q3', 'q4']
    choices2 = [False, True, False, True]
    main_df['period'] = np.select(conditions, choices, default='error')
    main_df['opto'] = np.select(conditions, choices2, default='error')

    # Add locomotion data
    loco = main_df[bodypart_to_use][['x', 'y', 'likelihood']]
    loco = loco[loco['likelihood'] > likelihood_threshold]
    loco['x_diff_px'] = loco.loc[:, 'x'].diff()
    loco['y_diff_px'] = loco.loc[:, 'y'].diff()
    loco['diff_cm'] = np.sqrt(np.square(loco['x_diff_px']) + np.square(loco['y_diff_px'])) * one_px
    loco_filtered = loco[loco['diff_cm'].ge(dist_threshold_in_cm)]
    loco_filtered.loc[0, :] = loco.iloc[0]
    loco_filtered = loco_filtered.sort_index()
    loco_filtered['x_diff_px'] = loco_filtered.loc[:, 'x'].diff()
    loco_filtered['y_diff_px'] = loco_filtered.loc[:, 'y'].diff()
    diff_cm = np.sqrt(np.square(loco_filtered['x_diff_px']) + np.square(loco_filtered['y_diff_px'])) * one_px
    loco_filtered['diff_cm'] = diff_cm
    loco_filtered['cum_dist_cm'] = loco_filtered['diff_cm'].cumsum()
    loco_filtered.loc[0, 'cum_dist_cm'] = 0
    main_df['cum_dist_cm'] = loco_filtered['cum_dist_cm']
    imputed_df = main_df

    return imputed_df


def get_bouts_df(imputed_df, bodypart_to_use='center', likelihood_threshold=0.25, bout_threshold_sec=3):
    # Collapse the bouts
    zones_shifted = imputed_df[imputed_df.zone != imputed_df.zone.shift(-1)]
    time_shifted = zones_shifted.loc[:, 'time'].shift(
        fill_value=float(zones_shifted.loc[zones_shifted.index[0], 'time']))
    time_differance = zones_shifted.loc[:, 'time'] - time_shifted
    zones_shifted['time'] = time_differance
    zones_shifted = zones_shifted[zones_shifted['time'] > bout_threshold_sec]
    # Repeat the process to merge the fragmented bouts after filtering out bouts shorter then bout_threshold_sec
    zones_shifted['time'] = zones_shifted['time'].cumsum()
    zones_shifted = zones_shifted[zones_shifted.zone != zones_shifted.zone.shift(-1)]
    time_shifted = zones_shifted.loc[:, 'time'].shift(fill_value=0)
    time_differance = zones_shifted.loc[:, 'time'] - time_shifted
    zones_shifted['time'] = time_differance
    zones_shifted = zones_shifted.rename(columns={'time': 'bout_duration', 'zone': 'bout_zone'}, level=0)
    bouts_df = zones_shifted

    # Add averaged_bout_velocities
    # Prepare bodypart marker data for the analysis
    bodypart_df = imputed_df.loc[:, bodypart_to_use]
    bodypart_df = bodypart_df.mask(bodypart_df['likelihood'] < likelihood_threshold)
    # bodypart_df = bodypart_df.dropna()
    speed = bodypart_df['speed']

    copy = bouts_df.copy()
    i = 0
    values = []
    for idx in copy.index:
        averaged_bout_velocity = speed[i:idx].mean()  # Speed is already converted to cm/s
        values.append(averaged_bout_velocity)
        i = idx
    bouts_df['bout_velocity'] = values

    return bouts_df


def clean_and_combine(imputed_df, bouts_df):
    imputed_df = imputed_df.loc[:, ['time', 'animal', 'group', 'day', 'zone', 'period', 'opto', 'cum_dist_cm']]
    imputed_df = imputed_df.droplevel(1, axis=1)
    bouts_df = bouts_df.loc[:,
               ['bout_duration', 'animal', 'group', 'day', 'bout_zone', 'period', 'opto', 'bout_velocity']]
    bouts_df = bouts_df.droplevel(1, axis=1)

    df = imputed_df.copy(deep=True)
    for col in bouts_df:
        if col not in imputed_df:
            df[col] = bouts_df[col]

    return df


def save_cleaned_df(df, save_folder):
    animal = df.loc[0, 'animal']
    day = df.loc[0, 'day']
    savename = animal + "_day" + str(day) + "_" + "clean" + '.csv'
    df.to_csv(os.path.join(save_folder, savename))


def execute_all_functions(h5_path, save_folder, bodypart_to_use='center', likelihood_threshold=0.25,
                          dist_threshold_in_cm=0.2, bout_threshold_sec=3):
    imputed_df = imputation(h5_path, bodypart_to_use, likelihood_threshold, dist_threshold_in_cm)
    bouts_df = get_bouts_df(imputed_df, bodypart_to_use, likelihood_threshold, bout_threshold_sec)
    df = clean_and_combine(imputed_df, bouts_df)
    save_cleaned_df(df, save_folder)


def execute_script_with_parallel(folder, outputfolder, n_jobs=32):
    files = [os.path.join(folder, h5) for h5 in os.listdir(folder) if h5.endswith('-processed.h5')]
    if not os.path.exists(outputfolder):
        os.mkdir(outputfolder)

    Parallel(n_jobs=n_jobs, verbose=100)(delayed(execute_all_functions)(file, outputfolder) for file in files)

folder = r"J:\Alja Podgornik\Multimaze arena\Cohort 1_June 2020\all_videos\processed\withROIs"
outputfolder = os.path.join(folder, 'cleaned')
execute_script_with_parallel(folder, outputfolder)
