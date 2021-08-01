import os
os.environ["DLClight"] = "True"
import sys
import deeplabcut as dlc

config_path = sys.argv[1]
shuffleindex = int(sys.argv[2])
gputouse = int(sys.argv[3])

print("'config_path' is:", config_path)
print("'dlc.__version__' is:'", dlc.__version__)
print("\n")
print("This is the name of the program:", sys.argv[0])
print("str(sys.argv):", str(sys.argv), "\n")

dlc.train_network(
    config=config_path,
    shuffle=shuffleindex,
    trainingsetindex=0,
    max_snapshots_to_keep=None,
    displayiters=100,
    saveiters=2500,
    maxiters=None,
    allow_growth=False,
    gputouse=gputouse,
    autotune=False,
    keepdeconvweights=True,
    modelprefix='',
)

print("dlc_start_training.py with the call", str(sys.argv), "is done!")
