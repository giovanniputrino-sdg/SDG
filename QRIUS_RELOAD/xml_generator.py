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
            file = reading_txt(parmsdir,'init_params.txt')
            doc.write('<crawl-urls>''\n')
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
                f = {'key-val':df.iloc[row].kdoc}
                for line in file:
                    doc.write(line.replace('<TODAY>',str(int(time.time())))
                        .replace('<ENCODE_URL>',a+str(urllib.parse.urlencode(f)))
                            )
                doc.write('\n')
                for col in list(df.columns):
                    if not pd.isnull(df.iloc[row][col]):
                        doc.write("<content name=\""+col+"\">")
                        doc.write("<![CDATA["+str(df.iloc[row][col])+"]]>")
                        doc.write("</content>"'\n')
                doc.write('</document>''\n')
                doc.write('</crawl-data>''\n')
                doc.write('</crawl-url>''\n')
                print(str(n))
                n+=1
            doc.write('</crawl-urls>''\n')
            doc.close()
            file_name = query_file.split('.')[0]
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
        print('connesso')
        cursor = conn.cursor()
        cursor.execute(query)
        # save all results into a pandas DF
        columns = [desc[0] for desc in cursor.description]
        results = cursor.fetchall()
        df = pd.DataFrame(results, columns=columns)
        print('dataframe creato')
        # Close connection
        cursor.close()
        conn.close()
        write_xml(query_file,parmsdir,df,server,env,staging,quantity=quantity)
    else:
        return("To be implemented")
    


def excute_xml(xml_file,env,num_doc,file_name,staging=True,recalc=False):
    if recalc:
        xmlstr = read_file(f'documents\\old\\{file_name}\\',xml_file)
    else:
        xmlstr = read_file('documents\\',xml_file)
    wd = os.getcwd()+'\\'
    parmsdir = wd + 'parms\\'
    if env == 'dev':
        url = 'https://ix1eipwexdev.am.lilly.com/vivisimo/cgi-bin/velocity.exe'
        file = 'api_dev.json'
    elif env == 'qa':
        url = 'https://ix1eipwexqar.am.lilly.com/vivisimo/cgi-bin/velocity.exe'
        file = 'api_qa.json'
    elif env == 'ps1':
        url = 'https://ix1eipwexps1.am.lilly.com/vivisimo/cgi-bin/velocity.exe'
        file = 'api_prd.json'
    else:
        url = 'https://ix1eipwexprd.am.lilly.com/vivisimo/cgi-bin/velocity.exe'
        file = 'api_prd.json'
    params = reading_cnf(parmsdir,file)
    params['collection'] = file_name
    if staging:
        params['subcollection'] = 'staging'
    f = {'crawl-nodes':xmlstr}
    payload = str(urllib.parse.urlencode(f))
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
        }
    response = requests.request("POST",url, params=params, headers = headers, data = payload)
    if response:
        num = response.text.find('key-val')
        if response.text.replace(' ','').find('error') == -1:
            if exists('logs\\ok\\'+datetime.today().strftime('%Y-%m-%d %H').replace('-','_').replace(' ','_').replace(':','_')+'.txt'):
                with open('logs\\ok\\'+datetime.today().strftime('%Y-%m-%d %H').replace('-','_').replace(' ','_').replace(':','_')+'.txt','a',encoding="utf-8") as log_ok:
                    log_ok.write(response.text[num:].split(' ')[0]+f'{num_doc}')
            else:
                with open('logs\\ok\\'+datetime.today().strftime('%Y-%m-%d %H').replace('-','_').replace(' ','_').replace(':','_')+'.txt','w+',encoding="utf-8") as log_ok:
                    log_ok.write(response.text[num:].split(' ')[0]+f'{num_doc}')
        else:
            if exists('logs\\failed\\'+datetime.today().strftime('%Y-%m-%d %H').replace('-','_').replace(' ','_').replace(':','_')+'.txt'):
                with open('logs\\failed\\'+datetime.today().strftime('%Y-%m-%d %H').replace('-','_').replace(' ','_').replace(':','_')+'.txt','a',encoding="utf-8") as log_f:
                    if response.text[num:].split(' ')[1]=='':
                        log_f.write('\n')
                        log_f.write(response.text[num:].split(' ')[0]+' / '+'cause: '+response.text[num:].split(' ')[2].split('"')[1]+f'{num_doc}')
                    else:
                        log_f.write('\n')
                        log_f.write(response.text[num:].split(' ')[0]+' / '+'cause: '+response.text[num:].split(' ')[1].split('"')[1]+f'{num_doc}')
            else:
                with open('logs\\failed\\'+datetime.today().strftime('%Y-%m-%d %H').replace('-','_').replace(' ','_').replace(':','_')+'.txt','w+',encoding="utf-8") as log_f:
                    if response.text[num:].split(' ')[1]=='':
                        log_f.write(response.text[num:].split(' ')[0]+' / '+'cause: '+response.text[num:].split(' ')[2].split('"')[1]+f'{num_doc}')
                    else:
                        log_f.write(response.text[num:].split(' ')[0]+' / '+'cause: '+response.text[num:].split(' ')[1].split('"')[1]+f'{num_doc}')
        return ('Success!')
    else:
        return('An error has occurred.')

