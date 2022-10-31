import torch
import torch.nn as nn
from torch.autograd import Variable

import string
import random
import re
import time, math

num_epochsnum_epo  = 10000
print_every = 100
plot_every = 10
chunk_len = 200
embedding_size = 150
hidden_size = 100
batch_size =1
num_layers = 1
lr = 0.002

class RNN(nn.Module):
    def __init__(self, input_size, hidden_size, output_size, num_layers=1):
        super(RNN, self).__init__()
        self.input_size = input_size
        self.hidden_size = hidden_size
        self.output_size = output_size
        self.num_layers = num_layers

        self.encoder = nn.Embedding(input_size, embedding_size)
        self.rnn = nn.RNN(embedding_size, hidden_size, num_layers)
        self.decoder = nn.Linear(hidden_size, output_size)

    def forward(self, input, hidden):
        out = self.encoder(input.view(1, -1))
        out, hidden = self.rnn(out, hidden)
        out = self.decoder(out.view(batch_size, -1))

        return out, hidden

    def init_hidden(self):
        hidden = Variable(torch.zeros(self.num_layers, batch_size, hidden_size)).cuda()
        return hidden


model = RNN(n_characters, embedding_size, hidden_size, n_characters, num_layers=2).cuda()