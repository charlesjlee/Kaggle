#%% Setup environment

from sklearn.ensemble import RandomForestClassifier 

# Create the random forest object which will include all the parameters
# for the fit
Forest = RandomForestClassifier(n_estimators = 100)

# Fit the training data to the training output and create the decision
# trees
Forest = Forest.fit(train_data[0::,1::],train_data[0::,0])

# Take the same decision trees and run on the test data
Output = Forest.predict(test_data)