import nzpy
import pandas as pd
import os
import time
import urllib
import json
import requests
import xml.etree.ElementTree as ET
from datetime import datetime
import jaydebeapi
from os.path import exists
import numpy as np
from os import listdir
from os.path import isfile, join

# file_exists = exists('C:\\Users\\putrino_giovanni@network.lilly.com\\OneDrive - Eli Lilly and Company\\Documents\\Python\\QRIUS_RELOAD\\logs\\ok\\'+datetime.today().strftime('%Y-%m-%d %H').replace('-','_').replace(' ','_').replace(':','_')+'.txt')

# 'C:\\Users\\putrino_giovanni@network.lilly.com\\OneDrive - Eli Lilly and Company\\Documents\\Python\\QRIUS_RELOAD\\logs\\ok\\'+datetime.today().strftime('%Y-%m-%d %H').replace('-','_').replace(' ','_').replace(':','_')


def read_file(dir,file):
    with open(dir + file ,'r',encoding = 'utf-8') as file:
        query = file.read().replace('\n', ' ')
    return query


def reading_txt(dir,input_file):
    file = open(dir + input_file,encoding = 'utf-8')
    file = list(file)
    return (file)

def reading_cnf(dir,file):
    json_file = open(dir + file)
    cnf = json.load(json_file)
    json_file.close()
    return cnf


def redshift_connection(parameter_file):
    """
    Parameters file is a json file defined as:

    {
        user:"your_user",
        password:"your_pwd",
        host:"your_host",
        port:your_port,
        database:"yoyr_database"

    }
    """
    parameter_file['jdbc_url'] = 'jdbc:redshift://{host}:{port}/{database};connectTimeout=1000;socketTimeout=1000'.format(**parameter_file)
    conn = jaydebeapi.connect(
        "com.amazon.redshift.jdbc42.Driver",
        parameter_file['jdbc_url'],
        [parameter_file['user'], parameter_file['password']],
        parameter_file['jar_file']
        )
    return conn 



def netezza_connection(parameter_file):
    """
    Parameters file is a json file defined as:

    {
        user:"your_user",
        password:"your_pwd",
        host:"your_host",
        port:your_port,
        database:"yoyr_database"

    }
    """
    conn = nzpy.connect(user=parameter_file['user'], password=parameter_file['password'], host=parameter_file['host'], port=parameter_file['port'], database=parameter_file['database'])
    return conn 


def write_xml(query_file,parmsdir,df,server,env,staging,quantity=200):
    divided_df = np.array_split(df, quantity)
    num_doc = 0 
    for group in range(len(divided_df)):
        df = divided_df[group]
        with open('documents\\'+ query_file.split('.')[0]+f'_{num_doc}.xml', 'w+',encoding="utf-8") as doc:
            if server == 'Redshift':
                if env == 'dev':
                    a = 'redshift://edb-analytic-consumer-dev.cnjndgzifrh0.us-east-2.redshift.amazonaws.com:5439/mq_dia_gmdf/?'
                elif env == 'qa':
                    a = 'redshift://edb-analytic-consumer-qa.cjlwfm8otbqm.us-east-2.redshift.amazonaws.com:5439/mq_dia_gmdf/?'
                elif env == 'prd':
                    a = 'redshift://edb-analytic-consumer-prod.carpdwnmaayt.us-east-2.redshift.amazonaws.com:5439/mq_dia_gmdf/?'
                elif env == 'ps1':
                    a = 'redshift://edb-analytic-consumer-prod.carpdwnmaayt.us-east-2.redshift.amazonaws.com:5439/mq_dia_gmdf/?'
                else:
                    return ('Define a correct environment')
            elif server == 'Netezza':
                a = 'netezza://mqpdap01.am.lilly.com:5480/GMDM/?'
            else:
                return ('Server to be implemented')
            n=1
            for row in range(len(df)):
                f = {'key-val':df.iloc[row].kdocdelete}
                doc.write('<crawl-delete\n')
                doc.write(f"""url=\"{a+str(urllib.parse.urlencode(f))}\">\n""")
                doc.write('</crawl-delete>\n')
                print(str(n))
                n+=1
            doc.close()
            file_name = query_file.split('.')[0].replace('_delete','')
            excute_xml(f'{file_name}_{num_doc}.xml',env,num_doc,file_name,staging=staging)
        num_doc+=1
    end = (datetime.now() ).strftime('%Y-%m-%d %H:%M:%S')
    print(f'FINISH: {end}')
    return ("total file created")


def recalculation(collection,env,staging=True):
    start = (datetime.now() ).strftime('%Y-%m-%d %H:%M:%S')
    print(f'START: {start}')
    onlyfiles = [f for f in listdir(f'documents\\old\\{collection}') if isfile(join(f'documents\\old\\{collection}', f))]
    num_doc = 0 
    for file in onlyfiles:
        print(f'Executing: {num_doc}')
        excute_xml(file,env,num_doc,collection,staging,recalc=True)
        num_doc += 1
    end = (datetime.now() ).strftime('%Y-%m-%d %H:%M:%S')
    print(f'FINISH: {end}')
     



def xml_generator(query_file,server='Netezza', parameter_file= 'parameters_netezza.json', env = 'dev',staging=True,quantity=200):
    """
    Pass your sql query file name. 
    The sql file must be saved in the folder query in the same repository of the py file.
    The params file is a json file in which 
    """
    start = (datetime.now() ).strftime('%Y-%m-%d %H:%M:%S')
    print(f'START: {start}')
    wd = os.getcwd()+'\\'
    querydir = wd + 'query\\'
    parmsdir = wd + 'parms\\'
    query = read_file(querydir,query_file)
    parms = reading_cnf(parmsdir,parameter_file)
    if server == 'Netezza':
        conn = netezza_connection(parms)
        df = pd.read_sql(f"{query}", conn)
        conn.close()
        write_xml(query_file,parmsdir,df,server,env,staging,quantity=quantity)
    elif server == 'Redshift':
        conn = redshift_connection(parms)
        cursor = conn.cursor()
        cursor.execute(query)
        # save all results into a pandas DF
        columns = [desc[0] for desc in cursor.description]
        results = cursor.fetchall()
        df = pd.DataFrame(results, columns=columns)
        # Close connection
        cursor.close()
        conn.close()
        write_xml(query_file,parmsdir,df,server,env,staging,quantity=quantity)
    else:
        return("To be implemented")
    


def excute_xml(xml_file,env,num_doc,file_name,staging=True,recalc=False):
    xmlstr = read_file('documents\\',xml_file).replace('crawl-delete ','crawl-delete%0A')
    wd = os.getcwd()+'\\'
    parmsdir = wd + 'parms\\'
    if env == 'dev':
        url = 'https://ix1eipwexdev.am.lilly.com/vivisimo/cgi-bin/velocity.exe'
        file = 'api_dev_delete.json'
    elif env == 'qa':
        url = 'https://ix1eipwexqar.am.lilly.com/vivisimo/cgi-bin/velocity.exe'
        file = 'api_qa_delete.json'
    elif env == 'ps1':
        url = 'https://ix1eipwexps1.am.lilly.com/vivisimo/cgi-bin/velocity.exe'
        file = 'api_prd_delete.json'
    else:
        url = 'https://ix1eipwexprd.am.lilly.com/vivisimo/cgi-bin/velocity.exe'
        file = 'api_prd_delete.json'
    params = reading_cnf(parmsdir,file)
    params['collection'] = file_name
    if staging:
        params['subcollection'] = 'staging'
    else:
        params['subcollection'] = 'live'
    params['crawl-deletes']="resume-and-idle"
    params['exception-on-failure']="false"
    params['crawl-type']="resume"
    f = {'crawl-deletes':xmlstr}
    payload = str(urllib.parse.urlencode(f))
    payload = xmlstr
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
        }
    response = requests.request("POST",url, params=params, headers = headers, data = payload)
    if response:
        if exists('logs\\delete\\'+datetime.today().strftime('%Y-%m-%d %H').replace('-','_').replace(' ','_').replace(':','_')+'.txt'):
            with open('logs\\delete\\'+datetime.today().strftime('%Y-%m-%d %H').replace('-','_').replace(' ','_').replace(':','_')+'.txt','a',encoding="utf-8") as log_ok:
                log_ok.write(response.text)
        else:
            with open('logs\\delete\\'+datetime.today().strftime('%Y-%m-%d %H').replace('-','_').replace(' ','_').replace(':','_')+'.txt','w+',encoding="utf-8") as log_ok:
                log_ok.write(response.text)
    else:
        print(f"API request failed with status code {response.status_code}")
        return('An error has occurred.')

