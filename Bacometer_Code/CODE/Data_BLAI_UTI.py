import os
import sys
import time
import pyudev
import Icon_rc
import pandas as pd
import shutil

from PyQt5.QtCore import *
from PyQt5.QtWidgets import *
from PyQt5 import uic, QtCore, QtGui, QtWidgets
from PyQt5.QtGui import QIcon, QPixmap

from threading import Timer
from Delete import DeleteWindow
from Nodata import NodataWindow
from Export import ExportWindow
from USBNoti import USBNotiWindow

from Temperature_Monitor import *

class DataWindow(QDialog):

    def setupUi(self, Dialog):
        Dialog.setObjectName("Dialog")
        Dialog.resize(1024, 600)
        font = QtGui.QFont()
        font.setFamily("Nanum square")
        font.setPointSize(18)
        Dialog.setFont(font)
        Dialog.setStyleSheet("background-color: rgb(255, 255, 255);")
        Dialog.setSizeGripEnabled(False)
        Dialog.setModal(False)
        self.frame_2 = QtWidgets.QFrame(Dialog)
        self.frame_2.setGeometry(QtCore.QRect(0, 100, 1024, 600))
        self.frame_2.setStyleSheet("background-color: rgb(237, 237, 237);")
        self.frame_2.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.frame_2.setFrameShadow(QtWidgets.QFrame.Raised)
        self.frame_2.setObjectName("frame_2")
        self.frame = QtWidgets.QFrame(self.frame_2)
        self.frame.setGeometry(QtCore.QRect(10, 13, 999, 474))
        self.frame.setStyleSheet("background-color: rgb(255, 255, 255);")
        self.frame.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.frame.setFrameShadow(QtWidgets.QFrame.Raised)
        self.frame.setObjectName("frame")
        self.data_calendar = QtWidgets.QCalendarWidget(self.frame)
        self.data_calendar.setGeometry(QtCore.QRect(10, 10, 400, 350))
        self.data_calendar.setContextMenuPolicy(QtCore.Qt.DefaultContextMenu)
        self.data_calendar.setStyleSheet("background-color: #f7f7f7;\n"
"alternate-background-color: #f7f7f7;\n"
"font: 14pt \"Nanum Square\";\n"
"color: #2f4163;")
        self.data_calendar.setMinimumDate(QtCore.QDate(2020, 3, 1))
        self.data_calendar.setGridVisible(False)
        self.data_calendar.setSelectionMode(QtWidgets.QCalendarWidget.SingleSelection)
        self.data_calendar.setVerticalHeaderFormat(QtWidgets.QCalendarWidget.NoVerticalHeader)
        self.data_calendar.setNavigationBarVisible(True)
        self.data_calendar.setObjectName("data_calendar")
        self.tableWidget = QtWidgets.QTableWidget(self.frame)
        self.tableWidget.setGeometry(QtCore.QRect(420, 10, 570, 450))
        self.tableWidget.setAcceptDrops(False)
        self.tableWidget.setAutoFillBackground(False)
        self.tableWidget.setStyleSheet("QHeaderView::section {\n"
"color: #2f4163; background-color: #f7f7f7;\n"
"}")

        self.tableWidget.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.tableWidget.setFrameShadow(QtWidgets.QFrame.Plain)
        self.tableWidget.setLineWidth(0)
        self.tableWidget.setMidLineWidth(0)
        self.tableWidget.setAutoScrollMargin(16)
        self.tableWidget.setDragDropOverwriteMode(False)
        self.tableWidget.setAlternatingRowColors(True)
        self.tableWidget.setShowGrid(False)
        self.tableWidget.setGridStyle(QtCore.Qt.SolidLine)
        self.tableWidget.setWordWrap(True)
        self.tableWidget.setCornerButtonEnabled(True)
        self.tableWidget.setRowCount(15)
        self.tableWidget.setColumnCount(6)
        self.tableWidget.setObjectName("tableWidget")
        item = QtWidgets.QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(0, item)
        item = QtWidgets.QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(1, item)
        item = QtWidgets.QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(2, item)
        item = QtWidgets.QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(3, item)
        item = QtWidgets.QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(4, item)
        item = QtWidgets.QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(5, item)
        self.tableWidget.horizontalHeader().setVisible(True)
        self.tableWidget.horizontalHeader().setCascadingSectionResizes(True)
        self.tableWidget.horizontalHeader().setDefaultSectionSize(150)
        self.tableWidget.horizontalHeader().setHighlightSections(True)
        self.tableWidget.horizontalHeader().setMinimumSectionSize(60)
        self.tableWidget.horizontalHeader().setSortIndicatorShown(False)
        self.tableWidget.horizontalHeader().setStretchLastSection(False)
        self.tableWidget.horizontalHeader().setSectionResizeMode(0, QtWidgets.QHeaderView.ResizeToContents)
        self.tableWidget.horizontalHeader().setSectionResizeMode(1, QtWidgets.QHeaderView.ResizeToContents)
        self.tableWidget.horizontalHeader().setSectionResizeMode(2, QtWidgets.QHeaderView.ResizeToContents)
        self.tableWidget.horizontalHeader().setSectionResizeMode(3, QtWidgets.QHeaderView.ResizeToContents)
        self.tableWidget.horizontalHeader().setSectionResizeMode(4, QtWidgets.QHeaderView.ResizeToContents)
        self.tableWidget.horizontalHeader().setSectionResizeMode(5, QtWidgets.QHeaderView.Stretch)
        self.tableWidget.verticalHeader().setVisible(True)
        self.tableWidget.verticalHeader().setCascadingSectionResizes(True)
       
# Export button
        self.pushButton = QtWidgets.QPushButton(self.frame)
        self.pushButton.setGeometry(QtCore.QRect(60, 383, 110, 70))
        self.pushButton.setStyleSheet("QPushButton {\n"
"    border-image: url(:/Icon/export_icon.png);\n"
"}\n"
"\n"
"QPushButton:pressed {\n"
"    \n"
"    border-image: url(:/Icon/export_pressed.png);\n"
"}\n"
"")
        self.pushButton.setText("")
        self.pushButton.setObjectName("pushButton")

# Delete button
        self.pushButton_3 = QtWidgets.QPushButton(self.frame)
        self.pushButton_3.setGeometry(QtCore.QRect(250, 383, 110, 70))
        self.pushButton_3.setStyleSheet("QPushButton {\n"
"    border-image: url(:/Icon/delete.png);\n"
"}\n"
"\n"
"QPushButton:pressed {\n"
"    border-image: url(:/Icon/delete_pressed.png);\n"
"}")
        self.pushButton_3.setText("")
        self.pushButton_3.setObjectName("pushButton_3")

# USB Icon
        self.Label_USB = QtWidgets.QLabel(Dialog)
        self.Label_USB.setGeometry(QtCore.QRect(714, 20, 30, 30))
        self.Label_USB.setStyleSheet("")
        self.Label_USB.setText("")
        self.Label_USB.setObjectName("Label_USB")

# Home Icon
        self.Button_Backspace = QtWidgets.QPushButton(Dialog)
        self.Button_Backspace.setGeometry(QtCore.QRect(25, 20, 40, 40))
        self.Button_Backspace.setStyleSheet("QPushButton {\n"
"    border-image: url(:/Icon/backspace.png);\n"
"}\n"
"\n"
"QPushButton:pressed {\n"
"    border-image: url(:/Icon/backspace_pressed.png);\n"
"}")
        self.Button_Backspace.setText("")
        self.Button_Backspace.setObjectName("Button_Backspace")

# Logo Icon
        self.label_14 = QtWidgets.QLabel(Dialog)
        self.label_14.setGeometry(QtCore.QRect(440, 20, 140, 60))
        self.label_14.setStyleSheet("image: url(:/Icon/logo.png);")
        self.label_14.setText("")
        self.label_14.setObjectName("label_14")

# Date Display
        self.Label_date = QtWidgets.QLabel(Dialog)
        self.Label_date.setGeometry(QtCore.QRect(80, 20, 120, 50))
        self.Label_date.setStyleSheet("font: 75 18pt \"Nanum square\";\n"
"\n"
"\n"
"\n"
"\n"
"")
        self.Label_date.setText("")
        self.Label_date.setObjectName("Label_date")

# Time Display
        self.Label_time = QtWidgets.QLabel(Dialog)
        self.Label_time.setGeometry(QtCore.QRect(200, 20, 170, 50))
        self.Label_time.setStyleSheet("font: 75 18pt \"Nanum square\";\n"
"\n"
"\n"
"\n"
"\n"
"")
        self.Label_time.setText("")
        self.Label_time.setObjectName("Label_time")

# Temperature Icon
        self.Label_temperature = QtWidgets.QLabel(Dialog)
        self.Label_temperature.setGeometry(QtCore.QRect(744, 19, 30, 30))
        self.Label_temperature.setStyleSheet("image: url(:/Icon/temperature2.png);")
        self.Label_temperature.setText("")
        self.Label_temperature.setObjectName("Label_temperature")

# Storage Icon
        self.Label_temperature = QtWidgets.QLabel(Dialog)
        self.Label_temperature.setGeometry(QtCore.QRect(747, 55, 25, 25))
        self.Label_temperature.setStyleSheet("image: url(:/Icon/storage.png);")
        self.Label_temperature.setText("")
        self.Label_temperature.setObjectName("Label_StorageIcon")

# Temp Icon_cur_set
        self.Label_temp_cur = QtWidgets.QLabel(Dialog)
        self.Label_temp_cur.setGeometry(QtCore.QRect(781, 23, 40, 20))
        self.Label_temp_cur.setStyleSheet("font: 75 14pt \"Nanum square\"; color: #a3a3a3;")
        self.Label_temp_cur.setObjectName("Label_temp_cur")

        self.Label_temp_set = QtWidgets.QLabel(Dialog)
        self.Label_temp_set.setGeometry(QtCore.QRect(904, 23, 40, 20))
        self.Label_temp_set.setStyleSheet("font: 75 14pt \"Nanum square\"; color: #a3a3a3;")
        self.Label_temp_set.setObjectName("Label_temp_set")

# Temp Icon_℃
        self.Label_temp_degree1 = QtWidgets.QLabel(Dialog)
        self.Label_temp_degree1.setGeometry(QtCore.QRect(853, 23, 30, 20))
        self.Label_temp_degree1.setStyleSheet("font: 75 18pt \"Nanum square\";")
        self.Label_temp_degree1.setObjectName("Label_temp_degree1")

        self.Label_temp_degree2 = QtWidgets.QLabel(Dialog)
        self.Label_temp_degree2.setGeometry(QtCore.QRect(975, 23, 30, 20))
        self.Label_temp_degree2.setStyleSheet("font: 18pt \"Nanum square\";")
        self.Label_temp_degree2.setObjectName("Label_temp_degree2")

# Temp Display
        self.Label_temp1 = QtWidgets.QLabel(Dialog)
        self.Label_temp1.setGeometry(QtCore.QRect(824, 23, 30, 20))
        self.Label_temp1.setStyleSheet("font: 18pt \"Nanum square\";")
        self.Label_temp1.setText("")
        self.Label_temp1.setObjectName("Label_temp1")

        self.Label_temp3 = QtWidgets.QLabel(Dialog)
        self.Label_temp3.setGeometry(QtCore.QRect(946, 23, 30, 20))
        self.Label_temp3.setStyleSheet("font: 18pt \"Nanum square\";")
        self.Label_temp3.setText("")
        self.Label_temp3.setObjectName("Label_temp3")

# Storage Icon_%
        self.Label_storage_set = QtWidgets.QLabel(Dialog)
        self.Label_storage_set.setGeometry(QtCore.QRect(981, 59, 20, 20))
        self.Label_storage_set.setStyleSheet("font: 75 14pt \"Nanum square\";")
        self.Label_storage_set.setObjectName("Label_storage_set")

# Storage Display
        self.Label_storage = QtWidgets.QLabel(Dialog)
        self.Label_storage.setGeometry(QtCore.QRect(958, 59, 25, 20))
        self.Label_storage.setStyleSheet("font: 14pt \"Nanum square\";")
        self.Label_storage.setText("")
        self.Label_storage.setObjectName("Label_storage")

# Progressbar Display
        self.Progressbar_2 = QProgressBar(self)
        self.Progressbar_2.setGeometry(782, 63, 170, 10)
        self.Progressbar_2.setStyleSheet("QProgressBar {\n"
"    background-color: #cdcdcd;\n"
"    border-radius: 10px;\n"
"    text-align: Left;\n"
"    font: 75 15pt \"Arial\"; color: #81d0bc;\n"
"}\n"

"QProgressBar::chunk {\n"
"    background-color: #81d0bc;\n"
"    border-radius: 10px;\n"
"    width: 10px;\n"
"}")

        self.retranslateUi(Dialog)
        QtCore.QMetaObject.connectSlotsByName(Dialog)

# Table Icon
    def retranslateUi(self, Dialog):
        _translate = QtCore.QCoreApplication.translate
        Dialog.setWindowTitle(_translate("Dialog", "Dialog"))
        self.tableWidget.setSortingEnabled(False)
        item = self.tableWidget.horizontalHeaderItem(0)
        item.setText(_translate("Dialog", "Date"))
        item = self.tableWidget.horizontalHeaderItem(1)
        item.setText(_translate("Dialog", "Time"))
        #item.setStyleSheet("font: 18pt \"Nanum square\";")
        item = self.tableWidget.horizontalHeaderItem(2)
        item.setText(_translate("Dialog", "Case"))
        item = self.tableWidget.horizontalHeaderItem(3)
        item.setText(_translate("Dialog", "Vial"))
        item = self.tableWidget.horizontalHeaderItem(4)
        item.setText(_translate("Dialog", "Concentration Value"))
        item = self.tableWidget.horizontalHeaderItem(5)
        item.setText(_translate("Dialog", "Result"))

        self.Label_temp_degree1.setText(_translate("Dialog", "℃"))
        self.Label_temp_degree2.setText(_translate("Dialog", "℃"))
        self.Label_temp_cur.setText(_translate("Dialog", "Cur."))
        self.Label_temp_set.setText(_translate("Dialog", "Set."))
        self.Label_storage_set.setText(_translate("Dialog", "%"))




    def __init__(self, parent) :
        super(self.__class__, self).__init__()
        self.setupUi(self)

        # Signal - Slot
        self.Button_Backspace.clicked.connect(self.Button_Backspace_Function)
        self.data_calendar.clicked.connect(self.data_load)
        self.pushButton.clicked.connect(self.export_function)
        self.pushButton_3.clicked.connect(self.delete_function)
        self.data_load()

        # Function Run
        self.showdate()
        self.showtime()
        self.showtemp_current()
        self.showtemp_setting()
        self.timer1_start()

        # Timer1 setting
    def timer1_start(self):
        self.timer = QtCore.QTimer(self)
        self.timer.setInterval(200)
        self.timer.timeout.connect(self.showtime)
        self.timer.timeout.connect(self.showdate)
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
        f.close()
        self.tempVar1 = float(self.tempVar2) # Setting Temp
        self.tempSet = int(self.tempVar1)
        self.Label_temp3.setText("%d" %self.tempSet)

# 4. Temp revision Function 

    def temprev(self):
    # Temp. setting / write 
        f = open("Setting_Temp.txt",'w')
        self.tempVar2 = self.Spinbox_Temp.value()
        self.data = "%d" %self.tempVar2
        f.write(self.data)
        f.close()

# 5. Date load Function

    def data_load(self):
        self.datevar = self.data_calendar.selectedDate()
        self.date = self.datevar.toString("yyyy-MM-dd")
        self.name = os.environ['LOGNAME']
        self.file_name = '/home/%s/Desktop/Bacometer_Value/Train/%s.csv' % (self.name, self.date)
        if os.path.isfile(self.file_name):
            self.df = pd.read_csv(self.file_name)
            self.tableWidget.setRowCount(len(self.df))

            for n, value in enumerate(self.df['Date']):
                self.tableWidget.setItem(n, 0, QTableWidgetItem(str(value)))
                item = self.tableWidget.item(n, 0)
                item.setTextAlignment(QtCore.Qt.AlignCenter)

            for n, value in enumerate(self.df['Time']):
                self.tableWidget.setItem(n, 1, QTableWidgetItem(str(value)))
                item = self.tableWidget.item(n, 1)
                item.setTextAlignment(QtCore.Qt.AlignCenter)

            for n, value in enumerate(self.df['Case']):
                self.tableWidget.setItem(n, 2, QTableWidgetItem(str(value)))
                item = self.tableWidget.item(n, 2)
                item.setTextAlignment(QtCore.Qt.AlignCenter)

            for n, value in enumerate(self.df['Vial']):
                self.tableWidget.setItem(n, 3, QTableWidgetItem(str(value)))
                item = self.tableWidget.item(n, 3)
                item.setTextAlignment(QtCore.Qt.AlignCenter)

            for n, value in enumerate(self.df['Concentration Value']):
                self.tableWidget.setItem(n, 4, QTableWidgetItem(str(value)))
                item = self.tableWidget.item(n, 4)
                item.setTextAlignment(QtCore.Qt.AlignCenter)

            for n, value in enumerate(self.df['Result']):
                self.tableWidget.setItem(n, 5, QTableWidgetItem(str(value)))
                item = self.tableWidget.item(n, 5)
                item.setTextAlignment(QtCore.Qt.AlignCenter)

        else:
            self.tableWidget.clear()
            self.tableWidget.setHorizontalHeaderLabels(["Date", "Time", "Case", "Vial", "Concentration Value", "Result"])
            self.tableWidget.horizontalHeaderItem(0).setTextAlignment(QtCore.Qt.AlignCenter)

# 6. Export Function

    def export_function(self):
        self.name = os.environ['LOGNAME']
        self.path ='/media/%s/' % self.name
        self.file_list = os.listdir(self.path)
        self.ignored = {}
        self.files = [x for x in self.file_list if x not in self.ignored]
        self.device = '\n'.join(self.files)
        self.datevar = self.data_calendar.selectedDate()
        self.date = self.datevar.toString("yyyy-MM-dd")
        print(self.device)
        print("/media/%s/" % self.device)
        if os.path.exists('/sys/devices/70090000.xusb/usb1/1-2/1-2.1/'):
            if os.path.exists('/home/%s/Desktop/Bacometer_Value/Train/%s.csv' % (self.name, self.date)) == False:
                Nodata = NodataWindow(parent=self)
                Nodata.showFullScreen()
                Nodata.exec_()
            else:
                if os.path.isdir('/media/%s/%s/Bacometer_Value/UTI' % (self.name, self.device)) == False:
                    os.system("sudo mkdir /media/%s/%s/Bacometer_Value" % (self.name, self.device))
                    os.system("sudo mkdir /media/%s/%s/Bacometer_Value/UTI" % (self.name, self.device))
#                    self.datevar = self.data_calendar.selectedDate()
#                    self.date = self.datevar.toString("yyyy-MM-dd")
                    os.system("cp -r /home/%s/Desktop/Bacometer_Value/Train/%s.csv /media/%s/%s/Bacometer_Value/UTI/%s.csv" % (self.name, self.date, self.name, self.device, self.date))
#                    print("make directory!")
                else:
#                    self.date = self.datevar.toString("yyyy-MM-dd")
                    os.system("cp -r /home/%s/Desktop/Bacometer_Value/Train/%s.csv /media/%s/%s/Bacometer_Value/UTI/%s.csv" % (self.name, self.date, self.name, self.device, self.date))
#                    print("just copy!")
                    Export = ExportWindow(parent=self)
                    Export.showFullScreen()
                    Export.exec_()

        else:

            usbnoti = USBNotiWindow(parent=self)
            usbnoti.showFullScreen()
            usbnoti.exec_()


# 7. Delete Function

    def delete_function(self):
        self.name = os.environ['LOGNAME']
        self.path ='/media/%s/' % self.name
        self.file_list = os.listdir(self.path)
        self.ignored = {}
        self.files = [x for x in self.file_list if x not in self.ignored]
        self.device = '\n'.join(self.files)
        self.datevar = self.data_calendar.selectedDate()
        self.date = self.datevar.toString("yyyy-MM-dd")
#        print(self.device)
#        print("/media/%s/" % self.device)
        if os.path.exists('/home/%s/Desktop/Bacometer_Value/Train/%s.csv' % (self.name, self.date)) == False:
            Nodata = NodataWindow(parent=self)
            Nodata.showFullScreen()
            Nodata.exec_()
        else:
#        self.datevar = self.data_calendar.selectedDate()
#        self.date = self.datevar.toString("yyyy-MM-dd")

           Delete = DeleteWindow(parent=self)
           Delete.showFullScreen()
           Delete.exec_()

           f = open("Setting_Delete_Question.txt",'r')
           self.Question1 = f.readline()
           self.Question = int(self.Question1)
           f.close()
           f = open("Setting_Bacono.txt",'r')
           self.bacono = f.readline()
           f.close()

           if self.Question == 1:           
               os.system("rm -r /home/%s/Desktop/Bacometer_Value/Train/%s.csv" % (self.name, self.date))
               os.system("rm -r /home/%s/Desktop/Bacometer_Data_M/Train/Bacometer_%s/%s/" % (self.name, self.bacono, self.date))
               self.data_load()

           else:
               pass

# 8. Storage Check Function

    def Storage_Check_Function(self):
        diskLabel = '/'
        total, used, free = shutil.disk_usage(diskLabel)
        self.storage2 = used/total*100
        self.storage1 = int(self.storage2)
        self.Progressbar_2.setValue(self.storage1)
        self.storage = str(self.storage1)
        self.Label_storage.setText(self.storage)

