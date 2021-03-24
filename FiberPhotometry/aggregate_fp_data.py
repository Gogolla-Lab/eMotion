import sys
import numpy as np
import pandas as pd
from os.path import join
from FiberPhotometry.color_code_behavior import mpl_datetime_from_seconds
from FiberPhotometry.color_code_behavior import find_nearest
from FiberPhotometry.color_code_behavior import get_mpl_datetime

main_dir = r"J:\Alja Podgornik\FP_Alja"


def return_animal_data(animal, day):
    """returns ts(timestamp), dff, dffzscore, behav_bouts and zone_bouts as arrays for the given animal and day"""

    dff_filename = r"{}.{}.npy".format(animal, day)  # change path
    data = np.load(join(dff_dir, dff_filename), allow_pickle=True)
    data = data.item()
    ts = data['ts']
    dff = data['dff']
    dffzscore = data['zscore']

    behavior_filename = r"ID{}_Day{}.xlsx".format(animal, day)
    xlsx = pd.ExcelFile(join(behavior_dir, behavior_filename), engine='openpyxl')
    behavior_labels = pd.read_excel(xlsx, header=0, dtype=object, engine='openpyxl')
    behaviors = [" ".join(col.split(" ")[0:-1]) for col in behavior_labels.columns if "Start" in col.split(" ")[-1]]
    zones = [" ".join(col.split(" ")[0:-1]) for col in behavior_labels.columns if "In" in col.split(" ")[-1]]

    # Create the highlighted episodes of behavior
    time_HMS = mpl_datetime_from_seconds(ts)

    behav_bouts = []
    for behav in behaviors:

        start_end_behavior = behavior_labels[[behav + " Start", behav + " End"]].dropna().to_numpy()

        if len(start_end_behavior) > 0:
            for episode in start_end_behavior:
                start_idx, start_time = find_nearest(time_HMS, get_mpl_datetime(episode[0]))
                end_idx, end_time = find_nearest(time_HMS, get_mpl_datetime(episode[1]))
                behav_bouts.append([start_time, end_time, behav])
    behav_bouts = np.array(behav_bouts)

    zone_bouts = []
    for zone in zones:
        start_end_zone = behavior_labels[[" ".join([zone, "In"]), " ".join([zone, "Out"])]].dropna().to_numpy()
        if len(start_end_zone) > 0:
            bool_array = np.zeros(len(time_HMS))
            for episode in start_end_zone:
                start_idx, start_time = find_nearest(time_HMS, get_mpl_datetime(episode[0]))
                end_idx, end_time = find_nearest(time_HMS, get_mpl_datetime(episode[1]))
                bool_array[start_idx:end_idx + 1] = 1
                print([start_time, end_time, zone])
                zone_bouts.append([start_time, end_time, behav])
    zone_bouts = np.array(zone_bouts)

    return ts, dff, dffzscore, behav_bouts, zone_bouts


if __name__ == "__main__":
    # main_dir = sys.argv[0]
    save_directory = join(main_dir, 'plots')
    behavior_dir = join(main_dir, 'Multimaze scoring')
    dff_dir = join(main_dir, 'FP_processed data')
