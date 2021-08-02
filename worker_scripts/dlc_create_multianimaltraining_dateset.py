import os
import sys
os.environ["DLClight"] = "True"
import deeplabcut as dlc

config_path = sys.argv[1]
num

print("'config_path' is:", config_path)
print("'dlc.__version__' is:'", dlc.__version__)
print("\n")

dlc.create_multianimaltraining_dataset(
    config,
    num_shuffles=1,
    Shuffles=None,
    windows2linux=False,
    net_type=None,
    numdigits=2,
    paf_graph=None,
)