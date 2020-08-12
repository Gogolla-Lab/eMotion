import os
os.environ["DLClight"]="True"
import sys

shuffleindex = int(sys.argv[1])
snapshotindex = int(sys.argv[2])
gputouse = int(sys.argv[3])

import deeplabcut as dlc
config_path = "/usr/users/onur.serce/dlc_real-alja_onur-2020-04-06/config.yaml"
videos_path = "/scratch/onur.serce/"

videos_path_list = []
for video in os.listdir(videos_path):
	if video.endswith(".mp4") or video.endswith(".MP4"):
		videos_path_list.append(os.path.join(videos_path, video))

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

edits = {'snapshotindex': snapshotindex}

dlc.auxiliaryfunctions.edit_config(config_path, edits)

print('\nediting the config file... ')
for item in edits.items():
	print(item)

print('edit completed!')

dlc.analyze_videos(config=config_path, videos=videos_path_list, videotype='.mp4', shuffle=shuffleindex,
				   trainingsetindex=0, gputouse=gputouse, save_as_csv=True, TFGPUinference=True)

print("dlc_start_training.py with the call", str(sys.argv), "is done!")

print("returning snapshotindex back to 'all'...!")
edits = {'snapshotindex': 'all'}
dlc.auxiliaryfunctions.edit_config(config_path, edits)
print("snapshotindex is set back to 'all'")
