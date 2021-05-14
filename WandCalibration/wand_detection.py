import os
import numpy as np
import pandas as pd
import pims
from tqdm import tqdm
from skimage.feature import blob_dog
from joblib import Parallel, delayed


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
    if grayscale_image.ndim != 2:
        result = np.delete(result, 2, axis=1)  # Delete 3rd row for 3D images

    if len(result) == n_blobs:
        return result, threshold
    elif len(result) < n_blobs:
        print('Found {} blobs instead of {} blobs, decreasing the threshold to {}'.format(len(result), n_blobs,
                                                                                          threshold - threshold_step))
        result, threshold = find_blobs(grayscale_image, n_blobs=n_blobs, threshold=threshold - threshold_step,
                                       threshold_step=threshold_step, min_threshold=min_threshold,
                                       max_threshold=max_threshold)
    elif len(result) > n_blobs:
        print('Found {} blobs instead of {} blobs, increasing the threshold to {}'.format(len(result), n_blobs,
                                                                                          threshold + threshold_step))
        result, threshold = find_blobs(grayscale_image, n_blobs=n_blobs, threshold=threshold + threshold_step,
                                       threshold_step=threshold_step, min_threshold=min_threshold,
                                       max_threshold=max_threshold)

    if len(result) == n_blobs:
        print('Success in finding {} blobs with threshold={}'.format(n_blobs, threshold))
        return result, threshold
    else:
        raise Exception('Function could not find the requested number of blobs, please change the hyperparameters and '
                        'try again or take a look at the code.')


def track_argus_wand(grayscale_video_path, cam_id, n_blobs=2, threshold=.3, threshold_step=.025, min_threshold=.15,
                     max_threshold=.45):
    """Given a video, extracts the wand led coordinates and generates a csv file"""

    video = pims.Video(grayscale_video_path)

    coords = []
    thresholds = []

    for frame in tqdm(video):
        if frame.ndim == 3:
            frame = frame[:, :, 0]
        blobs, threshold = find_blobs(frame, n_blobs=n_blobs, threshold=threshold, threshold_step=threshold_step,
                                      min_threshold=min_threshold, max_threshold=max_threshold)
        coords.append(blobs)
        thresholds.append(threshold)

    df = pd.DataFrame(
        data=np.array(coords).reshape(len(video), 6),
        columns=['Track 1_' + cam_id + '_y', 'Track 1_' + cam_id + '_x', 'Track 1_' + cam_id + '_r',
                 'Track 2_' + cam_id + '_y', 'Track 2_' + cam_id + '_x', 'Track 2_' + cam_id + '_r']
    )
    df['blob_detection_threshold'] = thresholds

    df.to_csv(grayscale_video_path[:-4] + '_wand_' + cam_id + '_yxrpts.csv', index=False)


def track_wands_in_all_videos(folder_path, n_jobs='default',
                              n_blobs=2, threshold=.3, threshold_step=.025, min_threshold=.15, max_threshold=.45):
    videos = [os.path.join(folder_path, video) for video in os.listdir(folder_path)
              if (video.endswith('.avi') or video.endswith('.mp4'))]

    if n_jobs == 'default':
        if len(videos) > 32:
            n_jobs = 32
        else:
            n_jobs = len(videos)

    Parallel(n_jobs=n_jobs, verbose=100)(
        delayed(track_argus_wand)(grayscale_video_path=os.path.join(folder_path, video), cam_id=video[:-4][-5:],
                                  n_blobs=n_blobs, threshold=threshold, threshold_step=threshold_step,
                                  min_threshold=min_threshold, max_threshold=max_threshold)
        for video in os.listdir(folder_path)
        if (video.endswith('.avi') or video.endswith('.mp4')))
