# Pulled from https://github.com/noahvanhoucke/PackingSantasSleigh/blob/master/MetricCalculation.py
# on Dec 12, 2013

# I converted code to Python 3

# -*- coding: utf-8 -*-
"""
Packing Santa's Sleigh -- Metric Calculation

@author: Joyce Noah-Vanhoucke
Created: Nov 22 09:55:38 2013

"""

import os
import csv
import math
import time
from collections import namedtuple


def int_reader_wrapper(reader):
    """ Allows file contents to be read as ints not as strings. """
    for row in reader:
        yield map(int, row)

def readPresentsFile(presentsFilename):
    """ Read file contents into memory as a dictionary of lists.
    Key is presentID, Value is dimensions.
    Arguments:
        presentFilename: name of file containing present Ids and Dimensions
    Returns:
        Dictionary of lists.
    """
    solution = {}
    with open(presentsFilename, 'r') as f:
        f.readline() # header
        fcsv = int_reader_wrapper(csv.reader(f))
        for row in fcsv:
            row = list(row)
            solution[row[0]] = row[1:]
    return solution

def readSubmissionFile(submissionFilename):
    """ Read file contents into memory as a dictionary of lists.
    Key is PresentId, Values is 8 vertices of the packed present.
    Arguments:
        submissionFilename: name of file containing present Ids and packing locations
    Returns:
        Dictioary of lists
    """
    submission = {}
    with open(submissionFilename, 'r') as f:
        f.readline() # header
        fcsv = int_reader_wrapper(csv.reader(f))
        for row in fcsv:
            row = list(row)
            submission[row[0]] = row[1:]
    return submission


Vertex = namedtuple('Vertex', 'x y z')
class Present:

    def create_vertices_list(self, submissionPresent):
        NUMBER_VERTICES = 8
        list_vertices = []
        for i in range(NUMBER_VERTICES):
            vertex = Vertex(submissionPresent[i*3], \
                            submissionPresent[i*3 + 1], \
                            submissionPresent[i*3 + 2])
            list_vertices.append(vertex)
        return list_vertices

    def set_submitted_package_dimensions(self):
        """ Returns the x, y, z values of the submitted package as a list. """
        xvalues = list(set(self.packageVertices[i].x for i in range(len(self.packageVertices))))
        yvalues = list(set(self.packageVertices[i].y for i in range(len(self.packageVertices))))
        zvalues = list(set(self.packageVertices[i].z for i in range(len(self.packageVertices))))

        if len(zvalues) != 2 or len(yvalues) != 2 or len(xvalues) != 2:
            # valid package coordinates have exactly 6 values: 2 each for x, y, z
            print('Error with submitted package vertices')
            exit()
        else:
            self.MinX = min(xvalues)
            self.MaxX = max(xvalues)
            self.MinY = min(yvalues)
            self.MaxY = max(yvalues)
            self.MinZ = min(zvalues)
            self.MaxZ = max(zvalues)
            return [int(math.fabs(xvalues[0] - xvalues[1]) + 1), \
                int(math.fabs(yvalues[0] - yvalues[1]) + 1), \
                int(math.fabs(zvalues[0] - zvalues[1]) + 1)]

    def is_expected_dimensions(self):
        # submitted packages may be rotated in any direction by 90-degrees
        return ( set(self.expectedDimensions) == set(self.submittedPackageDimensions) )

    def is_in_sleigh(self):
        xvalues = list(set(self.packageVertices[i].x for i in range(len(self.packageVertices))))
        yvalues = list(set(self.packageVertices[i].y for i in range(len(self.packageVertices))))
        zvalues = list(set(self.packageVertices[i].z for i in range(len(self.packageVertices))))
        return ( min(xvalues) > 0 and max(xvalues) <= self.SleightWidth and \
            min(yvalues) > 0 and max(yvalues) <= self.SleightWidth and \
            min(zvalues) > 0 )


    def __init__(self, solution, submission, presentId):
        self.SleightWidth = 1000
        self.MinX = None
        self.MaxX = None
        self.MinY = None
        self.MaxY = None
        self.MinZ = None
        self.MaxZ = None

        self.Id = presentId
        self.expectedDimensions = solution[presentId]
        self.packageVertices = self.create_vertices_list(submission[presentId])
        self.submittedPackageDimensions = self.set_submitted_package_dimensions()

        if not (self.is_expected_dimensions()):
            print('Submitted package ' + str(self.Id) + ' is not of the expected dimension')
            print('Expected Dimensions = ' + str(self.expectedDimensions))
            print('Submitted Dimensions = ' + str(self.submittedPackageDimensions))
            exit()
        if not (self.is_in_sleigh()):
            print('Submitted package ' + str(self.Id) + ' is not in the sleigh')
            print('Package Vertices = ' + str(self.packageVertices))
            exit()

    def intersects_with_another_present(self, otherPresent):
        """ Determines if present interects with another present in the xy-plane.
        Arguments:
            otherPresent: Present object
        Returns:
            boolean
        """
        ans = True
        if self.MaxX < otherPresent.MinX:
            ans = False
        if self.MinX > otherPresent.MaxX:
            ans = False
        if self.MaxY < otherPresent.MinY:
            ans = False
        if self.MinY > otherPresent.MaxY:
            ans = False
        if ans == True:
            # check z
            if ( (self.MinZ <= otherPresent.MaxZ and self.MaxZ > otherPresent.MinZ ) ):
                    print('Collision detected between presents ' + str(self.Id) + ', ' + str(otherPresent.Id))
                    exit()
            ans = False
        return ans

def update_ordered_presents(orderedPresents, presentZHeight, presentId):
    """ Updates the list ordered presents such that presents are
    listed in the order they appear from top to bottom of the sleigh.
    For presents that are found in the same horizontoal cross section,
    they are listed in numerical order.
    Arguments:
        orderedPresents: list of present ids
    Returns:
        orderedPresents: dictionary of sets, key is z-height of top of present ids
            in the set
    """
    if presentZHeight not in orderedPresents:
        orderedPresents[presentZHeight] = set()
    orderedPresents[presentZHeight].add(presentId)

def GetOrderedPresentsStartingAtTop(solution, submission):
    """ Goes through submission and returns an ordered list of present Ids
    as they appear in the sleigh from top to bottom. For presents in the
    same horizontal cross section (same xy-plane), the smallest present ids
    appears first.
    Arguments:
        solution: Dictionary of lists. Key is present id, value is dimensions
        submission: Dictionary of lists. Key is present id, value is list of Vertex
    Returns:
        presents: dictionary of present objects, key is present id
        presentsInCrossSection: dictionary of sets, key is z-height
    """
    presents = {}
    orderedPresents = {}
    for presentId in submission.keys():
        presents[presentId] = Present(solution, submission, presentId)
        update_ordered_presents(orderedPresents, presents[presentId].MaxZ, presentId)
    return presents, orderedPresents

def remove_presents_above_zheight(currentPresentsSet, zheight, presents):
    """ If zheight is lower than minimum z values of presents in currentPresentsSet,
    the remove from currentPresentsSet.
    Arguments:
        currentPresentsSet: list of present ids of presents currently in zheight cross section
        zheight: current position in z
        presents: dictionary of Present objects, key is present id
    Returns:
        void (updated currentPresents)
    """
    presentsToDiscard = set([i for i in currentPresentsSet if presents[i].MinZ > zheight])
    currentPresentsSet.difference_update(presentsToDiscard)

def add_to_current_presents(currentPresentsSet, presents, presentToAdd):
    """ Given set of current presents, check for collisions with presentToAdd.
    If no intersection, then adds presentToAdd to currentPresentsSet
    Arguments:
        currentPresentsSet: set of current present ids at current z-height of sleigh
        presents: dictionary of Present objects, key is present id
        presentToAdd: present id to be added to currentPresentsSet
    Returns:
        void (updated currentPresentsSet)
    """
    for pid in currentPresentsSet:
        if presents[pid].intersects_with_another_present(presents[presentToAdd]):
            print('Collision found between presents ' + str(pid) + ', ' + str(presentToAdd))
            exit()
    currentPresentsSet.add(presentToAdd)


def update_current_presents(currentPresentsSet, zheight, presents, presentsInCrossSection):
    """ Given the presents in the current horizontal cross section,
    checks for present intersections and updates list currentPresents
    based on min/max z-values.
    Arguments:
        currentPresentsSet: set of present ids for presents intersecting
            current z-height
        presents: dictionary of Present objects
        presentsInCrossSection: list of present ids in current cross section
    Returns:
        void (updates currentPresentsSet)
    """
    remove_presents_above_zheight(currentPresentsSet, zheight, presents)
    for i in range(len(presentsInCrossSection)):
        if len(currentPresentsSet) == 0:
            currentPresentsSet.add(presentsInCrossSection[i])
        else:
            add_to_current_presents(currentPresentsSet, presents, presentsInCrossSection[i])

def getTotalVolume(solution):
    """ Returns the total occupied volume of all the presents. """
    volume = 0
    for id in solution:
        volume += solution[id][0] * solution[id][1] * solution[id][2]
    return volume


if __name__ == "__main__":

    start = time.clock()

    presentsFilename = os.path.join('Data/', 'presents.csv')
    submissionFilename = os.path.join('Benchmarks/', 'MATLAB_Packing_Submission_File.csv')

    # read file contents into solution dictionary and submission dictionary
    solution = readPresentsFile(presentsFilename)
    submission = readSubmissionFile(submissionFilename)
    print('contents in memory')

    # create presents objects, and their order going down sleigh
    presents, orderedPresents = GetOrderedPresentsStartingAtTop(solution, submission)

    orderTerm = 0
    presentsSeenSoFar = 0
    currentPresentsSet = set()
    for zheight in sorted(orderedPresents.items(), reverse=True):
        presentsInCrossSection = list(orderedPresents[zheight])
        presentsInCrossSection.sort()
        update_current_presents(currentPresentsSet, zheight, presents, presentsInCrossSection)

        # calculate order term on the fly
        for i in range(len(presentsInCrossSection)):
            presentsSeenSoFar += 1
            orderTerm += math.fabs(presentsSeenSoFar - presentsInCrossSection[i])

    metric = 2 * max(orderedPresents.keys()) + orderTerm
    print('Metric = ' + str(metric))

    print('\nTotal clock time = ' + str(time.clock() - start))
