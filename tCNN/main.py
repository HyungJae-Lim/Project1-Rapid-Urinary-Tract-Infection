from multiprocessing import Process
import os
import json
import argparse
import utils

import torch
import torch.nn as nn

# torch.backends.cudnn.benchmark = True
torch.backends.cudnn.benchmark = False

# example for mnist
from data.SpeckleLoader import *

from data.preprocess import TRAIN_AUGS_2D, TEST_AUGS_2D

from Logger import Logger

from models.tCNN_3 import tCNN_3
from models.tCNN_3_regression import tCNN_3_regression
from models.tCNN_modified import tCNN_modified
from models.tCNN_auxcl import tCNN_auxcl

from runners.BaseRunner import BaseRunner
from runners.SpeckleRunner import SpeckleRunner
from runners.SpeckleRunner_auxcl import SpeckleRunner_auxcl

"""parsing and configuration"""


def arg_parse():
    # projects description
    desc = "Bacteria Speckle Analyzer"
    parser = argparse.ArgumentParser(description=desc)

    parser.add_argument('--gpus', type=str, default="0,1,2,3,4,5,6,7",
                        help="Select GPU Numbering | 0,1,2,3,4,5,6,7 | ")
    parser.add_argument('--cpus', type=int, default="16",
                        help="Select CPU Number workers")
    # parser.add_argument('--data', type=str, default="",
    #                     help="data directory name in dataset")

    # parser.add_argument('--dim', type=str, default='3d',
    #                     choices=["2d", "25d", "3d"])
    # parser.add_argument('--zdim', type=int, default="5")

    parser.add_argument('--aug', type=float, default=0.5, help='The number of Augmentation Rate')

    parser.add_argument('--norm', type=bool, default=False,
                        choices=[True, False])
    parser.add_argument('--act', type=str, default='lrelu',
                        choices=["relu", "lrelu", "prelu"])
    # parser.add_argument('--se', nargs="*", type=int, default=[])
    # parser.add_argument('--af', nargs="*", type=int, default=[])

    parser.add_argument('--task', type=str, default='bac',
                        choices=["bac"])
    # parser.add_argument('--num_classes', type=int, default="1",
    #                     help="The number of classes or regression goals")

    parser.add_argument('--model', type=str, default='tCNN_3',
                        choices=["3dCNN_3", "3dCNN_3_regression", "3dCNN_modified", "3dCNN_a"],
                        help='The type of Models | 3dCNN_3 | 3dCNN_3_regression | 3dCNN_modified |')

    # parser.add_argument('--agg', action="store_true", help='Attention Aggregator')

    parser.add_argument('--data_dir', type=str, default='',
                        help='Directory name to load the data')

    parser.add_argument('--save_dir', type=str, default='',
                        help='Directory name to save the model')

    parser.add_argument('--epoch', type=int, default=500, help='The number of epochs')
    parser.add_argument('--batch_size', type=int, default=64, help='The size of batch')
    parser.add_argument('--batch_size_test', type=int, default=1, help='The size of batch')
    parser.add_argument('--test', action="store_true", help='Only Test')
    parser.add_argument('--sampler', action="store_true", default=False, help='Weighted Sampler work')
    # parser.add_argument('--fold', action="store_true", help='3-Fold')

    parser.add_argument('--optim', type=str, default='adam', choices=["adam", "sgd"])
    parser.add_argument('--lr', type=float, default=1.0)
    # Adam Optimizer
    parser.add_argument('--beta', nargs="*", type=float, default=(0.5, 0.999))
    # SGD Optimizer
    parser.add_argument('--momentum', type=float, default=0.9)#0.9)
    parser.add_argument('--decay', type=float, default=0.0)#1e-4)
    parser.add_argument('--load_fname', type=str, default=None)

    return parser.parse_args()


if __name__ == "__main__":
    arg = arg_parse()
    # if arg.dim != "3d" and arg.model != "dense169":
    #     raise ValueError("Check dim, model")

    arg.save_dir = "%s/outs/%s" % (os.getcwd(), arg.save_dir)
    if os.path.exists(arg.save_dir) is False:
        os.mkdir(arg.save_dir)

    logger = Logger(arg.save_dir)
    logger.will_write(str(arg) + "\n")

    os.environ["CUDA_VISIBLE_DEVICES"] = arg.gpus
    torch_device = torch.device("cuda")

    # data_path = "/data2/DW/180930_bac/valid40/"
    data_path = arg.data_dir
    print("Data Path : ", data_path)

    train_loader = SpeckleLoader(data_path + "training", arg.batch_size, task=arg.task, sampler=arg.sampler,
                             transform=TRAIN_AUGS_2D, aug_rate=arg.aug,
                             num_workers=arg.cpus, shuffle=True, drop_last=True)
    val_loader = SpeckleLoader(data_path + "validation", arg.batch_size_test, task=arg.task, sampler=arg.sampler,
                           transform=TEST_AUGS_2D, aug_rate=0,
                           num_workers=arg.cpus, shuffle=True, drop_last=True)
    test_loader = SpeckleLoader(data_path + "test", arg.batch_size_test, task=arg.task, sampler=arg.sampler,
                            transform=TEST_AUGS_2D, aug_rate=0,
                            num_workers=arg.cpus, shuffle=True, drop_last=True)

    classes,_ = find_classes(data_path + "training", task="bac")#print(classes)
    classes = len(classes)
    # Keeping Yet..
    if arg.model == "3dCNN_3":
        net = tCNN_3(num_classes=classes, norm = arg.norm)
    elif arg.model == "3dCNN_3_regression":
        net = tCNN_3_regression(num_classes=classes, norm = arg.norm)
    elif arg.model == "3dCNN_modified":
        net = tCNN_modified(num_classes=classes, norm = arg.norm)
    elif arg.model == "3dCNN_auxcl":
        net = tCNN_a(num_classes=classes, norm = arg.norm)
        
    net = nn.DataParallel(net).to(torch_device)
    loss = nn.CrossEntropyLoss()

    optim = {
        "adam": torch.optim.Adam(net.parameters(), lr=arg.lr, betas=arg.beta, weight_decay=arg.decay),
        "sgd": torch.optim.SGD(net.parameters(),
                               lr=arg.lr, momentum=arg.momentum,
                               weight_decay=arg.decay, nesterov=False)
    }[arg.optim]

    # print("Dim : ", arg.dim)
    if arg.model == "tCNN_a": 
        model = SpeckleRunner_a(arg, net, optim, torch_device, loss, logger)
    else: 
        model = SpeckleRunner(arg, net, optim, torch_device, loss, logger)
    if arg.test is False:
        model.train(train_loader, val_loader, test_loader)
        model.test(train_loader, val_loader, test_loader)
    else:
        model.test(train_loader, val_loader, test_loader)
        #model._get_acc_path(test_loader, confusion = False)
        


