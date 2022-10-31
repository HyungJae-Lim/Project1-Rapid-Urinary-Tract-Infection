from __future__ import print_function
from __future__ import absolute_import
from __future__ import division


import tensorflow.keras.layers as Layers
import tensorflow.keras.activations as Actications
import tensorflow.keras.models as Models
import tensorflow.keras.optimizers as Optimizer
import tensorflow.keras.metrics as Metrics
import tensorflow.keras.utils as Utils
from keras.utils.vis_utils import model_to_dot
import os
import matplotlib.pyplot as plot
import cv2
import numpy as np
from sklearn.utils import shuffle
from sklearn.metrics import confusion_matrix as CM
from random import randint
from IPython.display import SVG
import matplotlib.gridspec as gridspec
from keras.layers import (
    Conv2D,
    MaxPooling2D,
    Dense,
    Dropout,
    Input,
    Flatten,
    SeparableConv2D,
)
from keras.layers.normalization import BatchNormalization
from keras.models import Sequential, Model
from keras.optimizers import Adam, SGD, RMSprop

import warnings

from keras.models import Model
from keras.layers.core import Dense, Dropout, Activation, Reshape
from keras.layers.convolutional import Conv2D, Conv2DTranspose, UpSampling2D
from keras.layers.pooling import AveragePooling2D, MaxPooling2D
from keras.layers.pooling import GlobalAveragePooling2D
from keras.layers import Input
from keras.layers.merge import concatenate
from keras.layers.normalization import BatchNormalization
from keras.regularizers import l2
from keras.utils.layer_utils import (
    convert_all_kernels_in_model,
    convert_dense_weights_data_format,
)
from keras.utils.data_utils import get_file
from keras.engine.topology import get_source_inputs
from keras_applications.imagenet_utils import _obtain_input_shape
from keras.applications.imagenet_utils import decode_predictions
import keras.backend as K

from skimage import io
from scipy.stats import norm
from sklearn.metrics import confusion_matrix
from sklearn import preprocessing
import matplotlib.pyplot as plt

# --------------------------------------Conv block, dense block, transitional block---------------------------


def __conv_block(ip, nb_filter, bottleneck=False, dropout_rate=None, weight_decay=1e-4):
    """Apply BatchNorm, Relu, 3x3 Conv2D, optional bottleneck block and dropout
    Args:
        ip: Input keras tensor
        nb_filter: number of filters
        bottleneck: add bottleneck block
        dropout_rate: dropout rate
        weight_decay: weight decay factor
    Returns: keras tensor with batch_norm, relu and convolution2d added (optional bottleneck)
    """
    concat_axis = 1 if K.image_data_format() == "channels_first" else -1

    x = BatchNormalization(axis=concat_axis, epsilon=1.1e-5)(ip)
    x = Activation("relu")(x)

    if bottleneck:
        inter_channel = (
            nb_filter * 4
        )  # Obtained from https://github.com/liuzhuang13/DenseNet/blob/master/densenet.lua

        x = Conv2D(
            inter_channel,
            (1, 1),
            kernel_initializer="he_normal",
            padding="same",
            use_bias=False,
            kernel_regularizer=l2(weight_decay),
        )(x)
        x = BatchNormalization(axis=concat_axis, epsilon=1.1e-5)(x)
        x = Activation("relu")(x)

    x = Conv2D(
        nb_filter,
        (3, 3),
        kernel_initializer="he_normal",
        padding="same",
        use_bias=False,
    )(x)
    if dropout_rate:
        x = Dropout(dropout_rate)(x)

    return x


def __dense_block(
    x,
    nb_layers,
    nb_filter,
    growth_rate,
    bottleneck=False,
    dropout_rate=None,
    weight_decay=1e-4,
    grow_nb_filters=True,
    return_concat_list=False,
):
    """Build a dense_block where the output of each conv_block is fed to subsequent ones
    Args:
        x: keras tensor
        nb_layers: the number of layers of conv_block to append to the model.
        nb_filter: number of filters
        growth_rate: growth rate
        bottleneck: bottleneck block
        dropout_rate: dropout rate
        weight_decay: weight decay factor
        grow_nb_filters: flag to decide to allow number of filters to grow
        return_concat_list: return the list of feature maps along with the actual output
    Returns: keras tensor with nb_layers of conv_block appended
    """
    concat_axis = 1 if K.image_data_format() == "channels_first" else -1

    x_list = [x]

    for i in range(nb_layers):
        cb = __conv_block(x, growth_rate, bottleneck, dropout_rate, weight_decay)
        x_list.append(cb)

        x = concatenate([x, cb], axis=concat_axis)

        if grow_nb_filters:
            nb_filter += growth_rate

    if return_concat_list:
        return x, nb_filter, x_list
    else:
        return x, nb_filter


def __transition_block(ip, nb_filter, compression=1.0, weight_decay=1e-4):
    """Apply BatchNorm, Relu 1x1, Conv2D, optional compression, dropout and Maxpooling2D
    Args:
        ip: keras tensor
        nb_filter: number of filters
        compression: calculated as 1 - reduction. Reduces the number of feature maps
                    in the transition block.
        dropout_rate: dropout rate
        weight_decay: weight decay factor
    Returns: keras tensor, after applying batch_norm, relu-conv, dropout, maxpool
    """
    concat_axis = 1 if K.image_data_format() == "channels_first" else -1

    x = BatchNormalization(axis=concat_axis, epsilon=1.1e-5)(ip)
    x = Activation("relu")(x)
    x = Conv2D(
        int(nb_filter * compression),
        (1, 1),
        kernel_initializer="he_normal",
        padding="same",
        use_bias=False,
        kernel_regularizer=l2(weight_decay),
    )(x)
    x = AveragePooling2D((2, 2), strides=(2, 2))(x)

    return x


def __transition_up_block(ip, nb_filters, type="deconv", weight_decay=1e-4):
    """SubpixelConvolutional Upscaling (factor = 2)
    Args:
        ip: keras tensor
        nb_filters: number of layers
        type: can be 'upsampling', 'subpixel', 'deconv'. Determines type of upsampling performed
        weight_decay: weight decay factor
    Returns: keras tensor, after applying upsampling operation.
    """

    if type == "upsampling":
        x = UpSampling2D()(ip)
    elif type == "subpixel":
        x = Conv2D(
            nb_filters,
            (3, 3),
            activation="relu",
            padding="same",
            kernel_regularizer=l2(weight_decay),
            use_bias=False,
            kernel_initializer="he_normal",
        )(ip)
        x = SubPixelUpscaling(scale_factor=2)(x)
        x = Conv2D(
            nb_filters,
            (3, 3),
            activation="relu",
            padding="same",
            kernel_regularizer=l2(weight_decay),
            use_bias=False,
            kernel_initializer="he_normal",
        )(x)
    else:
        x = Conv2DTranspose(
            nb_filters,
            (3, 3),
            activation="relu",
            padding="same",
            strides=(2, 2),
            kernel_initializer="he_normal",
            kernel_regularizer=l2(weight_decay),
        )(ip)

    return x


def __create_dense_net(
    nb_classes,
    img_input,
    include_top,
    depth=40,
    nb_dense_block=3,
    growth_rate=12,
    nb_filter=-1,
    nb_layers_per_block=-1,
    bottleneck=False,
    reduction=0.0,
    dropout_rate=None,
    weight_decay=1e-4,
    subsample_initial_block=False,
    activation="softmax",
):
    """Build the DenseNet model
    Args:
        nb_classes: number of classes
        img_input: tuple of shape (channels, rows, columns) or (rows, columns, channels)
        include_top: flag to include the final Dense layer
        depth: number or layers
        nb_dense_block: number of dense blocks to add to end (generally = 3)
        growth_rate: number of filters to add per dense block
        nb_filter: initial number of filters. Default -1 indicates initial number of filters is 2 * growth_rate
        nb_layers_per_block: number of layers in each dense block.
                Can be a -1, positive integer or a list.
                If -1, calculates nb_layer_per_block from the depth of the network.
                If positive integer, a set number of layers per dense block.
                If list, nb_layer is used as provided. Note that list size must
                be (nb_dense_block + 1)
        bottleneck: add bottleneck blocks
        reduction: reduction factor of transition blocks. Note : reduction value is inverted to compute compression
        dropout_rate: dropout rate
        weight_decay: weight decay rate
        subsample_initial_block: Set to True to subsample the initial convolution and
                add a MaxPool2D before the dense blocks are added.
        subsample_initial:
        activation: Type of activation at the top layer. Can be one of 'softmax' or 'sigmoid'.
                Note that if sigmoid is used, classes must be 1.
    Returns: keras tensor with nb_layers of conv_block appended
    """

    concat_axis = 1 if K.image_data_format() == "channels_first" else -1

    if reduction != 0.0:
        assert (
            reduction <= 1.0 and reduction > 0.0
        ), "reduction value must lie between 0.0 and 1.0"

    # layers in each dense block
    if type(nb_layers_per_block) is list or type(nb_layers_per_block) is tuple:
        nb_layers = list(nb_layers_per_block)  # Convert tuple to list

        assert len(nb_layers) == (nb_dense_block), (
            "If list, nb_layer is used as provided. "
            "Note that list size must be (nb_dense_block)"
        )
        final_nb_layer = nb_layers[-1]
        nb_layers = nb_layers[:-1]
    else:
        if nb_layers_per_block == -1:
            assert (
                depth - 4
            ) % 3 == 0, "Depth must be 3 N + 4 if nb_layers_per_block == -1"
            count = int((depth - 4) / 3)

            if bottleneck:
                count = count // 2

            nb_layers = [count for _ in range(nb_dense_block)]
            final_nb_layer = count
        else:
            final_nb_layer = nb_layers_per_block
            nb_layers = [nb_layers_per_block] * nb_dense_block

    # compute initial nb_filter if -1, else accept users initial nb_filter
    if nb_filter <= 0:
        nb_filter = 2 * growth_rate

    # compute compression factor
    compression = 1.0 - reduction

    # Initial convolution
    if subsample_initial_block:
        initial_kernel = (7, 7)
        initial_strides = (2, 2)
    else:
        initial_kernel = (3, 3)
        initial_strides = (1, 1)

    x = Conv2D(
        nb_filter,
        initial_kernel,
        kernel_initializer="he_normal",
        padding="same",
        strides=initial_strides,
        use_bias=False,
        kernel_regularizer=l2(weight_decay),
    )(img_input)

    if subsample_initial_block:
        x = BatchNormalization(axis=concat_axis, epsilon=1.1e-5)(x)
        x = Activation("relu")(x)
        x = MaxPooling2D((3, 3), strides=(2, 2), padding="same")(x)

    # Add dense blocks
    for block_idx in range(nb_dense_block - 1):
        x, nb_filter = __dense_block(
            x,
            nb_layers[block_idx],
            nb_filter,
            growth_rate,
            bottleneck=bottleneck,
            dropout_rate=dropout_rate,
            weight_decay=weight_decay,
        )
        # add transition_block
        x = __transition_block(
            x, nb_filter, compression=compression, weight_decay=weight_decay
        )
        nb_filter = int(nb_filter * compression)

    # The last dense_block does not have a transition_block
    x, nb_filter = __dense_block(
        x,
        final_nb_layer,
        nb_filter,
        growth_rate,
        bottleneck=bottleneck,
        dropout_rate=dropout_rate,
        weight_decay=weight_decay,
    )

    x = BatchNormalization(axis=concat_axis, epsilon=1.1e-5)(x)
    x = Activation("relu")(x)
    x = GlobalAveragePooling2D()(x)

    if include_top:
        x = Dense(nb_classes, activation=activation)(x)

    return x


# --------------------------------------DenseNet--------------------------------------------------------------


def DenseNet(
    input_shape=None,
    depth=40,
    nb_dense_block=3,
    growth_rate=12,
    nb_filter=-1,
    nb_layers_per_block=-1,
    bottleneck=False,
    reduction=0.0,
    dropout_rate=0.0,
    weight_decay=1e-4,
    subsample_initial_block=False,
    include_top=True,
    weights=None,
    input_tensor=None,
    classes=10,
    activation="softmax",
):

    if weights not in {"imagenet", None}:
        raise ValueError(
            "The `weights` argument should be either "
            "`None` (random initialization) or `cifar10` "
            "(pre-training on CIFAR-10)."
        )

    if weights == "imagenet" and include_top and classes != 1000:
        raise ValueError(
            "If using `weights` as ImageNet with `include_top`"
            " as true, `classes` should be 1000"
        )

    if activation not in ["softmax", "sigmoid"]:
        raise ValueError('activation must be one of "softmax" or "sigmoid"')

    if activation == "sigmoid" and classes != 1:
        raise ValueError("sigmoid activation can only be used when classes = 1")

    # Determine proper input shape
    input_shape = _obtain_input_shape(
        input_shape,
        default_size=32,
        min_size=8,
        data_format=K.image_data_format(),
        require_flatten=include_top,
    )

    if input_tensor is None:
        img_input = Input(shape=input_shape)
    else:
        if not K.is_keras_tensor(input_tensor):
            img_input = Input(tensor=input_tensor, shape=input_shape)
        else:
            img_input = input_tensor

    x = __create_dense_net(
        classes,
        img_input,
        include_top,
        depth,
        nb_dense_block,
        growth_rate,
        nb_filter,
        nb_layers_per_block,
        bottleneck,
        reduction,
        dropout_rate,
        weight_decay,
        subsample_initial_block,
        activation,
    )

    # Ensure that the model takes into account
    # any potential predecessors of `input_tensor`.
    if input_tensor is not None:
        inputs = get_source_inputs(input_tensor)
    else:
        inputs = img_input
    # Create model.
    model = Model(inputs, x, name="densenet")

    return model


# --------------------------------------model define----------------------------------------------------------

# with K.tf.device('/device:GPU:3'):

model = DenseNet(
    (256, 256, 2),
    depth=64,
    nb_dense_block=3,
    growth_rate=4,
    bottleneck=True,
    reduction=0.5,
    weights=None,
    classes=2,
)


# --------------------------------------model summary---------------------------------------------------------

model.summary()

# ------------------------------------------------------------------------------------------------------------


def get_images(directory):
    Images = []
    Labels = []
    label = 0

    for labels in os.listdir(
        directory
    ):  # Main Directory where each class label is present as folder name.
        if labels == "25922":
            label = 0
        elif labels == "29212":
            label = 1

        for image_file in os.listdir(
            directory + labels
        ):  # Extracting the file name of the image from Class Label folder

            f = open(directory + image_file, "rb")
            magic = np.fromfile(f, np.float32, count=1)
            data2d = None
            if 202021.25 != magic:
                print("Magic number incorrect. Invalid .flo file")
            else:
                w = np.fromfile(f, np.int32, count=1)[0]
                h = np.fromfile(f, np.int32, count=1)[0]
                print("Reading %d x %d flo file" % (h, w))
                data2d = np.fromfile(f, np.float32, count=2 * w * h)
                # reshape data into 3D array (columns, rows, channels)
                data2d = np.resize(data2d, (h, w, 2))
            image = data2d

            Images.append(image)
            Labels.append(label)

    #    return Images, Labels
    return shuffle(Images, Labels)  # Shuffle the dataset you just prepared.


def get_classlabel(class_code):
    labels = {0: "E102", 1: "E102f", 2: "E103", 3: "E103f", 4: "E104", 5: "E104f"}

    return labels[class_code]


# ------------------------------------------------------------------------------------------------------------


def get_images_test(directory):
    Images_test = []
    Labels_test = []
    label = 0

    for labels in os.listdir(
        directory
    ):  # Main Directory where each class label is present as folder name.
        if labels == "25922":
            label = 0
        elif labels == "29212":
            label = 1

        for image_file in os.listdir(
            directory + labels
        ):  # Extracting the file name of the image from Class Label folder

            f = open(directory + image_file, "rb")
            magic = np.fromfile(f, np.float32, count=1)
            data2d = None
            if 202021.25 != magic:
                print("Magic number incorrect. Invalid .flo file")
            else:
                w = np.fromfile(f, np.int32, count=1)[0]
                h = np.fromfile(f, np.int32, count=1)[0]
                print("Reading %d x %d flo file" % (h, w))
                data2d = np.fromfile(f, np.float32, count=2 * w * h)
                # reshape data into 3D array (columns, rows, channels)
                data2d = np.resize(data2d, (h, w, 2))
            image_test = data2d

            Images_test.append(image_test)
            Labels_test.append(label)

    #    return Images_test, Labels_test
    return shuffle(Images_test, Labels_test)  # Shuffle the dataset you just prepared.


# --------------------------------------Get image directory---------------------------------------------------

Images, Labels = get_images(
    "/data/hjim/Urine/input/flo/train/"
)  # Extract the training images from the folders.
Images_test, Labels_test = get_images_test("/data/hjim/Urine/input/flo/val/")


# Images = np.asarray(Images)
# Images = Images.astype(float)
# Images = np.array(Images, dtype=np.float32) #converting the list of images to numpy array.
# Images = np.expand_dims(Images, axis=3)
# Images_test = np.array(Images_test, dtype=np.float32)
# Images_test = np.expand_dims(Images_test, axis=3)


# Images = Images/255.
# Images_test = Images_test/255.

# ------------------------------------------------------------------------------------------------------------
Images = np.expand_dims(Images, axis=3)
Images_test = np.expand_dims(Images_test, axis=3)

Labels = np.array(Labels)
Labels_test = np.array(Labels_test)

# --------------------------------------Training image, Width, Height, Channel--------------------------------

print("Shape of Images:", Images.shape)
print("Shape of Labels:", Labels.shape)

print("Shape of test_Images:", Images_test.shape)
print("Shape of test_Labels:", Labels_test.shape)


"""
#--------------------------------------random image show-----------------------------------------------------

f,ax = plot.subplots(5,5) 
f.subplots_adjust(0,0,3,3)
for i in range(0,5,1):
    for j in range(0,5,1):
        rnd_number = randint(0,len(Images))
        ax[i,j].imshow(Images[rnd_number])
        ax[i,j].set_title(get_classlabel(Labels[rnd_number]))
        ax[i,j].axis('off')

"""
# --------------------------------------custom loss function-------------------------------------------------

from keras.utils import to_categorical

Labels = to_categorical(Labels)
Labels_test = to_categorical(Labels_test)
"""
Define our custom loss function.
"""
from keras import backend as K
import tensorflow as tf


def binary_focal_loss(gamma=2.0, alpha=0.25):
    """
    Binary form of focal loss.
      FL(p_t) = -alpha * (1 - p_t)**gamma * log(p_t)
      where p = sigmoid(x), p_t = p or 1 - p depending on if the label is 1 or 0, respectively.
    References:
        https://arxiv.org/pdf/1708.02002.pdf
    Usage:
     model.compile(loss=[binary_focal_loss(alpha=.25, gamma=2)], metrics=["accuracy"], optimizer=adam)
    """

    def binary_focal_loss_fixed(y_true, y_pred):
        """
        :param y_true: A tensor of the same shape as `y_pred`
        :param y_pred:  A tensor resulting from a sigmoid
        :return: Output tensor.
        """
        pt_1 = tf.where(tf.equal(y_true, 1), y_pred, tf.ones_like(y_pred))
        pt_0 = tf.where(tf.equal(y_true, 0), y_pred, tf.zeros_like(y_pred))

        epsilon = K.epsilon()
        # clip to prevent NaN's and Inf's
        pt_1 = K.clip(pt_1, epsilon, 1.0 - epsilon)
        pt_0 = K.clip(pt_0, epsilon, 1.0 - epsilon)

        return -K.sum(alpha * K.pow(1.0 - pt_1, gamma) * K.log(pt_1)) - K.sum(
            (1 - alpha) * K.pow(pt_0, gamma) * K.log(1.0 - pt_0)
        )

    return binary_focal_loss_fixed


def categorical_focal_loss(gamma=2.0, alpha=0.25):
    """
    Softmax version of focal loss.
           m
      FL = ¢²  -alpha * (1 - p_o,c)^gamma * y_o,c * log(p_o,c)
          c=1
      where m = number of classes, c = class and o = observation
    Parameters:
      alpha -- the same as weighing factor in balanced cross entropy
      gamma -- focusing parameter for modulating factor (1-p)
    Default value:
      gamma -- 2.0 as mentioned in the paper
      alpha -- 0.25 as mentioned in the paper
    References:
        Official paper: https://arxiv.org/pdf/1708.02002.pdf
        https://www.tensorflow.org/api_docs/python/tf/keras/backend/categorical_crossentropy
    Usage:
     model.compile(loss=[categorical_focal_loss(alpha=.25, gamma=2)], metrics=["accuracy"], optimizer=adam)
    """

    def categorical_focal_loss_fixed(y_true, y_pred):
        """
        :param y_true: A tensor of the same shape as `y_pred`
        :param y_pred: A tensor resulting from a softmax
        :return: Output tensor.
        """

        # Scale predictions so that the class probas of each sample sum to 1
        y_pred /= K.sum(y_pred, axis=-1, keepdims=True)

        # Clip the prediction value to prevent NaN's and Inf's
        epsilon = K.epsilon()
        y_pred = K.clip(y_pred, epsilon, 1.0 - epsilon)

        # Calculate Cross Entropy
        cross_entropy = -y_true * K.log(y_pred)

        # Calculate Focal Loss
        loss = alpha * K.pow(1 - y_pred, gamma) * cross_entropy

        # Sum the losses in mini_batch
        return K.sum(loss, axis=1)

    return categorical_focal_loss_fixed


# -------------------------------------model load option-----------------------------------------------------
"""
from keras.models import load_model
model = load_model('Urine_model.h5', custom_objects={'categorical_focal_loss_fixed': categorical_focal_loss(gamma=2., alpha=.25)})
"""
# --------------------------------------model setup-----------------------------------------------------------


optimizer = Adam(lr=0.00002, decay=1e-5)
model.compile(
    loss=[categorical_focal_loss(alpha=0.25, gamma=2)],
    metrics=["accuracy"],
    optimizer=optimizer,
)

from keras.callbacks import ModelCheckpoint

MODEL_SAVE_FOLDER_PATH = "./model/"
if not os.path.exists(MODEL_SAVE_FOLDER_PATH):
    os.mkdir(MODEL_SAVE_FOLDER_PATH)

model_path = MODEL_SAVE_FOLDER_PATH + "{epoch:02d}-{acc:.4f}-{val_acc:.4f}.h5"
cb_checkpoint = ModelCheckpoint(
    filepath=model_path, monitor="val_acc", verbose=1, save_best_only=True
)

# early_stopping = EarlyStopping(monitor='val_loss', patience = 5)
trained = model.fit(
    Images,
    Labels,
    epochs=100,
    shuffle=True,
    validation_data=(Images_test, Labels_test),
    callbacks=[cb_checkpoint],
)

# validation_data=(Images_test, Labels_test)

from keras.models import load_model

model.save("Urine_model.h5")

# ---------------------------------------model plt------------------------------------------------------------

plot.plot(trained.history["acc"])
plot.plot(trained.history["val_acc"])
plot.title("Model accuracy")
plot.ylabel("Accuracy")
plot.xlabel("Epoch")
plot.legend(["Train", "Test"], loc="upper left")
plot.savefig("Accuracy_graph.png", bbox_inches="tight")
plot.show()

plot.plot(trained.history["loss"])
plot.plot(trained.history["val_loss"])
plot.title("Model loss")
plot.ylabel("Loss")
plot.xlabel("Epoch")
plot.legend(["Train", "Test"], loc="upper left")
plot.savefig("Loss_graph.png", bbox_inches="tight")
plot.show()

prediction = model.predict(Images_test)
y_pred = prediction.argmax(axis=1)
print(y_pred.shape)
y_true = Labels_test.argmax(axis=1)
print(y_true.shape)


print(y_true.shape, y_pred.shape)
cm = confusion_matrix(y_true, y_pred)
print(cm)
# print(model.evaluate(Images_test, Labels_test))

fig, ax = plt.subplots()
im = ax.imshow(cm, interpolation="nearest", cmap=plt.cm.Blues)
ax.figure.colorbar(im, ax=ax)

ax.set(
    xticks=np.arange(cm.shape[1]),
    yticks=np.arange(cm.shape[0]),
    xticklabels=["00_neg", "00_pos", "01_neg", "01_pos"],
    yticklabels=["00_neg", "00_pos", "01_neg", "01_pos"],
)
ax.set_title("Test classification", fontsize=15)
ax.set_ylabel("True label", fontsize=15)
ax.set_xlabel("Predicted label", fontsize=15)

plt.setp(
    ax.get_xticklabels(), fontsize=15, rotation=0, ha="center", rotation_mode="anchor"
)
plt.setp(
    ax.get_yticklabels(), fontsize=15, rotation=90, ha="center", rotation_mode="anchor"
)


thresh = cm.max() / 2.0
for i in range(cm.shape[0]):
    for j in range(cm.shape[1]):
        ax.text(
            j,
            i,
            cm[i, j],
            ha="center",
            va="center",
            color="white" if cm[i, j] > thresh else "black",
        )
fig.tight_layout()

plt.savefig("model_test_confusion.png", dpi=400, bbox_inches="tight")
plt.show()
