# -*- coding: utf-8 -*-
"""
Created on Thu Feb 18 09:24:49 2021

@author: apodgornik
"""

from os.path import join
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as md
import time
%matplotlib qt

from PyQt5.QtWidgets import QFileDialog
from datetime import timedelta, datetime


def mouse_move(event):
    x, y = event.xdata, event.ydata
    print(x, y)



if __name__ == '__main__':

    filePath, _ = QFileDialog.getOpenFileName()
    print("Loaded: " + filePath)
    
    # animal = 1.1
    # filePath = join("J:\Alja Podgornik\FP_Alja\FP_processed data", str(animal) + ".npy")
    
    data = np.load(filePath, allow_pickle=True)
    data = data.item()
    
    ani_ID = data['ani_id']
    fp_times = data['ts']
    auto = data['auto']
    gcamp = data['gcamp']
    dff = data['dff']
    dffzscore = data['zscore']
    
    time_format = []
    zero = datetime(2021,1,1)
    for t in fp_times:
        dt = timedelta(seconds=t)
        time = zero + dt
        mp_dt = md.date2num(time)
        time_format.append(mp_dt)
    
    
    fig = plt.figure(figsize=(20,10))

    xfmt = md.DateFormatter('%H:%M:%S')
    plt.gca().xaxis.set_major_formatter(xfmt)
    plt.gca().xaxis_date()
    
    plt.plot(time_format, gcamp)
    plt.xlabel('Time')
    plt.ylabel('DFF')
    plt.title(str(ani_ID) + ' DFF')
    
    plt.show()