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
import csv

from datetime import datetime
from PyQt5.QtCore import *
from PyQt5.QtWidgets import *
from PyQt5 import uic, QtCore, QtGui, QtWidgets
from PyQt5.QtGui import QIcon, QPixmap
from PyQt5.QtGui import *
from skimage import io
from Start import StartWindow
from Stop import StopWindow
from Data_BLSD_CKD import DataWindow

from threading import Timer
from os.path import split

from Temperature_Monitor import *
from Temperature_Run import *
from Laser_Run import *
from multiprocessing import Process
from simple_pyspin import Camera
from PIL import Image
from pandas import Series

import smbus
import time
import Jetson.GPIO as GPIO 
from time import sleep  

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)  
GPIO.setup(10, GPIO.OUT)  # Camera


# UI file Link

form_class = uic.loadUiType("Engineering.ui")[0]

# UI Display

class EngineeringWindow(QDialog, form_class) :

    def __init__(self):
        super().__init__()
        self.setupUi(self)
 
        # Signal - Slot
        self.Button_Backspace.clicked.connect(self.Button_Backspace_Function)

        self.Button_Keypad_ET1.clicked.connect(self.Button_Keypad_ET_Cam1_Function) 
        self.Button_Keypad_ET2.clicked.connect(self.Button_Keypad_ET_Cam2_Function)              
        self.Button_Keypad_ET3.clicked.connect(self.Button_Keypad_ET_Cam3_Function)         
        self.Button_Keypad_ET4.clicked.connect(self.Button_Keypad_ET_Cam4_Function) 

        self.Button_Keypad_FPS1.clicked.connect(self.Button_Keypad_FPS_Cam1_Function) 
        self.Button_Keypad_FPS2.clicked.connect(self.Button_Keypad_FPS_Cam2_Function) 
        self.Button_Keypad_FPS3.clicked.connect(self.Button_Keypad_FPS_Cam3_Function) 
        self.Button_Keypad_FPS4.clicked.connect(self.Button_Keypad_FPS_Cam4_Function) 

        self.Button_Keypad_Gain1.clicked.connect(self.Button_Keypad_Gain_Cam1_Function) 
        self.Button_Keypad_Gain2.clicked.connect(self.Button_Keypad_Gain_Cam2_Function) 
        self.Button_Keypad_Gain3.clicked.connect(self.Button_Keypad_Gain_Cam3_Function) 
        self.Button_Keypad_Gain4.clicked.connect(self.Button_Keypad_Gain_Cam4_Function) 

        self.Button_Keypad_Offset_X1.clicked.connect(self.Button_Keypad_Offset_X_Cam1_Function)
        self.Button_Keypad_Offset_X2.clicked.connect(self.Button_Keypad_Offset_X_Cam2_Function)
        self.Button_Keypad_Offset_X3.clicked.connect(self.Button_Keypad_Offset_X_Cam3_Function)
        self.Button_Keypad_Offset_X4.clicked.connect(self.Button_Keypad_Offset_X_Cam4_Function)

        self.Button_Keypad_Offset_Y1.clicked.connect(self.Button_Keypad_Offset_Y_Cam1_Function)
        self.Button_Keypad_Offset_Y2.clicked.connect(self.Button_Keypad_Offset_Y_Cam2_Function)
        self.Button_Keypad_Offset_Y3.clicked.connect(self.Button_Keypad_Offset_Y_Cam3_Function)
        self.Button_Keypad_Offset_Y4.clicked.connect(self.Button_Keypad_Offset_Y_Cam4_Function)

        self.Button_Keypad_Repeat1.clicked.connect(self.Button_Keypad_Repeat_Cam1_Function) 
        self.Button_Keypad_Repeat2.clicked.connect(self.Button_Keypad_Repeat_Cam2_Function) 
        self.Button_Keypad_Repeat3.clicked.connect(self.Button_Keypad_Repeat_Cam3_Function) 
        self.Button_Keypad_Repeat4.clicked.connect(self.Button_Keypad_Repeat_Cam4_Function) 

        self.Button_Keypad_ROI_X1.clicked.connect(self.Button_Keypad_ROI_X_Cam1_Function)
        self.Button_Keypad_ROI_X2.clicked.connect(self.Button_Keypad_ROI_X_Cam2_Function)
        self.Button_Keypad_ROI_X3.clicked.connect(self.Button_Keypad_ROI_X_Cam3_Function)
        self.Button_Keypad_ROI_X4.clicked.connect(self.Button_Keypad_ROI_X_Cam4_Function)

        self.Button_Keypad_ROI_Y1.clicked.connect(self.Button_Keypad_ROI_Y_Cam1_Function)
        self.Button_Keypad_ROI_Y2.clicked.connect(self.Button_Keypad_ROI_Y_Cam2_Function)
        self.Button_Keypad_ROI_Y3.clicked.connect(self.Button_Keypad_ROI_Y_Cam3_Function)
        self.Button_Keypad_ROI_Y4.clicked.connect(self.Button_Keypad_ROI_Y_Cam4_Function)

        self.Button_Monitoring_Start.clicked.connect(self.timer2_start)
        self.Button_Monitoring_Stop.clicked.connect(self.Button_Monitoring_Stop_Function)

        self.Button_Autocalibration.clicked.connect(self.timer3_start)
        self.Button_Autocalibration_Load.clicked.connect(self.AutoCalibration_Load_Function)

        # progress Bar Initializing
        self.time = 0 
        if self.time == 0: 
            self.Information_1.setText("0") 

        # Run_Thread_Temperature
        self.Temprun = Temp_run() 
        self.Temprun.start()
        
        # Run_Thread_Laser usage time
        self.Laserrun = Laser_run()
        self.Laserrun.start()

        # Function Run
        self.showdate()
        self.showtime()
        self.showtemp_current()
        self.showtemp_setting()

        self.showExposetime_setting()
        self.showFPS_setting()
        self.showGain_setting()
        self.showOffset_X_setting()
        self.showOffset_Y_setting()
        self.showRepeat_setting()
        self.showROI_X_setting()
        self.showROI_Y_setting()

        self.timer1_start()

        # Timer1 setting
    def timer1_start(self):
        self.timer1 = QtCore.QTimer(self)
        self.timer1.setInterval(500)
        self.timer1.timeout.connect(self.showdate)
        self.timer1.timeout.connect(self.showtime)
        self.timer1.timeout.connect(self.showtemp_current)
        self.timer1.timeout.connect(self.showtemp_setting)

        self.timer1.timeout.connect(self.showExposetime_setting)
        self.timer1.timeout.connect(self.showFPS_setting)
        self.timer1.timeout.connect(self.showGain_setting)
        self.timer1.timeout.connect(self.showOffset_X_setting)
        self.timer1.timeout.connect(self.showOffset_Y_setting)
        self.timer1.timeout.connect(self.showRepeat_setting)
        self.timer1.timeout.connect(self.showROI_X_setting)
        self.timer1.timeout.connect(self.showROI_Y_setting)

        self.timer1.timeout.connect(self.USB)
        self.timer1.timeout.connect(self.Storage_Check_Function)
        self.timer1.start()

        # Timer2 setting _ progressbar
    def timer2_start(self):
         
        self.Progressbar_1.reset()
        self.Information_1.setText("1")

        self.n = 0
        self.n2 = str(self.n)
        f = open("Setting_Repeat.txt", 'w')
        f.write(self.n2)

        self.Time1 = 0
        self.Time = str(self.Time1)
        f = open("Setting_Progressbar.txt", 'w')
        f.write(self.Time)
        f.close()

        self.timer2 = QtCore.QTimer(self)
        self.timer2.setInterval(500)     
        self.timer2.timeout.connect(self.Button_Monitoring_Start_Function)
        self.timer2.start()

    def timer3_start(self):
         
        self.Information_1.setText("1")
        self.timer3 = QtCore.QTimer(self)
        self.timer3.setInterval(100)     
        self.timer3.timeout.connect(self.Autocalibration_Function)
        self.timer3.start()

# Function Part #

# 1. Button Function

    def Button_Backspace_Function(self):
        self.deleteLater() 
        self.close()

    def Button_Monitoring_Start_Function(self):

        self.time1 = self.Progressbar_1.value()

        f = open("/home/twt/Desktop/variable2/Manual/Cam_0/Setting_Repeat1.txt",'r')
        self.timenum1 = f.readline()
        f.close()
        self.timenum = int(self.timenum1)  # *1->12 revision

        f = open("Setting_Repeat.txt",'r')
        self.n1 = f.readline()
        self.n = int(self.n1)
        f.close()

        f = open("Setting_Progressbar.txt",'r')
        self.Time = f.readline()
        self.time1 = float(self.Time)
        f.close()


       
        if self.timenum > self.n:
   
            self.time1 += 100/self.timenum
            print(self.n)

            f = open("Setting_Case.txt",'r')
            casenum = f.readline()
            f.close()
            datevar = datetime.today().strftime("%Y-%m-%d")
            name = os.environ['LOGNAME']

            GPIO.output(10,True)
            time.sleep(5)

            os.system("python3 Cam1_Cali.py")
            os.system("python3 Cam2_Cali.py")
            os.system("python3 Cam3_Cali.py")
            os.system("python3 Cam4_Cali.py")
            os.system("python3 Cam1_Shot_M_Manual.py")
            os.system("python3 Cam2_Shot_M_Manual.py")
            os.system("python3 Cam3_Shot_M_Manual.py")
            os.system("python3 Cam4_Shot_M_Manual.py")

            GPIO.output(10,False)

            def get_images(directory):

                Images = []

                for image_file in sorted(
                        os.listdir(directory)):  # Main Directory where each class label is present as folder name.

                    image = io.imread(directory + r'/' + image_file)
                    image = np.asarray(image)
                    Images.append(image)

                return Images  # Shuffle the dataset you just prepared.

            def ftc(a):
                b = a / a.mean(axis=1).mean(axis=1).reshape(a.shape[0], 1, 1)
                x = np.fft.fftn(b)
                x = np.abs(x)
                x = np.square(x)
                x = np.fft.ifftn(x)
                x = np.real(x)
                x = np.fft.fftshift(x)
                x /= x.size

                return (x - 1) / b.std() ** 2

            matplotlib.rcParams['font.size'] = 12
            fig, ax = plt.subplots(figsize=(8, 7))

            f = open("Setting_Bacono.txt",'r')
            bacono1 = f.readline()
            bacono = int(bacono1)
            f.close()

            name = os.environ['LOGNAME']
            directory = '/home/%s/Desktop/Bacometer_Data_E/Multi/' % name

            for labels in sorted(os.listdir(directory)):
                if labels == 'cam_0':
                    Images = get_images(directory + labels)
                    Images = np.array(Images)
                    t = time.time()
                    cor = ftc(Images)
                    print(cor[int(cor.shape[0] / 2):, int(cor.shape[1] / 2), int(cor.shape[2] / 2)])
            y111 = Series(data =cor[int(cor.shape[0] / 2):, int(cor.shape[1] / 2), int(cor.shape[2] / 2)])
            y11 = y111.sort_values(ascending=False)
            y1 = np.mean(y11[0:100])

            for labels in sorted(os.listdir(directory)):
                if labels == 'cam_1':
                    Images = get_images(directory + labels)
                    Images = np.array(Images)
                    t = time.time()
                    cor = ftc(Images)
                    print(cor[int(cor.shape[0] / 2):, int(cor.shape[1] / 2), int(cor.shape[2] / 2)])

            y222 = Series(data =cor[int(cor.shape[0] / 2):, int(cor.shape[1] / 2), int(cor.shape[2] / 2)])
            y22 = y222.sort_values(ascending=False)
            y2 = np.mean(y22[0:100])

            for labels in sorted(os.listdir(directory)):
                if labels == 'cam_2':
                    Images = get_images(directory + labels)
                    Images = np.array(Images)
                    t = time.time()
                    cor = ftc(Images)
                    print(cor[int(cor.shape[0] / 2):, int(cor.shape[1] / 2), int(cor.shape[2] / 2)])
            y333 = Series(data =cor[int(cor.shape[0] / 2):, int(cor.shape[1] / 2), int(cor.shape[2] / 2)])
            y33 = y333.sort_values(ascending=False)
            y3 = np.mean(y33[0:100])

            for labels in sorted(os.listdir(directory)):
                if labels == 'cam_3':
                    Images = get_images(directory + labels)
                    Images = np.array(Images)
                    t = time.time()
                    cor = ftc(Images)
                    print(cor[int(cor.shape[0] / 2):, int(cor.shape[1] / 2), int(cor.shape[2] / 2)])
            y444 = Series(data =cor[int(cor.shape[0] / 2):, int(cor.shape[1] / 2), int(cor.shape[2] / 2)])
            y44 = y444.sort_values(ascending=False)
            y4 = np.mean(y44[0:100])
#            y4 = np.mean(cor[int(cor.shape[0] / 2):, int(cor.shape[1] / 2), int(cor.shape[2] / 2)])

            x = self.n * 5

#
            input_dir = '/home/%s/Desktop/Bacometer_Data_E/Multi/' % name
            date = time.strftime('%Y-%m-%d', time.localtime(time.time()))
            filename1 = '%s%s_correlation.csv' % (input_dir, date)

            if os.path.exists('%s%s_correlation.csv' % (input_dir, date)):
                df = pd.read_csv(filename1)
                x_value1 = df['X'].max()
                x_value = x_value1 + 1
                y1_value = y1
                y2_value = y2
                y3_value = y3
                y4_value = y4
                filename = '%s%s_correlation.csv' % (input_dir, date)

                df2 = df.append(pd.DataFrame([[x_value, y1_value, y2_value, y3_value, y4_value]], columns=['X', 'Y1', 'Y2', 'Y3', 'Y4']), ignore_index=True)
                df2.to_csv(filename, index=False)
                print("exists")
            else:
                df = pd.DataFrame(columns=['X', 'Y1', 'Y2', 'Y3', 'Y4'])
                x_value = x
                y1_value = y1
                y2_value = y2
                y3_value = y3
                y4_value = y4
                filename = '%s%s_correlation.csv' % (input_dir, date)
                df2 = df.append(pd.DataFrame([[x_value, y1_value, y2_value, y3_value, y4_value]], columns=['X', 'Y1', 'Y2', 'Y3', 'Y4']), ignore_index=True)
                df2.to_csv(filename, index=False)
                print("no exists")
#
            df3 = pd.read_csv(filename1)
            xx = df3['X']
            yy1 = df3['Y1']
            yy2 = df3['Y2']
            yy3 = df3['Y3']
            yy4 = df3['Y4']    

            self.Graph_9.canvas.axes.clear()
            self.Plot = self.Graph_9.canvas.axes.plot(xx, yy1, label="Port1", linestyle='--', marker='o') 
            self.Plot = self.Graph_9.canvas.axes.plot(xx, yy2, label="Port2", linestyle='--', marker='o')
            self.Plot = self.Graph_9.canvas.axes.plot(xx, yy3, label="Port3", linestyle='--', marker='o')
            self.Plot = self.Graph_9.canvas.axes.plot(xx, yy4, label="Port4", linestyle='--', marker='o')
            self.Plot = self.Graph_9.canvas.axes.legend()
            self.Graph_9.canvas.draw()

            self.time2 = math.floor(self.time1)
            self.Information_1.setText('%s' %self.time2)
            self.Progressbar_1.setValue(self.time2)

            self.Time = str(self.time1)
            f = open("Setting_Progressbar.txt", 'w')
            f.write(self.Time)
            f.close()

            self.n += 1
            self.n2 = str(self.n)
            f = open("Setting_Repeat.txt", 'w')
            f.write(self.n2)
            f.close()

        if self.timenum <= self.n:
            self.Information_1.setText("100")
            self.Progressbar_1.setValue(100)
            self.timer2.stop()

#... correlation code end

            image1 = cv2.imread('/home/%s/Desktop/Bacometer_Data_E/Multi/cam_0/000299.tiff' %name)
            image1_1 = np.array(image1, dtype=np.int)
            image1_2 = image1_1[:, :, 0]
            image1_3 = np.ravel(image1_2, order='k')  # ravel

            image2 = cv2.imread('/home/%s/Desktop/Bacometer_Data_E/Multi/cam_1/000299.tiff' %name)
            image2_1 = np.array(image2, dtype=np.int)
            image2_2 = image2_1[:, :, 0]
            image2_3 = np.ravel(image2_2, order='k')  # ravel

            image3 = cv2.imread('/home/%s/Desktop/Bacometer_Data_E/Multi/cam_2/000299.tiff' %name)
            image3_1 = np.array(image3, dtype=np.int)
            image3_2 = image3_1[:, :, 0]
            image3_3 = np.ravel(image3_2, order='k')  # ravel

            image4 = cv2.imread('/home/%s/Desktop/Bacometer_Data_E/Multi/cam_3/000299.tiff' %name)
            image4_1 = np.array(image4, dtype=np.int)
            image4_2 = image4_1[:, :, 0]
            image4_3 = np.ravel(image4_2, order='k')  # ravel

            sizestandard = math.exp(-2)
            jaepyon = np.mean(np.mean(np.square(image1_2)))
            pyonjae = np.square(np.mean(np.mean(image1_2)))
            pyurieh = np.square(np.abs(np.fft.fft2(image1_2)))
            pyurieh = np.fft.fftshift(np.fft.ifft2(pyurieh)) / image1_2.shape[0] / image1_2.shape[1]
            pyurieh = np.abs((pyurieh - pyonjae) / (jaepyon - pyonjae))

            for k in range(1, math.ceil((pyurieh.shape[0] + 1) / 2)):
                if (pyurieh.item(k, math.floor((pyurieh.shape[1] + 1) / 2)) >= sizestandard):
                    aa = pyurieh.item(k, math.floor((pyurieh.shape[1] + 1) / 2))
                    bb = pyurieh.item(k - 1, math.floor((pyurieh.shape[1] + 1) / 2))
                    try:
                        xa = (k - 1) + (sizestandard - aa) / (bb - aa)
                    except:
                        pass
                    break
                else:
                    pass
            for k in range(math.ceil((pyurieh.shape[0] + 1) / 2), pyurieh.shape[0]):
                if (pyurieh.item(k, math.floor((pyurieh.shape[1] + 1) / 2)) <= sizestandard):
                    aa = pyurieh.item(k, math.floor((pyurieh.shape[1] + 1) / 2))
                    bb = pyurieh.item(k - 1, math.floor((pyurieh.shape[1] + 1) / 2))
                    try:
                        xb = (k - 1) + (sizestandard - aa) / (bb - aa)
                    except:
                        pass
                    break
                else:
                    pass
            for k in range(1, math.ceil((pyurieh.shape[1] + 1) / 2)):
                if (pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k) >= sizestandard):
                    aa = pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k)
                    bb = pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k - 1)
                    try:
                        ya = (k - 1) + (sizestandard - aa) / (bb - aa)
                    except:
                        pass
                    break
                else:
                    pass
            for k in range(math.ceil((pyurieh.shape[1] + 1) / 2), pyurieh.shape[1]):
                if (pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k) <= sizestandard):
                    aa = pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k)
                    bb = pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k - 1)
                    try:
                        yb = (k - 1) + (sizestandard - aa) / (bb - aa)
                    except:
                        pass

                    break
                else:
                    pass
            xs1 = xb - xa
            ys1 = yb - ya
            mean_value1 = np.mean(image1_3)

            sizestandard = math.exp(-2)
            jaepyon = np.mean(np.mean(np.square(image2_2)))
            pyonjae = np.square(np.mean(np.mean(image2_2)))
            pyurieh = np.square(np.abs(np.fft.fft2(image2_2)))
            pyurieh = np.fft.fftshift(np.fft.ifft2(pyurieh)) / image2_2.shape[0] / image2_2.shape[1]
            pyurieh = np.abs((pyurieh - pyonjae) / (jaepyon - pyonjae))

            for k in range(1, math.ceil((pyurieh.shape[0] + 1) / 2)):
                if (pyurieh.item(k, math.floor((pyurieh.shape[1] + 1) / 2)) >= sizestandard):
                    aa = pyurieh.item(k, math.floor((pyurieh.shape[1] + 1) / 2))
                    bb = pyurieh.item(k - 1, math.floor((pyurieh.shape[1] + 1) / 2))
                    try:
                        xa = (k - 1) + (sizestandard - aa) / (bb - aa)
                    except:
                        pass
                    break
                else:
                    pass
            for k in range(math.ceil((pyurieh.shape[0] + 1) / 2), pyurieh.shape[0]):
                if (pyurieh.item(k, math.floor((pyurieh.shape[1] + 1) / 2)) <= sizestandard):
                    aa = pyurieh.item(k, math.floor((pyurieh.shape[1] + 1) / 2))
                    bb = pyurieh.item(k - 1, math.floor((pyurieh.shape[1] + 1) / 2))
                    try:
                        xb = (k - 1) + (sizestandard - aa) / (bb - aa)
                    except:
                        pass
                    break
                else:
                    pass
            for k in range(1, math.ceil((pyurieh.shape[1] + 1) / 2)):
                if (pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k) >= sizestandard):
                    aa = pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k)
                    bb = pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k - 1)
                    try:
                        ya = (k - 1) + (sizestandard - aa) / (bb - aa)
                    except:
                        pass
                    break
                else:
                    pass
            for k in range(math.ceil((pyurieh.shape[1] + 1) / 2), pyurieh.shape[1]):
                if (pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k) <= sizestandard):
                    aa = pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k)
                    bb = pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k - 1)
                    try:
                        yb = (k - 1) + (sizestandard - aa) / (bb - aa)
                    except:
                        pass

                    break
                else:
                    pass
            xs2 = xb - xa
            ys2 = yb - ya
            mean_value2 = np.mean(image2_3)

            sizestandard = math.exp(-2)
            jaepyon = np.mean(np.mean(np.square(image3_2)))
            pyonjae = np.square(np.mean(np.mean(image3_2)))
            pyurieh = np.square(np.abs(np.fft.fft2(image3_2)))
            pyurieh = np.fft.fftshift(np.fft.ifft2(pyurieh)) / image3_2.shape[0] / image3_2.shape[1]
            pyurieh = np.abs((pyurieh - pyonjae) / (jaepyon - pyonjae))

            for k in range(1, math.ceil((pyurieh.shape[0] + 1) / 2)):
                if (pyurieh.item(k, math.floor((pyurieh.shape[1] + 1) / 2)) >= sizestandard):
                    aa = pyurieh.item(k, math.floor((pyurieh.shape[1] + 1) / 2))
                    bb = pyurieh.item(k - 1, math.floor((pyurieh.shape[1] + 1) / 2))
                    try:
                        xa = (k - 1) + (sizestandard - aa) / (bb - aa)
                    except:
                        pass
                    break
                else:
                    pass
            for k in range(math.ceil((pyurieh.shape[0] + 1) / 2), pyurieh.shape[0]):
                if (pyurieh.item(k, math.floor((pyurieh.shape[1] + 1) / 2)) <= sizestandard):
                    aa = pyurieh.item(k, math.floor((pyurieh.shape[1] + 1) / 2))
                    bb = pyurieh.item(k - 1, math.floor((pyurieh.shape[1] + 1) / 2))
                    try:
                        xb = (k - 1) + (sizestandard - aa) / (bb - aa)
                    except:
                        pass
                    break
                else:
                    pass
            for k in range(1, math.ceil((pyurieh.shape[1] + 1) / 2)):
                if (pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k) >= sizestandard):
                    aa = pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k)
                    bb = pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k - 1)
                    try:
                        ya = (k - 1) + (sizestandard - aa) / (bb - aa)
                    except:
                        pass
                    break
                else:
                    pass
            for k in range(math.ceil((pyurieh.shape[1] + 1) / 2), pyurieh.shape[1]):
                if (pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k) <= sizestandard):
                    aa = pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k)
                    bb = pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k - 1)
                    try:
                        yb = (k - 1) + (sizestandard - aa) / (bb - aa)
                    except:
                        pass

                    break
                else:
                    pass
            xs3 = xb - xa
            ys3 = yb - ya
            mean_value3 = np.mean(image3_3)

            sizestandard = math.exp(-2)
            jaepyon = np.mean(np.mean(np.square(image4_2)))
            pyonjae = np.square(np.mean(np.mean(image4_2)))
            pyurieh = np.square(np.abs(np.fft.fft2(image4_2)))
            pyurieh = np.fft.fftshift(np.fft.ifft2(pyurieh)) / image4_2.shape[0] / image4_2.shape[1]
            pyurieh = np.abs((pyurieh - pyonjae) / (jaepyon - pyonjae))

            for k in range(1, math.ceil((pyurieh.shape[0] + 1) / 2)):
                if (pyurieh.item(k, math.floor((pyurieh.shape[1] + 1) / 2)) >= sizestandard):
                    aa = pyurieh.item(k, math.floor((pyurieh.shape[1] + 1) / 2))
                    bb = pyurieh.item(k - 1, math.floor((pyurieh.shape[1] + 1) / 2))
                    try:
                        xa = (k - 1) + (sizestandard - aa) / (bb - aa)
                    except:
                        pass
                    break
                else:
                    pass
            for k in range(math.ceil((pyurieh.shape[0] + 1) / 2), pyurieh.shape[0]):
                if (pyurieh.item(k, math.floor((pyurieh.shape[1] + 1) / 2)) <= sizestandard):
                    aa = pyurieh.item(k, math.floor((pyurieh.shape[1] + 1) / 2))
                    bb = pyurieh.item(k - 1, math.floor((pyurieh.shape[1] + 1) / 2))
                    try:
                        xb = (k - 1) + (sizestandard - aa) / (bb - aa)
                    except:
                        pass
                    break
                else:
                    pass
            for k in range(1, math.ceil((pyurieh.shape[1] + 1) / 2)):
                if (pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k) >= sizestandard):
                    aa = pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k)
                    bb = pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k - 1)
                    try:
                        ya = (k - 1) + (sizestandard - aa) / (bb - aa)
                    except:
                        pass
                    break
                else:
                    pass
            for k in range(math.ceil((pyurieh.shape[1] + 1) / 2), pyurieh.shape[1]):
                if (pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k) <= sizestandard):
                    aa = pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k)
                    bb = pyurieh.item(math.floor((pyurieh.shape[0] + 1) / 2), k - 1)
                    try:
                        yb = (k - 1) + (sizestandard - aa) / (bb - aa)
                    except:
                        pass

                    break
                else:
                    pass
            xs4 = xb - xa
            ys4 = yb - ya
            mean_value4 = np.mean(image4_3)

            # Graph1_setting_histogram

            self.Graph_1.canvas.axes.clear()
            self.Graph_1.canvas.axes.hist(image1_3, bins = 50, facecolor='black',  histtype='bar', rwidth=0.3)
            self.Graph_1.canvas.axes.tick_params(labelsize=7)
            self.Graph_1.canvas.draw()

            # Graph2_setting_histogram

            self.Graph_2.canvas.axes.clear()
            self.Graph_2.canvas.axes.hist(image2_3, bins = 50, facecolor='black',  histtype='bar', rwidth=0.3)
            self.Graph_2.canvas.axes.tick_params(labelsize=7)
            self.Graph_2.canvas.draw()

            # Graph3_setting_histogram

            self.Graph_3.canvas.axes.clear()
            self.Graph_3.canvas.axes.hist(image3_3, bins = 50, facecolor='black',  histtype='bar', rwidth=0.3)
            self.Graph_3.canvas.axes.tick_params(labelsize=7)
            self.Graph_3.canvas.draw()

            # Graph4_setting_histogram

            self.Graph_4.canvas.axes.clear()
            self.Graph_4.canvas.axes.hist(image4_3, bins=50, facecolor='black', histtype='bar', rwidth=0.3)
            self.Graph_4.canvas.axes.tick_params(labelsize=7)
            self.Graph_4.canvas.draw()

            # Graph5_setting_Viewer

            self.Graph_5.canvas.axes.clear()
            self.Plot = self.Graph_5.canvas.axes.imshow(image1_2, cmap='gray')
            self.Graph_5.canvas.axes.axis("off")
            self.Cbar = self.Graph_5.canvas.figure.colorbar(self.Plot)
            self.Cbar.ax.tick_params(labelsize=10)
            self.Graph_5.canvas.draw()
            self.Cbar.remove()

            # Graph6_setting_Viewer

            self.Graph_6.canvas.axes.clear()
            self.Plot = self.Graph_6.canvas.axes.imshow(image2_2, cmap='gray')
            self.Graph_6.canvas.axes.axis("off")
            self.Cbar = self.Graph_6.canvas.figure.colorbar(self.Plot)
            self.Cbar.ax.tick_params(labelsize=10)
            self.Graph_6.canvas.draw()
            self.Cbar.remove()

            # Graph7_setting_Viewer

            self.Graph_7.canvas.axes.clear()
            self.Plot = self.Graph_7.canvas.axes.imshow(image3_2, cmap='gray')
            self.Graph_7.canvas.axes.axis("off")
            self.Cbar = self.Graph_7.canvas.figure.colorbar(self.Plot)
            self.Cbar.ax.tick_params(labelsize=10)
            self.Graph_7.canvas.draw()
            self.Cbar.remove()

            # Graph8_setting_Viewer

            self.Graph_8.canvas.axes.clear()
            self.Plot = self.Graph_8.canvas.axes.imshow(image4_2, cmap='gray')
            self.Graph_8.canvas.axes.axis("off")
            self.Cbar = self.Graph_8.canvas.figure.colorbar(self.Plot)
            self.Cbar.ax.tick_params(labelsize=10)
            self.Graph_8.canvas.draw()
            self.Cbar.remove()
            # Label_setting_ALI_Speclesize

            self.Label_ALI_1.setText("%.2f" %(mean_value1))
            self.Label_ALI_2.setText("%.2f" %(mean_value2))
            self.Label_ALI_3.setText("%.2f" %(mean_value3))
            self.Label_ALI_4.setText("%.2f" %(mean_value4))

            self.Label_SS_1.setText("%.2f x %.2f" % (xs1, ys1))
            self.Label_SS_2.setText("%.2f x %.2f" % (xs2, ys2))
            self.Label_SS_3.setText("%.2f x %.2f" % (xs3, ys3))
            self.Label_SS_4.setText("%.2f x %.2f" % (xs4, ys4))

            print("plotting finished")

            self.time2 = math.floor(self.time1)
            self.Information_1.setText('%s' %self.time2)
            self.Progressbar_1.setValue(self.time2)

            self.Time = str(self.time1)
            f = open("Setting_Progressbar.txt", 'w')
            f.write(self.Time)
            f.close()

            self.n += 1
            self.n2 = str(self.n)
            f = open("Setting_Repeat.txt", 'w')
            f.write(self.n2)
            f.close()

        if self.timenum <= self.n:
            self.Information_1.setText("100")
            self.Progressbar_1.setValue(100)
            self.timer2.stop()

    def Button_Monitoring_Stop_Function(self):

        self.Progressbar_1.reset()
        self.Information_1.setText("0")

        self.Time1 = 0
        self.Time = str(self.Time1)
        f = open("Setting_Progressbar.txt", 'w')
        f.write(self.Time)

        self.n = 0
        self.n2 = str(self.n)
        f = open("Setting_Repeat.txt", 'w')
        f.write(self.n2)
        f.close()

        self.Time1 = 0
        self.Time = str(self.Time1)
        f = open("Setting_Progressbar.txt", 'w')
        f.write(self.Time)
        f.close()

        f1 = open("Correlation_value1.txt", 'w')
        f2 = open("Correlation_value2.txt", 'w')
        f3 = open("Correlation_value3.txt", 'w')
        f4 = open("Correlation_value4.txt", 'w')
        f1.truncate(0)
        f2.truncate(0)
        f3.truncate(0)
        f4.truncate(0)
        f1.close()
        f2.close()
        f3.close()
        f4.close()
        name = os.environ['LOGNAME']
#        shutil.rmtree('/home/%s/Desktop/Bacometer_Data_E/Single' %name)
        shutil.rmtree('/home/%s/Desktop/Bacometer_Data_E/Multi' %name)
#        os.system("rm -r /home/%s/Desktop/Bacometer_Data_E/Single" %name)
#        os.system("rm -r /home/%s/Desktop/Bacometer_Data_E/Multi" %name)
        self.Graph_1.canvas.axes.clear()
        self.Graph_2.canvas.axes.clear()
        self.Graph_3.canvas.axes.clear()
        self.Graph_4.canvas.axes.clear()
        self.Graph_5.canvas.axes.clear()
        self.Graph_6.canvas.axes.clear()
        self.Graph_7.canvas.axes.clear()
        self.Graph_8.canvas.axes.clear()
        self.Graph_9.canvas.axes.clear()
        self.Graph_1.canvas.draw()
        self.Graph_2.canvas.draw()
        self.Graph_3.canvas.draw()
        self.Graph_4.canvas.draw()
        self.Graph_5.canvas.draw()
        self.Graph_6.canvas.draw()
        self.Graph_7.canvas.draw()
        self.Graph_8.canvas.draw()
        self.Graph_9.canvas.draw()

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

    def showExposetime_setting(self):
        f = open("/home/twt/Desktop/variable2/Manual/Cam_0/Setting_Exposetime.txt") 
        self.SetVar1 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_1/Setting_Exposetime.txt")
        self.SetVar2 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_2/Setting_Exposetime.txt")
        self.SetVar3 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_3/Setting_Exposetime.txt")
        self.SetVar4 = f.readline()
        self.Label_ExposeTime1.setText("%s" %self.SetVar1)
        self.Label_ExposeTime2.setText("%s" %self.SetVar2)
        self.Label_ExposeTime3.setText("%s" %self.SetVar3)
        self.Label_ExposeTime4.setText("%s" %self.SetVar4)
        f.close()

    def showFPS_setting(self):
        f = open("/home/twt/Desktop/variable2/Manual/Cam_0/Setting_FPS.txt") 
        self.SetVar1 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_1/Setting_FPS.txt")
        self.SetVar2 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_2/Setting_FPS.txt")
        self.SetVar3 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_3/Setting_FPS.txt")
        self.SetVar4 = f.readline()
        self.Label_FPS1.setText("%s" %self.SetVar1)
        self.Label_FPS2.setText("%s" %self.SetVar2)
        self.Label_FPS3.setText("%s" %self.SetVar3)
        self.Label_FPS4.setText("%s" %self.SetVar4)
        f.close()

    def showGain_setting(self):
        f = open("/home/twt/Desktop/variable2/Manual/Cam_0/Setting_Gain.txt")
        self.SetVar1 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_1/Setting_Gain.txt")
        self.SetVar2 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_2/Setting_Gain.txt")
        self.SetVar3 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_3/Setting_Gain.txt")
        self.SetVar4 = f.readline()
        self.Label_Gain1.setText("%s" %self.SetVar1)
        self.Label_Gain2.setText("%s" %self.SetVar2)
        self.Label_Gain3.setText("%s" %self.SetVar3)
        self.Label_Gain4.setText("%s" %self.SetVar4)
        f.close()

    def showOffset_X_setting(self):
        f = open("/home/twt/Desktop/variable2/Manual/Cam_0/Setting_Offset_X.txt")
        self.SetVar1 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_1/Setting_Offset_X.txt")
        self.SetVar2 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_2/Setting_Offset_X.txt")
        self.SetVar3 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_3/Setting_Offset_X.txt")
        self.SetVar4 = f.readline()
        self.Label_Offset_X1.setText("%s" %self.SetVar1)
        self.Label_Offset_X2.setText("%s" %self.SetVar2)
        self.Label_Offset_X3.setText("%s" %self.SetVar3)
        self.Label_Offset_X4.setText("%s" %self.SetVar4)
        f.close()

    def showOffset_Y_setting(self):
        f = open("/home/twt/Desktop/variable2/Manual/Cam_0/Setting_Offset_Y.txt")
        self.SetVar1 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_1/Setting_Offset_Y.txt")
        self.SetVar2 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_2/Setting_Offset_Y.txt")
        self.SetVar3 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_3/Setting_Offset_Y.txt")
        self.SetVar4 = f.readline()
        self.Label_Offset_Y1.setText("%s" %self.SetVar1)
        self.Label_Offset_Y2.setText("%s" %self.SetVar2)
        self.Label_Offset_Y3.setText("%s" %self.SetVar3)
        self.Label_Offset_Y4.setText("%s" %self.SetVar4)
        f.close()

    def showROI_X_setting(self):
        f = open("/home/twt/Desktop/variable2/Manual/Cam_0/Setting_ROI_X.txt")
        self.SetVar1 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_1/Setting_ROI_X.txt")
        self.SetVar2 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_2/Setting_ROI_X.txt")
        self.SetVar3 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_3/Setting_ROI_X.txt")
        self.SetVar4 = f.readline()
        self.Label_ROI_X1.setText("%s" %self.SetVar1)
        self.Label_ROI_X2.setText("%s" %self.SetVar2)
        self.Label_ROI_X3.setText("%s" %self.SetVar3)
        self.Label_ROI_X4.setText("%s" %self.SetVar4)
        f.close()

    def showROI_Y_setting(self):
        f = open("/home/twt/Desktop/variable2/Manual/Cam_0/Setting_ROI_Y.txt")
        self.SetVar1 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_1/Setting_ROI_Y.txt")
        self.SetVar2 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_2/Setting_ROI_Y.txt")
        self.SetVar3 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_3/Setting_ROI_Y.txt")
        self.SetVar4 = f.readline()
        self.Label_ROI_Y1.setText("%s" %self.SetVar1)
        self.Label_ROI_Y2.setText("%s" %self.SetVar2)
        self.Label_ROI_Y3.setText("%s" %self.SetVar3)
        self.Label_ROI_Y4.setText("%s" %self.SetVar4)
        f.close()

    def showRepeat_setting(self):
        f = open("/home/twt/Desktop/variable2/Manual/Cam_0/Setting_Repeat1.txt")
        self.SetVar1 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_1/Setting_Repeat1.txt")
        self.SetVar2 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_2/Setting_Repeat1.txt")
        self.SetVar3 = f.readline()
        f = open("/home/twt/Desktop/variable2/Manual/Cam_3/Setting_Repeat1.txt")
        self.SetVar4 = f.readline()
        self.Label_Repeat1.setText("%s" %self.SetVar1)
        self.Label_Repeat2.setText("%s" %self.SetVar2)
        self.Label_Repeat3.setText("%s" %self.SetVar3)
        self.Label_Repeat4.setText("%s" %self.SetVar4)
        f.close()

# 4. Keypad Function

# 1) ET
    def Button_Keypad_ET_Cam1_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_ET_Cam_1.py")
    def Button_Keypad_ET_Cam2_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_ET_Cam_2.py")
    def Button_Keypad_ET_Cam3_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_ET_Cam_3.py")
    def Button_Keypad_ET_Cam4_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_ET_Cam_4.py")
# 2) FPS
    def Button_Keypad_FPS_Cam1_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_FPS_Cam_1.py")
    def Button_Keypad_FPS_Cam2_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_FPS_Cam_2.py")
    def Button_Keypad_FPS_Cam3_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_FPS_Cam_3.py")
    def Button_Keypad_FPS_Cam4_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_FPS_Cam_4.py")
# 3) Gain
    def Button_Keypad_Gain_Cam1_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_Gain_Cam_1.py")
    def Button_Keypad_Gain_Cam2_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_Gain_Cam_2.py")
    def Button_Keypad_Gain_Cam3_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_Gain_Cam_3.py")
    def Button_Keypad_Gain_Cam4_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_Gain_Cam_4.py")
# 4) Offset_X
    def Button_Keypad_Offset_X_Cam1_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_Offset_X_Cam_1.py")
    def Button_Keypad_Offset_X_Cam2_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_Offset_X_Cam_2.py")
    def Button_Keypad_Offset_X_Cam3_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_Offset_X_Cam_3.py")
    def Button_Keypad_Offset_X_Cam4_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_Offset_X_Cam_4.py")
# 5) Offset_Y
    def Button_Keypad_Offset_Y_Cam1_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_Offset_Y_Cam1.py")
    def Button_Keypad_Offset_Y_Cam2_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_Offset_Y_Cam2.py")
    def Button_Keypad_Offset_Y_Cam3_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_Offset_Y_Cam3.py")
    def Button_Keypad_Offset_Y_Cam4_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_Offset_Y_Cam4.py")
# 6) Repeat
    def Button_Keypad_Repeat_Cam1_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_Repeat_Cam_1.py")
    def Button_Keypad_Repeat_Cam2_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_Repeat_Cam_2.py")
    def Button_Keypad_Repeat_Cam3_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_Repeat_Cam_2.py")
    def Button_Keypad_Repeat_Cam4_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_Repeat_Cam_2.py")
# 7) ROI_X
    def Button_Keypad_ROI_X_Cam1_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_ROI_X_Cam_1.py")
    def Button_Keypad_ROI_X_Cam2_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_ROI_X_Cam_2.py")
    def Button_Keypad_ROI_X_Cam3_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_ROI_X_Cam_3.py")
    def Button_Keypad_ROI_X_Cam4_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_ROI_X_Cam_4.py")
# 8) ROI_Y
    def Button_Keypad_ROI_Y_Cam1_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_ROI_Y_Cam_1.py")
    def Button_Keypad_ROI_Y_Cam2_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_ROI_Y_Cam_2.py")
    def Button_Keypad_ROI_Y_Cam3_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_ROI_Y_Cam_3.py")
    def Button_Keypad_ROI_Y_Cam4_Function(self):
        os.system("python3 /home/twt/Desktop/Bacometer_Code/Keypad/Keypad_ROI_Y_Cam_4.py")

# 5. Storage Check Function

    def Storage_Check_Function(self):
        diskLabel = '/'
        total, used, free = shutil.disk_usage(diskLabel)
        self.storage2 = used/total*100
        self.storage1 = int(self.storage2)
        self.Progressbar_2.setValue(self.storage1)
        self.storage = str(self.storage1)
        self.Label_storage.setText(self.storage)

# 6. Auto Calibration Function

    def Autocalibration_Function(self):



        self.time1 = self.Progressbar_1.value()
        self.time1 += 1
        self.Progressbar_1.setValue(self.time1)

        if self.time1 == 1: 
            self.Information_1.setText("1")  
            GPIO.output(10,True)
            time.sleep(5)

        if self.time1 == 10: 

            self.Information_1.setText("10")    
            os.system("python3 Cam1_Cali.py")
        if self.time1 == 20: 

            self.Information_1.setText("20")          
        if self.time1 == 30: 

            self.Information_1.setText("30")     
            os.system("python3 Cam2_Cali.py")
        if self.time1 == 40: 

            self.Information_1.setText("40")
        if self.time1 == 50: 

            self.Information_1.setText("50")               
            os.system("python3 Cam3_Cali.py")
        if self.time1 == 60: 

            self.Information_1.setText("60")
        if self.time1 == 70: 

            self.Information_1.setText("70")               
            os.system("python3 Cam4_Cali.py")
        if self.time1 == 100: 

            self.Information_1.setText("100") 
            GPIO.output(10,False)
            self.timer3.stop()



# 7. Auto Calibration load Function

    def AutoCalibration_Load_Function(self):

# Expose_time Load

        f1 = open("/home/twt/Desktop/variable/exposure1_2",'r')
        self.cam1exposure = f1.read()
        f2 = open("/home/twt/Desktop/variable2/Manual/Cam_0/Setting_Exposetime.txt",'w')
        f2.write(self.cam1exposure)
        f1.close()
        f2.close()

        f1 = open("/home/twt/Desktop/variable/exposure2_2",'r')
        self.cam2exposure = f1.read()
        f2 = open("/home/twt/Desktop/variable2/Manual/Cam_1/Setting_Exposetime.txt",'w')
        f2.write(self.cam2exposure)
        f1.close()
        f2.close()

        f1 = open("/home/twt/Desktop/variable/exposure3_2",'r')
        self.cam3exposure = f1.read()
        f2 = open("/home/twt/Desktop/variable2/Manual/Cam_2/Setting_Exposetime.txt",'w')
        f2.write(self.cam3exposure)
        f1.close()
        f2.close()

        f1 = open("/home/twt/Desktop/variable/exposure4_2",'r')
        self.cam4exposure = f1.read()
        f2 = open("/home/twt/Desktop/variable2/Manual/Cam_3/Setting_Exposetime.txt",'w')
        f2.write(self.cam4exposure)
        f1.close()
        f2.close()

# FPS Load

        self.FPS = "30"

        f = open("/home/twt/Desktop/variable2/Manual/Cam_0/Setting_FPS.txt",'w')
        f.write(self.FPS)
        f.close()

        f = open("/home/twt/Desktop/variable2/Manual/Cam_1/Setting_FPS.txt",'w')
        f.write(self.FPS)
        f.close()

        f = open("/home/twt/Desktop/variable2/Manual/Cam_2/Setting_FPS.txt",'w')
        f.write(self.FPS)
        f.close()

        f = open("/home/twt/Desktop/variable2/Manual/Cam_3/Setting_FPS.txt",'w')
        f.write(self.FPS)
        f.close()

# Gain Load

        self.Gain = "0"

        f = open("/home/twt/Desktop/variable2/Manual/Cam_0/Setting_Gain.txt",'w')
        f.write(self.Gain)
        f.close()

        f = open("/home/twt/Desktop/variable2/Manual/Cam_1/Setting_Gain.txt",'w')
        f.write(self.Gain)
        f.close()

        f = open("/home/twt/Desktop/variable2/Manual/Cam_2/Setting_Gain.txt",'w')
        f.write(self.Gain)
        f.close()

        f = open("/home/twt/Desktop/variable2/Manual/Cam_3/Setting_Gain.txt",'w')
        f.write(self.Gain)
        f.close()


# Offset_X Load

        f1 = open("/home/twt/Desktop/variable/cam1_xoffset",'r')
        self.cam1offx = f1.read()
        f2 = open("/home/twt/Desktop/variable2/Manual/Cam_0/Setting_Offset_X.txt",'w')
        f2.write(self.cam1offx)
        f1.close()
        f2.close()

        f1 = open("/home/twt/Desktop/variable/cam2_xoffset",'r')
        self.cam2offx = f1.read()
        f2 = open("/home/twt/Desktop/variable2/Manual/Cam_1/Setting_Offset_X.txt",'w')
        f2.write(self.cam2offx)
        f1.close()
        f2.close()

        f1 = open("/home/twt/Desktop/variable/cam3_xoffset",'r')
        self.cam3offx = f1.read()
        f2 = open("/home/twt/Desktop/variable2/Manual/Cam_2/Setting_Offset_X.txt",'w')
        f2.write(self.cam3offx)
        f1.close()
        f2.close()

        f1 = open("/home/twt/Desktop/variable/cam4_xoffset",'r')
        self.cam4offx = f1.read()
        f2 = open("/home/twt/Desktop/variable2/Manual/Cam_3/Setting_Offset_X.txt",'w')
        f2.write(self.cam4offx)
        f1.close()
        f2.close()

# Offset_Y Load

        f1 = open("/home/twt/Desktop/variable/cam1_yoffset",'r')
        self.cam1offy = f1.read()
        f2 = open("/home/twt/Desktop/variable2/Manual/Cam_0/Setting_Offset_Y.txt",'w')
        f2.write(self.cam1offy)
        f1.close()
        f2.close()

        f1 = open("/home/twt/Desktop/variable/cam2_yoffset",'r')
        self.cam2offy = f1.read()
        f2 = open("/home/twt/Desktop/variable2/Manual/Cam_1/Setting_Offset_Y.txt",'w')
        f2.write(self.cam2offy)
        f1.close()
        f2.close()

        f1 = open("/home/twt/Desktop/variable/cam3_yoffset",'r')
        self.cam3offy = f1.read()
        f2 = open("/home/twt/Desktop/variable2/Manual/Cam_2/Setting_Offset_Y.txt",'w')
        f2.write(self.cam3offy)
        f1.close()
        f2.close()

        f1 = open("/home/twt/Desktop/variable/cam4_yoffset",'r')
        self.cam4offy = f1.read()
        f2 = open("/home/twt/Desktop/variable2/Manual/Cam_3/Setting_Offset_Y.txt",'w')
        f2.write(self.cam4offy)
        f1.close()
        f2.close()

# Repeat1 Load

        self.Repeat1 = "1"

        f = open("/home/twt/Desktop/variable2/Manual/Cam_0/Setting_Repeat1.txt",'w')
        f.write(self.Repeat1)
        f.close()

        f = open("/home/twt/Desktop/variable2/Manual/Cam_1/Setting_Repeat1.txt",'w')
        f.write(self.Repeat1)
        f.close()

        f = open("/home/twt/Desktop/variable2/Manual/Cam_2/Setting_Repeat1.txt",'w')
        f.write(self.Repeat1)
        f.close()

        f = open("/home/twt/Desktop/variable2/Manual/Cam_3/Setting_Repeat1.txt",'w')
        f.write(self.Repeat1)
        f.close()

# ROI Load

        self.ROI = "256"

        f = open("/home/twt/Desktop/variable2/Manual/Cam_0/Setting_ROI_X.txt",'w')
        f.write(self.ROI)
        f.close()

        f = open("/home/twt/Desktop/variable2/Manual/Cam_1/Setting_ROI_X.txt",'w')
        f.write(self.ROI)
        f.close()

        f = open("/home/twt/Desktop/variable2/Manual/Cam_2/Setting_ROI_X.txt",'w')
        f.write(self.ROI)
        f.close()

        f = open("/home/twt/Desktop/variable2/Manual/Cam_3/Setting_ROI_X.txt",'w')
        f.write(self.ROI)
        f.close()

        f = open("/home/twt/Desktop/variable2/Manual/Cam_0/Setting_ROI_Y.txt",'w')
        f.write(self.ROI)
        f.close()

        f = open("/home/twt/Desktop/variable2/Manual/Cam_1/Setting_ROI_Y.txt",'w')
        f.write(self.ROI)
        f.close()

        f = open("/home/twt/Desktop/variable2/Manual/Cam_2/Setting_ROI_Y.txt",'w')
        f.write(self.ROI)
        f.close()

        f = open("/home/twt/Desktop/variable2/Manual/Cam_3/Setting_ROI_Y.txt",'w')
        f.write(self.ROI)
        f.close()

if __name__ == "__main__":
    # QApplication : 프로그램을 실행시켜주는 클래스
    app = QApplication(sys.argv)

    # WindowClass의 인스턴스 생성
    myWindow = EngineeringWindow()

    # 프로그램 화면을 보여주는 코드
    myWindow.showFullScreen()

    # 프로그램을 이벤트루프로 진입시키는(프로그램을 작동시키는) 코드
    sys.exit(app.exec_())



