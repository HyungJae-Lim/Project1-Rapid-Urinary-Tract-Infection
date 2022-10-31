import smbus
import time
import Jetson.GPIO as GPIO     
from time import sleep  

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)  

GPIO.setup(13, GPIO.OUT)  # Set GPIO pin 13 to output mode.
GPIO.setup(12, GPIO.OUT)  # Set GPIO pin 12 to output mode.

def pwm_heating(fq1):
    GPIO.output(13,True)
    time.sleep(fq1*0.008)
    GPIO.output(13,False)
    time.sleep((100-fq1)*0.001)

def pwm_cooling(fq2):
    GPIO.output(12,True)
    time.sleep(fq2*0.008)
    GPIO.output(12,False)
    time.sleep((100-fq2)*0.001)

#while True:
#    pwm_cooling(50)
#    pwm_cooling(int(-50*(-0.2)/0.5))













      
