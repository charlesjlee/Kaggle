# Taken from http://beatingthebenchmark.blogspot.de/2013/12/packing-santas-sleigh-python-code-for.html

 #
 # This is a translation of the MATLAB benchmark code
 # given by Kaggle in "Packing Santa's Sleigh" competition
 #
 # This file will give a score same as the MATLAB benchmark score
 #
 import numpy as np
 import scipy as sp
 import pandas as pd
 def getData():
      print "reading data using pandas"
      data = pd.read_table('../presents.csv', sep=',')
      #print data
      print "converting data to numpy array"
      data = np.asarray(data)
      #print data
      return data
 def shelfNF(data):
      #data = data[:100, :]
      # the number of presents
      presents = data[:,1:]
      numPresents = data.shape[0]
      print "total presents : ", numPresents
      # width and length are 1000 units. Height is not fixed for the packing
      width = 1000
      length = 1000
      # Initial coordinates
      xs = 1
      ys = 1
      zs = -1
      lastRowsInd = np.zeros((100, 1)) # temp array for storing indexes of last few rows
      lastShelfInd = np.zeros((100,1)) # temp array for storing indexes of last few shelves
      numInRow = 0     # Store the number of presents in current row
      numInShelf = 0     # Store the number of presents in current shelf
      presentCoordinates = np.zeros((numPresents, 25))
      tempPresentLenRow = []
      tempPresentHeightShelf = []
      for i in range(numPresents):
           # check if there is room in the row, else increase the row
           if (xs + presents[i,0] > width + 1):
                ys = ys + np.max(tempPresentLenRow)
                xs = 1
                numInRow = 0
                tempPresentLenRow = []
           # check if there is room in shelf, else increase the height
           if (ys + presents[i,1] > length + 1):
                zs = zs - np.max(tempPresentHeightShelf)
                xs = 1
                ys = 1
                numInShelf = 0
                tempPresentHeightShelf = []
           presentCoordinates[i,0] = data[i,0]
           presentCoordinates[i,[1,7,13,19]] = xs
           presentCoordinates[i,[4,10,16,22]] = xs + presents[i,0] - 1
           presentCoordinates[i,[2,5,14,17]] = ys
           presentCoordinates[i,[8,11,20,23]] = ys + presents[i,1] - 1
           presentCoordinates[i,[3,6,9,12]] = zs
           presentCoordinates[i,[15,18,21,24]] = zs - presents[i,2] + 1
           xs = xs + presents[i,0]
           numInRow = numInRow + 1
           numInShelf = numInShelf + 1
           tempPresentLenRow.append(presents[i,1])
           tempPresentHeightShelf.append(presents[i,2])
           if i%1000 == 0: print i
      zCoords = presentCoordinates[:,3::3]
      minZ = np.min(zCoords.ravel())
      presentCoordinates[:,3::3] = zCoords - minZ + 1
      return presentCoordinates
 def saveCSV(predictions):
      datafile = pd.read_table('../presents.csv', sep=',')
      submission = pd.DataFrame(predictions, columns="PresentID,x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4,x5,y5,z5,x6,y6,z6,x7,y7,z7,x8,y8,z8".split(','), dtype = int)
      submission.to_csv('submission.csv', index = False)
 if __name__ == '__main__':
      data = getData()
      predictions = shelfNF(data)
      saveCSV(predictions)
