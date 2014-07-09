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

warnings.filterwarnings("ignore")

text_eng = ''
text_fre = ''
stopWordLang = dict()
stopWordLang['english'] = set(stopwords.words('english'))
stopWordLang['french'] = set(stopwords.words('french'))
sent_list = []
sent_score = defaultdict(int)

oper_list = ['7VR', '7VC']
ppg_list = ['LRZQ', 'LTFL', 'LP61']
goal_list = ['EM']
po_list = ['c70f5d80-a7cd-4d68-a085-aa04702c0fea', 'acb439ae-0d06-463c-b3c9-030f9bc889f8']
output_list = []
report_list = ['Summary Protetion Assessment', 'Operations Plan Document', 'Year-End Report', 'Mid Year Report', 'Operational Highlights Report']
report_type = ""
year = 0

def detectLanguages(tokens):
    words = [word.lower() for word in tokens]
    words_set = set(words)
    eng_num = stopWordLang['english'].intersection(words_set)
    fre_num = stopWordLang['french'].intersection(words_set)
    if len(eng_num) > len(fre_num):
        return 'english'
    else:
        return 'french'
        
def deletePunc(tokens):
    return [token for token in tokens if token not in set(string.punctuation)]
    
def inter_score(sent1, sent2):
    tok1 = nltk.word_tokenize(sent1)
    tok2 = nltk.word_tokenize(sent2)
    tok1 = deletePunc(tok1)
    tok2 = deletePunc(tok2)
    return float(2 * len([x for x in tok1 if x in tok2]))/(len(tok1) + len(tok2))
    
def checkValidSent(sent):
    tok = nltk.word_tokenize(sent)
    tok = deletePunc(tok)
    return tok != []

def buildGraph(sentList):
    gr = nx.Graph()
    gr.add_nodes_from(sentList)

    for sent1 in sentList:
        for sent2 in sentList:
            if sent1 != sent2:
                gr.add_edge(sent1, sent2, weight=inter_score(sent1, sent2))
    
    return gr

def set_oper_list(operlist):
    global oper_list
    oper_list = operlist

def set_ppg_list(ppglist):
    global ppg_list
    ppg_list = ppglist

def set_goal_list(goallist):
    global goal_list
    goal_list = goallist

def set_po_list(polist):
    global po_list
    po_list = polist

def set_output_list(outputlist):
    global output_list
    output_list = outputlist

def set_report_type(reporttype):
    global report_type
    if reporttype in report_list:
        report_type = reporttype
    else: print reporttype, " is invalid."

def set_year(givenyear):
    global year
    if givenyear >= 2010 and givenyear <= 2020:
        year = givenyear
    else: print givenyear, " is invalid."

def query_database():
    global text_eng
    global text_fre
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
    
    db = yaml.load(open('config/database.yml', 'rb'))['development']
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
    
def return_summary():
    sent_list = nltk.tokenize.sent_tokenize(text_eng)

    # deletes sentences that are only made of punctuations
    sent_list = [sent for sent in sent_list if checkValidSent(sent)]

    # makes a list of paragraphs - used to count the number of paragraphs
    pg = text_eng.splitlines(0)
    pg = [par for par in pg if par != '']

    baseline = len(text_eng)

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