#%% Initalize generator
import gzip, parse_sessions, sqlite3 as sqlite
#f = gzip.open('../data/test.gz', 'rb')
f = open('../data/test', 'r')
sp = parse_sessions.parse_sessions(f)

#%% Create database
dbconn = sqlite.connect('../Data/testData.sqlite')
dbconn.execute('create table Queries(User, Query)')
dbconn.execute('create table Terms(Query, Term)')
dbconn.execute('create table Clicks(Query, URL)')
dbconn.execute('create table URL(Query, URL, Rank integer)')
dbconn.commit()

#%% Insert into database
for session in sp:
    for query in session['Query']:
        i = 1
        dbconn.execute("""insert into Queries(User, Query)
                          values (?, ?)""", (session['USERID'],
                                                  query['QueryID']))
                                                  
        for term in query['ListOfTerms']:
            dbconn.execute("""insert into Terms(Query, Term)
                              values (?, ?)""", (query['QueryID'],
                                                 term))
        for click in query['Clicks']:
            dbconn.execute("""insert into Clicks(Query, URL)
                              values (?, ?)""", (query['QueryID'],
                                                 click['URLID']))
        for URL in query['URL_DOMAIN']:
            dbconn.execute("""insert into URL(Query, URL, Rank)
                              values (?, ?, ?)""", (query['QueryID'],
                                                    URL[0],
                                                    i))
            i += 1
            
dbconn.commit()
dbconn.close()

#%% Create indices
#.....