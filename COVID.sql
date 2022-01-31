-- •	Tabella anagrafica delle regioni con codice regione-descrizione partendo dal file 1
create table TRAINING.GP_C19_CORE_REG_AN
(
regione_cod number(38),
regione_ds varchar(200),
constraint dwh_reg_pk primary key (regione_cod)
);

-- popolazione
INSERT INTO TRAINING.GP_C19_CORE_REG_AN (regione_cod, regione_ds)
SELECT DISTINCT CODICE_REGIONE, DENOMINAZIONE_REGIONE
FROM TRAINING.ADP_CVD19_STG_POP

select * from TRAINING.GP_C19_CORE_REG_AN

-- •	Tabella anagrafica dati istat regioni con le informazioni relative a divisione in fasce di età

create table TRAINING.GP_C19_CORE_ISTAT_AN
(
regione_cod number(38) constraint fk_regione_cod REFERENCES GP_C19_CORE_REG_AN (regione_cod),
regione_eta varchar(5),
tot_m integer,
tot_f integer,
tot integer,
constraint dwh_reg2_pk primary key (regione_cod, regione_eta)
);


INSERT INTO  TRAINING.GP_C19_CORE_ISTAT_AN (regione_cod, regione_eta, tot_m, tot_f, tot)
SELECT DISTINCT CODICE_REGIONE, RANGE_ETA, TOTALE_GENERE_MASCHILE, TOTALE_GENERE_FEMMINILE, TOTALE_GENERALE 
FROM TRAINING.ADP_CVD19_STG_POP

select * from TRAINING.GP_C19_CORE_ISTAT_AN

-- •	Tabella dei fatti con i vaccini consegnati per anno-mese, con dettaglio fornitore e regione

create SEQUENCE GP_cons_id
START WITH 1
MAXVALUE 99999999999999999999
MINVALUE 1
NOCYCLE
CACHE 20
NOORDER
NOKEEP
GLOBAL;

create table TRAINING.GP_C19_CORE_CON_FT
(
cons_id integer default GP_cons_id.nextval,
regione_cod number(38) constraint fk2_regione_cod REFERENCES GP_C19_CORE_REG_AN (regione_cod),
fornitore_cons varchar (100), 
numero_dosi integer,
anno_cons varchar(50),
mese_cons varchar(50),
data_cons date,
constraint dwh_con2_pk primary key (cons_id)
);


INSERT INTO TRAINING.GP_C19_CORE_CON_FT (regione_cod, fornitore_cons, numero_dosi, anno_cons, mese_cons, data_cons)
SELECT REGIONE_COD, FORNITORE, NUMERO_DOSI ,EXTRACT (YEAR FROM DATA_CONSEGNA), EXTRACT (MONTH FROM DATA_CONSEGNA), DATA_CONSEGNA 
FROM
TRAINING.GP_C19_CORE_REG_AN
JOIN 
TRAINING.ADP_CVD19_STG_CON ON TRAINING.GP_C19_CORE_REG_AN.regione_cod = TRAINING.ADP_CVD19_STG_CON.CODICE_REGIONE_ISTAT


select distinct codice_regione, DENOMINAZIONE_REGIONE from TRAINING.ADP_CVD19_STG_POP

select distinct codice_regione_ISTAT, NOME_AREA from TRAINING.ADP_CVD19_STG_CON

select distinct codice_regione_ISTAT, NOME_AREA from TRAINING.ADP_CVD19_STG_SOM



--  Tabella dei fatti con i vaccini somministrati per anno-mese per prima dose e seconda dose, 
-- con dettaglio sul genere dei vaccinati, fornitore e regione

create SEQUENCE GP_somm_id
START WITH 1
MAXVALUE 99999999999999999999
MINVALUE 1
NOCYCLE
CACHE 20
NOORDER
NOKEEP
GLOBAL;


create table TRAINING.GP_C19_CORE_SOM_FT
(
somm_id integer default GP_somm_id.nextval,
regione_cod number(38) constraint fk3_regione_cod REFERENCES GP_C19_CORE_REG_AN (regione_cod),
fornitore_somm varchar (100), 
prima_dose integer,
seconda_dose integer,
dosi_m integer,
dosi_f integer,
anno_somm varchar(50),
mese_somm varchar(50),
data_somm date,
constraint dwh_som2_pk primary key (somm_id)
);


INSERT INTO TRAINING.GP_C19_CORE_SOM_FT (regione_cod, fornitore_somm, prima_dose, seconda_dose, dosi_m, dosi_f, anno_somm, mese_somm, data_somm)
SELECT REGIONE_COD, FORNITORE, prima_dose, seconda_dose, SESSO_MASCHILE, SESSO_FEMMINILE, EXTRACT (YEAR FROM DATA_SOMMINISTRAZIONE), EXTRACT (MONTH FROM DATA_SOMMINISTRAZIONE), DATA_SOMMINISTRAZIONE
FROM
TRAINING.GP_C19_CORE_REG_AN
JOIN
TRAINING.ADP_CVD19_STG_SOM ON TRAINING.GP_C19_CORE_REG_AN.regione_cod = TRAINING.ADP_CVD19_STG_SOM.CODICE_REGIONE_ISTAT


select * from TRAINING.GP_C19_CORE_SOM_FT


-- 1) La percentuale delle persone vaccinate per regione

SELECT REGIONE_DS, ROUND(((SUM(PRIMA_DOSE)+ SUM(SECONDA_DOSE))/SUM(TOT))*100,4) PERCENTUALE_VACCINATI FROM 
TRAINING.GP_C19_CORE_SOM_FT SOM  
JOIN 
TRAINING.GP_C19_CORE_ISTAT_AN ISTAT ON SOM.REGIONE_COD = ISTAT.REGIONE_COD
JOIN 
TRAINING.GP_C19_CORE_REG_AN REG ON SOM.REGIONE_COD = REG.REGIONE_COD
GROUP BY REGIONE_DS


-- 2) La percentuale delle persone vaccinate per regione per sesso

SELECT REGIONE_DS, ROUND((SUM(DOSI_M)/SUM(TOT))*100,4) PERCENTUALE_M, ROUND((SUM(DOSI_F)/SUM(TOT))*100,4) PERCENTUALE_F FROM 
TRAINING.GP_C19_CORE_SOM_FT SOM  
JOIN 
TRAINING.GP_C19_CORE_ISTAT_AN ISTAT ON SOM.REGIONE_COD = ISTAT.REGIONE_COD
JOIN 
TRAINING.GP_C19_CORE_REG_AN REG ON SOM.REGIONE_COD = REG.REGIONE_COD
GROUP BY REGIONE_DS

--3) Estrapola quante dosi sono state consegnate ad ogni regione per marca di vaccino

SELECT REGIONE_DS, FORNITORE_CONS, SUM(NUMERO_DOSI) TOTALE_DOSI FROM 
TRAINING.GP_C19_CORE_CON_FT CON  
JOIN 
TRAINING.GP_C19_CORE_REG_AN REG ON CON.REGIONE_COD = REG.REGIONE_COD
GROUP BY REGIONE_DS, FORNITORE_CONS
ORDER BY 1 ASC

--4) Determina qual è la regione che ha ricevuto un numero maggiore di vaccini in assoluto

SELECT REGIONE_DS, SUM(NUMERO_DOSI) TOTALE_DOSI FROM 
TRAINING.GP_C19_CORE_CON_FT CON  
JOIN 
TRAINING.GP_C19_CORE_REG_AN REG ON CON.REGIONE_COD = REG.REGIONE_COD
GROUP BY REGIONE_DS
ORDER BY 2 DESC
FETCH FIRST 1 ROWS ONLY

-- 5) Determina qual è la regione che ha ricevuto il maggior numero di vaccini in proporzione alla numerosità della popolazione

SELECT REGIONE_DS, ROUND(SUM(NUMERO_DOSI)/SUM(TOT),4) PROPORZIONE_DOSI_POP FROM 
TRAINING.GP_C19_CORE_CON_FT CON  
JOIN 
TRAINING.GP_C19_CORE_ISTAT_AN ISTAT ON CON.REGIONE_COD = ISTAT.REGIONE_COD
JOIN 
TRAINING.GP_C19_CORE_REG_AN REG ON CON.REGIONE_COD = REG.REGIONE_COD
GROUP BY REGIONE_DS
ORDER BY 2 DESC
FETCH FIRST 1 ROWS ONLY

-- 6) Determina qual è la regione che ha ricevuto il minor numero di vaccini in proporzione alla numerosità della popolazione

SELECT REGIONE_DS, ROUND(SUM(NUMERO_DOSI)/SUM(TOT),4) PROPORZIONE_DOSI_POP FROM 
TRAINING.GP_C19_CORE_CON_FT CON  
JOIN 
TRAINING.GP_C19_CORE_ISTAT_AN ISTAT ON CON.REGIONE_COD = ISTAT.REGIONE_COD
JOIN 
TRAINING.GP_C19_CORE_REG_AN REG ON CON.REGIONE_COD = REG.REGIONE_COD
GROUP BY REGIONE_DS
ORDER BY 2 ASC
FETCH FIRST 1 ROWS ONLY

-- 7) Calcola quante dosi ancora disponibili ha ogni singola regione

SELECT A.REGIONE_DS, TOTALE_DOSI-SOMMINISTRATE RIMANENTI FROM
-- DOSI RICEVUTE 
(SELECT REGIONE_DS, SUM(NUMERO_DOSI) TOTALE_DOSI FROM 
TRAINING.GP_C19_CORE_CON_FT CON  
JOIN 
TRAINING.GP_C19_CORE_REG_AN REG ON CON.REGIONE_COD = REG.REGIONE_COD
GROUP BY REGIONE_DS) A 
JOIN 
-- DOSI SOMMINISTRATE 
(SELECT REGIONE_DS, SUM(PRIMA_DOSE)+ SUM(SECONDA_DOSE) SOMMINISTRATE FROM 
TRAINING.GP_C19_CORE_SOM_FT SOM 
JOIN 
TRAINING.GP_C19_CORE_REG_AN REG ON SOM.REGIONE_COD = REG.REGIONE_COD
GROUP BY REGIONE_DS) B ON A.REGIONE_DS = B.REGIONE_DS 


-- 8) Considerando che la somministrazione dei vaccini è cominciata il 27/12/2020 determina qual è stata la 
-- media dei vaccini eseguiti in un giorno e la data di completamento prevista in base al numero di persone da vaccinare
-- basandosi su questo valore medio


SELECT A.REGIONE_DS, DATA_CONS, RICEVUTE, DATA_SOMM, SOMMINISTRATE FROM 
--DOSI RICEVUTE OGNI GIORNO 
(SELECT REGIONE_DS, DATA_CONS, SUM(NUMERO_DOSI)RICEVUTE FROM 
TRAINING.GP_C19_CORE_CON_FT CON  
JOIN 
TRAINING.GP_C19_CORE_REG_AN REG ON CON.REGIONE_COD = REG.REGIONE_COD
GROUP BY  REGIONE_DS, DATA_CONS) A 
JOIN 


--DOSI SOMMINISTRATE OGNI GIORNO 
SELECT AVG(SOMMINISTRATE) FROM 
(SELECT DATA_SOMM, SUM(PRIMA_DOSE)+SUM(SECONDA_DOSE) SOMMINISTRATE FROM 
TRAINING.GP_C19_CORE_SOM_FT SOM 
JOIN 
TRAINING.GP_C19_CORE_REG_AN REG ON SOM.REGIONE_COD = REG.REGIONE_COD
GROUP BY DATA_SOMM) A
