import os
import pandas as pd


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


if __name__ == "__main__":
    import sys

    rename_files(sys.argv[1], sys.argv[2])
