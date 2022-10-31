# -*- coding: utf-8 -*-

import sys
import os
import time
from PyQt5.QtCore import *
from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5 import uic, QtCore
from threading import Timer
from PyQt5.QtGui import QIcon, QPixmap

#UI파일 연결
#단, UI파일은 Python 코드 파일과 같은 디렉토리에 위치해야한다.
form_class = uic.loadUiType("Stop.ui")[0]

#화면을 띄우는데 사용되는 Class 선언
class StopWindow(QDialog, form_class) :

    def __init__(self, parent) :
        super(self.__class__, self).__init__()
        self.setupUi(self)

        # Qdialog
        self.Button_ok.clicked.connect(self.Qdialog_ok)
        self.Button_cancel.clicked.connect(self.Qdialog_cancel)

    # Button_ok 가 눌리면 작동할 함수
    def Qdialog_ok(self):
        f = open("Setting_Question.txt",'w')
        self.data = "1" 
        f.write(self.data)
        f.close()
        f = open("Setting_Acquisition.txt",'w')
        self.Acquisition = "0"
        f.write(self.Acquisition)
        f.close()
        self.close()

    def Qdialog_cancel(self):
        f = open("Setting_Question.txt",'w')
        self.data = "0" 
        f.write(self.data)
        f.close()

        self.close()

'''
if __name__ == "__main__" :
    #QApplication : 프로그램을 실행시켜주는 클래스
    app = QApplication(sys.argv)

    #WindowClass의 인스턴스 생성
    myWindow = Measurement()

    #프로그램 화면을 보여주는 코드
    myWindow.show()

    #프로그램을 이벤트루프로 진입시키는(프로그램을 작동시키는) 코드
    app.exec_()
'''
