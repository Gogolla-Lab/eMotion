import os
os.environ["DLClight"]="True"
import sys

shuffleindex = int(sys.argv[1])
snapshotindex = int(sys.argv[2])
videofolder = sys.argv[3]
index = int(sys.argv[4]) # $SLURM_ARRAY_TASK_ID
gputouse = int(sys.argv[5])

import deeplabcut as dlc
config_path = "/usr/users/onur.serce/dlc_real-alja_onur-2020-04-06/config.yaml"
videos = [os.path.join(videofolder, vid) for vid in os.listdir(videofolder) if (vid.endswith('.mp4') or vid.endswith('.MP4'))]


print("\n")
print("\n")
print("'config_path' is:", config_path)
print("'dlc.__version__' is:'", dlc.__version__)
print("\n")
print("This is the name of the calling program:", sys.argv[0])
print("str(sys.argv):", str(sys.argv), "\n")
print("\n")
print("\n")


edits = {'snapshotindex': snapshotindex}
dlc.auxiliaryfunctions.edit_config(config_path, edits)
print('\nediting the config file... ')
print('\nedits are: ', edits)
for item in edits.items():
	print(item)
print('edit completed!')


dlc.analyze_videos(config=config_path, videos=videos[index:index+5], videotype='.mp4', shuffle=shuffleindex, trainingsetindex=0, gputouse=gputouse, save_as_csv=True, TFGPUinference=True)
# dlc.analyze_videos(config=config_path, videos=[videos_path+'Control_8_Day_1_cropped.mp4'], videotype='.mp4', shuffle=shuffleindex, trainingsetindex=0, gputouse=gputouse, save_as_csv=True, TFGPUinference=True)


print("returning snapshotindex back to 'all'...!")
edits = {'snapshotindex': 'all'}
dlc.auxiliaryfunctions.edit_config(config_path, edits)
print("snapshotindex is set back to 'all'")
print("dlc_analyse_videos_jobarray.py with the call", str(sys.argv), "is done!")