import os
os.environ["DLClight"] = "True"
import sys
import deeplabcut as dlc
from time import sleep
from random import uniform

shuffleindex = int(sys.argv[1])
snapshotindex = int(sys.argv[2])
SLURM_ARRAY_TASK_ID = int(sys.argv[3])

config_path = "/usr/users/onur.serce/emotipose-Stoyo-2021-05-10/config.yaml"
videos_path = "/usr/users/onur.serce/isopreteranol"

videos_path_list = []
for video in os.listdir(videos_path):
    if video.endswith(".mp4") or video.endswith(".MP4"):
        if 'labeled' not in video:
            videos_path_list.append(os.path.join(videos_path + video))

# This is to resume the training from where it left off, don't forget to remove this!
# videos_path_list = videos_path_list[10:]

print("\n")
print("\n")
print("'config_path' is:", config_path)
print("'dlc.__version__' is:'", dlc.__version__)
print("\n")
print("This is the name of the program:", sys.argv[0])
print("str(sys.argv):", str(sys.argv), "\n")
print("\n")
print("\n")

sleeptime = uniform(1, 180)
print('ZzzZzz.. Sleeping for', sleeptime, 'seconds.. zzzZZzzZz')
sleep(sleeptime)

edits = {'snapshotindex': snapshotindex}

dlc.auxiliaryfunctions.edit_config(config_path, edits)

print('\nediting the config file... ')
for item in edits.items():
    print(item)

print('edit completed!')

dlc.create_video_with_all_detections(
    config=config_path,
    videos=videos_path_list[SLURM_ARRAY_TASK_ID:SLURM_ARRAY_TASK_ID+1],
    shuffle=shuffleindex,
    trainingsetindex=0,
    displayedbodyparts='all',
    destfolder=None,
    modelprefix='',
)

print("dlc_create_video_with_all_detections.py with the call", str(sys.argv), "is done!")

print("returning snapshotindex back to 'all'...!")
edits = {'snapshotindex': 'all'}
dlc.auxiliaryfunctions.edit_config(config_path, edits)
print("snapshotindex is set back to 'all'")
