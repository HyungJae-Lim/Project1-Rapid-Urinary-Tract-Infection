import os
import sys

from PyQt5.QtCore import *
from PyQt5.QtWidgets import *
from PyQt5 import uic, QtCore, QtGui, QtWidgets
from PyQt5.QtGui import QIcon, QPixmap
from PyQt5.QtGui import *

# UI file Link

form_class = uic.loadUiType("Keypad_ET.ui")[0]

# UI Display

class KeypadWindow(QDialog, form_class) :

    def __init__(self) :
        super(self.__class__, self).__init__()
        self.setupUi(self)
 
        # Signal - Slot
        self.pushButton_0.clicked.connect(lambda state, button = self.pushButton_0: 
        self.NumClicked(state, button))
        self.pushButton_1.clicked.connect(lambda state, button = self.pushButton_1: 
        self.NumClicked(state, button))
        self.pushButton_2.clicked.connect(lambda state, button = self.pushButton_2: 
        self.NumClicked(state, button))
        self.pushButton_3.clicked.connect(lambda state, button = self.pushButton_3: 
        self.NumClicked(state, button))
        self.pushButton_4.clicked.connect(lambda state, button = self.pushButton_4: 
        self.NumClicked(state, button))
        self.pushButton_5.clicked.connect(lambda state, button = self.pushButton_5: 
        self.NumClicked(state, button))
        self.pushButton_6.clicked.connect(lambda state, button = self.pushButton_6: 
        self.NumClicked(state, button))
        self.pushButton_7.clicked.connect(lambda state, button = self.pushButton_7: 
        self.NumClicked(state, button))
        self.pushButton_8.clicked.connect(lambda state, button = self.pushButton_8: 
        self.NumClicked(state, button))
        self.pushButton_9.clicked.connect(lambda state, button = self.pushButton_9: 
        self.NumClicked(state, button))
        self.pushButton_Back.clicked.connect(self.Parameter_Back_Function)       
        self.pushButton_Enter.clicked.connect(self.Parameter_Setting_Function)
        self.pushButton_Close.clicked.connect(self.Parameter_Close_Function)


# Function Part #

# 1. Keypad function

    def NumClicked(self, state, button):
        exist_line_text = self.Label_Number.text()
        now_num_text = button.text()
        self.Label_Number.setText(exist_line_text + now_num_text)

    def Parameter_Back_Function(self):
        exist_line_text = self.Label_Number.text()
        exist_line_text = exist_line_text[:-1]
        self.Label_Number.setText(exist_line_text)

    def Parameter_Setting_Function(self):
        f = open("/home/twt/Desktop/variable2/Manual/Cam_0/Setting_Exposetime.txt",'w')
        self.NumVar = self.Label_Number.text()
        f.write(self.NumVar)
        f.close()

    def Parameter_Close_Function(self):
        sys.exit()


if __name__ == "__main__":
    # QApplication : 프로그램을 실행시켜주는 클래스
    app = QApplication(sys.argv)

    # WindowClass의 인스턴스 생성
    myWindow = KeypadWindow()

    # 프로그램 화면을 보여주는 코드
    myWindow.show()

    # 프로그램을 이벤트루프로 진입시키는(프로그램을 작동시키는) 코드
    sys.exit(app.exec_())
