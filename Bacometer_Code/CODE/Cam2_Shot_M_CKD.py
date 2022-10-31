import pandas as pd
import os
import sys
import time

from multiprocessing import Process
from simple_pyspin import Camera
from PIL import Image
from datetime import datetime

def get_image(serial):
    f = open("Setting_Case.txt",'r')
    casenum = f.readline()
    f.close()
    f = open("Setting_Bacono.txt",'r')
    bacono1 = f.readline()
    bacono = int(bacono1)
    datevar = datetime.today().strftime("%Y-%m-%d")

    with Camera(index = serial) as cam:
        name = os.environ['LOGNAME']
        if os.path.isfile("/home/%s/Desktop/variable/cam2_xoffset" % name):
            f1 = open("/home/%s/Desktop/variable/cam2_xoffset" % name, 'r+t')
            cam2offx = f1.read()
            print("check_cam2offx:", cam2offx)
            f1.close()

        if os.path.isfile("/home/%s/Desktop/variable/cam2_yoffset" % name):
            f2 = open("/home/%s/Desktop/variable/cam2_yoffset" % name, 'r+t')
            cam2offy = f2.read()
            print("check_cam2offy:", cam2offy)
            f2.close()

        cam.OffsetX = int(cam2offx)
        cam.OffsetY = int(cam2offy)

        cam.Width = 256
        cam.Height = 256
        cam.AcquisitionFrameRateEnable = True
        cam.AcquisitionFrameRate = 30
        cam.ExposureAuto = 'Off'

        if os.path.isfile("/home/%s/Desktop/variable/exposure2" % name):
            f = open("/home/%s/Desktop/variable/exposure2" % name, 'r+t')
            exposure2 = f.read()
            print("check_expoure2:", exposure2)
            f.close()

        cam.ExposureTime = int(exposure2)

        cam.start()
        imgs = [cam.get_array() for n in range(300)]
        cam.stop()

    
    name = os.environ['LOGNAME']
    output_dir = '/home/%s/Desktop/Bacometer_Data_M/CKD/Bacometer_%s/%s/%s/cam_%s' % (name, bacono, datevar, casenum, serial)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    print("Saving Images to: %s" % output_dir)

    for n, img in enumerate(imgs):
        Image.fromarray(img).save(os.path.join(output_dir, '%06d.tiff' % n))

#
    input_dir = '/home/twt/Desktop/Bacometer_Value/CKD/'
    date = time.strftime('%Y-%m-%d', time.localtime(time.time()))
#    time = time.strftime('%H-%M-%S', time.localtime(time.time()))
    filename1 = '%s%s.csv' % (input_dir, date)

    if os.path.exists('%s%s.csv' % (input_dir, date)):
        df = pd.read_csv(filename1)
#        df1 = pd.DataFrame(columns=['Date', 'Case', 'Vial', 'Result', 'Concentration Value'])
        date = time.strftime('%Y-%m-%d', time.localtime(time.time()))
        tm = time.strftime('%H:%M:%S', time.localtime(time.time()))
        serial1 = serial +1 
        vial = ("# %s" %serial1)
        case = ("# %s" %casenum)
        result = "Port2"
        filename = '%s%s.csv' % (input_dir, date)
        df2 = df.append(pd.DataFrame([[date, tm, case, vial, result]], columns=['Date', 'Time', 'Case', 'Vial', 'Result']), ignore_index=True)
        df2.to_csv(filename, index=False)
    else:
        df = pd.DataFrame(columns=['Date', 'Time', 'Case', 'Vial', 'Result'])
        date = time.strftime('%Y-%m-%d', time.localtime(time.time()))
        tm = time.strftime('%H:%M:%S', time.localtime(time.time()))
        serial1 = serial +1 
        vial = ("# %s" %serial1)
        case = ("# %s" %casenum)
        result = "Port2"
        filename = '%s%s.csv' % (input_dir, date)
        df2 = df.append(pd.DataFrame([[date, tm, case, vial, result]], columns=['Date', 'Time', 'Case', 'Vial', 'Result']), ignore_index=True)
        df2.to_csv(filename, index=False)
#


if __name__=='__main__':
    c2 = Process(target=get_image, args=(1,))
    c2.start()
    c2.join()






