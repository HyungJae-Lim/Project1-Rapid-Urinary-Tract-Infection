import torch.nn as nn
import torch.nn.functional as F
import torch
from torch.autograd import Variable
import numpy as np
from torch import optim
class CRNN(nn.Module):
    """Convolutional recurrent neural network model class
    Args:
        img_size (int) - size of an image
        depth_c (int) - how many convolutional layers
        depth_r (int) - how many recurrent neurons to stack
        cnn_features (int) - number of features extracted from CNN
        rnn_features (int) - number of features extracted from RNN
        drop_rate (float) - dropout rate after each dense layer
        num_classes (int) - number of classification classes
    """

    def __init__(self,
                 img_size = 96,
                 depth_c = 3,
                 depth_r = 1,
                 cnn_features = 128,
                 rnn_features = 64,
                 num_classes = 2,
                 batchnorm = True):

        super(CRNN, self).__init__()

        self.rnn_features = rnn_features
        self.cnn_features = cnn_features
        self.num_classes = num_classes
        self.cnn = nn.Sequential()
        channel_input = 1
        channel_output = 16
        # Convolutional layers
        for iter1 in range(depth_c):
            self.cnn.add_module('conv{0}'.format(iter1), nn.Conv2d(in_channels=channel_input, out_channels=channel_output,kernel_size=3,padding=1))
            if batchnorm:
                self.cnn.add_module('norm{0}'.format(iter1), nn.BatchNorm2d(channel_output))
            self.cnn.add_module('relu{0}'.format(iter1), nn.ReLU(inplace=True))
            self.cnn.add_module('pool{0}'.format(iter1), nn.MaxPool2d(kernel_size=3, stride=2, padding=1))
            channel_input = channel_output
            channel_output = channel_output + 4

        # Fully connected network 1
        self.fc1 = nn.Sequential()
        self.fc1.add_module('fc1', nn.Linear(int(channel_input*img_size*img_size/2**(2*depth_c)), cnn_features))
        if batchnorm:
            self.fc1.add_module('norm_fc1', nn.BatchNorm1d(cnn_features))
        self.fc1.add_module('relu_fc1', nn.ReLU(inplace=True))

        # Recurrent layer
        self.rnn = nn.LSTM(cnn_features,rnn_features, depth_r)
        # self.rnn = nn.Sequential()
        # self.rnn.add_module('recurrent', nn.LSTM(cnn_features,rnn_features, depth_r))

        self.fc2 = nn.Sequential()
        # Fully connected network 2
        self.fc2.add_module('fc2', nn.Linear(rnn_features, num_classes))
        if batchnorm:
            self.fc2.add_module('norm_fc2', nn.BatchNorm1d(num_classes))
        self.fc2.add_module('relu_fc2', nn.Softmax(dim = 2))

        for m in self.modules():
            if isinstance(m, nn.Conv2d) or isinstance(m, nn.Linear):
                m.weight = nn.init.kaiming_normal(m.weight, mode='fan_out')
            elif isinstance(m, nn.BatchNorm1d):
                m.weight.data.fill_(1)
                m.bias.data.zero_()

    def forward(self, input):

        batch_size = input.size(0)
        # print(input[:, :, :, :, 0].shape)
        feature = self.cnn(input[:, :, :, :, 0])
        feature = feature.contiguous().view(list(feature.size())[0], -1)
        feature = self.fc1(feature)
        feature = feature.contiguous().view((1, list(feature.size())[0], list(feature.size())[1])) # sequence, batch, elements
        features = [feature]
        outputs = Variable(torch.zeros(input.shape[4], input.shape[0], self.rnn_features))
        hidden = None
        output, hidden = self.rnn(feature, hidden)
        outputs[0] = output

        # print("time loop")
        for t in range(1, input.shape[4]):
            input_t = input[:, :, :, :, t]
            feature_t = self.cnn(input_t)
            feature_t = feature_t.contiguous().view(list(feature_t.size())[0], -1)
            feature_t = self.fc1(feature_t)
            # print("%d time shape : " % (t), feature_t.shape)
            feature_t = feature_t.contiguous().view((1, list(feature_t.size())[0], list(feature_t.size())[1]))
            ### feature.append(feature_t)
            features.append(feature_t)
            output, hidden = self.rnn(feature_t, hidden)
            outputs[t] = output
        # print("time loop end")
        # print("raw time feautres shape : ", feature.shape)
        ### output, hidden = self.rnn(feature)
        classes = self.fc2(output)
        classes =classes.view((list(classes.size())[1], list(classes.size())[2]))
        return classes


# input = Variable(torch.randn(5, 1, 96, 96, 63)) #
# model = CRNN(batchnorm = False)
# model.forward(input)
#
#
# n_epochs = 100
# n_iters = 50
# criterion = nn.CrossEntropyLoss
# optimizer = optim.SGD(model.parameters(), lr=0.01)
# losses = np.zeros(n_epochs) # For plotting
#
# for epoch in range(n_epochs):
#
#     for iter in range(n_iters):
#         _inputs = sample(50)
#         inputs = Variable(torch.from_numpy(_inputs[:-1]).float())
#         inputs = Variable(torch.randn(5, 1, 64, 64, 16))
#         targets = Variable(torch.from_numpy(_inputs[1:]).float())
#
#         # Use teacher forcing 50% of the time
#         # force = random.random() < 0.5
#         force = True
#         outputs, hidden = model(inputs, None, force)
#
#         optimizer.zero_grad()
#         loss = criterion(outputs, targets)
#         loss.backward()
#         optimizer.step()
#
#         losses[epoch] += loss.data[0]
#
#     if epoch > 0:
#         print(epoch, loss.data[0])
