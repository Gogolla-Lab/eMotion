import os
os.environ["DLClight"]="True"
import sys

shuffles = sys.argv[1]
gputouse = int(sys.argv[2])

shuffles_splitted = shuffles.split("-")
shuffles_list = list(int(i) for i in shuffles_splitted)

import deeplabcut as dlc

config_path = "/usr/users/onur.serce/dlc_real-alja_onur-2020-04-06/config.yaml"

print("'config_path' is:", config_path)
print("'dlc.__version__' is:'", dlc.__version__)
print("\n")
print("This is the name of the program:", sys.argv[0]) 
print("str(sys.argv):", str(sys.argv), "\n") 

dlc.evaluate_network(config=config_path, Shuffles=shuffles_list, plotting=True, gputouse=gputouse)

print("dlc_evaluate_network.py with the call", str(sys.argv), "is done!")
