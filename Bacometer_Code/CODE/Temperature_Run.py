from PyQt5 import uic, QtCore
from PyQt5.QtCore import *
from Temperature_Monitor import *
from Temperature_PWM import *

class Temp_run(QThread):

    def __init__(self):
        super().__init__()

    def run(self):

        while True:

            # Temp. data
            f = open("Setting_Temp.txt",'r')
            self.tempVar2 = f.readline()
            f.close()

            self.tempVar = Temperature_C() # Current Temp
            self.tempVar1 = float(self.tempVar2) # Setting Temp
            #print("current temperature is %.2f" %self.tempVar) 
            #print("setting temperature is %.2f" %self.tempVar1) 
         
            if (self.tempVar1 - self.tempVar > 0.2):
                pwm_heating(int(50))
                pwm_cooling(int(0))
            elif(self.tempVar1 - self.tempVar >= 0) :
                pwm_heating(int(50*(self.tempVar1 - self.tempVar)/0.5))
                pwm_cooling(int(0))
            elif(self.tempVar1 - self.tempVar >= -0.2) :
                pwm_heating(int(0))
                pwm_cooling(int(-50*(self.tempVar1 - self.tempVar)/0.5))
            elif(self.tempVar1 - self.tempVar < -0.2) :
                pwm_heating(int(0))
                pwm_cooling(int(50))






      
