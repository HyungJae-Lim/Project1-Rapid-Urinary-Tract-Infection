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

class tCNN(nn.Module):
    def __init__(self, num_classes,channels_cnn = [256, 256, 256, 256 ,256], hidden_fc = [128, 64]):
        super(tCNN, self).__init__()

        count = 0
        self.first_block = nn.Sequential()
        for idx, channel_input in enumerate(channels_cnn[0:-1]):
            self.first_block.add_module('{}'.format(count), nn.Conv2d(in_channels=channels_cnn[idx], out_channels=channels_cnn[idx+1], kernel_size=1, stride=1, padding=0,
                  bias=True))
            count = count+1
            self.first_block.add_module('{}'.format(count), nn.BatchNorm2d(num_features=channels_cnn[idx+1]))
            count = count + 1
            self.first_block.add_module('{}'.format(count), nn.LeakyReLU(inplace=True))
            count = count + 1

        self.first_block.add_module('{}'.format(count), nn.AdaptiveAvgPool2d(output_size=[1,1]))
        count = count+1

        self.second_block = nn.Sequential()
        size_fc = [channels_cnn[-1]]+hidden_fc+[num_classes]
        for idx, width_layer in enumerate(size_fc[0:-1]):
            self.second_block.add_module('{}'.format(count), nn.Linear(size_fc[idx], size_fc[idx+1]))
            count = count+1
            self.second_block.add_module('{}'.format(count), nn.BatchNorm1d(size_fc[idx+1]))
            count = count+1
            if idx == size_fc.__len__()-2:
                self.second_block.add_module('{}'.format(count), nn.Softmax(dim=0))
                count = count+1
            else:
                self.second_block.add_module('{}'.format(count),nn.LeakyReLU(inplace=True))
                count = count + 1
        #  [FC -> RELU] * K -> FC


        # weight initialization
        for m in self.first_block.children():
            if isinstance(m, nn.Conv2d):
                m.weight = nn.init.kaiming_normal(m.weight, mode='fan_in')
            elif isinstance(m, nn.BatchNorm2d):
                m.weight.data.fill_(1)
                m.bias.data.zero_()

        for m in self.second_block.children():
            if isinstance(m, nn.Linear):
                m.weight = nn.init.xavier_uniform(m.weight)
            elif isinstance(m, nn.BatchNorm1d):
                m.weight.data.fill_(1)
                m.bias.data.zero_()

    def forward(self,x):
        x = self.first_block(x)
        x = x.view(x.size(0),-1)
        x = self.second_block(x)

        return x




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