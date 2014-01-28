#%% Setup environment
from Metric import computeMetric
from sklearn.ensemble import RandomForestClassifier
import numpy as np
import os

#%% Load processed numpy file
test = False
if test:
    os.chdir('..\\Data\\test')
else:
    os.chdir('..\\Data\\images_training_rev1')
images = np.loadtxt("processed_images.txt")

#%% Train random forest
rf = RandomForestClassifier(n_estimators=100, n_jobs=4)
rf = rf.fit(train_data[0::,1::],train_data[0::,0])

# Take the same decision trees and run on the test data
pred = rf.predict(test_data)

#%% Revert working directory
os.chdir('C:\Projects\Kaggle\Galaxy_Zoo\Code')
