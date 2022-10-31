import smbus
import time
import Jetson.GPIO as GPIO     
from time import sleep  
import os

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)  # Set Pi to use pin number when referencing GPIO pins.
                          # Can use GPIO.setmode(GPIO.BCM) instead to use 
                          # Broadcom SOC channel names.
bus = smbus.SMBus(1)

# ADT75 address, 0x48(72)
# Read data back from 0x00(00), 2 bytesls
# temp MSB, temp LSB

def Temperature_C():

    data = bus.read_i2c_block_data(0x48, 0x00, 2)

# Convert the data to 12-bits
    temp = ((data[0] * 256) + data[1]) / 16
    if temp > 2047 :
        temp -= 4096
    cTemp = temp * 0.0625 
    fTemp = (cTemp * 1.8) + 32

#    print (cTemp)
    return (cTemp)


cTemp = Temperature_C()
















      
