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


# UI file Link

form_class = uic.loadUiType("Measurement_BLSD_CKD.ui")[0]

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

        # progress Bar / Acquision setting Initializing
        self.time = 0 
        if self.time == 0: 
            self.Information_1.setText("0") 

        f = open("Setting_Repeat.txt",'w')
        self.Repeat = "0"
        f.write(self.Repeat)
        f.close()

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

        # Time setting
        f = open("Setting_Time.txt",'r')
        self.timeVar2 = f.readline()
        self.timeVar1 = float(self.timeVar2) # Setting Time
        f.close()
        self.currentTime = self.timeVar1
        self.Spinbox_Time.setValue(self.currentTime)
        self.Button_Timeset.clicked.connect(self.timerev)

        # Function Run
        self.showdate()
        self.showtime()
        self.showtemp_current()
        self.showtemp_setting()
        self.showdata_setting()
        self.showtime_setting()
        self.timer1_start()

        # Timer1 setting
    def timer1_start(self):
        self.timer = QtCore.QTimer(self)
        self.timer.setInterval(200)
        self.timer.timeout.connect(self.showtime)
        self.timer.timeout.connect(self.showdate)
        self.timer.timeout.connect(self.showtemp_current)
        self.timer.timeout.connect(self.showtemp_setting)
        self.timer.timeout.connect(self.showdata_setting)
        self.timer.timeout.connect(self.showtime_setting)
        self.timer.timeout.connect(self.USB)
        self.timer.timeout.connect(self.Storage_Check_Function)
        self.timer.start()

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
        output_dir = '/home/%s/Desktop/Bacometer_Data_M/CKD/Bacometer_%s/%s/%s/' % (name, bacono, datevar, casenum)

        if not os.path.exists(output_dir):
            self.Information_1.setText("1")
            self.timer2 = QtCore.QTimer(self)
            self.timer2.setInterval(500)
            self.timer2.timeout.connect(self.Correlation_Function)
            self.timer2.start()

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

    def showtime_setting(self):
        f = open("Setting_Time.txt",'r')
        self.timesetVar = f.readline()
        f.close()
        self.Label_timeset.setText("%s" %self.timesetVar)

# 4. Case revision Function 

    def caserev(self):

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

        self.Graph_9.canvas.axes.clear()
        self.Graph_9.canvas.draw()



# 5. Temp revision Function 

    def temprev(self):
    # Temp. setting / write 
        f = open("Setting_Temp.txt",'w')
        self.tempVar = self.Spinbox_Temp.value()
        self.data = "%d" %self.tempVar
        f.write(self.data)
        f.close()

# 6. Time revision Function 

    def timerev(self):
    # Time. setting / write 
        f = open("Setting_Time.txt",'w')
        self.timeVar = self.Spinbox_Time.value()
        self.data = "%d" %self.timeVar
        f.write(self.data)
        f.close()

# 7. Cam shot Function 
    def Correlation_Function(self):

        f = open("Setting_Acquisition.txt",'w')
        self.Acquisition = "1"
        f.write(self.Acquisition)
        f.close()

        self.time1 = self.Progressbar_1.value()
        f = open("Setting_Time.txt",'r')
        self.timenum1 = f.readline()
        f.close()
        self.timenum = int(self.timenum1)*12+1  # *1->12 revision

        f = open("Setting_Repeat.txt",'r')
        self.n1 = f.readline()
        self.n = int(self.n1)
        f.close()

        f = open("Setting_Progressbar.txt",'r')
        self.Time = f.readline()
        self.time1 = float(self.Time)
        f.close()
        print(self.time1)


        if self.timenum > self.n:  # Revision later
   
            self.time1 += 100/self.timenum  # Revision later

            f = open("Setting_Case.txt",'r')
            casenum = f.readline()
            f.close()
            datevar = datetime.today().strftime("%Y-%m-%d")
            name = os.environ['LOGNAME']

            os.system("python3 Cam1_Shot_M_CKD.py")
            os.system("python3 Cam2_Shot_M_CKD.py")
            os.system("python3 Cam3_Shot_M_CKD.py")
            os.system("python3 Cam4_Shot_M_CKD.py")

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

            directory = '/home/%s/Desktop/Bacometer_Data_M/CKD/Bacometer_%s/%s/%s/' % (name, bacono, datevar, casenum)

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
            input_dir = '/home/%s/Desktop/Bacometer_Data_M/CKD/Bacometer_%s/%s/%s/' % (name, bacono, datevar, casenum)
            date = time.strftime('%Y-%m-%d', time.localtime(time.time()))
            filename1 = '%s%s_correlation.csv' % (input_dir, date)

            if os.path.exists('%s%s_correlation.csv' % (input_dir, date)):
                df = pd.read_csv(filename1)
                x_value = x
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

# [Result Calculation coding start]

            self.port_1 = 9
            self.port_1_1 = 9
            self.CFU_Port1_I.setText("%s" %self.port_1)
            self.CFU_Port1.setText("x 10")
            self.CFU_Port1_S.setText("%s" %self.port_1_1)

            self.port_2 = 9
            self.port_2_1 = 9
            self.CFU_Port2_I.setText("%s" %self.port_2)
            self.CFU_Port2.setText("x 10")
            self.CFU_Port2_S.setText("%s" %self.port_2_1)

            self.port_3 = 9
            self.port_3_1 = 9
            self.CFU_Port3_I.setText("%s" %self.port_3)
            self.CFU_Port3.setText("x 10")
            self.CFU_Port3_S.setText("%s" %self.port_3_1)

            self.port_4 = 9
            self.port_4_1 = 9
            self.CFU_Port4_I.setText("%s" %self.port_4)
            self.CFU_Port4.setText("x 10")
            self.CFU_Port4_S.setText("%s" %self.port_4_1)

# [Result Calculation coding stop]

            Result1 = '%dx10^%d' %(self.port_1, self.port_1_1)
            Result2 = '%dx10^%d' %(self.port_2, self.port_2_1)
            Result3 = '%dx10^%d' %(self.port_3, self.port_3_1)
            Result4 = '%dx10^%d' %(self.port_4, self.port_4_1)
          
            f = open("Setting_Case.txt",'r')
            casenum = f.readline()
            f.close()
            input_dir = '/home/twt/Desktop/Bacometer_Value/CKD/'
            date = time.strftime('%Y-%m-%d', time.localtime(time.time()))
            tm = time.strftime('%H:%M:%S', time.localtime(time.time()))
            filename = '%s%s.csv' % (input_dir, date)     
            filename_R= '%s%s_R.csv' % (input_dir, date)   
            name = os.environ['LOGNAME']              
            df = pd.read_csv(filename)
            df1 = df.loc[0:3]

            print(df1)

            df1['Result'] = df1['Result'].apply(lambda x: Result1 if x == 'Port1' else x) 
            df1['Result'] = df1['Result'].apply(lambda x: Result2 if x == 'Port2' else x)         
            df1['Result'] = df1['Result'].apply(lambda x: Result3 if x == 'Port3' else x)            
            df1['Result'] = df1['Result'].apply(lambda x: Result4 if x == 'Port4' else x)
            df1['Time'] = df1['Time'].apply(lambda x: Result1 if x == 'Port1' else tm) 
            df1['Time'] = df1['Time'].apply(lambda x: Result2 if x == 'Port2' else tm)         
            df1['Time'] = df1['Time'].apply(lambda x: Result3 if x == 'Port3' else tm)            
            df1['Time'] = df1['Time'].apply(lambda x: Result4 if x == 'Port4' else tm)

            print(df1)
        
            if os.path.exists('%s%s_R.csv' %(input_dir, date)):
                df2 = pd.read_csv(filename_R)
                df3 = pd.concat([df2,df1])
                df3.to_csv(filename_R, index=False)

            else:
                df1.to_csv(filename_R, index=False)

            f = open("Setting_Acquisition.txt",'w')
            self.Acquisition = "0"
            f.write(self.Acquisition)
            f.close()

            os.system("rm -r /home/%s/Desktop/Bacometer_Value/CKD/%s.csv" % (name, date))

            self.timer2.stop()

# 10. Correlation Function_Stop 

    def Button_Monitoring_Stop_Function(self):
       
        f = open("Setting_Acquisition.txt",'r')
        self.Acquisition1 = f.readline()
        self.Acquisition = int(self.Acquisition1)
        f.close()

        if self.Acquisition == 0:
            pass

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
            output_dir = '/home/%s/Desktop/Bacometer_Data_S/CKD/Bacometer_%s/%s/%s/' % (name, bacono, datevar, casenum)

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

                    Result1 = "Fail"
                    Result2 = "Fail"
                    Result3 = "Fail"
                    Result4 = "Fail"

                    f = open("Setting_Case.txt",'r')
                    casenum = f.readline()
                    f.close()
                    input_dir = '/home/twt/Desktop/Bacometer_Value/CKD/'
                    date = time.strftime('%Y-%m-%d', time.localtime(time.time()))
                    filename = '%s%s.csv' % (input_dir, date)
                    df = pd.read_csv(filename)
                    print(df)
                    df['Result'] = df['Result'].apply(lambda x: Result1 if x == 'Port1' else x)
                    df['Result'] = df['Result'].apply(lambda x: Result2 if x == 'Port2' else x)
                    df['Result'] = df['Result'].apply(lambda x: Result3 if x == 'Port3' else x)
                    df['Result'] = df['Result'].apply(lambda x: Result4 if x == 'Port4' else x)

                    df.to_csv(filename, index=False)

                    self.timer2.stop()
                    self.Graph_9.canvas.axes.clear()
                    self.Graph_9.canvas.draw()


# 11. Storage Check Function

    def Storage_Check_Function(self):
        diskLabel = '/'
        total, used, free = shutil.disk_usage(diskLabel)
        self.storage2 = used/total*100
        self.storage1 = int(self.storage2)
        self.Progressbar_2.setValue(self.storage1)
        self.storage = str(self.storage1)
        self.Label_storage.setText(self.storage)

# 12. Data Number Function
    def Button_Datanum_Function(self):
        data = DataWindow(parent=self)
        data.showFullScreen()
        data.exec_()



