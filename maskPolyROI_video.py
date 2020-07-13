"""
from roipoly import RoiPoly
import cv2
import pims
import imageio
import matplotlib.pyplot as plt


path1 = "J:/Onur Serce/Preprocessed videos/Day1/to_be_overlaid/ChR2_1_Day1.mp4"



v = pims.Video(path1)

plt.imshow(v[0])

my_roi = RoiPoly(color='r') # draw new ROI in red color

mask = my_roi.get_mask(v[0][0])

"""

def maskFrame_poly(frame, mask = []):
    # utility function which masks (blackens) all pixels in the ROI as defined
    # by maskCoords argument, expected to be output of cv2.selectROI  function.
    
    frame[0][mask] = 0

    return frame


def maskVideo_poly(videoPath = [], outputFilename = [], mask = [], fps = 30.0):
    # function containing a pipeline which masks a desired ROI in a given video
    # (defined by videoPath argument) and saves the result
    import cv2
    import pims
    import imageio
    from roipoly import RoiPoly
    import matplotlib.pyplot as plt

    v = pims.Video(path1)

    if mask == []:
    #    maskCoords = cv2.selectROI("Image", v[0])
    #    cv2.destroyAllWindows()
        plt.imshow(v[0])
        my_roi = RoiPoly(color='r')
        mask = my_roi.get_mask(v[0][0])
    

    masking_pipeline = pims.pipeline(maskFrame_poly)
    kwargs = dict(mask = mask)
    processed_video = masking_pipeline(v, **kwargs)

    #if outputFilename == []:
    #    outputFilename = videoPath.rsplit('/', 1)[-1][:-4] + "_MASKED.mp4"
    #    outputFilename = videoPath[:-4] + "_MASKED.mp4"
    outputFilename = "C:/Users/ndolensek/Downloads/t1.mp4"
    imageio.mimwrite(outputFilename, processed_video , fps = fps)

path1 = "J:/Onur Serce/Preprocessed videos/Day1/to_be_overlaid/ChR2_1_Day1.mp4"
maskVideo_poly(path1)

