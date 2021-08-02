import os
os.environ["DLClight"] = "True"
import deeplabcut as dlc
import sys

shuffle = [int(sys.argv[1])]
gputouse = int(sys.argv[2])
config_path = sys.argv[3]

print("'config_path' is:", config_path)
print("'dlc.__version__' is:'", dlc.__version__)
print("\n")
print("This is the name of the program:", sys.argv[0])
print("str(sys.argv):", str(sys.argv), "\n")

dlc.evaluate_network(
    config=config_path,
    Shuffles=shuffle,
    trainingsetindex=0,
    plotting=None,
    show_errors=True,
    comparisonbodyparts='all',
    gputouse=gputouse,
    rescale=False,
    modelprefix='',
    c_engine=False,
)

print("dlc_evaluate_network.py with the call", str(sys.argv), "is done!")
