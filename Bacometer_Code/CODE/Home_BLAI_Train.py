import os
import sys
import pyudev

from PyQt5 import uic, QtCore
from PyQt5.QtCore import *
from PyQt5.QtWidgets import *
from PyQt5.QtGui import QIcon, QPixmap

from threading import Timer

from Temperature_Monitor import *
from Temperature_Run import *
from Laser_Run import *

from Shutdown import ShutdownWindow
from Reset import ResetWindow
from Measurement_BLAI_Train import MeasurementWindow
from Data_BLAI_Train import DataWindow
from Setting import SettingWindow
from Engineering import EngineeringWindow


# UI file Link

form_class = uic.loadUiType("Home.ui")[0]

# UI Display

class HomeWindow(QMainWindow, form_class):
    front_wid = None
    def __init__(self, parent=None):
        super(self.__class__, self).__init__()
        self.setupUi(self)

        # Signal - Slot
        self.Button_Shutdown.clicked.connect(self.Button_Shutdown_Function)
        self.Button_Reset.clicked.connect(self.Button_Reset_Function)
        self.Button_Measurement.clicked.connect(self.Button_Measurement_Function)
        self.Button_Data.clicked.connect(self.Button_Data_Function)
        self.Button_Setting.clicked.connect(self.Button_Setting_Function)
        self.Button_EasterEgg.clicked.connect(lambda state, button = self.Button_EasterEgg: 
        self.Easter_egg(state, button))

        # Initial temperature setting
        f = open("Setting_Temp.txt",'w')
        self.data = "30" 
        f.write(self.data)
        f.close()

        # Run_Thread_Temperature
        self.Temprun = Temp_run() 
        self.Temprun.start()
        
        # Function Run
        self.showdate()
        self.showtime()
        self.showtemp_current()
        self.showtemp_setting()
        self.Easter_text_clear()
        self.timer1_start()
        self.timer2_start()

        # Timer1 setting
    def timer1_start(self):
        self.timer = QtCore.QTimer(self)
        self.timer.setInterval(200)
        self.timer.timeout.connect(self.showtime)
        self.timer.timeout.connect(self.showdate)
        self.timer.timeout.connect(self.showtemp_current)
        self.timer.timeout.connect(self.showtemp_setting)
        self.timer.timeout.connect(self.USB)
        self.timer.start()

    def timer2_start(self):
        self.timer = QtCore.QTimer(self)
        self.timer.setInterval(2000)
        self.timer.timeout.connect(self.Easter_text_clear)
        self.timer.start()

    def keyPressEvent(self, e):
        if int(e.modifiers()) == (Qt.AltModifier):
            if e.key() == Qt.Key_F4:
                text, ok = QInputDialog.getText(self, "PWD", "Password", QLineEdit.Password)
                if ok:
                    if text == 'twt0711':
                        self.close()
                    else:
                        QMessageBox.warning(self, "Warning", "비정상적인 행동이 감지되어 해당 기기의 모든 활동 내역이 본사로 전송됩니다.")
# Function Part #

# 1. Button Function

    def Button_Shutdown_Function(self):
        shutdown = ShutdownWindow(parent=self)
        shutdown.showFullScreen()
        shutdown.exec_()

    def Button_Reset_Function(self):
        shutdown = ResetWindow(parent=self)
        shutdown.showFullScreen()
        shutdown.exec_()

    def Button_Measurement_Function(self):
        measurement = MeasurementWindow(parent=self)
        measurement.showFullScreen()
        measurement.exec_()

    def Button_Data_Function(self):
        data = DataWindow(parent=self)
        data.showFullScreen()
        data.exec_()

    def Button_Setting_Function(self):
        setting = SettingWindow(parent=self)
        setting.showFullScreen()
        setting.exec_()

    def Easter_egg(self, state, button):
        exist_line_text = self.Label_mini.text()
        now_num_text = button.text()
        self.Label_mini.setText(exist_line_text + now_num_text)
        if exist_line_text == "1111":
            os.system("python3 Engineering.py")

    def Easter_text_clear(self):
        self.Label_mini.clear()

# 2. USB Detect Fuction

    def USB(self):
        if os.path.exists('/sys/devices/70090000.xusb/usb1/1-2/1-2.1/'):
            self.USB_DetectionVar = QPixmap()
            self.USB_DetectionVar.load("usb.png")
            self.USB_DetectionVar = self.USB_DetectionVar.scaledToWidth(28)
            self.Label_USB.setPixmap(self.USB_DetectionVar)
        else:
            self.USB_DetectionVar = QPixmap()
            self.USB_DetectionVar.load("usb_disconnected.png")
            self.USB_DetectionVar = self.USB_DetectionVar.scaledToWidth(28)
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

# 4. Temp revision Function 

    def temprev(self):
    # Temp. setting / write 
        f = open("Setting_Temp.txt",'w')
        self.tempVar2 = self.Spinbox_Temp.value()
        self.data = "%d" %self.tempVar2
        f.write(self.data)
        f.close()
      
if __name__ == "__main__":
    # QApplication : 프로그램을 실행시켜주는 클래스
    app = QApplication(sys.argv)

    # WindowClass의 인스턴스 생성
    myWindow = HomeWindow()

    # 프로그램 화면을 보여주는 코드
    myWindow.showFullScreen()

    # 프로그램을 이벤트루프로 진입시키는(프로그램을 작동시키는) 코드
    sys.exit(app.exec_())


