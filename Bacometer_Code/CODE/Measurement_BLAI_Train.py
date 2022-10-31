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

from datetime import datetime
from PyQt5.QtCore import *
from PyQt5.QtWidgets import *
from PyQt5 import uic, QtCore, QtGui, QtWidgets
from PyQt5.QtGui import QIcon, QPixmap
from PyQt5.QtGui import *
from skimage import io
from Start import StartWindow
from Stop import StopWindow
from Data_BLAI_Train import DataWindow

from threading import Timer
from os.path import split

from Temperature_Monitor import *
from Temperature_Run import *
from Laser_Run import *
from multiprocessing import Process
from simple_pyspin import Camera
from PIL import Image

import smbus
import time
import Jetson.GPIO as GPIO 
from time import sleep  

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)  
GPIO.setup(10, GPIO.OUT)  # Camera

# UI file Link

form_class = uic.loadUiType("Measurement_BLAI_Train.ui")[0]

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
        self.Button_Toserver.clicked.connect(self.timer3_start)
        self.Button_Topc.clicked.connect(self.timer4_start)

        # progress Bar Initializing
        self.time = 0 
        if self.time == 0: 
            self.Information_1.setText("0") 
        self.time1 = 0 
        if self.time1 == 0: 
            self.Information_2.setText("Ready...") 
        self.time2 = 0 
        if self.time2 == 0: 
            self.Information_3.setText("Ready...") 

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
            self.timerVar1.setInterval(12000)
            self.timerVar1.timeout.connect(self.Data_acquisition_Function)
            self.timerVar1.start()

        if os.path.exists(output_dir):
            Start = StartWindow(parent=self)
            Start.showFullScreen()
            Start.exec_()

        # Timer3 setting_Toserver
    def timer3_start(self):
        self.timerVar2 = QtCore.QTimer(self)
        self.timerVar2.setInterval(100)
        self.timerVar2.timeout.connect(self.Data_Toserver)
        self.timerVar2.start()

        # Timer4 setting_Topc
    def timer4_start(self):
        self.timerVar3 = QtCore.QTimer(self)
        self.timerVar3.setInterval(100)
        self.timerVar3.timeout.connect(self.Data_Topc)
        self.timerVar3.start()

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
        self.Progressbar_3.reset() 
        self.Progressbar_4.reset()

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

# 6. Cam shot Function 
    def Data_acquisition_Function(self):

        self.time1 = self.Progressbar_1.value()
        self.time1 += 1
        self.Progressbar_1.setValue(self.time1)
        if self.time1 > 0:
            self.Information_1.setText(str(self.time1))

        if self.time1 == 2: 
        
            GPIO.output(10,True)
            time.sleep(5)

            self.Information_1.setText("1")   
            f = open("Setting_Acquisition.txt",'w')
            self.Acquisition = "1"
            f.write(self.Acquisition)
            f.close()

            os.system("python3 Cam1_Cali2.py")
            os.system("python3 Cam2_Cali2.py")
            os.system("python3 Cam3_Cali2.py")
            os.system("python3 Cam4_Cali2.py")
            os.system("python3 Cam1_Shot_M_Train.py")
            os.system("python3 Cam2_Shot_M_Train.py")
            os.system("python3 Cam3_Shot_M_Train.py")
            os.system("python3 Cam4_Shot_M_Train.py")

            GPIO.output(10,False)

        if self.time1 == 99: 

            GPIO.output(10,True)
            time.sleep(5)

            os.system("python3 Cam1_Cali2.py")
            os.system("python3 Cam2_Cali2.py")
            os.system("python3 Cam3_Cali2.py")
            os.system("python3 Cam4_Cali2.py")
            os.system("python3 Cam1_Shot_M_Train_20m.py")
            os.system("python3 Cam2_Shot_M_Train_20m.py")
            os.system("python3 Cam3_Shot_M_Train_20m.py")
            os.system("python3 Cam4_Shot_M_Train_20m.py")

            GPIO.output(10,False)

        if self.time1 == 100: 
            Result1 = "Saved"
            Result2 = "Saved"
            Result3 = "Saved"
            Result4 = "Saved"

            f = open("Setting_Case.txt",'r')
            casenum = f.readline()
            f.close()
            input_dir = '/home/twt/Desktop/Bacometer_Value/Train/'
            date = time.strftime('%Y-%m-%d', time.localtime(time.time()))
            filename = '%s%s.csv' % (input_dir, date)           
            df = pd.read_csv(filename)
#            print(df)
            df['Result'] = df['Result'].apply(lambda x: Result1 if x == 'Port1' else x) 
            df['Result'] = df['Result'].apply(lambda x: Result2 if x == 'Port2' else x)         
            df['Result'] = df['Result'].apply(lambda x: Result3 if x == 'Port3' else x)            
            df['Result'] = df['Result'].apply(lambda x: Result4 if x == 'Port4' else x)
#            print(df)
            df.to_csv(filename, index=False)

            if Result1 == "Saved":
                self.Infection_ResultVar1 = QPixmap()
                self.Infection_ResultVar1.load("saved.png")
#                self.Infection_ResultVar1 = self.Infection_ResultVar1.scaledToWidth(40)
                self.Label_Result_1.setPixmap(self.Infection_ResultVar1)

            if Result2 == "Saved":
                self.Infection_ResultVar2 = QPixmap()
                self.Infection_ResultVar2.load("saved.png")
#                self.Infection_ResultVar2 = self.Infection_ResultVar2.scaledToWidth(40)
                self.Label_Result_2.setPixmap(self.Infection_ResultVar2)

            if Result3 == "Saved":
                self.Infection_ResultVar3 = QPixmap()
                self.Infection_ResultVar3.load("saved.png")
#                self.Infection_ResultVar3 = self.Infection_ResultVar3.scaledToWidth(40)
                self.Label_Result_3.setPixmap(self.Infection_ResultVar3)

            if Result4 == "Saved":
                self.Infection_ResultVar4 = QPixmap()
                self.Infection_ResultVar4.load("saved.png")
#                self.Infection_ResultVar4 = self.Infection_ResultVar4.scaledToWidth(40)
                self.Label_Result_4.setPixmap(self.Infection_ResultVar4)

            f = open("Setting_Acquisition.txt",'w')
            self.Acquisition = "0"
            f.write(self.Acquisition)
            f.close()
            self.timerVar1.stop()

# 7. Correlation Function_Stop 

    def Button_Monitoring_Stop_Function(self):

        GPIO.output(10,False)

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

                    Result1 = "Fail"
                    Result2 = "Fail"
                    Result3 = "Fail"
                    Result4 = "Fail"

                    f = open("Setting_Case.txt",'r')
                    casenum = f.readline()
                    f.close()
                    input_dir = '/home/twt/Desktop/Bacometer_Value/Train/'
                    date = time.strftime('%Y-%m-%d', time.localtime(time.time()))
                    filename = '%s%s.csv' % (input_dir, date)
                    df = pd.read_csv(filename)
                    print(df)
                    df['Result'] = df['Result'].apply(lambda x: Result1 if x == 'Port1' else x)
                    df['Result'] = df['Result'].apply(lambda x: Result2 if x == 'Port2' else x)
                    df['Result'] = df['Result'].apply(lambda x: Result3 if x == 'Port3' else x)
                    df['Result'] = df['Result'].apply(lambda x: Result4 if x == 'Port4' else x)

                    df.to_csv(filename, index=False)

                    self.timerVar1.stop()

# 8. Data Transport Function 
    def Data_Toserver(self):
        self.time2 = self.Progressbar_3.value()
        self.time2 += 1
        self.Progressbar_3.setValue(self.time2)

        if self.time2 == 1: 
            self.Information_2.setText("Transporting...")       
        if self.time2 == 10: 
            os.system("rclone sync /home/twt/Desktop/Bacometer_Data_M/Train/Bacometer_6 Bacometer_1:Bacometer_6")
        if self.time2 == 100: 
            self.Information_2.setText("Complete.")  
            self.timerVar2.stop()

    def Data_Topc(self):
        self.time3 = self.Progressbar_4.value()
        self.time3 += 1
        self.Progressbar_4.setValue(self.time3)

        if self.time3 == 1: 
            self.Information_3.setText("Transporting...")       
        if self.time3 == 10: 
            os.system("rclone sync Bacometer_1:Bacometer_6 /home/twt/Desktop/Bacometer_Data_M/Train/Bacometer_6")
        if self.time3 == 100: 
            self.Information_3.setText("Complete.")  
            self.timerVar3.stop()

# 9. Infection result Function

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

# 10. Storage Check Function

    def Storage_Check_Function(self):
        diskLabel = '/'
        total, used, free = shutil.disk_usage(diskLabel)
        self.storage2 = used/total*100
        self.storage1 = int(self.storage2)
        self.Progressbar_2.setValue(self.storage1)
        self.storage = str(self.storage1)
        self.Label_storage.setText(self.storage)

# 11. Data Number Function
    def Button_Datanum_Function(self):
        data = DataWindow(parent=self)
        data.showFullScreen()
        data.exec_()






