__author__ = 'Miroslaw Horbal'
__email__ = 'miroslaw@gmail.com'
__date__ = 'December 1, 2013'
__website__ = 'http://pastebin.com/gaPnVwNH#'
 
# Notes
# Dec 2, 2013: Updated the parser to fix the bug noticed by kinnskogr
#              on the kaggle forums. The fix involves directly assigning
#              clicks to query objects
# Dec 22, 2013: Updated the parser to include an extra yield statement at
#               the end of the end of the main parser for-loop
#               Thanks to kaggle user's Shan and Sebastian Butterweck for finding the bug!
 
def parse_sessions(file):
    """
   A generator that yields session objects from file
   
   Each session object has the form:
       { SessionID: int,
         Day: int,
         USERID: int,
         Query: [{ TimePassed: int,
                  SERPID: int,
                  QueryID: int,
                  ListOfTerms: [TermID_1, ...],
                  Clicks: [{ TimePassed: int, SERPID: int, URLID: int }, ...],
                  URL_DOMAIN: [(URLID_1, DomainID_1), ...] } }, ...]
   """
    s = None
    for line in file:
        sline = line.strip().split('\t')
       
        if len(sline) == 4 and s is not None:
            yield s
       
        if len(sline) == 4:
            sid, tor, day, uid = sline
            s = create_session(sid, day, uid)
        elif len(sline) == 16:
            sid, tp, tor, serpid, quid, lot = sline[:6]
            lou = sline[6:]
            s['Query'].append(create_query(tp, serpid, quid, lot, lou))
        elif len(sline) == 5:
            sid, tp, tor, serpid, urlid = sline
            s['Query'][-1]['Clicks'].append(create_click(tp, serpid, urlid))
    yield s
 
def create_session(session_id, day, user_id):
    return { 'SessionID': int(session_id),
              'Day': int(day),
              'USERID': int(user_id),
              'Query': [] }
 
def create_query(time_passed, serp_id, query_id, list_of_terms, url_list):
    return { 'TimePassed': int(time_passed),
              'SERPID': int(serp_id),
              'QueryID': int(query_id),
              'Clicks': [],
              'ListOfTerms': [int(t) for t in list_of_terms.split(',')],
              'URL_DOMAIN': [tuple(int(ui) for ui in u.split(','))
                                for u in url_list] }
 
def create_click(time_passed, serp_id, url_id):
    return { 'TimePassed': int(time_passed),
              'SERPID': int(serp_id),
              'URLID': int(url_id) }