import os
import pandas as pd
import imageio as io
from tqdm import tqdm
from PIL import Image


def check_sizes(labeled_data, extension='.png'):
    """Checks frame sizes in a given folder. Returns True if all equal, otherwise returns unique sizes as tuples in a
    set """

    def all_equal_ivo(lst):
        return not lst or lst.count(lst[0]) == len(lst)

    correct = {}

    for dir in os.listdir(labeled_data):
        folder = os.path.join(labeled_data, dir)
        sizes = []
        for f in os.listdir(folder):
            if f.endswith(extension):
                im_uri = os.path.join(folder, f)
                img = Image.open(im_uri)
                imsize = img.size
                sizes.append(imsize)
        if not all_equal_ivo(sizes):
            print(folder, 'contains frames of varying sizes!')
            correct[folder] = list(set(sizes))

    return correct


def resize_frames(folder, extension='.png', initial_size=None, new_size=None):
    """Resizes all images in a given folder to desired dimensions"""

    for f in tqdm(os.listdir(folder), desc='Resizing...'):
        if f.endswith(extension):
            im_uri = os.path.join(folder, f)
            img = Image.open(im_uri)
            if (initial_size is not None) and (img.size == initial_size):
                if (new_size is not None) and (new_size != img.size):
                    io.imwrite(uri=im_uri, im=img.resize(new_size))


def rename_files(folder, extension):
    """Utility function for renaming files with a certain extension in a folder using renaming.csv file"""

    if not os.path.exists(os.path.join(folder, 'renaming.csv')):
        filenames = [f[:-(len(extension))] for f in os.listdir(folder) if f.endswith(extension)]
        new_filenames = filenames.copy()
        df = pd.DataFrame()
        df['original'] = filenames
        df['reformatted'] = new_filenames
        df.to_csv(os.path.join(folder, 'renaming.csv'))
        print('renaming.csv is created in', folder)
        print('Please edit the renaming.csv file and re-run the function!')
    else:
        df = pd.read_csv(os.path.join(folder, 'renaming.csv'), index_col=0)
        if (df['original'] == df['reformatted']).mean() == 1:
            print('Please edit the renaming.csv file and re-run the function!')
        else:
            for i in df.index:
                old_filename = os.path.join(folder, df.loc[i, 'original'] + extension)
                if os.path.exists(old_filename):
                    new_filename = os.path.join(folder, df.loc[i, 'reformatted'] + extension)
                    os.rename(old_filename, new_filename)
                else:
                    print(old_filename, 'does not exist!')
            print('Renaming completed!')


def import_labeled_dlc_data(folder, prefix, scorer, videotype='.mp4', fps=30):
    """Collects labeled DLC data in a single csv file and creates a video from frames
    expects all videos to be the same size"""

    df_accu = pd.DataFrame()

    for d in os.listdir(folder):
        subdir = os.path.join(folder, d)
        if os.path.isdir(subdir) and not subdir.endswith('_labeled'):  # Eliminate *_labeled folders
            if os.path.exists(os.path.join(subdir, 'CollectedData_' + scorer + '.h5')):
                data = pd.read_hdf(os.path.join(subdir, 'CollectedData_' + scorer + '.h5'))
                df_accu = df_accu.append(data)

    scorer = prefix + '_' + scorer  # add prefix to scorer in order to name the files as we wish (don't change above
    # to not interfere with the hdf readings)
    count = 0
    newindex = []

    if not os.path.exists(os.path.join(folder, scorer + '_accumulated')):
        os.mkdir(os.path.join(folder, scorer + '_accumulated'))

    kwargs = {'macro_block_size': None}  # to prevent imageio_ffmpeg video resizing
    writer = io.get_writer(os.path.join(folder, scorer + '_accumulated' + videotype), fps=fps, **kwargs)
    for imgpath in tqdm(df_accu.index):
        directory, img = os.path.split(imgpath)
        directory = os.path.split(directory)[-1]
        img = io.imread(os.path.join(folder, directory, img))
        writer.append_data(img)
        newindex.append(os.path.join('labeled-data', scorer + '_accumulated', 'img' + str(count).zfill(5) + '.png'))
        io.imwrite(os.path.join(folder, scorer + '_accumulated', 'img' + str(count).zfill(5) + '.png'), img)
        count += 1
    writer.close()

    df_accu.index = newindex
    df_accu.to_csv(os.path.join(folder, scorer + '_accumulated', "CollectedData" + scorer[len(prefix):] + ".csv"),
                   index=True)
    df_accu.to_hdf(os.path.join(folder, scorer + '_accumulated', "CollectedData" + scorer[len(prefix):] + ".h5"),
                   key="df_with_missing", mode="w", format='table')


def import_labeled_dlc_data_to_separate_folders(folder, scorer, videotype='.mp4', frametype='.png', fps=30):
    """Collects labeled DLC data in csv and h5 files and creates videos from frames
    for each folder"""

    correct = check_sizes(folder)
    if len(correct) > 0:
        for subfol in correct.keys():
            if len(correct[subfol]) == 2:
                if (correct[subfol][0][0] > correct[subfol][1][0]) or (correct[subfol][0][1] > correct[subfol][1][1]):
                    resize_frames(subfol, initial_size=correct[subfol][1], new_size=correct[subfol][0])
                else:
                    resize_frames(subfol, initial_size=correct[subfol][0], new_size=correct[subfol][1])
            else:
                raise BaseException

    if len(correct) > 0:
        if len(check_sizes(folder)) != 0:
            raise BaseException
        else:
            print("All frames are of same size, continuing with the process...")

    kwargs = {'fps': fps, 'macro_block_size': None}

    newdir = os.path.join(folder, scorer + '_accumulated')
    videosdir = os.path.join(folder, scorer + '_accumulated', 'videos')
    if not os.path.exists(newdir):
        os.mkdir(newdir)
    if not os.path.exists(videosdir):
        os.mkdir(videosdir)

    for d in tqdm(os.listdir(folder), desc='1st loop'):
        subdir = os.path.join(folder, d)
        if os.path.isdir(subdir) and not subdir.endswith('_labeled'):  # Eliminate *_labeled folders
            if os.path.exists(os.path.join(subdir, 'CollectedData_' + scorer + '.h5')):
                data = pd.read_hdf(os.path.join(subdir, 'CollectedData_' + scorer + '.h5'))
                newsubdir = os.path.join(newdir, os.path.split(subdir)[-1])
                if not os.path.exists(newsubdir):
                    os.mkdir(newsubdir)
                frames = []
                frame_uris = []
                for i, impath in enumerate(tqdm(data.index, desc='2nd loop')):
                    f = io.imread(uri=os.path.join(subdir, os.path.split(impath)[-1]))
                    frames.append(f)
                    frame_uri = os.path.join(newsubdir, str(i).zfill(5) + frametype)
                    io.imwrite(uri=frame_uri, im=f)
                    frame_uris.append(
                        os.path.join('labeled-data', os.path.split(subdir)[-1], str(i).zfill(5) + frametype))
                io.mimwrite(uri=os.path.join(videosdir, os.path.split(subdir)[-1] + videotype), ims=frames, **kwargs)
                data.index = frame_uris
                data.to_hdf(os.path.join(newsubdir, 'CollectedData_' + scorer + '.h5'),
                            key='df_with_missing', mode='w', format='table')
                data.to_csv(os.path.join(newsubdir, 'CollectedData_' + scorer + '.csv'), index=True)


# if __name__ == "__main__":
#     import sys
#
#     rename_files(sys.argv[1], sys.argv[2]
