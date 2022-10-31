import Jetson.GPIO as GPIO
import time

from PyQt5.QtCore import *

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)  

GPIO.setup(4, GPIO.OUT)  # Set GPIO pin 19 to output mode.
GPIO.output(4, True)  

class Laser_run(QThread):

    def __init__(self):
        super().__init__()

    def run(self):
  
        while True:

            # Laser usage time data

            f = open("Setting_Laser.txt",'r')
            self.LaserHour1 = f.readline()
            self.LaserMin1 = f.readline()
            self.LaserSec1 = f.readline()

            self.LaserHour = float(self.LaserHour1)
            self.LaserMin = float(self.LaserMin1)
            self.LaserSec = float(self.LaserSec1)

            f.close()
#            print("1:", "%d" %self.LaserHour, "%d" %self.LaserMin, "%d" %self.LaserSec)

            if self.LaserSec < 59:
                self.LaserSec += 1
            elif self.LaserSec == 59:
                self.LaserSec = 0
                if  self.LaserMin < 59:
                    self.LaserMin += 1
                elif  self.LaserMin == 59:
                    self.LaserMin = 0
                    self.LaserHour += 1

#            print("%d" %self.LaserHour, "%d" %self.LaserMin, "%d" %self.LaserSec)

            f = open("Setting_Laser.txt", 'w')

            f.write('%d\n' %int(self.LaserHour))
            f.write('%d\n' %int(self.LaserMin))
            f.write('%d\n' %int(self.LaserSec))
            f.close()

            time.sleep(1)

#           print("%d\n"%self.LaserHour,"%d\n"%self.LaserMin,"%d"%self.LaserSec)

        





     

          


