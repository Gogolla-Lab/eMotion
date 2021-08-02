import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import tempfile
import pims
import imageio as io
from ruamel.yaml import YAML
from tqdm import tqdm


def read_plainconfig(configname):
    # Change to deeplabcut.utils.auxillaryfunctions.read_plainconfig after DLC solves the wxPython issue
    # (https://github.com/DeepLabCut/DeepLabCut/issues/682#issuecomment-884229506)
    if not os.path.exists(configname):
        raise FileNotFoundError(
            f"Config {configname} is not found. Please make sure that the file exists."
        )
    with open(configname) as file:
        return YAML().load(file)


def open_figure(figure_id, nrows: int = 1, ncols: int = 1):
    fig = plt.figure(figure_id)
    ax = fig.add_subplot(projection='3d')
    return fig, ax


class MouseDrawer(object):
    def __init__(self, dlc_config_path, xyz_tracks_path):

        # Class variables
        self.dlc_config_path = dlc_config_path
        self.xyz_tracks_path = xyz_tracks_path
        self.rec_name = xyz_tracks_path.split('__')[-1][:-4]
        self.buffer = []
        self.tmp = None
        self.config = None
        self.xyz_data = None
        self.bodyparts = None
        self.skeleton = None

        # Settings
        plt.ioff()
        self.use_tmp = True

        self.init_all_inits()

    def init_all_inits(self):
        self.init_config()
        self.init_xyz_data()
        self.init_bodyparts()
        self.init_skeleton()
        self.init_temp_dir()

    def init_config(self):
        self.config = read_plainconfig(configname=self.dlc_config_path)

    def init_xyz_data(self):
        self.xyz_data = pd.read_csv(self.xyz_tracks_path, header=[0, 1])
        self.xyz_data = self.xyz_data.drop(columns=self.xyz_data.columns[0])
        self.xyz_data = self.xyz_data * 100  # Convert to cm

    def init_bodyparts(self):
        self.bodyparts = self.get_config()['multianimalbodyparts']

    def init_skeleton(self):
        self.skeleton = self.get_config()['skeleton']

    def init_temp_dir(self):
        tmp = tempfile.mkdtemp()
        tmp = os.path.join(tmp, self.get_rec_name())
        os.mkdir(tmp)
        self.tmp = tmp

    def get_rec_name(self):
        return self.rec_name

    def get_tmp(self):
        return self.tmp

    def get_config(self):
        return self.config

    def get_xyz_data(self):
        return self.xyz_data

    def get_bodyparts(self):
        return self.bodyparts

    def get_skeleton(self):
        return self.skeleton

    def get_frame_data(self, frame_id: int):
        """frame_ids: Pandas slicing format"""
        return self.get_xyz_data().iloc[frame_id, :]

    def draw_a_frame(self, frame_id: int):
        skeleton = self.get_skeleton()
        bodyparts = self.get_bodyparts()
        data = self.get_frame_data(frame_id=frame_id)
        fig, ax = open_figure(figure_id=frame_id)

        # Draw the bodyparts
        for bp in bodyparts:
            x, y, z = data[bp]
            if not np.isnan(x):
                ax.scatter(xs=x, ys=y, zs=z)

        # Draw connections
        for conn in skeleton:
            if not data[conn].isna().any():
                ax.plot(xs=data.xs('x', level=1), ys=data.xs('y', level=1), zs=data.xs('z', level=1),
                        color='red')

        # Figure artistics
        ax.set_title('Frame: {:05d}'.format(data.name))

        if self.use_tmp:
            fig.savefig(os.path.join(self.get_tmp(), '{:05d}'.format(data.name) + '.png'))
            plt.close(fig=frame_id)
        else:
            self.buffer.append(fig)
            plt.close(fig=frame_id)

    def draw_frames(self, frame_indices):
        for i in tqdm(frame_indices):
            self.draw_a_frame(frame_id=i)

    # def make_a_video(self, buffer: 'tmp'):
    #     """
    #
    #     Parameters
    #     ----------
    #     buffer : 'tmp' or 'buffer', depending on where frames were saved.
    #     """
    #     pass

dlc_config_path = r"D:\emotipose\dlc\emotipose-Stoyo-2021-05-10\config.yaml"
xyz_tracks_path = r"D:\emotipose\isopreteranol\reformatted_dlc_outputs\3D__2021-06-14-16-10_control_female_1.csv"

fps = 50
secs = 60
md = MouseDrawer(dlc_config_path, xyz_tracks_path)
md.draw_frames(md.get_xyz_data().index[(fps*secs*-1):].to_list())
images = pims.ImageSequence(os.path.join(md.get_tmp()+'/*.png'))
io.mimwrite(r"C:\Users\serce\Desktop\output.mp4", images, format=".mp4", fps=50)
