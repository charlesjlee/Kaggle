#%% Connect to MongoDB
import parse_sessions, pymongo
from pymongo import MongoClient
client = MongoClient('localhost', 27017)
db = client.testMongo
sessions = db.sessions

#%% Initalize generator
f = open('../data/test', 'r')
sp = parse_sessions.parse_sessions(f)

#%% Insert into database
sessions.insert(sp)

#%% Create indices
#.....