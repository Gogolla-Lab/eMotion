import numpy as np
import pandas as pd
import os

project_path = "/usr/users/onur.serce/dlc_real-alja_onur-2020-04-06/"
labeled_data = os.path.join(project_path, 'labeled-data')

for folder in os.listdir(labeled_data):
    folder_path = os.path.join(labeled_data, folder)
    if os.path.isdir(folder_path):
        for file in os.listdir(folder_path):
            if file == 'CollectedData_alja_onur.csv':
                file_path = os.path.join(folder_path, file)
                
                print('\n', '\n', '\n')
                print('editing file: ' ,file_path)
                df = pd.read_csv(file_path, header=[0,1,2])
                print('columns before edit: ', df.columns)
                columns = [('scorer', 'bodyparts', 'coords'),
                 ('alja_onur', 'left_ear', 'x'),
                 ('alja_onur', 'left_ear', 'y'),
                 ('alja_onur', 'right_ear', 'x'),
                 ('alja_onur', 'right_ear', 'y'),
                 ('alja_onur', 'snout', 'x'),
                 ('alja_onur', 'snout', 'y'),
                 ('alja_onur', 'center', 'x'),
                 ('alja_onur', 'center', 'y'),
                 ('alja_onur', 'left_side', 'x'),
                 ('alja_onur', 'left_side', 'y'),
                 ('alja_onur', 'right_side', 'x'),
                 ('alja_onur', 'right_side', 'y'),
                 ('alja_onur', 'tail_base', 'x'),
                 ('alja_onur', 'tail_base', 'y'),
                 ('alja_onur', 'tail_mid', 'x'),
                 ('alja_onur', 'tail_mid', 'y'),
                 ('alja_onur', 'tail_tip', 'x'),
                 ('alja_onur', 'tail_tip', 'y'),
                 ('alja_onur', 'paw_f_right', 'x'),
                 ('alja_onur', 'paw_f_right', 'y'),
                 ('alja_onur', 'paw_f_left', 'x'),
                 ('alja_onur', 'paw_f_left', 'y'),
                 ('alja_onur', 'paw_h_right', 'x'),
                 ('alja_onur', 'paw_h_right', 'y'),
                 ('alja_onur', 'paw_h_left', 'x'),
                 ('alja_onur', 'paw_h_left', 'y')]
                df = df[columns]
                print('columns after edit: ', df.columns)
                df.to_csv(file_path, index=False)
                #definitely save the file with a different name at first to try if the code works as expected!

print('all done!')
