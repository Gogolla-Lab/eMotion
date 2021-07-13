import os
os.environ["DLClight"] = "True"
from time import sleep
from random import uniform
import sys

videofolder = sys.argv[1]
index = int(sys.argv[2])  # $SLURM_ARRAY_TASK_ID

import deeplabcut as dlc

config_path = "/usr/users/onur.serce/emotipose-Stoyo-2021-05-10/config.yaml"
pickles = [os.path.join(videofolder, pkl) for pkl in os.listdir(videofolder) if (pkl.endswith('_el.pickle'))]

dlc.stitch_tracklets(
    config_path,
    pickle_file,
    n_tracks=None,
    min_length=10,
    split_tracklets=True,
    prestitch_residuals=True,
    max_gap=None,
    weight_func=None,
    output_name='',
)

print("dlc_stitch_tracklets_jobarray.py with the call", str(sys.argv), "is done!")
