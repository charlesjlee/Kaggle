"""
Galaxy Zoo - Imports the training and test images
Input: training and test images
Output: csv of image data

Original image ETL written by Kaggle user Michal Mrnustik in this forum post
https://www.kaggle.com/c/galaxy-zoo-the-galaxy-challenge/forums/t/6803/beating-the-benchmark
"""

#%% Setup environment
import numpy as np
import cv2
import os
import glob
import time

test = True
os.chdir('C:\Projects\Kaggle\Galaxy Zoo\Code')
if test:
    os.chdir('..\\Data\\test')
else:
    os.chdir('..\\Data\\images_training_rev1')

#%% ETL images into a text file
t = time.time()
images = []
image_files = sorted(os.listdir('.'))
glob_files = '*.jpg'
#with open("processed_images.txt", "wb") as outfile:
for enum, imgf in enumerate(glob.glob(glob_files)):        
    img = cv2.imread(imgf, cv2.IMREAD_GRAYSCALE)
    img = img[140:284, 140:284] # Crop the image
    img = cv2.resize(img, (128, 128), interpolation=cv2.INTER_CUBIC)
    length = np.prod(img.shape)
    img = np.reshape(img, length)
    images.append(img)
    #outfile.write(os.path.splitext(imgf)[0] + " " + str(img) + "\n")

images = np.vstack(images)
np.savetxt("numpy_save.csv", images, delimiter=",")
elapsed = time.time() - t

#%% Revert working directory
os.chdir('C:\Projects\Kaggle\Galaxy Zoo\Code')

#%% Leftover testing code to display an image
#cv2.imshow('image',img)
#k = cv2.waitKey(0)
#cv2.destroyAllWindows()