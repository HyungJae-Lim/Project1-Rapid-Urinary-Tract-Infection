import torch.nn as nn
import torch.nn.functional as F
import torch
from torch.autograd import Variable
class FCRNN(nn.Module):
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
                 img_size = 128,
                 depth_fc = 3,
                 depth_r = 1,
                 fc_features = 24,
                 rnn_features = 64,
                 num_classes = 5,
                 batchnorm = True):

        super(FCRNN, self).__init__()

        self.fc_features = fc_features
        self.num_classes = num_classes
        self.fc = nn.Sequential()
        features_input = 64*64
        features_output = 16
        # Fully-connected layers
        for iter1 in range(depth_fc):
            self.fc.add_module('fc{0}'.format(iter1), nn.Linear(in_features=features_input, out_features=features_output))
            if batchnorm:
                self.fc.add_module('norm{0}'.format(iter1), nn.BatchNorm2d(features_output))
            self.fc.add_module('relu{0}'.format(iter1), nn.ReLU(inplace=True))
            features_input = features_output
            feature_output = features_output + 4


        self.rnn = nn.Sequential()
        # Recurrent layer
        self.rnn.add_module('recurrent', nn.GRU(features_input,rnn_features, depth_r, batch_first=True))

        self.fc2 = nn.Sequential()
        # Fully connected network 2
        self.fc2.add_module('fc2', nn.Linear(rnn_features, num_classes))
        if batchnorm:
            self.fc2.add_module('norm_fc2', nn.BatchNorm1d(num_classes))
        self.fc2.add_module('relu_fc2', nn.Softmax())

    def forward(self, input):

        batch_size = input.size(0)

        print(input[:, :, 0].shape)
        features = self.fc(input[:, :, 0])
        # features = features.view(list(features.size())[0], -1)

        print("time loop")
        for t in range(1, input.shape[2]):
            input_t = input[:, :, t]
            feature_t = self.fc(input_t)
            # feature_t = feature_t.view(list(feature_t.size())[0], -1)
            print("%d time shape : " % (t), feature_t.shape)
            features.append(feature_t)
        features = torch.stack(features, dim=2)
        print("time loop end")
        print("raw time feautres shape : ", features.shape)
        output, hidden = self.rnn(features)
        classes = self.fc2(hidden)
        return classes


input = Variable(torch.randn(2, 4096, 16))
model = FCRNN()
model.forward(input)