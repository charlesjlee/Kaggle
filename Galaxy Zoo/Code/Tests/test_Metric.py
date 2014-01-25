#%% Test Metric.py
import os, sys
lib_path = os.path.join('..')
sys.path.append(lib_path)

from .. import Metric
import pandas as pd


class test_Metric:
    # Test if RMSE is 0 if file passed is the same
    def test_Metric_SameFile():
        answer = pd.read_csv('../Data/training_solutions_rev1.csv')
        answer = answer.sort_index(by='GalaxyID', ascending=1)
        answer = answer.drop('GalaxyID', 1)
        assert Metric.computeMetric(answer, answer) == 0

    # Test if RMSE is 0 if file passed is the same
    def test_Metric_SameFile2():
        answer = pd.read_csv('../Submissions/all_ones_benchmark.csv')
        answer = answer.sort_index(by='GalaxyID', ascending=1)
        answer = answer.drop('GalaxyID', 1)
        assert Metric.computeMetric(answer, answer) == 0