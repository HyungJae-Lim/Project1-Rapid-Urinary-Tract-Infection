# -*- coding: utf-8 -*-

import os
import sys

from PyQt5 import uic, QtCore
from PyQt5.QtCore import *
from PyQt5.QtWidgets import *
from PyQt5.QtGui import QIcon, QPixmap

from Laser_Run import *


# UI파일 연결
# 단, UI파일은 Python 코드 파일과 같은 디렉토리에 위치해야한다.
form_class = uic.loadUiType("Booting.ui")[0]

class BootingWindow(QMainWindow, form_class) :
    def __init__(self):
        super().__init__()
        self.setupUi(self)

        self.timerVar = QTimer()
        self.timerVar.setInterval(100)
        self.timerVar.timeout.connect(self.progressBarTimer)
        self.timerVar.start()

        # Run_Thread_Laser usage time
        self.Laserrun = Laser_run()
        self.Laserrun.start()

    def progressBarTimer(self):
        self.time = self.Progressbar_Booting.value()
        self.time += 1
        self.Progressbar_Booting.setValue(self.time)

        if self.time == 1: 
            self.Information.setText("Initializing...")
        if self.time == 10: 
            self.Information.setText("Doing Port1 Calibration...")           
        if self.time == 20: 
            os.system("python3 Cam1_Cali.py") 
            self.Information.setText("port1 Complete...")
        if self.time == 30: 
            self.Information.setText("Doing Port2 Calibration...")           
        if self.time == 40: 
            os.system("python3 Cam2_Cali.py") 
            self.Information.setText("port2 Complete...")
        if self.time == 50: 
            self.Information.setText("Doing Port3 Calibration...")           
        if self.time == 60: 
            os.system("python3 Cam3_Cali.py") 
            self.Information.setText("port3 Complete...")
        if self.time == 70: 
            self.Information.setText("Doing Port4 Calibration...")           
        if self.time == 80: 
            os.system("python3 Cam4_Cali.py") 
            self.Information.setText("port4 Complete...")
        if self.time == 85: 
            self.Information.setText("Calibration Complete...")
        if self.time == 90: 
            self.Information.setText("Starting Home Menu...")
        if self.time == 100: 
            self.timerVar.stop()
            self.close()
            os.system("python3 Home_BLAI_UTI.py")



if __name__ == "__main__" :
    app = QApplication(sys.argv)
    myWindow = BootingWindow()
    myWindow.showFullScreen()
    app.exec_()
