import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import os
from os.path import join
from datetime import timedelta, datetime
import matplotlib.dates as md
from scipy.signal import medfilt
from scipy.stats import sem



def find_nearest(array, value):
    array = np.asarray(array)
    idx = (np.abs(array - value)).argmin()
    return idx, array[idx]


def get_sec_from_min_sec(time: float):
     split_time = str(time).split('.')
     minutes = int(split_time[0])
     seconds = int(split_time[1])
     return minutes*60 + seconds



def get_mpl_datetime(time: float, seconds_adjustment=0):
    """ Time comes in format min.sec"""
    zero = datetime(2021, 1, 1)

    split_time = str(time).split('.')
    dt = timedelta(minutes=int(split_time[0]), seconds=int(split_time[1]) + seconds_adjustment)
    return md.date2num(zero + dt)


def mpl_datetime_from_seconds(time):
    """ Takes either an integer or an array and converts it to mpl datetime format"""
    zero = datetime(2021, 1, 1)

    if isinstance(time, int):
        return md.date2num(zero + timedelta(seconds=time))
    else:
        return [md.date2num(zero + timedelta(seconds=t)) for t in time]


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


def load_from_excel_summary(exp_metadata):
    ani_id = str(exp_metadata['Ani_ID'])

    behavior_label_path = exp_metadata['Behavior Labelling']
    behavior_filename = r"ID{}_Day{}.xlsx".format(*ani_id.split('.'))
    x = pd.ExcelFile(join(behavior_label_path, behavior_filename))
    behavior_labels = pd.read_excel(x, header=0, dtype=object)

    preprocessed_data_path = exp_metadata['Preprocessed Data']
    dff_filename = r"{}.npy".format(ani_id)               # change path
    data = np.load(join(preprocessed_data_path, dff_filename), allow_pickle=True)
    data = data.item()

    return data, behavior_labels


def find_episodes(time, f_trace, labels, key, period=(-5, 5), dwell_filter=0):
     exp_episodes = []
     
     # Convert seconds into HH:MM:SS format
     # time_HMS = mpl_datetime_from_seconds(time)
     
     if "Zone" in key:
         start_end = labels[[" ".join([key, "In"]), " ".join([key, "Out"])]].dropna().to_numpy()
     else:
         start_end = labels[[" ".join([key, "Start"]), " ".join([key, "End"])]].dropna().to_numpy()
    
     if len(start_end) > 0:
         vfunc = np.vectorize(get_sec_from_min_sec)
         start_end = vfunc(start_end)
         
         for episode in start_end:
             
             dwell_time = episode[1] - episode[0]
             
             if dwell_time <= dwell_filter:
                 
                 start_idx, start_time = find_nearest(time, episode[0] + period[0])
                 end_idx, end_time = find_nearest(time, episode[0] + period[1])
                 
                 exp_episodes.append([time[start_idx:end_idx], f_trace[start_idx:end_idx]])

     return exp_episodes


def flatten_list(list_of_lists):
    return [item for sublist in list_of_lists for item in sublist]


def list_lists_to_array(list_of_lists):
    max_length = max([len(l) for l in list_of_lists])
    new_array = np.empty((len(list_of_lists), max_length))
    new_array[:] = np.NaN
    
    for row, l in enumerate(list_of_lists):
        new_array[row, :len(l)] = l
    
    return new_array


def get_mean_episode(episodes):
    time = [e[0] for e in episodes]
    f_traces = [e[1] for e in episodes]

    trace_array = list_lists_to_array(f_traces)
    
    mean_trace = np.nanmean(trace_array, axis=0)
    std_trace = np.nanstd(trace_array, axis=0)
    
    return trace_array, mean_trace, std_trace

# norm.window here is a default; if you don't pass the parameter in the code lower down it will resort to -5
def remove_baseline(time, traces, norm_window=-5):
    idx, _ = find_nearest(time, 0)
    wind_idx, _ = find_nearest(time, norm_window)
    baseline = np.median(traces[:, wind_idx:idx], axis=1)
    traces = traces - np.expand_dims(baseline, axis=1)
    return traces


if __name__ == "__main__":

    summary_file_path = r'Multimaze sheet summary.xlsx'    # Set this to wherever it is
    save_directory = r"J:\Alja Podgornik\FP_Alja\plots"    # Set this to wherever you want

    # Read the summary file as a pandas dataframe
    all_exps = read_summary_file(summary_file_path)
    
    # remove certain days
    exps_to_run = all_exps
    #exps_to_run = all_exps.loc[all_exps["Day"] == 3]

    # Which behavior do you want to look at
    key_to_plot = 'Eating Zone'
    period = (-5, 10)
    dfilt = 30
    all_episodes = []

    # Go row by row through the summary data
    for idx, row in exps_to_run.iterrows():

        try:
            # load the raw data from 1 rec at a time
            data, labels = load_from_excel_summary(row)
    
            Ani_ID = data['ani_id']
            time = data['ts']
            auto = data['auto']
            gcamp = data['gcamp']
            dff = data['dff']
            dffzscore = data['zscore']
            
            dffzscore = medfilt(dffzscore, kernel_size=51)
            
            exp_episodes = find_episodes(time, dffzscore, labels, key_to_plot, period=period, dwell_filter=dfilt)
            all_episodes.append(exp_episodes)
        
        except FileNotFoundError as error:
            print(str(error))
    
    all_episodes = flatten_list(all_episodes)
    all_episodes = list(filter(None, all_episodes))
    f_traces = [e[1] for e in all_episodes]
    trace_array = list_lists_to_array(f_traces)
    
    num_episodes = trace_array.shape[0]
    print("Number of {} trials = {}".format(key_to_plot, num_episodes))
    
    t = np.linspace(*period, trace_array.shape[-1])
    trace_array = remove_baseline(t, trace_array, norm_window=-5)
    
    mean_trace = np.nanmean(trace_array, axis=0)
    sem_trace = sem(trace_array, axis=0, nan_policy='omit')
    
    fig = plt.figure(figsize=(10,10))
    #for trace in trace_array:
         #plt.plot(t, trace)
        
    plt.fill_between(t, mean_trace - sem_trace, mean_trace + sem_trace, alpha=0.2)
    plt.plot(t, mean_trace, c='k', linewidth=2)
    #plt.ylim([-0.25, 1.5])
    plt.axvline(0, color="orangered")
    plt.text(-4.5, 0.3, "n = " + str(num_episodes), fontsize='large')
        
    plt.xlabel('Time from Behavior Start (s)')
    plt.ylabel('$\Delta$FF Z-score minus')
    plt.title('Mean trace for {}'.format(key_to_plot))
    
    plt_name = "mean_{}_dff_zscore.png".format(key_to_plot.lower())
    plt.savefig(join(save_directory, plt_name))
    plt.show()
    

