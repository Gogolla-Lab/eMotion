import os
os.environ["DLClight"] = "True"
import deeplabcut as dlc

config_path = "/usr/users/onur.serce/emotipose-Stoyo-2021-05-10/config.yaml"

print("'config_path' is:", config_path)
print("'dlc.__version__' is:'", dlc.__version__)
print("\n")

dlc.create_training_model_comparison(config_path, num_shuffles=10, net_types=['resnet_152'], augmenter_types=['imgaug'],
                                     userfeedback=False, windows2linux=True)

print('\n', 'create_training_model_comparison completed!')
