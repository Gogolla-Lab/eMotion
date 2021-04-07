import sys
import os
import pandas as pd
from preprocessing.process_videos import processVideo

inputfolder = sys.argv[1]
outputfolder = sys.argv[2]
array_task_id = int(sys.argv[3])

df = pd.read_csv(os.path.join(inputfolder, "process.csv"), index_col=0)
videopath = os.path.join(inputfolder, df.index[array_task_id])

processVideo(videopath, outputfolder)

print("Finished: processVideo with arguments", videopath, outputfolder)
