import cv2
import pims
import imageio

def maskFrame_rect(frame, maskCoords = []):
    # utility function which masks (blackens) all pixels in the ROI as defined
    # by maskCoords argument, expected to be output of cv2.selectROI  function.
    
    r = maskCoords
    frame[int(r[1]):int(r[1]+r[3]), int(r[0]):int(r[0]+r[2])] = 0

    return frame

def maskVideo_rect(videoPath = [], outputFilename = [], maskCoords = [], fps = 30.0):
    # function containing a pipeline which masks a desired ROI in a given video
    # (defined by videoPath argument) and saves the result

    v = pims.Video(videoPath)

    if maskCoords == []:
        maskCoords = cv2.selectROI("Image", v[0])
        cv2.destroyAllWindows()

    r = maskCoords

    masking_pipeline = pims.pipeline(maskFrame_rect)
    kwargs = dict(maskCoords = r)
    processed_video = masking_pipeline(v, **kwargs)

    #if outputFilename == []:
    #    outputFilename = videoPath.rsplit('/', 1)[-1][:-4] + "_MASKED.mp4"
    #    outputFilename = videoPath[:-4] + "_MASKED.mp4"
    outputFilename = "C:/Users/serce/Desktop" + videoPath.rsplit('/', 1)[-1][:-4] + "_MASKED.mp4" #CHANGE PATH!!!
    imageio.mimwrite(outputFilename, processed_video , fps = fps)

#test
path1 = "J:/Onur Serce/Preprocessed videos/Day1/to_be_overlaid/ChR2_1_Day1.mp4"
maskVideo_rect(path1)

# see https://programmersought.com/article/3449903953/ for a polygon ROI/mask






### parallelized

def maskVideo_rect_parallel(folderPath = [], n_jobs = 10):
    # this function will process all files in a given folder using the above described functions
    import os
    from joblib import Parallel, delayed
    Parallel(n_jobs = n_jobs)(delayed(maskVideo_rect)(folderPath+filename) for filename in os.listdir(folderPath))


#test
pathF1 = "J:/Onur Serce/Preprocessed videos/Day1/to_be_overlaid/"
maskVideo_rect_parallel(pathF1)




### TO DO
# add file type filtering to the parallel func (glob.glob?)
# include initial file compression step into this pipeline, possibly using GPU ffmpeg
# test performance on headless systems (ROI needs a screen for now), possibly using vscode server or jupyter
# ensure that ROI selection pop-ups take over focus
#



# import os
# from joblib import Parallel, delayed
# Parallel(n_jobs=10)(delayed(maskVideo_rect)(pathF1+filename) for filename in os.listdir(pathF1))


# #find all maskCoords for all files in the dir
# import os
# import cv2
# import pims
# maskCoordsDir = []
# for filename in os.listdir(pathF1):
#     v = pims.Video(pathF1+filename)
#     maskCoords = cv2.selectROI("Image", v[0])
#     cv2.destroyAllWindows()
#     maskCoordsDir.append(maskCoords)

# import os
# from joblib import Parallel, delayed
# Parallel(n_jobs=2)(delayed(maskVideo_rect)(filename) for filename in os.listdir(pathF1))
