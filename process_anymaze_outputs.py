import os
import pandas as pd
import tqdm
import sys

folder = sys.argv[1]
# folder = r"J:\Alja Podgornik\Multimaze arena\Cohort 1_June 2020\all_outputs_main\anymaze_outputs"
all_csvs = [csv for csv in os.listdir(folder) if csv.endswith('ROIs.csv')]

dtypes = {'social': 'bool', 'drinking': 'bool', 'marble': 'bool', 'nest': 'bool', 'black_circle': 'bool',
          'animal': 'category', 'day': 'category', 'group': 'category', 'stim': 'category', 'stim_bool': 'bool',
          'zone': 'category'}


def label_stim(row):
    if row['time'] <= 15 * 60:
        return 'stim1'
    elif 30 * 60 <= row['time'] < 45 * 60:
        return 'stim2'
    elif row['time'] >= 45 * 60:
        return 'nonstim2'
    elif 30 * 60 > row['time'] > 15 * 60:
        return 'nonstim1'


def label_stim_bool(row):
    if row['stim'] == 'stim1' or row['stim'] == 'stim2':
        return True
    else:
        return False


def label_zone(row):
    nest = row['nest']
    marble = row['marble']
    drinking = row['drinking']
    social = row['social']
    circle = row['black_circle']

    if (nest + marble + drinking + social + circle) == 0:
        return 'interspace'
    elif nest == 1:
        if (marble + drinking + social + circle) == 0:
            return 'nest'
        return 'exit1'
    elif marble == 1:
        if (nest + drinking + social + circle) == 0:
            return 'marble'
        return 'exit2'
    elif drinking == 1:
        if (nest + marble + social + circle) == 0:
            return 'drinking'
        return 'exit3'
    elif social == 1:
        if circle == 1:
            return 'eating_zone'
        elif circle == 0:
            return 'social'
        return 'exit4'
    else:
        return 'exit5'


read_data = {}

print('Processing .csv files!')
for csv in tqdm.tqdm(all_csvs):
    splitted_name = csv.rsplit(sep='_')
    if len(splitted_name) == 3:
        animal = splitted_name[0]
        day = int(splitted_name[1][-1])
        if animal.startswith('chr'):
            group = 'chr'
        elif animal.startswith('hr'):
            group = 'hr'
        elif animal.startswith('ctrl'):
            group = 'ctrl'
        csvdf = pd.read_csv(os.path.join(folder, csv), index_col=0)
        csvdf['animal'] = animal
        csvdf['group'] = group
        csvdf['day'] = day
        csvdf = csvdf.reset_index().rename(columns={'index': 'time'})
        csvdf['time'] = csvdf['time'] / 30
        csvdf['stim'] = csvdf.apply(lambda row: label_stim(row), axis=1)
        csvdf['stim_bool'] = csvdf.apply(lambda row: label_stim_bool(row), axis=1)
        csvdf['zone'] = csvdf.apply(lambda row: label_zone(row), axis=1)
        csvdf = csvdf.astype(dtypes)
        read_data[csv] = csvdf

save_folder = os.path.join(folder, 'cleaned_h5s')
if not os.path.exists(save_folder):
    print('Creating directory:', save_folder)
    os.mkdir(save_folder)
print('Saving processed data as .h5 files in the directory:', save_folder)
df_accu = pd.DataFrame()
for key in tqdm.tqdm(read_data):
    read_data[key].to_hdf(path_or_buf=os.path.join(save_folder, key[:-4] + '.h5'), key=key[:-4], format='table')
    df_accu = df_accu.append(read_data[key])
df_accu.to_hdf(path_or_buf=os.path.join(save_folder, 'accumulated.h5'), key='df_accu', format='table')
print('done!')
