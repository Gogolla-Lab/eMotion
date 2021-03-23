# -*- coding: utf-8 -*-
"""
Created on Thu Mar  4 12:00:52 2021

@author: apodgornik
"""


import pandas as pd
from os.path import join

mouse_ID = 1
day = 3

base_dir = r"J:\Alja Podgornik\FP_Alja\Multimaze\Multimaze_Jan21_FPdata_csvs"
filename = r"Day{}_{}_nondecimated.csv".format(day, mouse_ID)
save_filename = r"Day{}_{}.csv".format(day, mouse_ID)

# Load the csv
df = pd.read_csv(join(base_dir, filename), skiprows=1, header=0)

# The initial temporal offset is given roughly by this index. Not sure what exactly this is, but it matches the other files
initial_unit = 1048
step = 300

# Drop these first indices and reset the index
df = df.drop(range(initial_unit)).reset_index(drop=True)

time = df[['Time(s)']].to_numpy()[::step] 
df2 = df.drop('Time(s)', axis=1)

# Get the means by step
m_df = df2.groupby(df2.index // step).mean()

# Add time back
m_df = m_df.insert(0, 'Time(s)', time).copy()

# Save as csv
m_df.to_csv(join(base_dir, save_filename), index=False)
