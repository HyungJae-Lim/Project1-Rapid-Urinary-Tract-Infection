import os
import os.path
import shutil
import re
import sys
import pyudev
import numpy as np
import math as math
import cv2
import random
import matplotlib.pyplot as plt
import matplotlib
import pandas as pd
import signal
from datetime import datetime
from PyQt5.QtCore import *
from PyQt5.QtWidgets import *
from PyQt5 import uic, QtCore, QtGui, QtWidgets
from PyQt5.QtGui import QIcon, QPixmap
from PyQt5.QtGui import *
from skimage import io
from Start import StartWindow
from Stop import StopWindow
from CamshotF import CamshotFWindow
from Data_BLAI_UTI import DataWindow

from threading import Timer
from os.path import split

from Temperature_Monitor import *
from Temperature_Run import *
from Laser_Run import *
from multiprocessing import Process
from simple_pyspin import Camera
from PIL import Image

# UI file Link

form_class = uic.loadUiType("Measurement_BLAI_UTI.ui")[0]

# UI Display

class MeasurementWindow(QDialog, form_class) :

    def __init__(self, parent) :
        super(self.__class__, self).__init__()
        self.setupUi(self)

        # Signal - Slot
        self.Button_Backspace.clicked.connect(self.Button_Backspace_Function)
        self.Button_Monitoring_Start.clicked.connect(self.timer2_start)
        self.Button_Monitoring_Stop.clicked.connect(self.Button_Monitoring_Stop_Function)
        self.Button_Datanum.clicked.connect(self.Button_Datanum_Function)

        # progress Bar Initializing
        self.time = 0 
        if self.time == 0: 
            self.Information_1.setText("0") 

        # Case setting
        f = open("Setting_Case.txt",'r')
        self.caseVar2 = f.readline()
        self.caseVar1 = int(self.caseVar2) # Setting Case
        f.close()
        self.currentCase = self.caseVar1
        self.Spinbox_Case.setValue(self.currentCase)
        self.Button_Dataset.clicked.connect(self.caserev)

        # Temperature setting
        f = open("Setting_Temp.txt",'r')
        self.tempVar2 = f.readline()
        self.tempVar1 = float(self.tempVar2) # Setting Temp
        f.close()
        self.currentTemp = self.tempVar1
        self.Spinbox_Temp.setValue(self.currentTemp)
        self.Button_Tempset.clicked.connect(self.temprev)

        # Function Run
        self.showdate()
        self.showtime()
        self.showtemp_current()
        self.showtemp_setting()
        self.showdata_setting()
        self.timer1_start()
        self.ResultWindow_Initializing()

        # Timer1 setting
    def timer1_start(self):
        self.timer = QtCore.QTimer(self)
        self.timer.setInterval(200)
        self.timer.timeout.connect(self.showtime)
        self.timer.timeout.connect(self.showdate)
        self.timer.timeout.connect(self.showtemp_current)
        self.timer.timeout.connect(self.showtemp_setting)
        self.timer.timeout.connect(self.showdata_setting)
        self.timer.timeout.connect(self.USB)
        self.timer.timeout.connect(self.Storage_Check_Function)
        self.timer.start()

        # Timer2 setting_Progressbar
    def timer2_start(self):
        f = open("Setting_Case.txt",'r')
        casenum = f.readline()
        f.close()
        f = open("Setting_Bacono.txt",'r')
        bacono1 = f.readline()
        bacono = int(bacono1)
        f.close()
        datevar = datetime.today().strftime("%Y-%m-%d")
        name = os.environ['LOGNAME']
        output_dir = '/home/%s/Desktop/Bacometer_Data_M/Train/Bacometer_%s/%s/%s/' % (name, bacono, datevar, casenum)

        if not os.path.exists(output_dir):
            self.Information_1.setText("1")
            self.timerVar1 = QtCore.QTimer(self)
            self.timerVar1.setInterval(15000)
            self.timerVar1.timeout.connect(self.Data_acquisition_Function)
            self.timerVar1.start()

        if os.path.exists(output_dir):
            Start = StartWindow(parent=self)
            Start.showFullScreen()
            Start.exec_()

# Function Part #

# 1. Button backspace Function

    def Button_Backspace_Function(self):
        self.deleteLater() 
        self.close()
      
# 2. USB Detect Fuction

    def USB(self):
        if os.path.exists('/sys/devices/70090000.xusb/usb1/1-2/1-2.1/'):
            self.USB_DetectionVar = QPixmap()
            self.USB_DetectionVar.load("usb.png")
            self.USB_DetectionVar = self.USB_DetectionVar.scaledToWidth(22)
            self.Label_USB.setPixmap(self.USB_DetectionVar)
        else:
            self.USB_DetectionVar = QPixmap()
            self.USB_DetectionVar.load("usb_disconnected.png")
            self.USB_DetectionVar = self.USB_DetectionVar.scaledToWidth(22)
            self.Label_USB.setPixmap(self.USB_DetectionVar)

# 3. Show Function : date / time / temp current / temp setting 

    def showdate(self):
        self.dateVar = QDate.currentDate()
        self.Label_date.setText(self.dateVar.toString("yy-MM-dd"))

    def showtime(self):
        self.timeVar = QTime.currentTime()
        self.Label_time.setText(self.timeVar.toString("AP hh:mm:ss"))

    def showtemp_current(self):
        self.tempVar = Temperature_C()
        self.Label_temp1.setText("%d" %self.tempVar)

    def showtemp_setting(self):
        f = open("Setting_Temp.txt",'r')
        self.tempVar2 = f.readline()
        f.close()
        self.tempVar1 = float(self.tempVar2) # Setting Temp
        self.tempSet = int(self.tempVar1)
        self.Label_temp3.setText("%s" %self.tempSet)

    def showdata_setting(self):
        f = open("Setting_Case.txt",'r')
        self.dataVar = f.readline()
        f.close()
        self.Label_data.setText("%s" %self.dataVar)

# 4. Case revision Function 

    def caserev(self):
    # Temp. setting / write 

        f = open("Setting_Case.txt",'w')
        self.caseVar = self.Spinbox_Case.value()
        self.data = "%d" %self.caseVar
        f.write(self.data)
        f.close()

        self.Progressbar_1.reset() 

        self.time1 = 0 
        if self.time1 == 0: 
            self.Information_1.setText("0") 

        self.Time1 = 0
        self.Time = str(self.Time1)
        f = open("Setting_Progressbar.txt", 'w')
        f.write(self.Time)
        f.close()

        self.n = 0
        self.n2 = str(self.n)
        f = open("Setting_Repeat.txt", 'w')
        f.write(self.n2)
        f.close()

        self.ResultWindow_Initializing()

# 5. Temp revision Function 

    def temprev(self):
    # Temp. setting / write 
        f = open("Setting_Temp.txt",'w')
        self.tempVar2 = self.Spinbox_Temp.value()
        self.data = "%d" %self.tempVar2
        f.write(self.data)
        f.close()

    def categorical_focal_loss(self, gamma=2., alpha=.25):
        import keras.backend as K
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
            y_pred = K.clip(y_pred, epsilon, 1. - epsilon)

            # Calculate Cross Entropy
            cross_entropy = -y_true * K.log(y_pred)

            # Calculate Focal Loss
            loss = alpha * K.pow(1 - y_pred, gamma) * cross_entropy

            # Sum the losses in mini_batch
            return K.sum(loss, axis=1)

        return categorical_focal_loss_fixed
    # Deep Learning Calculation Function
    def calculation(self):
        import cv2
        import tensorflow as tf
        gpu_options = tf.GPUOptions(per_process_gpu_memory_fraction=0.4) 
        sess = tf.Session(config=tf.ConfigProto(gpu_options=gpu_options))
        import tensorflow.keras.layers as Layers
#        import tensorflow.keras.activations as Actications
        import tensorflow.keras.models as Models
        import tensorflow.keras.optimizers as Optimizer
        import tensorflow.keras.metrics as Metrics
        import tensorflow.keras.utils as Utils
        import numpy as np
        from keras.utils import to_categorical
#        from keras.utils.vis_utils import model_to_dot
        from keras.models import load_model
#        from random import randint
        #from IPython.display import SVG
#        import matplotlib.gridspec as gridspec
        import keras.losses
#        import keras.backend as K
        from scipy.stats import norm
        from sklearn import preprocessing
        from collections import Counter
        print("start calculation")
        f = open("Setting_Case.txt",'r')
        casenum = f.readline()
        f.close()
        f = open("Setting_Bacono.txt",'r')
        bacono1 = f.readline()
        bacono = int(bacono1)
        f.close()
        datevar = datetime.today().strftime("%Y-%m-%d")
        name = os.environ['LOGNAME']
        directory = '/home/%s/Desktop/Bacometer_Data_M/Train/Bacometer_%s/%s/%s/' % (name, bacono, datevar, casenum)

        model_path = '/home/twt/Desktop/Bacometer_Code/urine_model.h5'
        model = load_model(model_path, custom_objects={'categorical_focal_loss_fixed':self.categorical_focal_loss(gamma=2., alpha=.25)})
        for n in range(4):
            print('Set{}'.format(n))
            cam_image = []
            image = 0
            label = 0
            for labels in os.listdir(directory):
                if labels == 'cam_{}'.format(n): 
                    label = n-1
                    for image_file in os.listdir(directory+labels):
                        image = cv2.imread(directory+labels+r'/'+image_file, cv2.IMREAD_GRAYSCALE)
                        image = np.array(image, dtype=np.float32)
                        image = image/255.0
                        tif_mean = np.mean(image)
                        tif_max = np.max(image)
                        tif_min = np.min(image)
                        image = (image-tif_min)/(tif_max - tif_min)
                        cam_image.append(image)
            cam_image = np.expand_dims(cam_image, axis =3)
            prediction = model.predict(cam_image)
            y_pred = prediction.argmax(axis=1)
            cnt = Counter(y_pred).most_common(1)

            globals()['cam_results{}'.format(n)] = cnt
#            print('cam{}_results is'.format(n), cnt)
#            print('calculation end')
            a = open("results{}.txt".format(n),'w')
            self.calculation_results = cnt[0][0]
            print(cnt[0][0], self.calculation_results)
            self.data = "%d" %self.calculation_results
            a.write(self.data)
            a.close()
    def calcullation1(self):
        f = open("Setting_Case.txt",'r')
        casenum = f.readline()
        f.close()
        f = open("Setting_Bacono.txt",'r')
        bacono1 = f.readline()
        bacono = int(bacono1)
        f.close()
        datevar = datetime.today().strftime("%Y-%m-%d")
        os.system("python3 main.py --inference --model FlowNet2SD --save_flow --inference_dataset ImagesFromFolder --inference_dataset_root ../Bacometer_Data_M/Train/Bacometer_%s/%s/%s/cam_0 --resume ./checkpoints/ihj_model.pth.tar --save ./output/cam_0" % (bacono, datevar, casenum))
    def calcullation2(self):
        f = open("Setting_Case.txt",'r')
        casenum = f.readline()
        f.close()
        f = open("Setting_Bacono.txt",'r')
        bacono1 = f.readline()
        bacono = int(bacono1)
        f.close()
        datevar = datetime.today().strftime("%Y-%m-%d")
        os.system("python3 main.py --inference --model FlowNet2SD --save_flow --inference_dataset ImagesFromFolder --inference_dataset_root ../Bacometer_Data_M/Train/Bacometer_%s/%s/%s/cam_1 --resume ./checkpoints/ihj_model.pth.tar --save ./output/cam_1" % (bacono, datevar, casenum))
    def calcullation3(self):
        f = open("Setting_Case.txt",'r')
        casenum = f.readline()
        f.close()
        f = open("Setting_Bacono.txt",'r')
        bacono1 = f.readline()
        bacono = int(bacono1)
        f.close()
        datevar = datetime.today().strftime("%Y-%m-%d")
        os.system("python3 main.py --inference --model FlowNet2SD --save_flow --inference_dataset ImagesFromFolder --inference_dataset_root ../Bacometer_Data_M/Train/Bacometer_%s/%s/%s/cam_2 --resume ./checkpoints/ihj_model.pth.tar --save ./output/cam_2" % (bacono, datevar, casenum))
    def calcullation4(self):
        f = open("Setting_Case.txt",'r')
        casenum = f.readline()
        f.close()
        f = open("Setting_Bacono.txt",'r')
        bacono1 = f.readline()
        bacono = int(bacono1)
        f.close()
        datevar = datetime.today().strftime("%Y-%m-%d")
        os.system("python3 main.py --inference --model FlowNet2SD --save_flow --inference_dataset ImagesFromFolder --inference_dataset_root ../Bacometer_Data_M/Train/Bacometer_%s/%s/%s/cam_3 --resume ./checkpoints/ihj_model.pth.tar --save ./output/cam_3" % (bacono, datevar, casenum))
    def prostart1(self):
        pro1 = Process(target=self.calcullation1)
        pro1.start()
        pro1.join()
    def prostart2(self):
        pro2 = Process(target=self.calcullation2)
        pro2.start()
        pro2.join()
    def prostart3(self):
        pro3 = Process(target=self.calcullation3)
        pro3.start()
        pro3.join()
    def prostart4(self):
        pro4 = Process(target=self.calcullation4)
        pro4.start()
        pro4.join()
    def prostart5(self):
        for n in range(4):
            mean_dxs = []
            mean_dys = []
            directory = '/home/twt/Desktop/Bacometer_Code/output/cam_{}/inference/run.epoch-0-flow-field/'.format(n)
            print('Set{}'.format(n))
            for flow_file in sorted(os.listdir(directory)):
                f = open(directory+flow_file, 'rb')
                magic = np.fromfile(f, np.float32, count=1)
                data2d = None
                if 202021.25 != magic:
                    print ('Magic number incorrect. Invalid .flo file')
                else:
                    w = np.fromfile(f, np.int32, count=1)[0]
                    h = np.fromfile(f, np.int32, count=1)[0]
                    print ("Reading %d x %d flo file" % (h, w))
                    data2d = np.fromfile(f, np.float32, count=2 * w * h)
                # reshape data into 3D array (columns, rows, channels)
                    data2d = np.resize(data2d, (h, w, 2))
                    dx, dy = np.reshape(np.swapaxes(data2d, 0, 2), (2, -1))
                    dx2 = round(np.mean(abs(dx)), 4)
                    dy2 = round(np.mean(abs(dy)), 4)
                    mean_dxs.append(dx2)
                    mean_dys.append(dy2)
                f.close()
            print(dx2, dy2)
            a = open("results{}.txt".format(n),'w')
            self.data = "%d" %self.calculation_results
            a.write(self.data)
            a.close()
        os.system("rm -r /home/twt/Desktop/Bacometer_Code/output")
        print("finished calculation")

# 6. Cam shot Function 
    def Data_acquisition_Function(self):
        self.time1 = self.Progressbar_1.value()
        self.time1 += 1
        self.Progressbar_1.setValue(self.time1)
        if self.time1 > 0:
            self.Information_1.setText(str(self.time1))

        if self.time1 == 81:   
            f = open("Setting_Acquisition.txt",'w')
            self.Acquisition = "1"
            f.write(self.Acquisition)
            f.close()
            os.system("python3 Cam1_Shot_M_Train.py")  
            os.system("python3 Cam2_Shot_M_Train.py")              
            os.system("python3 Cam3_Shot_M_Train.py")             
            os.system("python3 Cam4_Shot_M_Train.py")
            self.timerVar1.setInterval(200)
        if self.time1 == 83:
            self.prostart1()
        if self.time1 == 87:
            self.prostart2()
        if self.time1 == 91:
            self.prostart3()
        if self.time1 == 95:
            self.prostart4()
        if self.time1 == 100: 
            self.timerVar1.stop()           
            self.result_name = ['','','','']
            for i in range(4):
                d = open("results{}.txt".format(i),'r')
                self.result_name[i] = d.readline()
                d.close()
                print(self.result_name[i])
            print(self.result_name[0])
            self.Result1 = float(self.result_name[0])
            self.Result2 = float(self.result_name[1])
            self.Result3 = float(self.result_name[2])
            self.Result4 = float(self.result_name[3])
            self.Concentration_Value1 = "Port1"
            self.Concentration_Value2 = "Port2"
            self.Concentration_Value3 = "Port3"
            self.Concentration_Value4 = "Port4"

            if self.Result1 == 0:
                self.Infection_ResultVar1 = QPixmap()
                self.Infection_ResultVar1.load("negative.png")
                self.Label_Result_1.setPixmap(self.Infection_ResultVar1)
                self.Result11 = "Negative"
            if self.Result1 == 2:
                self.Infection_ResultVar1 = QPixmap()
                self.Infection_ResultVar1.load("gram_positive.png")
                self.Label_Result_1.setPixmap(self.Infection_ResultVar1)
                self.Result11 = "Gram(positive)"
            if self.Result1 == 1:
                self.Infection_ResultVar1 = QPixmap()
                self.Infection_ResultVar1.load("gram_negative.png")
                self.Label_Result_1.setPixmap(self.Infection_ResultVar1)
                self.Result11 = "Gram(negative)"

            if self.Result2 == 0:
                self.Infection_ResultVar2 = QPixmap()
                self.Infection_ResultVar2.load("negative.png")
                self.Label_Result_2.setPixmap(self.Infection_ResultVar2)
                self.Result22 = "Negative"
            if self.Result2 == 2:
                self.Infection_ResultVar2 = QPixmap()
                self.Infection_ResultVar2.load("gram_positive.png")
                self.Label_Result_2.setPixmap(self.Infection_ResultVar2)
                self.Result22 = "Gram(positive)"
            if self.Result2 == 1:
                self.Infection_ResultVar2 = QPixmap()
                self.Infection_ResultVar2.load("gram_negative.png")
                self.Label_Result_2.setPixmap(self.Infection_ResultVar2)
                self.Result22 = "Gram(negative)"

            if self.Result3 == 0:
                self.Infection_ResultVar3 = QPixmap()
                self.Infection_ResultVar3.load("negative.png")
                self.Label_Result_3.setPixmap(self.Infection_ResultVar3)
                self.Result33 = "Negative"
            if self.Result3 == 2:
                self.Infection_ResultVar3 = QPixmap()
                self.Infection_ResultVar3.load("gram_positive.png")
                self.Label_Result_3.setPixmap(self.Infection_ResultVar3)
                self.Result33 = "Gram(positive)"
            if self.Result3 == 1:
                self.Infection_ResultVar3 = QPixmap()
                self.Infection_ResultVar3.load("gram_negative.png")
                self.Label_Result_3.setPixmap(self.Infection_ResultVar3)
                self.Result33 = "Gram(negative)"

            if self.Result4 == 0:
                self.Infection_ResultVar4 = QPixmap()
                self.Infection_ResultVar4.load("negative.png")
                self.Label_Result_4.setPixmap(self.Infection_ResultVar4)
                self.Result44 = "Negative"
            if self.Result4 == 2:
                self.Infection_ResultVar4 = QPixmap()
                self.Infection_ResultVar4.load("gram_positive.png")
                self.Label_Result_4.setPixmap(self.Infection_ResultVar4)
                self.Result44 = "Gram(positive)"
            if self.Result4 == 1:
                self.Infection_ResultVar4 = QPixmap()
                self.Infection_ResultVar4.load("gram_negative.png")
                self.Label_Result_4.setPixmap(self.Infection_ResultVar4)
                self.Result44 = "Gram(negative)"

            f = open("Setting_Case.txt",'r')

            casenum = f.readline()
            f.close()

            input_dir = '/home/twt/Desktop/Bacometer_Value/Train/'

            date = time.strftime('%Y-%m-%d', time.localtime(time.time()))
            filename = '%s%s.csv' % (input_dir, date)           
            df = pd.read_csv(filename)

            df['Concentration Value'] = df['Concentration Value'].apply(lambda x: self.Concentration_Value1 if x == 'Port1'  else x) 
            df['Concentration Value'] = df['Concentration Value'].apply(lambda x: self.Concentration_Value2 if x == 'Port2'  else x) 

            df['Concentration Value'] = df['Concentration Value'].apply(lambda x: self.Concentration_Value3 if x == 'Port3'  else x) 

            df['Concentration Value'] = df['Concentration Value'].apply(lambda x: self.Concentration_Value4 if x == 'Port4'  else x)
            df['Result'] = df['Result'].apply(lambda x: self.Result11 if x == 'Port1' else x) 
            df['Result'] = df['Result'].apply(lambda x: self.Result22 if x == 'Port2' else x)         
            df['Result'] = df['Result'].apply(lambda x: self.Result33 if x == 'Port3' else x)            
            df['Result'] = df['Result'].apply(lambda x: self.Result44 if x == 'Port4' else x)
            df.to_csv(filename, index=False)

#            self.Information_1.setText("100")  
            f = open("Setting_Acquisition.txt",'w')
            self.Acquisition = "0"
            f.write(self.Acquisition)
            f.close()

            # Noti: cam shot finished
            from CamshotF import CamshotFWindow
            CamshotF = CamshotFWindow(parent=self)
            CamshotF.showFullScreen()
            CamshotF.exec_()

# 7. Correlation Function_Stop 
    def Button_Monitoring_Stop_Function(self):
        f = open("Setting_Acquisition.txt",'r')
        self.Acquisition1 = f.readline()
        self.Acquisition = int(self.Acquisition1)
        f.close()

        if self.Acquisition == 0:
            Stop = StopWindow(parent=self)
            Stop.showFullScreen()
            Stop.exec_()

            f = open("Setting_Question.txt",'r')
            self.Question1 = f.readline()
            self.Question = int(self.Question1)
            f.close()

            if self.Question == 1:
                self.Progressbar_1.reset()
                self.time1 = 0
                if self.time1 == 0:
                    self.Information_1.setText("0")

                self.Time1 = 0
                self.Time = str(self.Time1)
                f = open("Setting_Progressbar.txt", 'w')
                f.write(self.Time)
                f.close()

                self.n = 0
                self.n2 = str(self.n)
                f = open("Setting_Repeat.txt", 'w')

                f.write(self.n2)
                f.close()

                self.timerVar1.stop() 

        if self.Acquisition == 1:          
            f = open("Setting_Bacono.txt",'r')
            bacono1 = f.readline()
            bacono = int(bacono1)
            f.close()
            f = open("Setting_Case.txt",'r')
            casenum = f.readline()
            f.close()
            datevar = datetime.today().strftime("%Y-%m-%d")
            name = os.environ['LOGNAME']
            output_dir = '/home/%s/Desktop/Bacometer_Data_M/Train/Bacometer_%s/%s/%s/' % (name, bacono, datevar, casenum)

            if not os.path.exists(output_dir):
                pass

            if os.path.exists(output_dir):
                Stop = StopWindow(parent=self)
                Stop.showFullScreen()
                Stop.exec_()

                f = open("Setting_Question.txt",'r')
                self.Question1 = f.readline()
                self.Question = int(self.Question1)
                f.close()

                if self.Question == 1:
                    self.Progressbar_1.reset()
                    self.time1 = 0
                    if self.time1 == 0:
                        self.Information_1.setText("0")

                    self.Time1 = 0
                    self.Time = str(self.Time1)
                    f = open("Setting_Progressbar.txt", 'w')
                    f.write(self.Time)
                    f.close()

                    self.n = 0
                    self.n2 = str(self.n)
                    f = open("Setting_Repeat.txt", 'w')
                    f.write(self.n2)
                    f.close()

                    Result1 = "None"
                    Result2 = "None"
                    Result3 = "None"
                    Result4 = "None"
                    Concentration_Value1 = "None"
                    Concentration_Value2 = "None"
                    Concentration_Value3 = "None"
                    Concentration_Value4 = "None"

                    f = open("Setting_Case.txt",'r')
                    casenum = f.readline()
                    f.close()
                    input_dir = '/home/twt/Desktop/Bacometer_Value/Train/'
                    date = time.strftime('%Y-%m-%d', time.localtime(time.time()))
                    filename = '%s%s.csv' % (input_dir, date)
                    df = pd.read_csv(filename)
                    print(df)

                    df['Concentration Value'] = df['Concentration Value'].apply(lambda x: Concentration_Value1 if x == 'Port1'  else x)
                    df['Concentration Value'] = df['Concentration Value'].apply(lambda x: Concentration_Value2 if x == 'Port2'  else x)
                    df['Concentration Value'] = df['Concentration Value'].apply(lambda x: Concentration_Value3 if x == 'Port3'  else x)
                    df['Concentration Value'] = df['Concentration Value'].apply(lambda x: Concentration_Value4 if x == 'Port4'  else x)
                    df['Result'] = df['Result'].apply(lambda x: Result11 if x == 'Port1' else x)
                    df['Result'] = df['Result'].apply(lambda x: Result22 if x == 'Port2' else x)
                    df['Result'] = df['Result'].apply(lambda x: Result33 if x == 'Port3' else x)
                    df['Result'] = df['Result'].apply(lambda x: Result44 if x == 'Port4' else x)

                    df.to_csv(filename, index=False)

                    self.timerVar1.stop()


# 8. Infection result Function

    def ResultWindow_Initializing(self):

#        self.Label_Result_1.setText("?")
#        self.Label_Result_2.setText("?")
#        self.Label_Result_3.setText("?")
#        self.Label_Result_4.setText("?")

#        self.Label_Result_1.clear()
#        self.Label_Result_2.clear()
#        self.Label_Result_3.clear()
#        self.Label_Result_4.clear()

        self.Infection_ResultVar1 = QPixmap()
        self.Infection_ResultVar2 = QPixmap()
        self.Infection_ResultVar3 = QPixmap()
        self.Infection_ResultVar4 = QPixmap()
        self.Infection_ResultVar1.load("none.png")
        self.Infection_ResultVar2.load("none.png")
        self.Infection_ResultVar3.load("none.png")
        self.Infection_ResultVar4.load("none.png")
        self.Label_Result_1.setPixmap(self.Infection_ResultVar1)
        self.Label_Result_2.setPixmap(self.Infection_ResultVar2)
        self.Label_Result_3.setPixmap(self.Infection_ResultVar3)
        self.Label_Result_4.setPixmap(self.Infection_ResultVar4)

# 9. Storage Check Function

    def Storage_Check_Function(self):
        diskLabel = '/'
        total, used, free = shutil.disk_usage(diskLabel)
        self.storage2 = used/total*100
        self.storage1 = int(self.storage2)
        self.Progressbar_2.setValue(self.storage1)
        self.storage = str(self.storage1)
        self.Label_storage.setText(self.storage)

# 10. Data Number Function
    def Button_Datanum_Function(self):
        data = DataWindow(parent=self)
        data.show()
        data.exec_()


        








