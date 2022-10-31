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

        f = open("/home/%s/Desktop/variable/exposure4_2" % (name), 'r')
        ET = int(f.readline())
        f.close()
        f = open("/home/%s/Desktop/variable2/Manual/Cam_%s/Setting_FPS.txt" % (name, serial), 'r')
        FPS = int(f.readline())
        f.close()
        f = open("/home/%s/Desktop/variable2/Manual/Cam_%s/Setting_Gain.txt" % (name, serial), 'r')
        Gain = int(f.readline())
        f.close()
        f = open("/home/%s/Desktop/variable/cam4_xoffset" % (name), 'r')
        Offset_X = int(f.readline())
        f.close()
        f = open("/home/%s/Desktop/variable/cam4_yoffset" % (name), 'r')
        Offset_Y = int(f.readline())
        f.close()
        f = open("/home/%s/Desktop/variable2/Manual/Cam_%s/Setting_ROI_X.txt" % (name, serial), 'r')
        ROI_X = int(f.readline())
        f.close()
        f = open("/home/%s/Desktop/variable2/Manual/Cam_%s/Setting_ROI_Y.txt" % (name, serial), 'r')
        ROI_Y = int(f.readline())
        f.close()

        cam.ExposureAuto = 'Off'
        cam.ExposureTime = ET
        cam.AcquisitionFrameRateEnable = True
        cam.AcquisitionFrameRate = FPS
        cam.GainAuto = 'Off'
        cam.Gain = Gain
        cam.OffsetX = Offset_X
        cam.OffsetY = Offset_Y
        cam.Width = ROI_X
        cam.Height = ROI_Y

        cam.start()
        imgs = [cam.get_array() for n in range(300)]
        cam.stop()
    #
    name = os.environ['LOGNAME']
    output_dir = '/home/%s/Desktop/Bacometer_Data_E/Multi/cam_%s' % (name, serial)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    print("Saving Images to: %s" % output_dir)

    for n, img in enumerate(imgs):
        Image.fromarray(img).save(os.path.join(output_dir, '%06d.tiff' % n))

if __name__=='__main__':
    c4 = Process(target=get_image, args=(3,))
    c4.start()
    c4.join()





