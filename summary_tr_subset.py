# This summary script summarizes the text using TextRank.
# It will append sentences until
# either there are more sentences than there are paragraphs
# or the length of the summary is 1/4 of the length of the text.

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

warnings.filterwarnings("ignore")

text_eng = ''
text_fre = ''
stopWordLang = dict()
stopWordLang['english'] = set(stopwords.words('english'))
stopWordLang['french'] = set(stopwords.words('french'))
sent_list = []
sent_score = defaultdict(int)

# Select operations, ppgs, and goals
oper_list = raw_input("List operations: ").split()
ppg_list = raw_input("List ppgs: ").split()
goal_list = raw_input("List goals: ").split()
po_list = raw_input("List problem objectives: ").split()
output_list = raw_input("List outputs: ").split()

# Select report type: it has to be one of the five, and can only select one
report_list = ['Summary Protetion Assessment', 'Operations Plan Document', 'Year-End Report', 'Mid Year Report', 'Operational Highlights Report']
report_type = ""
while report_type not in report_list:
    report_type = raw_input("Report type: ")
    
# Select year: has to be between 2010 and 2020
year = 0
while year < 2010 or year > 2020:
    year = int(raw_input("Year: "))


# oper_list = ['7VR', '7VC']
# ppg_list = ['LRZQ', 'LTFL', 'LP61']
# goal_list = ['EM']
# po_list = ['c70f5d80-a7cd-4d68-a085-aa04702c0fea', 'acb439ae-0d06-463c-b3c9-030f9bc889f8']
# output_list = []

# Makes mysql query string

condition_str = ""
oper_str = ""
ppg_str = ""
goal_str = ""
po_str = ""
output_str = ""

if oper_list:
    oper_str ="(" + " OR ".join(["operation_id = " + "'" + oper + "'" for oper in oper_list]) + ")"

if ppg_list:
    ppg_str ="(" + " OR ".join(["ppg_id = " + "'" + ppg + "'" for ppg in ppg_list]) + ")"
            
if goal_list:
    goal_str ="(" + " OR ".join(["goal_id = " + "'" + goal + "'" for goal in goal_list]) + ")"

if po_list:
    po_str = "(" + " OR ".join(["problem_objective_id = " + "'" + po + "'" for po in po_list]) + ")"
    
if output_list:
    output_str = "(" + " OR ".join(["output_id = " + "'" + output + "'" for output in output_list]) + ")"

conditions = [oper_str, ppg_str, goal_str, po_str, output_str]

condition_str = " WHERE " + "(report_type = " + "'" + report_type + "'" + ") AND (year = " + str(year) + ")"

if oper_list or ppg_list or goal_list or po_list or output_str:
    s = " AND ".join([x for x in conditions if x])
    condition_str = " AND ".join([condition_str, s])

database = mysql.connector.connect(user = 'root', database = 'projects_development', host = '127.0.0.1')
cursor = database.cursor()

# detects which language the tokens are in
def detectLanguages(tokens):
    words = [word.lower() for word in tokens]
    words_set = set(words)
    eng_num = stopWordLang['english'].intersection(words_set)
    fre_num = stopWordLang['french'].intersection(words_set)
    if len(eng_num) > len(fre_num):
        return 'english'
    else:
        return 'french'

# deletes punctuations from tokens
def deletePunc(tokens):
    return [token for token in tokens if token not in set(string.punctuation)]

# intersection score of two sentences
def inter_score(sent1, sent2):
    tok1 = nltk.word_tokenize(sent1)
    tok2 = nltk.word_tokenize(sent2)
    tok1 = deletePunc(tok1)
    tok2 = deletePunc(tok2)
    return float(2 * len([x for x in tok1 if x in tok2]))/(len(tok1) + len(tok2))

# checks if a sentence is valid
def checkValidSent(sent):
    tok = nltk.word_tokenize(sent)
    tok = deletePunc(tok)
    return tok != []
    
# builds a graph of sentences
def buildGraph(sentList):
    gr = nx.Graph()
    gr.add_nodes_from(sentList)

    for sent1 in sentList:
        for sent2 in sentList:
            if sent1 != sent2:
                gr.add_edge(sent1, sent2, weight=inter_score(sent1, sent2))
    
    return gr

query_str = "SELECT usertxt FROM narratives" + condition_str

cursor.execute(query_str)

# reads texts
for usertxt in cursor:
    if usertxt[0] is not None:
        text = usertxt[0]
        text = text.replace('\\\\n', '\n')
        text = text.replace('\\n', '\n')
        if detectLanguages(nltk.word_tokenize(text)) == "english":
            text_eng = '\n'.join([text_eng, text])
        else: text_fre = '\n'.join([text_fre, text])

database.close()

# divides given text to sentences
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

print summary.encode('utf-8')