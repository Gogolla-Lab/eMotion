import os
os.environ["DLClight"]="True"

import deeplabcut as dlc

config_path = "/usr/users/onur.serce/dlc_real-alja_onur-2020-04-06/config.yaml"

print("'config_path' is:", config_path)
print("'dlc.__version__' is:'", dlc.__version__)
print("\n")

dlc.convertcsv2h5(config_path, userfeedback=False)

print('\n', 'convertcsv2h5.py completed!')
