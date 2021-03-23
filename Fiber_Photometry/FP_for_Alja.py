#load and process data for fiber photometry experiments
#smooth and fit data with auto signal

import os
import numpy as np
import pandas as pd
import scipy
import matplotlib.pyplot as plt
from scipy.signal import savgol_filter, butter, lfilter, filtfilt


def read_summary_file(file_path):

    summ_file = pd.ExcelFile(file_path)
    sheets = list(summ_file.sheet_names)
    sheet_dfs = []

    for sheet in sheets:
        df = pd.read_excel(summ_file, header=0, sheet_name=sheet, dtype=object)
        day = int(sheet[-1])
        df['Day'] = [day for i in range(len(df))]
        sheet_dfs.append(df)

    all_data = pd.concat(sheet_dfs)
    return all_data


def load_data_FP(exp_metadata):

    fp_file = os.path.join(exp_metadata['Raw Data Folder'], exp_metadata['FP file'] + '.csv')

    # load the corresponding fp file (ignore the first raw with text)
    csv = pd.read_csv(fp_file, skiprows=2)  # , skiprows = (0), skipfooter =(10))
    fp_times = csv.values[:, exp_metadata['ts']]
    auto = csv.values[:, exp_metadata['auto column']]
    gcamp = csv.values[:, exp_metadata['gcamp column']]

    # convert array of object to array of float
    gcamp = gcamp.astype(np.float)
    auto = auto.astype(np.float)

    # replace NaN's with closest non-NaN
    mask = np.isnan(gcamp)
    gcamp[mask] = np.interp(np.flatnonzero(mask), np.flatnonzero(~mask), gcamp[~mask])
    mask_auto = np.isnan(auto)
    auto[mask_auto] = np.interp(np.flatnonzero(mask_auto), np.flatnonzero(~mask_auto), auto[~mask_auto])

    auto = remove_large_jumps(auto)
    gcamp = remove_large_jumps(gcamp)
    #fig = plt.figure(), plt.plot(auto), plt.show()
    #fig = plt.figure(), plt.plot(gcamp), plt.show()


    # compute the dff, adapted from Alex's matlab code
    # smoothing the data by applying filter
    auto = savgol_filter(auto, 21, 2)
    gcamp = savgol_filter(gcamp, 21, 2)

    # fitting like in LERNER paper
    controlFit = lernerFit(auto, gcamp)
    # dff = (gcamp - controlFit) / controlFit
    
    # Compute DFF
    dff = (gcamp - auto) / auto
    dff = dff * 100
    
    # zscore whole data set with overall median
    mediandff = np.median(dff)
    stdevdff = np.std(dff)
    dffzscore = (dff - mediandff) / stdevdff
    
    # Remove homecage period baseline
    # dff_rem_base = remove_baseline(fp_times, gcamp, start_time=0, end_time=240)
    # dff_rem_base = dff_rem_base * 100
    

    return fp_times, auto, gcamp, dff, dffzscore


def remove_baseline(time_trace, f_trace, start_time=None, end_time=None):
    if start_time is not None:
        start_idx, _ = find_nearest(time_trace, start_time)
    else:
        start_idx = 0
        
    if end_time is not None:
        end_idx, _ = find_nearest(time_trace, end_time)
    else:
        end_idx = -1
    
    baseline = np.median(f_trace[start_idx:end_idx])
    return f_trace - baseline


def find_nearest(array, value):
    array = np.asarray(array)
    idx = (np.abs(array - value)).argmin()
    return idx, array[idx]


def butter_lowpass(cutoff, fs, order=5):
    nyq = 0.5 * fs
    normal_cutoff = cutoff / nyq
    b, a = butter(order, normal_cutoff, btype='low', analog=False)
    return b, a

def butter_lowpass_filter(data, cutoff, fs, order=5):
    b, a = butter_lowpass(cutoff, fs, order=order)
    y = filtfilt(b, a, data)
    return y

def remove_large_jumps(trace, percentile=0.95):
    
    filtered_trace = trace.copy()
    
    med = np.median(trace)
    mask = np.argwhere((trace < percentile*med))
    filtered_trace[mask] = med
    
    return filtered_trace
   

def lernerFit(auto, gcamp, power=1):
    # fitting like in LERNER paper
    # https://github.com/talialerner
    reg = np.polyfit(auto, gcamp, power)
    a = reg[0]
    b = reg[1]
    controlFit = a * auto + b
    return controlFit


# definition for downsampling
def ds(ts, signal, ds_factor):
    signal_ds = np.mean(np.resize(signal,
                                  (int(np.floor(signal.size / ds_factor)), ds_factor)), 1)
    ds_ts = ts[np.arange(int(np.round(ds_factor / 2)), ts.size, ds_factor)]
    # trim off last time stamp if necessary
    ds_ts = ds_ts[0:signal_ds.size]
    return ds_ts, signal_ds


# find CS bool - boolean of CS duration
def find_CS_bool(ts, start_times_CSplus, end_times_CSplus):
    CS_bool = np.zeros(ts.size, dtype=bool)
    preCS_bool = np.zeros(ts.size, dtype=bool)
    postCS_bool = np.zeros(ts.size, dtype=bool)
    for j in np.arange(start_times_CSplus.size):
        start_CS_ind = np.argmin(np.abs(ts - start_times_CSplus[j]))
        end_CS_ind = np.argmin(np.abs(ts - end_times_CSplus[j]))
        CS_bool[start_CS_ind:end_CS_ind] = True
        start_preCS_ind = np.argmin(np.abs(ts - (start_times_CSplus[j] - 30)))
        end_preCS_ind = np.argmin(np.abs(ts - (end_times_CSplus[j] - 30)))
        preCS_bool[start_preCS_ind:end_preCS_ind] = True
        start_postCS_ind = np.argmin(np.abs(ts - (start_times_CSplus[j] + 30)))
        end_postCS_ind = np.argmin(np.abs(ts - (end_times_CSplus[j] + 30)))
        postCS_bool[start_postCS_ind:end_postCS_ind] = True

    return CS_bool, preCS_bool, postCS_bool


def tsplotSlice(corrData, shockStartTimepoints, windowPlusMinus):
    counter = 0
    # tempDf1 = pd.DataFrame()
    tempDf1 = []
    for i in shockStartTimepoints:
        temp1 = corrData[(i - windowPlusMinus): (i + windowPlusMinus)]
        tempDf1.append(temp1)

        counter = counter + 1

    return np.array(tempDf1)


if __name__ == "__main__":

    summary_file_path =  r"J:\Alja Podgornik\FP_Alja\Multimaze sheet summary.xlsx"   # Set this to wherever it is
    save_directory = r"J:\Alja Podgornik\FP_Alja\FP_processed data"                         # Set this to wherever you want

    # Read the summary file as a pandas dataframe
    all_data = read_summary_file(summary_file_path)

    # Go row by row through the summary data
    for idx, row in all_data.iterrows():
        data = {}

        # load the raw data from 1 rec at a time
        fp_times, auto, gcamp, dff, dffzscore, = load_data_FP(row)

        data['ani_id'] = row['Ani_ID']
        data['ts'] = fp_times
        data['auto'] = auto
        data['gcamp'] = gcamp
        data['dff'] = dff
        data['zscore'] = dffzscore

        # save dictionaries using numpy
        # File format is save_directory/Ani_ID.npy
        # I would suggest using a different file format like hdf5, but this is
        # fine for now.
        np.save(os.path.join(save_directory, str(row['Ani_ID']) + '.npy'), data)
        
        fig = plt.figure(figsize=(15,10))
        plt.plot(data['ts'], data['zscore'])
        plt.title(str(row['Ani_ID']) + " Z-Score DFF")
        plt.xlabel('Time (s)')
        plt.ylabel('Z-Score DFF')
        # plt.show()
        plt.savefig(os.path.join(save_directory, str(row['Ani_ID']) + '_gcamp_ts.png'), format="png")
