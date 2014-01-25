"""
Galaxy Zoo - Computes the root mean squared(https://www.kaggle.com/wiki/RootMeanSquaredError) of a solution
Input: proposed solution and correct solution
Output: RMSE
"""

#%% Import
import numpy as np

#%% Compute RMSE
def computeMetric(solution, answer):
    # Cast to array and reshape
    answer = np.reshape(np.array(answer), np.size(answer))
    solution = np.reshape(np.array(solution), np.size(solution))
    
    # Calculate RMSE
    rmse = np.sqrt(np.mean((answer - solution)**2))
    return rmse