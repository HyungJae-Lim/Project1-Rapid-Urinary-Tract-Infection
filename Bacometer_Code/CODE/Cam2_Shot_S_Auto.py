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
        if os.path.isfile("/home/%s/Desktop/variable/Auto/cam2_xoffset" % name):
            f1 = open("/home/%s/Desktop/variable/Auto/cam2_xoffset" % name, 'r+t')
            cam2offx = f1.read()
            print("check_cam2offx:", cam2offx)
            f1.close()

        if os.path.isfile("/home/%s/Desktop/variable/Auto/cam2_yoffset" % name):
            f2 = open("/home/%s/Desktop/variable/Auto/cam2_yoffset" % name, 'r+t')
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

        if os.path.isfile("/home/%s/Desktop/variable/Auto/exposure2" % name):
            f = open("/home/%s/Desktop/variable/Auto/exposure2" % name, 'r+t')
            exposure2 = f.read()
            print("check_expoure2:", exposure2)
            f.close()

        cam.ExposureTime = int(exposure2)

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
    c2 = Process(target=get_image, args=(1,))
    c2.start()
    c2.join()





