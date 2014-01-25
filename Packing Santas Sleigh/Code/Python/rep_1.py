"""One-line documentation for presents module.

A detailed description of presents.
"""
import sys
import csv
import numpy as np

def main():

  staging_area = []
  sleigh = Sleigh(1000,1000)

  with open(sys.argv[1],'r') as f:
    reader = csv.reader(f)
    reader.next() #Skip Header

    staging_area = [Present([i,j,k],pres_id) for pres_id,i,j,k in reader]
    print("Loaded %s presents successfuly"% len(staging_area))


class Sleigh:

  #Describes the dimension of the sleigh
  x,y = 0,0

  packed_presents = []

  def __init__(self,x,y):
    self.x = x
    self.y = y

  def export_solution(self):
    with open("solution.csv",'w') as f:
      writer = csv.writer(f)
      names = ["PresentID"]+[i+str(j) for i in "xyz" for j in (range(8)+1)]
      writer.writerow(names)
      [writer.writerow(present.get_all_vert()) for present in packed_presents]

  def stack_presents(presents):
    #Find lowest spot and place present
    first = presents.pop()
    first.set_location(1,1,1)
    for p in staging area:



class Present:

  # Present ID describes priority of present that needs to be unpacked first (be
  # at the top of the sleigh)
  present_id = 0
  # Present dimentions
  present_dim = None
  # Describes orientation via opposite verticies
  vert1,vert2 = None, None

  def __init__(self,dim,pres_id):

    self.present_dim = dim
    self.present_id = pres_id

  def is_packed(self):
    if vert1 is None or vert2 is None:
      return False
    else:
      return True

  def get_all_vert(self):
    verticies = []
    v1 = vert1*4
    v2 = vert2*4
    v1[1],v1[5],v1[9] = self.vert2[1], self.vert2[2], self.vert2[3]
    v2[1],v2[5],v2[9] = self.vert1[1], self.vert1[2], self.vert1[3]
    return v1+v2

  def set_location(self,x1,y1,z1):
    self.vert1 = [x1,y1,z1]
    self.vert2 = [x1+dim[1],y1+dim[2],z1+dim[3]]



if __name__ == '__main__':
  main()
