import os
import pandas as pd
import tqdm
import sys

folder = sys.argv[1]
# folder = r"J:\Alja Podgornik\Multimaze arena\Cohort 1_June 2020\all_outputs_main\anymaze_outputs"
all_csvs = [csv for csv in os.listdir(folder) if csv.endswith('.csv')]

df = pd.DataFrame()
read_data = {}

dtypes = {'social': 'bool', 'drinking': 'bool', 'marble': 'bool', 'nest': 'bool', 'black_circle': 'bool',
          'animal': 'category', 'day': 'category', 'group': 'category', 'stim': 'category', 'stim_bool': 'bool'}


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
        csvdf = csvdf.astype(dtypes)
        read_data[csv] = csvdf

save_folder = os.path.join(folder, 'cleaned_h5s')
if not os.path.exists(save_folder):
    os.mkdir(save_folder)
for key in tqdm.tqdm(read_data):
    read_data[key].to_hdf(path_or_buf=os.path.join(save_folder, key[:-4]+'.h5'), key=key[:-4], format='table')
