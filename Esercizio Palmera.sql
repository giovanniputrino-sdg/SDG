-- *** SqlDbx Personal Edition ***
-- !!! Not licensed for commercial use beyound 90 days evaluation period !!!
-- For version limitations please check http://www.sqldbx.com/personal_edition.htm
-- Number of queries executed: 133, number of rows retrieved: 2112

-- 1) Qual è il totale della quantità fatturata per prodotto? 

SELECT P.P_Prod_Ds AS PRODOTTO, SUM(T_RF_Pezzi*RF2.T_RF_Prezzo) AS FATTURATO FROM PALM_Prodotto AS P
JOIN PALM_Righe_Fatture2 AS RF2
ON P.P_Prod_Cd = RF2.T_RF_CdProd
GROUP BY P.P_Prod_Ds

-- 2) Qual è il totale della quantità fatturata per prodotto il giorno 30/04/2003

SELECT P.P_Prod_Ds AS PRODOTTO, SUM(T_RF_Pezzi*RF2.T_RF_Prezzo) AS FATTURATO FROM PALM_Prodotto AS P
JOIN PALM_Righe_Fatture2 AS RF2 
ON P.P_Prod_Cd = RF2.T_RF_CdProd
WHERE DAY(RF2.T_RF_DataDoc) = '30' 
AND MONTH(RF2.T_RF_DataDoc) = '04' 
AND YEAR(RF2.T_RF_DataDoc) = '2003'
GROUP BY P.P_Prod_Ds

-- 3) Qual è il totale della quantità fatturata il giorno 03/06/2005 per il prodotto 33006?

SELECT P.P_Prod_Ds AS PRODOTTO, SUM(T_RF_Pezzi*RF2.T_RF_Prezzo) AS FATTURATO FROM PALM_Prodotto AS P
JOIN PALM_Righe_Fatture2 AS RF2 
ON P.P_Prod_Cd = RF2.T_RF_CdProd
WHERE DAY(RF2.T_RF_DataDoc) = '03' 
AND MONTH(RF2.T_RF_DataDoc) = '06' 
AND YEAR(RF2.T_RF_DataDoc) = '2005'
AND P.P_Prod_Cd = '33006'
GROUP BY P.P_Prod_Ds

-- 4) In quale anno ho venduto di più?

SELECT TOP 1 * FROM
(SELECT YEAR(RF2.T_RF_DataDoc) AS ANNO ,SUM(T_RF_Pezzi*RF2.T_RF_Prezzo) AS TOTALE FROM PALM_Righe_Fatture2 AS RF2
GROUP BY YEAR(RF2.T_RF_DataDoc)) A
ORDER BY 2 DESC


-- 5) Quale prodotto ho venduto di più nel 2004 ?

SELECT P_Prod_Ds PRODOTTO, N NUMERO_PEZZI FROM
(SELECT TOP 1 RF2.T_RF_CdProd, SUM(RF2.T_RF_Pezzi) N FROM PALM_Righe_Fatture2 RF2
WHERE YEAR( RF2.T_RF_DataDoc) =2004 
GROUP BY RF2.T_RF_CdProd, RF2.T_RF_Pezzi
ORDER BY 2 DESC) A
JOIN PALM_Prodotto P 
ON A.T_RF_CdProd = P.P_Prod_Cd

-- 6) Qual è il fatturato per linea?

SELECT P.P_Lin_Ds AS LINEA, SUM(T_RF_Pezzi*RF2.T_RF_Prezzo) AS FATTURATO FROM PALM_Prodotto AS P 
JOIN PALM_Righe_Fatture2 AS RF2 
ON P.P_Prod_Cd = RF2.T_RF_CdProd
GROUP BY P.P_Lin_Ds

-- 7) Qual è il fatturato per linea e categoria cliente di fatturazione

SELECT Z.P_Lin_Ds AS LINEA, Z.T_CF_CdCat AS Categoria_fatturazione, SUM(Z.T_RF_Pezzi*Z.T_RF_Prezzo) AS FATTURATO FROM 
(SELECT * FROM
(SELECT * FROM
(SELECT P.P_Lin_Ds, RF2.T_RF_NumFatt, RF2.T_RF_Pezzi, RF2.T_RF_Prezzo FROM PALM_Prodotto AS P
JOIN  PALM_Righe_Fatture2 AS RF2 
ON P.P_Prod_Cd = RF2.T_RF_CdProd) X
JOIN PALM_Testate_Fatture AS TF 
ON X.T_RF_NumFatt = TF.T_NF_NumFat) Y
JOIN PALM_Cliente_Fatturazione AS CF 
ON Y.T_NF_CdCliFat = CF.T_CF_CdCliFat) Z
GROUP BY Z.P_Lin_Ds, Z.T_CF_CdCat
ORDER BY 1 ASC


-- 8) Prezzo medio di linea 

SELECT P.P_Lin_Ds AS LINEA, AVG(RF2.T_RF_Prezzo) AS PREZZO_MEDIO FROM PALM_Prodotto AS P 
JOIN PALM_Righe_Fatture2 AS RF2 
ON P.P_Prod_Cd = RF2.T_RF_CdProd
GROUP BY P.P_Lin_Ds
ORDER BY 1 ASC 

-- 9) Totale quantità annuali per descrizione prodotto

SELECT P.P_Prod_Ds, YEAR(RF2.T_RF_DataDoc), SUM(RF2.T_RF_Pezzi) FROM PALM_Prodotto AS P
JOIN PALM_Righe_Fatture2 AS RF2 
ON P.P_Prod_Cd = RF2.T_RF_CdProd
GROUP BY P.P_Prod_Ds, YEAR(RF2.T_RF_DataDoc)
ORDER BY 1,2 ASC

-- 10) Totale quantità annuali per BRAND 

SELECT P.P_Brand_Ds, YEAR(RF2.T_RF_DataDoc), SUM(RF2.T_RF_Pezzi) FROM PALM_Prodotto AS P
JOIN PALM_Righe_Fatture2 AS RF2 
ON P.P_Prod_Cd = RF2.T_RF_CdProd
GROUP BY P.P_Brand_Ds, YEAR(RF2.T_RF_DataDoc)
ORDER BY 1,2 ASC

-- 11) Totale FATTURATO per NAZIONE in ordine decrescente di fatturato

SELECT Z.T_GEO_DsNaz AS NAZIONE , SUM(Z.T_RF_Pezzi*Z.T_RF_Prezzo) AS FATTURATO FROM
(SELECT * FROM
(SELECT * FROM
(SELECT RF2.T_RF_NumFatt, RF2.T_RF_Pezzi, RF2.T_RF_Prezzo FROM PALM_Prodotto P
JOIN PALM_Righe_Fatture2 RF2 
ON P.P_Prod_Cd = RF2.T_RF_CdProd) X 
JOIN PALM_Testate_Fatture TF
ON X.T_RF_NumFatt = TF.T_NF_NumFat) Y 
JOIN PALM_Geografia G
ON Y.T_NF_CdCliFat = G.T_GEO_CdCliDes) Z
GROUP BY Z.T_GEO_DsNaz
ORDER BY 2 DESC 

-- 12) Totale FATTURATO annuale per NAZIONE

SELECT Z.T_GEO_DsNaz AS NAZIONE, Z.ANNO, SUM(Z.T_RF_Pezzi*Z.T_RF_Prezzo) AS FATTURATO FROM
(SELECT * FROM
(SELECT *FROM
(SELECT RF2.T_RF_NumFatt, RF2.T_RF_Pezzi, RF2.T_RF_Prezzo, YEAR(RF2.T_RF_DataDoc) AS ANNO FROM PALM_Prodotto P
JOIN PALM_Righe_Fatture2 RF2 
ON P.P_Prod_Cd = RF2.T_RF_CdProd) X 
JOIN PALM_Testate_Fatture TF
ON X.T_RF_NumFatt = TF.T_NF_NumFat) Y 
JOIN PALM_Geografia G
ON Y.T_NF_CdCliFat = G.T_GEO_CdCliDes) Z
GROUP BY Z.T_GEO_DsNaz, Z.ANNO
ORDER BY 1, 2 ASC

-- 13) Totale FATTURATO annuale del BELGIO

SELECT Z.T_GEO_DsNaz AS NAZIONE, Z.ANNO, SUM(Z.T_RF_Pezzi*Z.T_RF_Prezzo) AS FATTURATO FROM
(SELECT * FROM
(SELECT *FROM
(SELECT RF2.T_RF_NumFatt, RF2.T_RF_Pezzi, RF2.T_RF_Prezzo, YEAR(RF2.T_RF_DataDoc) AS ANNO FROM PALM_Prodotto P
JOIN PALM_Righe_Fatture2 RF2 
ON P.P_Prod_Cd = RF2.T_RF_CdProd) X 
JOIN PALM_Testate_Fatture TF
ON X.T_RF_NumFatt = TF.T_NF_NumFat) Y 
JOIN PALM_Geografia G
ON Y.T_NF_CdCliFat = G.T_GEO_CdCliDes) Z
WHERE Z.T_GEO_DsNaz = 'BELGIO'
GROUP BY Z.T_GEO_DsNaz, Z.ANNO

-- 14) Totale FATTURATO annuale delle nazioni che iniziano per I e finiscono per A

SELECT Z.T_GEO_DsNaz AS NAZIONE, Z.ANNO, SUM(Z.T_RF_Pezzi*Z.T_RF_Prezzo) AS FATTURATO FROM
(SELECT * FROM
(SELECT *FROM
(SELECT RF2.T_RF_NumFatt, RF2.T_RF_Pezzi, RF2.T_RF_Prezzo, YEAR(RF2.T_RF_DataDoc) AS ANNO FROM PALM_Prodotto P
JOIN PALM_Righe_Fatture2 RF2 
ON P.P_Prod_Cd = RF2.T_RF_CdProd) X 
JOIN PALM_Testate_Fatture TF
ON X.T_RF_NumFatt = TF.T_NF_NumFat) Y 
JOIN PALM_Geografia G
ON Y.T_NF_CdCliFat = G.T_GEO_CdCliDes) Z
WHERE Z.T_GEO_DsNaz LIKE 'I%A'
GROUP BY Z.T_GEO_DsNaz, Z.ANNO

-- 15) Numero Fattura per cliente,agenzia, codice prodotti e pezzi acquistati

SELECT FATTURA,AGENZIA,T_CF_DsCliFat AS CLIENTE, T_RF_CdProd AS PRODOTTO,T_RF_Pezzi AS N_PEZZI FROM 
(SELECT CF.T_CF_CdCliFat AS FATTURA,CF.T_CF_DsCliFat, CF.T_CF_DsCat AS AGENZIA, RF2.T_RF_CdProd, RF2.T_RF_Pezzi FROM  PALM_Cliente_Fatturazione CF
JOIN PALM_Righe_Fatture2 RF2
ON CF.T_CF_CdCliFat = RF2.T_RF_NumFatt) X
JOIN PALM_Prodotto P
ON X.T_RF_CdProd = P.P_Prod_Cd

-- 16) Verificare se sono presenti fatture con codice cliente riga diverso dal codice cliente testata

SELECT COUNT(*) NUMERO_DIFF FROM PALM_Righe_Fatture2 RF2
JOIN PALM_Testate_Fatture TF
ON RF2.T_RF_NumFatt = TF.T_NF_NumFat
WHERE RF2.T_RF_CdCliDes != TF.T_NF_CdCliFat

-- 17) Controllare se sono presenti fatture a cui sono associati più di un codice cliente

SELECT COUNT(*) FROM
(SELECT RF.T_RF_NumFatt FATTURA, COUNT(RF.T_RF_CdCliDes) NUMERO_CODICI_ASS FROM PALM_Righe_Fatture2 RF
GROUP BY RF.T_RF_NumFatt) H
WHERE H.NUMERO_CODICI_ASS >1


-- 18) Calcolare il numero di fatture per cliente

SELECT T_CF_DsCliFat CLIENTE, COUNT(T_rf_NumFatt) NUMERO_FATTURE FROM
(SELECT * FROM PALM_Righe_Fatture2 RF2
JOIN PALM_Cliente_Fatturazione CF
ON RF2.T_RF_CdCliDes= CF.T_CF_CdCliFat) X
GROUP BY T_CF_DsCliFat


-- 19) Quanti prodotti non sono stati venduti?

SELECT COUNT(*) FROM PALM_Prodotto P
LEFT JOIN PALM_Righe_Fatture2 RF2
ON P.P_Prod_Cd=RF2.T_RF_CdProd
WHERE T_RF_NumFatt IS NULL

-- 20) Quanti prodotti non sono stati venduti nel 2003? 


SELECT COUNT(*) INVENDUTI_2013 FROM PALM_Prodotto P
LEFT JOIN (SELECT * FROM PALM_Righe_Fatture2 RF2
WHERE YEAR(RF2.T_RF_DataDoc)=2003) X
ON P.P_Prod_Cd=X.T_RF_CdProd
WHERE X.T_RF_NumFatt IS NULL

-- 21) Quante fatture presentano più di 10 righe fattura?

SELECT COUNT(*) FROM PALM_Righe_Fatture2 RF2
WHERE RF2.T_RF_RigaFatt >= 10

-- 22) Qual è il fatturato a valore per ogni fattura del caso precedente? (da svolgere con un'unica query)

SELECT RF2.T_RF_NumFatt FATTURA, SUM(RF2.T_RF_Pezzi*RF2.T_RF_Prezzo) FROM PALM_Righe_Fatture2 RF2 
WHERE RF2.T_RF_RigaFatt >= 10
GROUP BY RF2.T_RF_NumFatt

-- 23) Qual è il fatturato a valore che fa riferimento ai grossisti?

SELECT CF.T_CF_DsCliFat GROSSISTI, SUM(RF2.T_RF_Pezzi*RF2.T_RF_Prezzo) FATTURATO FROM PALM_Cliente_Fatturazione CF
JOIN PALM_Righe_Fatture2 RF2
ON CF.T_CF_CdCliFat=RF2.T_RF_NumFatt
WHERE CF.T_CF_DsCat = 'GROSSISTI'
GROUP BY CF.T_CF_DsCliFat
ORDER BY 1 ASC

-- 24) Qual è il prezzo medio di ogni nazione?

SELECT G.T_GEO_DsNaz NAZIONE, AVG(RF2.T_RF_Prezzo) PREZZO_MEDIO FROM PALM_Righe_Fatture2 RF2
JOIN PALM_Geografia G 
ON RF2.T_RF_CdCliDes = G.T_GEO_CdCliDes
GROUP BY G.T_GEO_DsNaz
ORDER BY 2 DESC

-- 25) Considerando solo le prime 3 nazioni con prezzo medio maggiore, determinare per quale linea 
--complessivamente sono stati venduti più pezzi


SELECT  TOP 1 * FROM
(SELECT NAZIONE, P_Lin_Ds LINEA, count(T_RF_Pezzi) NUMERO_PEZZI FROM
(SELECT * FROM 
(SELECT * FROM
(SELECT TOP 3 G.T_GEO_DsNaz NAZIONE , AVG(RF2.T_RF_Prezzo) PREZZO_MEDIO FROM PALM_Righe_Fatture2 RF2
JOIN PALM_Geografia G 
ON RF2.T_RF_CdCliDes = G.T_GEO_CdCliDes
GROUP BY G.T_GEO_DsNaz
ORDER BY 2 DESC) X
JOIN PALM_Geografia G
ON X.NAZIONE = G.T_GEO_DsNaz) J
JOIN PALM_Righe_Fatture2 RF2
ON RF2.T_RF_CdCliDes = J.T_GEO_CdCliDes) K 
JOIN PALM_Prodotto P
ON P.P_Prod_Cd = K.T_RF_CdProd
GROUP BY NAZIONE, P_Lin_Ds) C
ORDER BY 3 DESC

-- 26) Quant è l'incidenza percentuale del primo e del secondo anno di vendita sul totale del fatturato?

SELECT TOP 2 * FROM 
(SELECT YEAR(RF2.T_RF_DataDoc) ANNO,SUM(RF2.T_RF_Pezzi*RF2.T_RF_Prezzo)*100 / (SELECT SUM(RF2.T_RF_Pezzi*RF2.T_RF_Prezzo) FROM PALM_Righe_Fatture2 RF2) PERCENTUALE FROM PALM_Righe_Fatture2 RF2
GROUP BY YEAR(RF2.T_RF_DataDoc)) X
ORDER BY 1 ASC

-- 27) Per ogni linea qual è lo scostamento tra il numero di prodotti esposti a listino e quelli effettivamente venduti?

SELECT P_Lin_Ds LINEA, COUNT(*) NUM_PROD_NON_VENDUTI FROM
(SELECT P.P_Lin_Ds, P.P_Prod_Cd, P.P_Prod_Ds FROM PALM_Prodotto P
GROUP BY P.P_Lin_Ds, P.P_Prod_Cd, P.P_Prod_Ds) X
LEFT JOIN PALM_Righe_Fatture2 RF2
ON X.P_Prod_Cd = RF2.T_RF_CdProd
WHERE T_RF_CdProd IS NULL
GROUP BY P_Lin_Ds

-- 28) Quanti clienti hanno comprato almeno 3 prodotti diversi?

SELECT COUNT(*) FROM 
(SELECT T_RF_CdCliDes, COUNT(*) NUMERO_PROD_ACQ FROM
(SELECT RF2.T_RF_CdCliDes, RF2.T_RF_CdProd FROM PALM_Righe_Fatture2 RF2
GROUP BY RF2.T_RF_CdCliDes, RF2.T_RF_CdProd) X
GROUP BY T_RF_CdCliDes) Y
WHERE Y.NUMERO_PROD_ACQ >= 3


-- 29) Quanti clienti hanno comprato prodotti di almeno 3 linee?

SELECT COUNT(*) FROM 
(SELECT T_RF_CdCliDes, COUNT(*) N FROM 
(SELECT T_RF_CdCliDes,P_Lin_Ds FROM PALM_Righe_Fatture2 RF2
JOIN PALM_Prodotto P 
ON RF2.T_RF_CdProd = P.P_Prod_Cd
GROUP BY T_RF_CdCliDes,P_Lin_Ds) X
GROUP BY X.T_RF_CdCliDes) Y 
WHERE Y.N >= 3

-- 30) Mostrare i soli clienti che hanno ordinato almeno 8 prodotti diversi

SELECT T_CF_dsCliFat CLIENTE, N NUMERO_PRODOTTI_DIVERSI FROM 
(SELECT * FROM 
(SELECT T_RF_CdCliDes, COUNT(*) N FROM 
(SELECT RF2.T_RF_CdCliDes, RF2.T_RF_CdProd FROM PALM_Righe_Fatture2 RF2 
GROUP BY RF2.T_RF_CdCliDes, RF2.T_RF_CdProd) X
GROUP BY T_RF_CdCliDes) Y
WHERE Y.N >=8) Z
JOIN PALM_Cliente_Fatturazione CF 
ON Z.T_RF_CdCliDes = CF.T_CF_CdCliFat

-- 31) Dividere le nazioni in 3 bucket differenti, chiamati A, B e C, in modo che siano suddivisi sulla base del fatturato (alto, medio e basso)


SELECT *, 'A' SOGLIA FROM 
(SELECT T_GEO_DsNaz G1, SUM(T_RF_Pezzi*T_RF_Prezzo) FATT_LOW FROM 
(SELECT * FROM PALM_Righe_Fatture2 RF2
JOIN PALM_Geografia G 
ON G.T_GEO_CdCliDes = RF2.T_RF_CdCliDes) X
GROUP BY X.T_GEO_DsNaz) A 
WHERE A.FATT_LOW < 50000
UNION 
SELECT *, 'B' FROM 
(SELECT T_GEO_DsNaz G2, SUM(T_RF_Pezzi*T_RF_Prezzo) FATT_MIDD FROM 
(SELECT * FROM PALM_Righe_Fatture2 RF2
JOIN PALM_Geografia G 
ON G.T_GEO_CdCliDes = RF2.T_RF_CdCliDes) X
GROUP BY X.T_GEO_DsNaz) A 
WHERE A.FATT_MIDD BETWEEN 50000 AND 500000
UNION
SELECT *, 'C' FROM 
(SELECT T_GEO_DsNaz G3, SUM(T_RF_Pezzi*T_RF_Prezzo) FATT_HIGH FROM 
(SELECT * FROM PALM_Righe_Fatture2 RF2
JOIN PALM_Geografia G 
ON G.T_GEO_CdCliDes = RF2.T_RF_CdCliDes) X
GROUP BY X.T_GEO_DsNaz) A 
WHERE A.FATT_HIGH > 500000 


-- 32) I prodotti non venduti nel 2003 che fatturato hanno comportato nel 2004?

SELECT SUM(T_RF_Pezzi*T_RF_Prezzo) FATTURATO FROM 
(SELECT P_Prod_Cd, P_Prod_Ds FROM PALM_Prodotto P
LEFT JOIN (SELECT * FROM PALM_Righe_Fatture2 RF2
WHERE YEAR(RF2.T_RF_DataDoc)=2003) X
ON P.P_Prod_Cd=X.T_RF_CdProd
WHERE X.T_RF_NumFatt IS NULL) A
JOIN
(SELECT * FROM PALM_Righe_Fatture2 RF2
WHERE YEAR(RF2.T_RF_DataDoc)=2004) B 
ON A.P_Prod_Cd = B.T_RF_CdProd

-- 33) Determinare il fatturato mensile degli anni 2003 e 2004 e calcolare il delta % di incremento tra i due anni

SELECT MESE_03 MESE, ((TOT_04-TOT_03)/TOT_03)*100.0 DELTA FROM
(SELECT * FROM
(SELECT MONTH(T_RF_DataDoc) MESE_03, SUM(T_RF_Pezzi*T_RF_Prezzo) TOT_03 FROM PALM_Righe_Fatture2 RF2
WHERE YEAR(RF2.T_RF_DataDoc)=2003
GROUP BY MONTH(RF2.T_RF_DataDoc)) X
JOIN 
(SELECT MONTH(T_RF_DataDoc) MESE_04, SUM(T_RF_Pezzi*T_RF_Prezzo) TOT_04 FROM PALM_Righe_Fatture2 RF2
WHERE YEAR(RF2.T_RF_DataDoc)=2004
GROUP BY MONTH(RF2.T_RF_DataDoc)) Y 
ON X.MESE_03=Y.MESE_04) Z
ORDER BY 1 ASC 

-- 34) Il cliente che ha ordinato il valore più rilevante, è lo stesso che ha il maggior numero di pezzi ordinati?

SELECT T_CF_DsCliFat, TIPO FROM
(SELECT T_RF_CdCliDes, 'ORDINE PIU RILEVANTE' TIPO FROM 
(SELECT TOP 1 * FROM 
(SELECT RF2.T_RF_CdCliDes, MAX(T_RF_Pezzi) M FROM PALM_Righe_Fatture2 RF2
GROUP BY RF2.T_RF_CdCliDes) A
ORDER BY 2 DESC) D
UNION
SELECT T_RF_CdCliDes ,'MAGGIOR NUMERO PEZZI ORDINATI' FROM(
SELECT TOP 1 * FROM
(SELECT RF2.T_RF_CdCliDes, SUM (RF2.T_RF_Pezzi) M FROM PALM_Righe_Fatture2 RF2
GROUP BY RF2.T_RF_CdCliDes) B
ORDER BY 2 DESC ) C ) Z
JOIN PALM_Cliente_Fatturazione CF
ON Z.T_RF_CdCliDes = CF.T_CF_CdCliFat



-- 35) Qual è il cliente che ha effettuato il maggior numero di ordini?

-- VEDI SOPRA 


-- 36) Determinare l'ordinato a valore complessivamente prodotto nel 2003 di lunedì.

SELECT SUM(T_RF_Pezzi*T_RF_Prezzo) 'FATTURATO COMPLESSIVO DI TUTTI I LUNEDI' FROM 
(SELECT * FROM
(SELECT * FROM PALM_Righe_Fatture2 RF2
WHERE YEAR( RF2.T_RF_DataDoc) =2003) A
WHERE DATENAME(WEEKDAY,A.T_RF_DataDoc ) = 'Monday') B





