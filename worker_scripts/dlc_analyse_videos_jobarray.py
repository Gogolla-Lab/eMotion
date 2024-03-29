import os
from time import sleep
from random import uniform
os.environ["DLClight"] = "True"
import sys

shuffleindex = int(sys.argv[1])
snapshotindex = int(sys.argv[2])
videofolder = sys.argv[3]
index = int(sys.argv[4])  # $SLURM_ARRAY_TASK_ID
gputouse = int(sys.argv[5])

import deeplabcut as dlc

config_path = "/usr/users/onur.serce/emotipose-Stoyo-2021-05-10/config.yaml"
videos = [os.path.join(videofolder, vid) for vid in os.listdir(videofolder) if
          (vid.endswith('.mp4') or vid.endswith('.MP4'))]

sleeptime = uniform(1, 180)
print('ZzzZzz.. Sleeping for', sleeptime, 'seconds.. zzzZZzzZz')
sleep(sleeptime)

print('editing the config file!')
edits = {'snapshotindex': snapshotindex}
dlc.auxiliaryfunctions.edit_config(config_path, edits)
print(edits)

dlc.analyze_videos(config=config_path, videos=videos[index:index + 1], videotype='.mp4', shuffle=shuffleindex,
                   trainingsetindex=0, gputouse=gputouse, save_as_csv=True, TFGPUinference=True)

edits = {'snapshotindex': 'all'}
dlc.auxiliaryfunctions.edit_config(config_path, edits)
print("snapshotindex is set back to 'all'")
print("dlc_analyse_videos_jobarray.py with the call", str(sys.argv), "is done!")
