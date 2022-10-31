'''
the most common CNN structure:

Input -> [[Conv -> RELU]* N -> POOL? ] * M -> [FC -> RELU] * K -> FC
'''

# 1. Preparation
import torch
import torch.nn as nn
import torch.optim as optim
from torch.autograd import Variable
from torch.utils.data import DataLoader
from torch.utils.data import sampler

import torchvision.datasets as dset
import torchvision.transforms as T
import torch.nn.functional as F
import numpy as np

import math


'''
channel_0 = 1 #input channel (3 for general dataset like CIFAR, 1 for our ODT data)
channel_1 = 32
filter_size1 = 5
channel_2 = 16
filter_size2 = 3
channel_3 = 8
num_classes = 10
learning_rate = 1e-2
hidden_layer1 = input_size**2*channel_2
hidden_layer2 = 2048
'''

class tCNN_auxcl(nn.Module):
    def __init__(self, num_classes, norm = False):
        super(tCNN_auxcl, self).__init__()
        self.num_classes = num_classes
        self.hidden_fc = [512, 256, 128]
        self.channels_input = 60
        self.channels_cnn = [60, 60, 60, 60, 60, 60, 60, 60, 60]
        
        self.act = nn.LeakyReLU(inplace=True)
        self.act_fin = nn.Softmax(dim=1)
        
        self.conv0 = nn.Conv2d(self.channels_input, self.channels_cnn[0], kernel_size=1, stride=1, padding=0)
        self.conv1 = nn.Conv2d(self.channels_cnn[0], self.channels_cnn[1], kernel_size=1, stride=1, padding=0)
        self.conv2 = nn.Conv2d(self.channels_cnn[1], self.channels_cnn[2], kernel_size=1, stride=1, padding=0)
        self.conv3 = nn.Conv2d(self.channels_cnn[2], self.channels_cnn[3], kernel_size=1, stride=1, padding=0)
        self.conv4 = nn.Conv2d(self.channels_cnn[3], self.channels_cnn[4], kernel_size=1, stride=1, padding=0)
        self.conv5 = nn.Conv2d(self.channels_cnn[4], self.channels_cnn[5], kernel_size=1, stride=1, padding=0)
        self.conv6 = nn.Conv2d(self.channels_cnn[5], self.channels_cnn[6], kernel_size=1, stride=1, padding=0)
        self.conv7 = nn.Conv2d(self.channels_cnn[6], self.channels_cnn[7], kernel_size=1, stride=1, padding=0)
        self.conv8 = nn.Conv2d(self.channels_cnn[7], self.channels_cnn[8], kernel_size=1, stride=1, padding=0)
        
        self.aap = nn.AdaptiveAvgPool2d((1,1))
        
        self.fc0 = nn.Sequential()
        self.fc0.add_module('fcA', nn.Linear(self.channels_cnn[0], self.hidden_fc[0]))
        self.fc0.add_module('actA', self.act)
        self.fc0.add_module('fcB', nn.Linear(self.hidden_fc[0], self.hidden_fc[1]))
        self.fc0.add_module('actB', self.act)
        self.fc0.add_module('fcC', nn.Linear(self.hidden_fc[1], self.hidden_fc[2]))
        self.fc0.add_module('actC', self.act)
        self.fc0.add_module('fcD', nn.Linear(self.hidden_fc[2], self.num_classes))
        self.fc0.add_module('actD', self.act_fin)
        
        self.fc1 = nn.Sequential()
        self.fc1.add_module('fcA', nn.Linear(self.channels_cnn[1], self.hidden_fc[0]))
        self.fc1.add_module('actA', self.act)
        self.fc1.add_module('fcB', nn.Linear(self.hidden_fc[0], self.hidden_fc[1]))
        self.fc1.add_module('actB', self.act)
        self.fc1.add_module('fcC', nn.Linear(self.hidden_fc[1], self.hidden_fc[2]))
        self.fc1.add_module('actC', self.act_fin)
        self.fc1.add_module('fcD', nn.Linear(self.hidden_fc[2], self.num_classes))
        self.fc1.add_module('actD', self.act_fin)
        
        self.fc2 = nn.Sequential()
        self.fc2.add_module('fcA', nn.Linear(self.channels_cnn[2], self.hidden_fc[0]))
        self.fc2.add_module('actA', self.act)
        self.fc2.add_module('fcB', nn.Linear(self.hidden_fc[0], self.hidden_fc[1]))
        self.fc2.add_module('actB', self.act)
        self.fc2.add_module('fcC', nn.Linear(self.hidden_fc[1], self.hidden_fc[2]))
        self.fc2.add_module('actC', self.act_fin)
        self.fc2.add_module('fcD', nn.Linear(self.hidden_fc[2], self.num_classes))
        self.fc2.add_module('actD', self.act_fin)
        
        self.fc3 = nn.Sequential()
        self.fc3.add_module('fcA', nn.Linear(self.channels_cnn[3], self.hidden_fc[0]))
        self.fc3.add_module('actA', self.act)
        self.fc3.add_module('fcB', nn.Linear(self.hidden_fc[0], self.hidden_fc[1]))
        self.fc3.add_module('actB', self.act)
        self.fc3.add_module('fcC', nn.Linear(self.hidden_fc[1], self.hidden_fc[2]))
        self.fc3.add_module('actC', self.act_fin)
        self.fc3.add_module('fcD', nn.Linear(self.hidden_fc[2], self.num_classes))
        self.fc3.add_module('actD', self.act_fin)
        
        self.fc4 = nn.Sequential()
        self.fc4.add_module('fcA', nn.Linear(self.channels_cnn[4], self.hidden_fc[0]))
        self.fc4.add_module('actA', self.act)
        self.fc4.add_module('fcB', nn.Linear(self.hidden_fc[0], self.hidden_fc[1]))
        self.fc4.add_module('actB', self.act)
        self.fc4.add_module('fcC', nn.Linear(self.hidden_fc[1], self.hidden_fc[2]))
        self.fc4.add_module('actC', self.act_fin)
        self.fc4.add_module('fcD', nn.Linear(self.hidden_fc[2], self.num_classes))
        self.fc4.add_module('actD', self.act_fin)
        
        self.fc5 = nn.Sequential()
        self.fc5.add_module('fcA', nn.Linear(self.channels_cnn[5], self.hidden_fc[0]))
        self.fc5.add_module('actA', self.act)
        self.fc5.add_module('fcB', nn.Linear(self.hidden_fc[0], self.hidden_fc[1]))
        self.fc5.add_module('actB', self.act)
        self.fc5.add_module('fcC', nn.Linear(self.hidden_fc[1], self.hidden_fc[2]))
        self.fc5.add_module('actC', self.act_fin)
        self.fc5.add_module('fcD', nn.Linear(self.hidden_fc[2], self.num_classes))
        self.fc5.add_module('actD', self.act_fin)
        
        self.fc6 = nn.Sequential()
        self.fc6.add_module('fcA', nn.Linear(self.channels_cnn[6], self.hidden_fc[0]))
        self.fc6.add_module('actA', self.act)
        self.fc6.add_module('fcB', nn.Linear(self.hidden_fc[0], self.hidden_fc[1]))
        self.fc6.add_module('actB', self.act)
        self.fc6.add_module('fcC', nn.Linear(self.hidden_fc[1], self.hidden_fc[2]))
        self.fc6.add_module('actC', self.act_fin)
        self.fc6.add_module('fcD', nn.Linear(self.hidden_fc[2], self.num_classes))
        self.fc6.add_module('actD', self.act_fin)
        
        self.fc7 = nn.Sequential()
        self.fc7.add_module('fcA', nn.Linear(self.channels_cnn[7], self.hidden_fc[0]))
        self.fc7.add_module('actA', self.act)
        self.fc7.add_module('fcB', nn.Linear(self.hidden_fc[0], self.hidden_fc[1]))
        self.fc7.add_module('actB', self.act)
        self.fc7.add_module('fcC', nn.Linear(self.hidden_fc[1], self.hidden_fc[2]))
        self.fc7.add_module('actC', self.act_fin)
        self.fc7.add_module('fcD', nn.Linear(self.hidden_fc[2], self.num_classes))
        self.fc7.add_module('actD', self.act_fin)
        
        self.fc8 = nn.Sequential()
        self.fc8.add_module('fcA', nn.Linear(self.channels_cnn[8], self.hidden_fc[0]))
        self.fc8.add_module('actA', self.act)
        self.fc8.add_module('fcB', nn.Linear(self.hidden_fc[0], self.hidden_fc[1]))
        self.fc8.add_module('actB', self.act)
        self.fc8.add_module('fcC', nn.Linear(self.hidden_fc[1], self.hidden_fc[2]))
        self.fc8.add_module('actC', self.act_fin)
        self.fc8.add_module('fcD', nn.Linear(self.hidden_fc[2], self.num_classes))
        self.fc8.add_module('actD', self.act_fin)
            
    def forward(self, input):
        x0 = self.act(self.conv0(input))
        x1 = self.act(self.conv0(x0))
        x2 = self.act(self.conv0(x1))
        x3 = self.act(self.conv0(x2))
        x4 = self.act(self.conv0(x3))
        x5 = self.act(self.conv0(x4))
        x6 = self.act(self.conv0(x5))
        x7 = self.act(self.conv0(x6))
        x8 = self.act(self.conv0(x7))
        
        x0 = self.aap(x0)
        x0 = x0.view(x0.size(0),-1)
        y0 = self.fc0(x0)
        x1 = self.aap(x1)
        x1 = x1.view(x1.size(0),-1)
        y1 = self.fc0(x1)
        x2 = self.aap(x2)
        x2 = x2.view(x2.size(0),-1)
        y2 = self.fc0(x2)
        x3 = self.aap(x3)
        x3 = x3.view(x3.size(0),-1)
        y3 = self.fc0(x3)
        x4 = self.aap(x4)
        x4 = x4.view(x4.size(0),-1)
        y4 = self.fc0(x4)
        x5 = self.aap(x5)
        x5 = x5.view(x5.size(0),-1)
        y5 = self.fc0(x5)
        x6 = self.aap(x6)
        x6 = x6.view(x6.size(0),-1)
        y6 = self.fc0(x6)
        x7 = self.aap(x7)
        x7 = x7.view(x7.size(0),-1)
        y7 = self.fc0(x7)
        x8 = self.aap(x8)
        x8 = x8.view(x8.size(0),-1)
        y8 = self.fc0(x8)
        
        return y0,y1,y2,y3,y4,y5,y6,y7,y8,x0,x1,x2,x3,x4,x5,x6,x7,x8
        




###############################################################
### this block is used to change parameters for optimizer
### something like lr_scheduler.StepLR
##################################################################

### whenever running programs locally, check whether gpu exists as follows
### when running on server, programs can harness nn.DataParallel






def train_cnn(model, optimizer, epochs,loader_train, loader_val, batch_size,loss_function):
    highest_accuracy = torch.FloatTensor([0])
    acc = np.zeros((2,100))
    print_every = 100
    model.train()


    for e in range(epochs):
        num_correct1 = torch.FloatTensor([0])
        print('epoch number: %d'%e)
        for batch_idx, (x,y) in enumerate(loader_train):

            optimizer.zero_grad()  # this line is required since parameter update by gradient keeps accumulated

            #x,y = Variable(x), Variable(y)
            x = Variable(x.type_as(torch.FloatTensor())).cuda()
            y = Variable(y.cuda())


            scores = model(x)
            loss = loss_function(scores, y)

            loss.backward()

            optimizer.step()



            _, preds_idx = scores.max(dim = 1)
            num_correct1 += torch.sum(preds_idx == y).float().cpu().data

            '''''
            if batch_idx % print_every == 0:
                print('Iteration %d, loss = %.4f' % (batch_idx, loss))
                check_accuracy(loader_val, model)
                print()
            '''''
        print((batch_idx + 1)*batch_size)
        print(num_correct1)
        accuracy = 100 * num_correct1.cpu() / ((batch_idx + 1) * batch_size)

        print("train accuracy: {}%".format(accuracy.numpy()))
        acc[0][e % 100] = accuracy.numpy()

        model.eval()
        num_correct2 = torch.FloatTensor([0])

        for val_batch_idx, (image, label) in enumerate(loader_val):
            x = Variable(image.type_as(torch.FloatTensor()), volatile=True).cuda()
            y = Variable(label.cuda())

            output = model(x)

            # accuracy

            values, idx = output.max(dim=1)
            num_correct2 += torch.sum(y == idx).float().cpu().data

        print((val_batch_idx + 1) * batch_size)
        print(num_correct2)
        accuracy2 = 100 * num_correct2.cpu() / ((val_batch_idx + 1) * batch_size)
        print("validation accuracy: {}%".format(accuracy2.numpy()))
        acc[1][e % 100] = accuracy2.numpy()

    return acc
### This function defines test accuracy metric


def check_accuracy(loader, model):
    if loader.dataset.train:
        print('Checking accuracy on validation set')
    else:
        print('Checking accuracy on test set')

    num_correct = 0
    num_samples = 0
    model.eval() #set model to evaluation mode

    for x,y in loader:

        #x, y = Variable(x), Variable(y)
        x, y = Variable(x.cuda()), Variable(y.cuda())


        scores = model(x)
        _, preds = scores.max(1)
        num_correct += (preds == y).sum()
        num_samples += preds.size(0)

    acc = float(num_correct) / num_samples
    print('obtained %d / %d correct (%.2f)' % (num_correct, num_samples, 100 * acc))
    return acc








'''''
for t, (x, y) in enumerate(loader_train):


    # these lines moves to device, need to figure out how it can be done in 0.3.x
    #x, y = Variable(x), Variable(y)

    test0 = x
    if t == 0:
        break
    #scores = model(x)
    #loss = loss_function(scores, y)
    #print(loss)




input = torch.randn(3, 5, requires_grad=True)
target = torch.empty(3, dtype=torch.long).random_(5)
output = loss(input, target)



test_input = Variable(torch.randn(10,1,256,256))
test_output = Variable(torch.LongTensor(10).random_(10))

test_scores = model(test_input)
test_loss = loss_function(test_scores,test_output)

test_values, test_idx = test_scores.max(dim=1)
top_1_count = torch.FloatTensor([0])
top_1_count += torch.sum(test_output == test_idx.cpu()).float().cpu().data

# accuracy = 100*top_1_count.cpu()/(train_set.__len__())
print((train_idx + 1) * batch_size)
accuracy = 100 * top_1_count.cpu() / ((train_idx + 1) * batch_size)
print("train accuracy: {}%".format(accuracy.numpy()))
acc[0][i % 100] = accuracy.numpy()  ## added by G Kim
train_accuracy = accuracy  
'''