import os
import pandas as pd
import imageio
import tqdm

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
                new_filename = os.path.join(folder, df.loc[i, 'reformatted'] + extension)
                os.rename(old_filename, new_filename)
            print('Renaming completed!')


def import_labeled_dlc_data(folder, prefix, scorer, fps=30):
    """Collects labeled DLC data in a single csv file and creates a video from frames"""

    df_accu = pd.DataFrame()

    for d in os.listdir(folder):
        subdir = os.path.join(folder, d)
        if os.path.isdir(subdir) and not subdir.endswith('_labeled'):
            if os.path.exists(os.path.join(subdir, 'CollectedData_'+scorer+'.h5')):
                data = pd.read_hdf(os.path.join(subdir, 'CollectedData_'+scorer+'.h5'))
                df_accu = df_accu.append(data)

    scorer = prefix + '_' + scorer  # add prefix to scorer in order to name the files as we wish (don't change above
    # to not interfere with the hdf readings)
    count = 0
    newindex = []

    if not os.path.exists(os.path.join(folder, scorer+'_accumulated')):
        os.mkdir(os.path.join(folder, scorer+'_accumulated'))

    kwargs = {'macro_block_size': None}     # to prevent imageio_ffmpeg video resizing
    writer = imageio.get_writer(os.path.join(folder, scorer+'_accumulated.mp4'), fps=fps, **kwargs)
    for imgpath in tqdm.tqdm(df_accu.index):
        directory, img = os.path.split(imgpath)
        directory = os.path.split(directory)[-1]
        img = imageio.imread(os.path.join(folder, directory, img))
        writer.append_data(img)
        newindex.append(os.path.join('labeled-data', scorer+'_accumulated', 'img'+str(count).zfill(5)+'.png'))
        imageio.imwrite(os.path.join(folder, scorer+'_accumulated', 'img'+str(count).zfill(5)+'.png'), img)
        count += 1
    writer.close()

    df_accu.index = newindex
    df_accu.to_csv(os.path.join(folder, scorer+'_accumulated', "CollectedData" + scorer[len(prefix):] + ".csv"),
                   index=True)
    df_accu.to_hdf(os.path.join(folder, scorer+'_accumulated', "CollectedData" + scorer[len(prefix):] + ".h5"),
                   key="df_with_missing", mode="w", format='table')


if __name__ == "__main__":
    import sys

    rename_files(sys.argv[1], sys.argv[2])
