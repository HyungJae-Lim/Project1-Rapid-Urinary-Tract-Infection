import os
import random

import numpy as np
import scipy.io as io

import torch
from torch.utils import data

from data.preprocess import TEST_AUGS_2D
from data.preprocess import mat2npy


def find_classes(path, task="bac"):

    classes = sorted([d for d in os.listdir(path) if os.path.isdir(os.path.join(path, d))])

    class_to_idx = {classes[i]: i for i in range(len(classes))}
    return classes, class_to_idx


def make_dataset(path, class_to_idx, task="bac"):
    if task == "multi" or task == "cascade":
        task = "bac"
    images = []
    path = os.path.expanduser(path)
    for target in sorted(os.listdir(path)):
        d = os.path.join(path, target)
        if not os.path.isdir(d):
            continue

        # target = class_meta_data[target][task_meta[task]]
        for root, _, fnames in sorted(os.walk(d)):
            for fname in sorted(fnames):
                mat_path = os.path.join(root, fname)
                item = (mat_path, class_to_idx[target])
                images.append(item)
    return images


class SpeckleDataset(data.Dataset):
    def __init__(self, root, aug_rate=0, transform=None, task="bac"):
        classes, class_to_idx = find_classes(root, task)
        self.imgs = make_dataset(root, class_to_idx, task)

        if len(self.imgs) == 0:
            raise (RuntimeError("Found 0 images in subfolders of: " + root))

        self.origin_imgs = len(self.imgs)
        if len(self.imgs) == 0:
            raise (RuntimeError("Found 0 images in subfolders of: " + root))

        if aug_rate != 0:
            self.imgs += random.sample(self.imgs, int(len(self.imgs) * aug_rate))
        print(root, "origin : ", self.origin_imgs, ", aug : ", len(self.imgs))

        self.root = root
        self.task = task
        self.classes = classes
        self.class_to_idx = class_to_idx
        self.augs = [] if transform is None else transform

    def __getitem__(self, index):
        """
        Args:
            index (int): Index
        Returns:
            tuple: (image, target) where target is class_index of the target class.
        """
        classes, class_to_idx = find_classes(self.root, self.task)
        path, target = self.imgs[index]
        #print(path)
        mat = io.loadmat(path)
        #img, target_regression = mat2npy(mat)
        img = mat2npy(mat)
        # img = img[:, :, z_dim]

        if index > self.origin_imgs:
            for t in self.augs:
                img = t(img)
        else:
            for t in TEST_AUGS_2D:
                img = t(img)
        
        
        # target_ = np.zeros((len(classes)))
        # target_[target] = 1
        # target_ = target_.astype('long')
        # print(path)
        # return img, target, target_regression, path
        return img, target, path

    def __len__(self):
        return len(self.imgs)



def _make_weighted_sampler(images, classes):
    nclasses = len(classes)
    count = [0] * nclasses
    for item in images:
        count[item[1]] += 1
    print(classes)
    print(count)

    N = float(sum(count))
    assert N == len(images)

    weight_per_class = [0.] * nclasses
    for i in range(nclasses):
        weight_per_class[i] = N / float(count[i])

    weight = [0] * len(images)
    for idx, val in enumerate(images):
        weight[idx] = weight_per_class[val[1]]

    sampler = torch.utils.data.sampler.WeightedRandomSampler(weight, len(weight))
    return sampler

def SpeckleLoader(image_path, batch_size, task="bac", sampler=False,
                 transform=None, aug_rate=0,
                 num_workers=1, shuffle=False, drop_last=False):
    dataset = SpeckleDataset(image_path, task=task, transform=transform, aug_rate=aug_rate)
    if sampler:
        print("Sampler : ", image_path[-5:])
        sampler = _make_weighted_sampler(dataset.imgs)
        return data.DataLoader(dataset, batch_size, sampler=sampler, num_workers=num_workers, drop_last=drop_last)
    return data.DataLoader(dataset, batch_size, shuffle=shuffle, num_workers=num_workers, drop_last=drop_last)
#
#if __name__ == "__main__":
#    data_path = "/data2/DW/180930_bac/Bacteria/train"
#
#    import preprocess_25d as preprocess
#    train_preprocess = preprocess.get_preprocess("train")
#    train_loader = SpeckleLoader(data_path, 2, "bac",
#                                 transform=train_preprocess,
#                                 num_workers=1, infer=False, shuffle=True, drop_last=True)
#
#    for input, target_, _ in train_loader:
#        print("input :", input.shape)
#
#
