import torch
import torch.nn as nn
from torch.nn import functional as F
from torch.autograd import Variable
from torch import optim
import numpy as np
import math, random

# Generating a noisy multi-sin wave

def sine_2(X, signal_freq=60.):
    return (np.sin(2 * np.pi * (X) / signal_freq) + np.sin(4 * np.pi * (X) / signal_freq)) / 2.0

def noisy(Y, noise_range=(-0.05, 0.05)):
    noise = np.random.uniform(noise_range[0], noise_range[1], size=Y.shape)
    return Y + noise

def sample(sample_size):
    random_offset = random.randint(0, sample_size)
    X = np.arange(sample_size)
    Y = noisy(sine_2(X + random_offset))
    return Y

# Define the model

class SimpleRNN(nn.Module):
    def __init__(self, hidden_size, channel_input = 1, channel_output = 3):
        super(SimpleRNN, self).__init__()
        self.hidden_size = hidden_size

        self.cnn = nn.Conv2d(in_channels=channel_input, out_channels=channel_output,kernel_size=3,padding=1)
        self.relu = nn.ReLU(inplace=True)
        self.maxpool = nn.MaxPool2d(kernel_size=3, stride=2, padding=1)
        self.inp = nn.Linear(1, hidden_size)
        self.rnn = nn.LSTM(hidden_size, hidden_size, 2, dropout=0.05)
        self.out = nn.Linear(hidden_size, 1)


    def step(self, input, hidden=None):
        input = self.cnn(input)
        input = self.relu(input)
        input = self.maxpool(input)
        input = self.inp(input.view(1, -1)).unsqueeze(1)
        output, hidden = self.rnn(input, hidden)
        output = self.out(output.squeeze(1))
        return output, hidden

    def forward(self, inputs, hidden=None, force=True, steps=0):
        if force or steps == 0: steps = inputs.shape[4]
        outputs = Variable(torch.zeros(steps, 1, 1))
        for i in range(steps):
            if force or i == 0:
                input = inputs[:,:,:,:,i]
            else:
                input = output
            output, hidden = self.step(input, hidden)
            outputs[i] = output
        return outputs, hidden

n_epochs = 100
n_iters = 50
hidden_size = 15360

model = SimpleRNN(hidden_size)
criterion = nn.MSELoss()
optimizer = optim.SGD(model.parameters(), lr=0.01)

losses = np.zeros(n_epochs) # For plotting

for epoch in range(n_epochs):

    for iter in range(n_iters):
        _inputs = sample(50)
        inputs = Variable(torch.from_numpy(_inputs[:-1]).float())
        inputs = Variable(torch.randn(5, 1, 64, 64, 16))
        targets = Variable(torch.from_numpy(_inputs[1:]).float())

        # Use teacher forcing 50% of the time
        # force = random.random() < 0.5
        force = True
        outputs, hidden = model(inputs, None, force)

        optimizer.zero_grad()
        loss = criterion(outputs, targets)
        loss.backward()
        optimizer.step()

        losses[epoch] += loss.data[0]

    if epoch > 0:
        print(epoch, loss.data[0])

    # Use some plotting library
    # if epoch % 10 == 0:
        # show_plot('inputs', _inputs, True)
        # show_plot('outputs', outputs.data.view(-1), True)
        # show_plot('losses', losses[:epoch] / n_iters)

        # Generate a test
        # outputs, hidden = model(inputs, False, 50)
        # show_plot('generated', outputs.data.view(-1), True)

