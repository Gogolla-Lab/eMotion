import os
os.environ["DLClight"]="True"
import deeplabcut as dlc
import sys

config_path = sys.argv[1]
num_shuffles = int(sys.argv[2])

print("'config_path' is:", config_path)
print("'dlc.__version__' is:'", dlc.__version__)
print("\n")

dlc.create_multianimaltraining_dataset(
    config=config_path,
    num_shuffles=num_shuffles,
    Shuffles=None,
    windows2linux=False,
    net_type='resnet_152',
    numdigits=2,
    paf_graph=None,
)

print('\n', 'dlc_create_multianimaltraining_dataset.py completed!')
