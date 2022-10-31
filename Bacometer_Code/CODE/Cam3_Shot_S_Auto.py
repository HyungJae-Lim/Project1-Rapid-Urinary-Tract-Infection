from multiprocessing import Process
from simple_pyspin import Camera
from PIL import Image
from datetime import datetime
import os

def get_image(serial):
    f = open("Setting_Case.txt",'r')
    casenum = f.readline()
    f.close()
    datevar = datetime.today().strftime("%Y_%m_%d")

    with Camera(index = serial) as cam:
        name = os.environ['LOGNAME']
        if os.path.isfile("/home/%s/Desktop/variable/Auto/cam3_xoffset" % name):
            f1 = open("/home/%s/Desktop/variable/Auto/cam3_xoffset" % name, 'r+t')
            cam3offx = f1.read()
            print("check_cam3offx:", cam3offx)
            f1.close()

        if os.path.isfile("/home/%s/Desktop/variable/Auto/cam3_yoffset" % name):
            f2 = open("/home/%s/Desktop/variable/Auto/cam3_yoffset" % name, 'r+t')
            cam3offy = f2.read()
            print("check_cam3offy:", cam3offy)
            f2.close()

        cam.OffsetX = int(cam3offx)
        cam.OffsetY = int(cam3offy)

        cam.Width = 256
        cam.Height = 256
        cam.AcquisitionFrameRateEnable = True
        cam.AcquisitionFrameRate = 30
        cam.ExposureAuto = 'Off'

        if os.path.isfile("/home/%s/Desktop/variable/Auto/exposure3" % name):
            f = open("/home/%s/Desktop/variable/Auto/exposure3" % name, 'r+t')
            exposure3 = f.read()
            print("check_expoure3:", exposure3)
            f.close()

        cam.ExposureTime = int(exposure3)

        cam.start()
        imgs = [cam.get_array() for n in range(2)]
        cam.stop()
    
    name = os.environ['LOGNAME']
    output_dir = '/home/%s/Desktop/Bacometer_Data_S/Bacometer_1/%s/%s/cam_%s' % (name, datevar, casenum, serial)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    print("Saving Images to: %s" % output_dir)
    numbers = len([f for f in os.listdir(output_dir)if os.path.isfile(os.path.join(output_dir,f))])
    for n, img in enumerate(imgs):
        Image.fromarray(img).save(os.path.join(output_dir, '%06d.tiff' % (n+numbers)))


if __name__=='__main__':
    c3 = Process(target=get_image, args=(2,))
    c3.start()
    c3.join()





