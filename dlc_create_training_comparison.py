import os
os.environ["DLClight"]="True"

import deeplabcut as dlc

config_path = "/usr/users/onur.serce/dlc_real-alja_onur-2020-04-06/config.yaml"

print("'config_path' is:", config_path)
print("'dlc.__version__' is:'", dlc.__version__)
print("\n")

dlc.create_training_model_comparison(config_path, num_shuffles=3, net_types=['resnet_101', 'resnet_152'], augmenter_types=['imgaug', 'tensorpack', 'deterministic', 'default'], userfeedback=False, windows2linux=True)

print('\n', 'create_training_model_comparison completed!')
