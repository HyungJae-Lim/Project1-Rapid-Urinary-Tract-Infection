import os
import sys
import pyudev
import shutil

from PyQt5.QtCore import *
from PyQt5.QtWidgets import *
from PyQt5 import uic, QtCore, QtGui, QtWidgets
from PyQt5.QtGui import QIcon, QPixmap
from PyQt5.QtGui import *

from threading import Timer

from Temperature_Monitor import *

# UI file Link

form_class = uic.loadUiType("Setting.ui")[0]

# UI Display

class SettingWindow(QDialog, form_class) :

    def __init__(self, parent) :
        super(self.__class__, self).__init__()
        self.setupUi(self)
 
        # Signal - Slot
        self.Button_Backspace.clicked.connect(self.Button_Backspace_Function)

        # Time / Date edit

        self.currentDate = QDate.currentDate()
        self.Button_Date.setDate(self.currentDate)

        self.currentTime = QTime.currentTime()
        self.Button_Time.setTime(self.currentTime)

        self.Button_Dataset.clicked.connect(self.daterev)
        self.Button_Timeset.clicked.connect(self.timerev)

        # Function Run
        self.showdate()
        self.showtime()
        self.showtime_Laser()
        self.showtemp_current()
        self.showtemp_setting()
        self.timer1_start()

        # Timer1 setting
    def timer1_start(self):
        self.timer = QtCore.QTimer(self)
        self.timer.setInterval(200)
        self.timer.timeout.connect(self.showtime)
        self.timer.timeout.connect(self.showdate)
        self.timer.timeout.connect(self.showtime_Laser)
        self.timer.timeout.connect(self.showtemp_current)
        self.timer.timeout.connect(self.showtemp_setting)
        self.timer.timeout.connect(self.USB)
        self.timer.timeout.connect(self.Storage_Check_Function)
        self.timer.start()

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
        self.tempVar1 = float(self.tempVar2) # Setting Temp
        self.tempSet = int(self.tempVar1)
        self.Label_temp3.setText("%s" %self.tempSet)
        f.close()

    def showtime_Laser(self):
        f = open("Setting_Laser.txt",'r')
        self.LaserHour1 = f.readline()
        self.LaserMin1 = f.readline()
        self.LaserSec1 = f.readline()
        self.LaserHour = self.LaserHour1.strip()
        self.LaserMin = self.LaserMin1.strip()
        self.LaserSec = self.LaserSec1.strip()
        self.Label_Laser_Hour.setText("%s" %self.LaserHour)
        self.Label_Laser_Min.setText("%s" %self.LaserMin)
        self.Label_Laser_Sec.setText("%s" %self.LaserSec)
        f.close()

    def showdata_setting(self):
        f = open("Setting_Case.txt",'r')
        self.dataVar = f.readline()
        f.close()
        self.Label_data.setText("%s" %self.dataVar)

# 4. Date revision Function 

    def daterev(self):
        self.dateVar1 = self.Button_Date.date()
        self.date = self.dateVar1.toString("yyyy-MM-dd")
        self.timeVar1 = self.Button_Time.time()

        self.time = self.timeVar1.toString("hh:mm:ss")
        pwd='1234'
        os.system("echo %s|sudo -S timedatectl set-time '%s %s'" % (pwd, self.date, self.time))

# 5. Time revision Function 

    def timerev(self):
        self.timeVar1 = self.Button_Time.time()
        self.time = self.timeVar1.toString("hh:mm:ss")
        pwd = '1234'
        os.system("echo %s|sudo -S timedatectl set-time '%s'" % (pwd, self.time))

# 6. Storage Check Function

    def Storage_Check_Function(self):
        diskLabel = '/'
        total, used, free = shutil.disk_usage(diskLabel)
        self.storage2 = used/total*100
        self.storage1 = int(self.storage2)
        self.Progressbar_2.setValue(self.storage1)
        self.storage = str(self.storage1)
        self.Label_storage.setText(self.storage)
