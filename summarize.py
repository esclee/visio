# Module: summarize.py
# Usage: python summarize.py [token] -d [database yml] -r [redis yml]
# ---------------------------------------------------------------------------
# It takes the narrative texts that satisfy the query and summarizes
# the text into a summary that is 1/4 of the length of the original text
# or has no more sentences than the number of paragraphs in the original text.
# It summarizes the French portion and the English portion of the text
# separately.

import nltk
import csv
from collections import *
from nltk.corpus import stopwords
import string
import networkx as nx
import pydot
import warnings
import mysql.connector
import random
import yaml
import redis
import sys
import argparse
import json

warnings.filterwarnings("ignore")

text_eng = ''
text_fre = ''
stopWordLang = dict()
stopWordLang['english'] = set(stopwords.words('english'))
stopWordLang['french'] = set(stopwords.words('french'))
sent_list = []
sent_score = defaultdict(int)

# Method: detectLanguages
# Usage: if detectLanguages(tokens) == 'english': ...
# ----------------------------------------------------
# It takes a tokenized text and determines if the text is
# in French or English.

def detectLanguages(tokens):
    words = [word.lower() for word in tokens]
    words_set = set(words)
    eng_num = stopWordLang['english'].intersection(words_set)
    fre_num = stopWordLang['french'].intersection(words_set)
    if len(eng_num) > len(fre_num):
        return 'english'
    else:
        return 'french'
        
# Method: deletePunc
# Usage: tokens = deletePunc(tokens)
# ---------------------------------------------------
# It takes a tokenized text and returns the text with all
# punctuations stripped.

def deletePunc(tokens):
    return [token for token in tokens if token not in set(string.punctuation)]
    
# Method: inter_score
# Usage: score = inter_score(sent1, sent2)
# ---------------------------------------------------
# It takes two sentences and returns the intersection
# score of the sentences.
    
def inter_score(sent1, sent2):
    tok1 = nltk.word_tokenize(sent1)
    tok2 = nltk.word_tokenize(sent2)
    tok1 = deletePunc(tok1)
    tok2 = deletePunc(tok2)
    return float(2 * len([x for x in tok1 if x in tok2]))/(len(tok1) + len(tok2))
    
# Method: checkValidSent
# Usage: if checkValidSent(sent)
# --------------------------------------
# It takes a sentence and determines if
# the sentence has non-punctuation tokens
# in it.
    
def checkValidSent(sent):
    tok = nltk.word_tokenize(sent)
    tok = deletePunc(tok)
    return tok != []

# Method: buildGraph
# Usage: graph = buildGraph(sentList)
# -------------------------------------------
# It takes a list of sentences and builds a graph
# where each node is a sentence and the weight of an edge
# is the intersection score of its two endpoints.

def buildGraph(sentList):
    gr = nx.Graph()
    gr.add_nodes_from(sentList)

    for sent1 in sentList:
        for sent2 in sentList:
            if sent1 != sent2:
                gr.add_edge(sent1, sent2, weight=inter_score(sent1, sent2))
    
    return gr

# Method: make_query_string
# Usage: querySt = make_query_string()
# ----------------------------------------------
# With the lists of conditions, it makes the condition
# part of the SQL query string to be used.

def make_query_string():
    if oper_list:
        oper_str ="(" + " OR ".join(["operation_id = " + "'" + oper + "'" for oper in oper_list]) + ")"
    else: oper_str = ""

    if ppg_list:
        ppg_str ="(" + " OR ".join(["ppg_id = " + "'" + ppg + "'" for ppg in ppg_list]) + ")"
    else: ppg_str = ""
            
    if goal_list:
        goal_str ="(" + " OR ".join(["goal_id = " + "'" + goal + "'" for goal in goal_list]) + ")"
    else: goal_str = ""

    if po_list:
        po_str = "(" + " OR ".join(["problem_objective_id = " + "'" + po + "'" for po in po_list]) + ")"
    else: po_str = ""
    
    if output_list:
        output_str = "(" + " OR ".join(["output_id = " + "'" + output + "'" for output in output_list]) + ")"
    else: output_str = ""

    conditions = [oper_str, ppg_str, goal_str, po_str, output_str]

    condition_str = " WHERE " + "(report_type = " + "'" + report_type + "'" + ") AND (year = " + str(year) + ")"

    if oper_list or ppg_list or goal_list or po_list or output_str:
        s = " AND ".join([x for x in conditions if x])
        condition_str = " AND ".join([condition_str, s])
    return condition_str

# Method: query_database
# Usage: query_database(dbyml)
# -----------------------------------------------
# It takes the address of the yml file and queries
# the database to get the texts needed for the particular
# query.

def query_database(dbadd = 'config/database.yml'):
    global text_eng
    global text_fre
    
    condition_str = make_query_string()
    
    db = yaml.load(open(dbadd, 'rb'))['development']
    database = mysql.connector.connect(user = db['username'], database = db['database'], host = db['host'])
    cursor = database.cursor()
    
    query_str = "SELECT usertxt FROM narratives" + condition_str

    cursor.execute(query_str)
    for usertxt in cursor:
        if usertxt[0] is not None:
            text = usertxt[0]
            text = text.replace('\\\\n', '\n')
            text = text.replace('\\n', '\n')
            if detectLanguages(nltk.word_tokenize(text)) == "english":
                text_eng = '\n'.join([text_eng, text])
            else: text_fre = '\n'.join([text_fre, text])

    database.close()

# Method: return_summary
# Usage: summary = return_summary(text)
# ----------------------------------------------
# It takes a text and summarizes it using TextRank
# algorithm. If the text is too long (> 150 sentences),
# then it randomly picks 150 sentences before running TextRank.
    
def return_summary(text):
    sent_list = nltk.tokenize.sent_tokenize(text)

    # deletes sentences that are only made of punctuations
    sent_list = [sent for sent in sent_list if checkValidSent(sent)]

    # makes a list of paragraphs - used to count the number of paragraphs
    pg = text.splitlines(0)
    pg = [par for par in pg if par != '']

    baseline = len(text)

    # if tehre are too many sentences, this will pick 150 random sentences
    if len(sent_list) > 150:
        sent_list = random.sample(sent_list, 150)
        baseline = sum([len(sent) for sent in sent_list])

    # makes graph to use for pagerank
    text_graph = buildGraph(sent_list)

    sent_scores = nx.pagerank(text_graph, weight = 'weight')

    sent_sorted = sorted(sent_scores, key = sent_scores.get, reverse = True)
    summary = ""
    scount = 0
    # selects a number of the most salient sentences
    while sent_sorted:
        sent = sent_sorted.pop(0)
        scount += 1
        if 4 * (len(sent) + len(summary)) >= baseline:
            break
        if scount > len(pg): break
        summary += sent + ' '

    return summary

if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(description = 'Summarizer!')
    parser.add_argument('token', type = str, help = 'token for redis')
    parser.add_argument('-d', '--database', help= 'database yml file', required = True)
    parser.add_argument('-r', '--redis', help= 'redis yml file')
    args = parser.parse_args()
    
    if args.redis:
        # set redis up from server
        print "redis"
    else:
        r_server = redis.Redis()
    # json_str = r_server.get(token)
    json_str = '{"output_id": [], "ppg_id": ["LRZQ", "LTFL", "LP61"], "problem_objective_id": ["c70f5d80-a7cd-4d68-a085-aa04702c0fea", "acb439ae-0d06-463c-b3c9-030f9bc889f8"], "goal_id": ["EM"], "report_type": "Year-End Report", "year": 2013, "operation_id": ["7VR", "7VC"]}'
    list_dict = json.loads(json_str)
    
    oper_list = list_dict["operation_id"]
    ppg_list = list_dict["ppg_id"]
    goal_list = list_dict["goal_id"]
    po_list = list_dict["problem_objective_id"]
    output_list = list_dict["output_id"]
    report_type = list_dict["report_type"]
    year = list_dict["year"]
    
    query_database(args.database)
    
    print "Summary: "
    print return_summary(text_eng).encode('utf-8')
    
    print '\n'
    
    print "Text: "
    print text_eng.encode('utf-8')
    print return_summary(text_fre).encode('utf-8')