import os
import numpy as np
import pandas as pd
import pims
from tqdm import tqdm
from skimage.feature import blob_dog

video = pims.Video(
    r"C:\Users\serce\PycharmProjects\eMotion\campy\argus_calib_wand_34mm\Cam_A\argus_calib_wand_34mm.mp4")
img = video[0]


def find_blobs(grayscale_image, n_blobs, threshold=.3, threshold_step=.025, min_threshold=.15, max_threshold=.45):
    """Given a GRAYSCALE image, finds 'n_blobs' number of blobs and returns the y, x, r coordinates as numpy array
    with shape (n, 3) along with the latest threshold used. Recursive function adjusts the 'threshold_step' until the
    requested number of blobs are found. Since consecutive frames of videos usually need the same hyperparameters,
    returned threshold can be used to call the function on the next frame, therefore speed up the processing.

    :param grayscale_image: 2D or 3D ndarray
        Input grayscale image, blobs are assumed to be light on dark
        background (white on black).
    :param n_blobs: int
        Number of blobs to find
    :param threshold: float.
        The absolute lower bound for scale space maxima. Local maxima smaller
        than thresh are ignored. Reduce this to detect blobs with less
        intensities.
    :param threshold_step: float
        Step size of the threshold. Used when adjusting the threshold in a
        recursive call. If the algorithm finds less and more number of blobs
        but not the requested one, decreasing this value may help.
    :param min_threshold: float
        Minimum threshold. If the threshold goes below this value, the function will return NaN with the expected shape.
    :param max_threshold: float
        Maximum threshold. If the threshold goes above this value, the function will return NaN with the expected shape.
    """

    # Return NaN if the threshold is out of bounds
    if not min_threshold <= threshold <= max_threshold:
        return np.full((n_blobs, 3), np.NaN), threshold

    result = blob_dog(grayscale_image, threshold=threshold)
    if img.ndim != 2:
        result = np.delete(result, 2, axis=1)  # Delete 3rd row for 3D images

    if len(result) == n_blobs:
        return result, threshold
    elif len(result) < n_blobs:
        result, threshold = find_blobs(grayscale_image, n_blobs=n_blobs, threshold=threshold - threshold_step,
                                       threshold_step=threshold_step, min_threshold=min_threshold,
                                       max_threshold=max_threshold)
    elif len(result) > n_blobs:
        result, threshold = find_blobs(grayscale_image, n_blobs=n_blobs, threshold=threshold + threshold_step,
                                       threshold_step=threshold_step, min_threshold=min_threshold,
                                       max_threshold=max_threshold)

    if len(result) == n_blobs:
        return result, threshold
    else:
        raise Exception('Function could not find the requested number of blobs, please change the hyperparameters and '
                        'try again or take a look at the code.')
