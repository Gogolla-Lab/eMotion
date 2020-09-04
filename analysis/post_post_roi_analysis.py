import os
import numpy as np
import pandas as pd

pd.options.mode.chained_assignment = None  # default='warn'
h5 = r"J:\Alja Podgornik\Multimaze arena\Cohort 1_June 2020\all_videos\processed\withROIs\hr6_day2_withROIs-processed.h5"



def imputation(h5_path):

    main_df = pd.read_hdf(h5)
    videoname = os.path.split(h5)[-1][:-22] + '.mp4'

    # Convert speeds
    lengths = pd.read_csv(os.path.join(os.path.split(h5)[0], 'lengths.csv'), index_col=0)
    known_length_px = lengths.loc[videoname, 'known_length_px']
    known_length_cm = lengths.loc[videoname, 'known_length_cm']
    one_px = known_length_cm / known_length_px

    for speedcol in main_df.loc[:, main_df.columns.get_level_values(1) == 'speed']:
        main_df.loc[:, speedcol] = main_df.loc[:, speedcol]*one_px

    # Zone classification
    consider = main_df.columns.get_level_values(0).unique()[1:8]

    unvisible = main_df.loc[:, main_df.columns.get_level_values(1) == 'likelihood'].loc[:, consider].mean(axis=1).le(0.10)
    mostly_visible = main_df.loc[:, main_df.columns.get_level_values(1) == 'likelihood'].loc[:, consider].mean(axis=1).gt(0.40)
    center_visible = main_df.loc[:, ('center', 'likelihood')] > 0.8
    visible = mostly_visible | center_visible

    snout_max = main_df.loc[:, main_df.columns.get_level_values(1) == 'likelihood'].idxmax(axis=1) == ('snout', 'likelihood')
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
    imputed = main_df

    return imputed


def get_bouts_df(imputed, bout_threshold=1.5):

    # Collapse the bouts
    zones_shifted = imputed[imputed.zone != imputed.zone.shift(-1)]
    time_shifted = zones_shifted.loc[:, 'time'].shift(fill_value=float(zones_shifted.loc[zones_shifted.index[0], 'time']))
    time_differance = zones_shifted.loc[:, 'time'] - time_shifted
    zones_shifted['time'] = time_differance
    zones_shifted = zones_shifted[zones_shifted['time'] > bout_threshold]
    # Repeat the process to merge the fragmented bouts after filtering out bouts shorter then 3 secs
    zones_shifted['time'] = zones_shifted['time'].cumsum()
    zones_shifted = zones_shifted[zones_shifted.zone != zones_shifted.zone.shift(-1)]
    time_shifted = zones_shifted.loc[:, 'time'].shift(fill_value=0)
    time_differance = zones_shifted.loc[:, 'time'] - time_shifted
    zones_shifted['time'] = time_differance
    zones_shifted = zones_shifted.rename(columns={'time':'bout_duration'}, level=0)
    bouts_df = zones_shifted

    # Add averaged_bout_velocities
    # Prepare center marker data for the velocity and the locomotion analysis
    center_df = imputed.loc[:, 'center']
    center_df = center_df.mask(center_df['likelihood'] < 0.5)
    # center_df = center_df.dropna()
    speed = center_df['speed']

    copy = bouts_df.copy()
    i = 0
    values = []
    for idx in copy.index:
        averaged_bout_velocity = speed[i:idx].mean()
        values.append(averaged_bout_velocity)
        i = idx
    bouts_df['bout_velocity'] = values

    return bouts_df





# bouts_df.to_hdf(os.path.split(h5)[-1][-12]+'bouts.h5', key=bouts)
# sb.catplot(data=zones_shifted, kind='box', y='time', x='zone', hue='period')
# plt.show()