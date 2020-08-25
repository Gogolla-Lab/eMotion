import os

os.environ["DLClight"] = "True"
import sys

shuffleindex = int(sys.argv[1])
snapshotindex = int(sys.argv[2])
outlieralgorithm = sys.argv[3]
epsilon = float(sys.argv[4])
extractionalgorithm = sys.argv[5]
nframes = int(sys.argv[6])

import deeplabcut as dlc

config_path = "/usr/users/onur.serce/dlc_real-alja_onur-2020-04-06/config.yaml"
videos_path = "/usr/users/onur.serce/dlc_real-alja_onur-2020-04-06/videos/"

videos_path_list = []
for video in os.listdir(videos_path):
    if video.endswith(".mp4") or video.endswith(".MP4"):
        videos_path_list.append(videos_path + video)

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

edits = {'snapshotindex': snapshotindex, 'numframestopick': nframes}
print('\nediting the config file... ')
for item in edits.items():
    print(item)
dlc.auxiliaryfunctions.edit_config(config_path, edits)
print('edit completed!')

dlc.extract_outlier_frames(config=config_path, videos=videos_path_list, videotype='.mp4', shuffle=shuffleindex,
                           trainingsetindex=0, outlieralgorithm=outlieralgorithm, epsilon=epsilon, automatic='True',
                           extractionalgorithm=extractionalgorithm)

print("dlc_extract_outlier_frames with the call", str(sys.argv), "is done!")

print("returning snapshotindex back to 'all'...!")
edits = {'snapshotindex': 'all'}
dlc.auxiliaryfunctions.edit_config(config_path, edits)
print("snapshotindex is set back to 'all'")
