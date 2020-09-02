import os
os.environ["DLClight"]="True"
import sys

shuffleindex = int(sys.argv[1])
gputouse = int(sys.argv[2])

import deeplabcut as dlc

config_path = "/usr/users/onur.serce/dlc_real-alja_onur-2020-04-06/config.yaml"

print("'config_path' is:", config_path)
print("'dlc.__version__' is:'", dlc.__version__)
print("\n")
print("This is the name of the program:", sys.argv[0]) 
print("str(sys.argv):", str(sys.argv), "\n") 

dlc.train_network(config_path, shuffle=shuffleindex, trainingsetindex=0, max_snapshots_to_keep=None, displayiters=250, saveiters=None, maxiters=None, allow_growth=False, gputouse=gputouse, autotune=False, keepdeconvweights=True)

print("dlc_start_training.py with the call", str(sys.argv), "is done!")
