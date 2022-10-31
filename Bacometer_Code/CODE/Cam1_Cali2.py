from multiprocessing import Process
from simple_pyspin import Camera
from PIL import Image
import os
import numpy as np
import cv2
def average(vals):
    pos = len(vals) >>1
    vals = sorted(vals)
    print(vals)
    vals = vals[pos:]
    print(vals)
    return np.mean(vals)
'''
def crop_center_2d(img, cropx, cropy):
    y,x = img.shape
    startx = x//2 - cropx//2
    starty = y//2 - cropy//2
    return img[starty:starty+cropy, startx:startx+cropx]

def crop_center_3d(img, cropx, cropy):
    y,x,z =img.shape
    startx = x//2 - cropx//2
    starty = y//2 - cropy//2
    return img[starty:starty+cropy, startx:startx+cropx]
'''

def cam1step1(serial):

    with Camera(index = serial) as cam:

        cam.OffsetX = 0
        cam.OffsetY = 0
        cam.Width = 1440
        cam.Height = 1080
        cam.AcquisitionFrameRateEnable = True
        cam.AcquisitionFrameRate = 10
        cam.ExposureAuto = 'Off'

        name = os.environ['LOGNAME']
        if os.path.isfile("/home/%s/Desktop/variable/exposure1" % name):
            f = open("/home/%s/Desktop/variable/exposure1" % name, 'r+t')
            exposure1 = f.read()
            print("expoure1:", exposure1)
            f.close()

        TARGET_EXPOSURE = 50
        SHUTTER_SPEED_DEFAULT = 4000
        SHUTTER_SPEED_MAX = 20000


        shutterSpeed = SHUTTER_SPEED_DEFAULT
        exposure1 = ""
        targetExposureReached = False
        if shutterSpeed > SHUTTER_SPEED_MAX or shutterSpeed == 0:
            shutterSpeed = SHUTTER_SPEED_DEFAULT
            cam.ExposureTime = shutterSpeed

        while targetExposureReached == False:

            for frame in range(1,999):
                name = os.environ['LOGNAME']
                if os.path.isfile("/home/%s/Desktop/variable/exposure1" % name):
                    f = open("/home/%s/Desktop/variable/exposure1" % name, 'r+t')
                    exposure = f.read()
                    print(exposure)
                    f.close()

                shutterSpeed = int(exposure)
                cam.ExposureTime = shutterSpeed
                cam.start()
                imgs = [cam.get_array()]
                avg = np.average(imgs)
                if avg == 0:
                    targetExposureReached =True
                    cam.ExposureTime = shutterSpeed
                    f = open("/home/%s/Desktop/variable/exposure1" % name, 'w+t')
                    f.write(str(shutterSpeed))
                    f.close()
                    break
                else:
                    ratio = TARGET_EXPOSURE / avg
                    print("TARGET_EXPOSURE : ", TARGET_EXPOSURE, "avg : ", avg, "ratio : ", ratio)

                    if abs(1-ratio) < 0.01:

                        targetExposureReached = True
                        f = open("/home/%s/Desktop/variable/exposure1" % name, 'w+t')
                        f.write(str(shutterSpeed))
                        f.close()
                        break

                    else:

                        if ratio < 1:
                            shutterSpeed = int(shutterSpeed*(1-(1-ratio)/5))
                        elif ratio > 1 :
                            shutterSpeed = int(shutterSpeed*(1+(ratio-1)/5))

                        print("shutterSpeed : ", shutterSpeed)
                        cam.ExposureTime = shutterSpeed
                        f = open("/home/%s/Desktop/variable/exposure1" % name, 'w+t')
                        f.write(str(shutterSpeed))
                        f.close()

                        if shutterSpeed > SHUTTER_SPEED_MAX:
                            targetExposureReached = True
                            print("Calibration finished : TOO DARK")
                            cam.ExposureTime = shutterSpeed
                            f = open("/home/%s/Desktop/variable/exposure1" % name, 'w+t')
                            f.write(str(shutterSpeed))
                            f.close()
                            break

                        elif shutterSpeed == 0:
                            targetExposureReached = True
                            print("Calibration finished : TOO BRIGHT")
                            cam.ExposureTime = shutterSpeed
                            f = open("/home/%s/Desktop/variable/exposure1" % name, 'w+t')
                            f.write(str(shutterSpeed))
                            f.close()
                            break
                        else:
                            print("else")
                cam.stop()

def cam1step2(serial):

    with Camera(index = serial) as cam:

        cam.OffsetX = 0
        cam.OffsetY = 0
        cam.Width = 1440
        cam.Height = 1080
        cam.AcquisitionFrameRateEnable = True
        cam.AcquisitionFrameRate = 10
        cam.ExposureAuto = 'Off'

        name = os.environ['LOGNAME']
        if os.path.isfile("/home/%s/Desktop/variable/exposure1" % name):
            f = open("/home/%s/Desktop/variable/exposure1" % name, 'r+t')
            exposure1 = f.read()
            print("step2_expoure1:", exposure1)
            f.close()

        cam.ExposureTime = int(exposure1)

        cam.start()
        img1 = np.array(cam.get_array())
        template = cv2.imread('/home/twt/Desktop/ref.tiff', cv2.IMREAD_GRAYSCALE)
        w, h = template.shape[::-1]
        methods= ['cv2.TM_CCOEFF', 'cv2.TM_CCOEFF_NORMED', 'cv2.TM_CCORR', 'cv2.TM_CCORR_NORMED', 'cv2.TM_SQDIFF', 'cv2.TM_SQDIFF_NORMED']

        maxvalue = 0
        for meth in methods:
            method = eval(meth)

            try:
                res = cv2.matchTemplate(img1, template, method)
                min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(res)
            except:
                print('error', meth)
                continue
            if method in [cv2.TM_SQDIFF, cv2.TM_SQDIFF_NORMED]:
                top_left = min_loc
            else:
                top_left = max_loc
                bottom_right = (top_left[0]+w, top_left[1]+h)

            histim1 = img1[top_left[1]:top_left[1]+h, top_left[0]:top_left[0]+w]
            hist1 = cv2.calcHist([histim1], [0], None, [256], [0,256])
            hist2 = cv2.calcHist([template], [0], None, [256], [0,256])

            if maxvalue < cv2.compareHist(hist1,hist2,cv2.HISTCMP_CORREL):
                maxvalue = cv2.compareHist(hist1,hist2,cv2.HISTCMP_CORREL)
                loc = [top_left[0], top_left[1]]
        print(maxvalue, loc)

        modx = loc[0] % 4
        mody = loc[1] % 4
        if modx != 0:
            loc[0] = loc[0] + (4 - modx)
        if mody != 0:
            loc[1] = loc[1] + (4 - mody)

        f1 = open("/home/%s/Desktop/variable/cam1_xoffset" % name, 'w+t')
        f1.write(str(loc[0]))
        f1.close()

        f2 = open("/home/%s/Desktop/variable/cam1_yoffset" % name, 'w+t')
        f2.write(str(loc[1]))
        f2.close()
        cam.stop()

def cam1step3(serial):

    with Camera(index = serial) as cam:

        name = os.environ['LOGNAME']
        if os.path.isfile("/home/%s/Desktop/variable/cam1_xoffset" % name):
            f1 = open("/home/%s/Desktop/variable/cam1_xoffset" % name, 'r+t')
            cam1offx = f1.read()
            print("step3_cam1offx:", cam1offx)
            f1.close()

        if os.path.isfile("/home/%s/Desktop/variable/cam1_yoffset" % name):
            f2 = open("/home/%s/Desktop/variable/cam1_yoffset" % name, 'r+t')
            cam1offy = f2.read()
            print("step3_cam1offy:", cam1offy)
            f2.close()

        cam.Width = 256
        cam.Height = 256
        cam.OffsetX = int(cam1offx)
        cam.OffsetY = int(cam1offy)
        cam.AcquisitionFrameRateEnable = True
        cam.AcquisitionFrameRate = 10
        cam.ExposureAuto = 'Off'

        if os.path.isfile("/home/%s/Desktop/variable/exposure1_2" % name):
            f = open("/home/%s/Desktop/variable/exposure1_2" % name, 'r+t')
            exposure1 = f.read()
            print("step3_expoure1:", exposure1)
            f.close()

        template = cv2.imread('/home/twt/Desktop/ref.tiff', cv2.IMREAD_GRAYSCALE)
        avgref = np.average(template)
        print("step3_avg:", avgref)
        TARGET_EXPOSURE = 116
        SHUTTER_SPEED_DEFAULT = 5000
        SHUTTER_SPEED_MAX = 40000


        shutterSpeed = SHUTTER_SPEED_DEFAULT
        exposure1 = ""
        targetExposureReached = False
        if shutterSpeed > SHUTTER_SPEED_MAX or shutterSpeed == 0:
            shutterSpeed = SHUTTER_SPEED_DEFAULT
            cam.ExposureTime = shutterSpeed

        while targetExposureReached == False:

            for frame in range(1,999):
                name = os.environ['LOGNAME']
                if os.path.isfile("/home/%s/Desktop/variable/exposure1_2" % name):
                    f = open("/home/%s/Desktop/variable/exposure1_2" % name, 'r+t')
                    exposure = f.read()
                    print(exposure)
                    f.close()

                shutterSpeed = int(exposure)
                cam.ExposureTime = shutterSpeed
                cam.start()
                imgs = [cam.get_array()]
                avg = np.average(imgs)
                if avg == 0:
                    targetExposureReached =True
                    cam.ExposureTime = shutterSpeed
                    f = open("/home/%s/Desktop/variable/exposure1_2" % name, 'w+t')
                    f.write(str(shutterSpeed))
                    f.close()
                    break
                else:
                    ratio = TARGET_EXPOSURE / avg
                    print("TARGET_EXPOSURE : ", TARGET_EXPOSURE, "avg : ", avg, "ratio : ", ratio)

                    if abs(1-ratio) < 0.01:

                        targetExposureReached = True
                        f = open("/home/%s/Desktop/variable/exposure1_2" % name, 'w+t')
                        f.write(str(shutterSpeed))
                        f.close()
                        break

                    else:

                        if ratio < 1:
                            shutterSpeed = int(shutterSpeed*(1-(1-ratio)/5))
                        elif ratio > 1 :
                            shutterSpeed = int(shutterSpeed*(1+(ratio-1)/5))

                        print("shutterSpeed : ", shutterSpeed)
                        cam.ExposureTime = shutterSpeed
                        f = open("/home/%s/Desktop/variable/exposure1_2" % name, 'w+t')
                        f.write(str(shutterSpeed))
                        f.close()

                        if shutterSpeed > SHUTTER_SPEED_MAX:
                            targetExposureReached = True
                            print("Calibration finished : TOO DARK")
                            cam.ExposureTime = shutterSpeed
                            f = open("/home/%s/Desktop/variable/exposure1_2" % name, 'w+t')
                            f.write(str(shutterSpeed))
                            f.close()
                            break

                        elif shutterSpeed == 0:
                            targetExposureReached = True
                            print("Calibration finished : TOO BRIGHT")
                            cam.ExposureTime = shutterSpeed
                            f = open("/home/%s/Desktop/variable/exposure1_2" % name, 'w+t')
                            f.write(str(shutterSpeed))
                            f.close()
                            break
                        else:
                            print("else")
                cam.stop()

def check(serial):

    with Camera(index = serial) as cam:

        name = os.environ['LOGNAME']
        if os.path.isfile("/home/%s/Desktop/variable/cam1_xoffset" % name):
            f1 = open("/home/%s/Desktop/variable/cam1_xoffset" % name, 'r+t')
            cam1offx = f1.read()
            print("check_cam1offx:", cam1offx)
            f1.close()

        if os.path.isfile("/home/%s/Desktop/variable/cam1_yoffset" % name):
            f2 = open("/home/%s/Desktop/variable/cam1_yoffset" % name, 'r+t')
            cam1offy = f2.read()
            print("check_cam1offy:", cam1offy)
            f2.close()

        cam.OffsetX = int(cam1offx)
        cam.OffsetY = int(cam1offy)
        cam.Width = 256
        cam.Height = 256
        cam.AcquisitionFrameRateEnable = True
        cam.AcquisitionFrameRate = 10
        cam.ExposureAuto = 'Off'

        if os.path.isfile("/home/%s/Desktop/variable/exposure1" % name):
            f = open("/home/%s/Desktop/variable/exposure1" % name, 'r+t')
            exposure1 = f.read()
            print("check_expoure1:", exposure1)
            f.close()

        cam.ExposureTime = int(exposure1)

        cam.start()
        img1 = np.array(cam.get_array())
        template = cv2.imread('/home/twt/Desktop/ref.tiff', cv2.IMREAD_GRAYSCALE)
        w, h = template.shape[::-1]

        hist1 = cv2.calcHist([img1], [0], None, [256], [0,256])
        hist2 = cv2.calcHist([template], [0], None, [256], [0,256])

        a = cv2.compareHist(hist1,hist2,cv2.HISTCMP_CORREL)
        print("final CORR:", a)
        cam.stop()

if __name__=='__main__':
#    cam1step1(0)
#    cam1step2(0)
    cam1step3(0)
    check(0)
    print("cam1:Full ROI calibration finished")
