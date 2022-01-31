
---query 1 Tot qtà per prodotto
SELECT F.T_RF_CdProd, SUM(F.T_RF_Pezzi) 
FROM PALM_Righe_Fatture2 F
GROUP BY F.T_RF_CdProd


--2 tot fatturato per giorno 30-04-2003
SELECT Sum(t_rf_pezzi) AS FATTURATO_GG
FROM PALM_Righe_Fatture2
WHERE T_RF_DataDoc BETWEEN '2003-04-30 00:00:00' AND '2003-04-30 23:59:59';


--query 3
SELECT T_RF_CdProd, Sum(t_rf_pezzi) AS somma
FROM PALM_Righe_Fatture2
WHERE T_RF_DataDoc BETWEEN '2005-06-03 00:00:00' AND '2005-06-03 23:59:59'
AND T_RF_CdProd = '33006'
GROUP BY T_RF_CdProd;


--query 4
SELECT TOP 1 year (T_RF_DataDoc) AS ANNO, sum (t_rf_pezzi*) AS QTA
FROM PALM_Righe_Fatture2
GROUP BY year (T_RF_DataDoc)
ORDER BY sum (t_rf_pezzi) desc;

SELECT TOP 2 C.CalendarYear AS Year, SUM(F.T_RF_Prezzo * F.T_RF_Pezzi) AS Fatturato
FROM PALM_Righe_Fatture2 F 
JOIN PALM_Calendar C ON F.T_RF_DataDoc = C.CalendarDate
GROUP BY C.CalendarYear
ORDER BY Fatturato DEsc



--query 5
SELECT TOP 1 T_RF_CdProd AS PRODUCT, P.P_Prod_Ds, sum (t_rf_pezzi) AS QTA
FROM PALM_Righe_Fatture2 RF
INNER JOIN PALM_Prodotto P ON RF.T_RF_CdProd = P.P_Prod_Cd
WHERE year (T_RF_DataDoc)=2004
GROUP BY T_RF_CdProd, P.P_Prod_Ds
ORDER BY QTA DESC


SELECT TOP 1 T_RF_CdProd, sum(t_rf_pezzi) AS QTA
FROM PALM_Righe_Fatture2
WHERE year(T_RF_DataDoc)=2004
GROUP BY T_RF_CdProd
ORDER BY QTA DESC

--query 6
SELECT sum(RF.T_RF_Prezzo * RF.T_RF_Pezzi) AS Fatturato
	, P.P_Lin_Cd AS lin_code
	, P.P_Lin_Ds AS descr
FROM PALM_Righe_Fatture2 As RF
	INNER JOIN PALM_Prodotto AS P
		ON RF.T_RF_CdPRod = P.P_prod_Cd
GROUP BY P.P_lin_Cd, P.P_Lin_Ds
ORDER BY Fatturato desc; 

SELECT  P.P_Lin_Cd, SUM(F.T_RF_Prezzo*F.T_RF_Pezzi) AS Fatturato 
FROM PALM_Prodotto P
JOIN PALM_Righe_Fatture2 F ON P.P_Prod_Cd = F.T_RF_CdProd
GROUP BY P.P_Lin_Cd
ORDER BY Fatturato DESC



---query 7
SELECT 
sum(RF.T_RF_Prezzo * RF.T_RF_Pezzi) AS FATTURATO
, P.P_Lin_Cd AS cod_lin, P.P_Lin_Ds AS descr
, CF.T_CF_CdCat AS cod_cat, CF.T_CF_DsCat AS category
FROM PALM_Righe_Fatture2 As RF
	INNER JOIN PALM_Prodotto AS P 
	ON RF.T_RF_CdPRod = P.P_prod_Cd 

	INNER JOIN PALM_Cliente_Fatturazione AS CF
	ON CF.T_CF_CdCliFat  = RF.T_RF_CdCliDes

GROUP BY P.P_lin_Cd, P.P_Lin_Ds, CF.T_CF_DsCat, P.P_Lin_Cd, CF.T_CF_CdCat
ORDER BY FATTURATO DESC;



SELECT P.P_Lin_Cd, CF.T_CF_CdCat, sum(f2.T_RF_Pezzi*f2.T_RF_Prezzo) AS FATTURATO
FROM PALM_Righe_Fatture2 F2 
     INNER JOIN PALM_Prodotto P ON F2.T_RF_CdProd=P.P_Prod_Cd
     INNER JOIN PALM_Cliente_Fatturazione CF ON F2.T_RF_CdCliDes=CF.T_CF_CdCliFat
GROUP BY P.P_Lin_Cd, CF.T_CF_CdCat


---Query 8

SELECT 
	avg (a.T_RF_Prezzo) AS avg
	, b.P_Lin_Cd AS lin_code
	, b.P_Lin_Ds AS descr
FROM PALM_Righe_Fatture2 As a
	INNER JOIN PALM_Prodotto AS b
	ON a.T_RF_CdPRod = b.P_prod_Cd
GROUP BY b.P_lin_Cd, b.P_Lin_Ds
ORDER BY avg desc; 

--query 9
SELECT sum (t_rf_pezzi) AS quantità
	, b.P_Prod_Ds AS description
	, year (a.T_RF_DataDoc) AS yy
FROM PALM_Righe_Fatture AS a
	INNER JOIN PALM_Prodotto AS b 
	ON a.T_RF_CdPRod = b.P_prod_Cd 
GROUP BY b.P_Prod_Ds, year (a.T_RF_DataDoc)
ORDER BY yy ASC, quantità desc;

--query 10
SELECT sum (t_rf_pezzi) AS quantità
	, b.P_Brand_Ds AS brand
	, year (a.T_RF_DataDoc) AS yy
FROM PALM_Righe_Fatture2 AS a
	INNER JOIN PALM_Prodotto AS b 
	ON a.T_RF_CdPRod = b.P_prod_Cd 
GROUP BY b.P_Brand_Ds, year (a.T_RF_DataDoc)
ORDER BY yy ASC, quantità desc;

--query 11
SELECT round(sum (a.T_RF_Prezzo * a.T_RF_Pezzi),2) AS fatturato
, b.T_GEO_DsNaz
	FROM PALM_Righe_Fatture2 AS a
	INNER JOIN PALM_Geografia AS b 
ON a.T_RF_CdCliDes = b.T_GEO_CdCliDes
GROUP BY b.T_GEO_DsNaz 
ORDER BY fatturato desc;

--query 12
SELECT b.T_GEO_DsNaz
	, sum(a.T_RF_Prezzo * a.T_RF_Pezzi) AS Fatturato
	, year (a.T_RF_DataDoc) AS yyyy
FROM PALM_Righe_Fatture2 AS a
	INNER JOIN PALM_Geografia AS b 
	ON a.T_RF_CdCliDes = b.T_GEO_CdCliDes
GROUP BY b.T_GEO_DsNaz, year (a.T_RF_DataDoc)
ORDER BY b.T_GEO_DsNaz ASC, year (a.T_RF_DataDoc)ASC;

--query 13
SELECT b.T_GEO_DsNaz
	, sum(a.T_RF_Prezzo * a.T_RF_Pezzi) AS Fatturato
	, year (a.T_RF_DataDoc) AS yyyy
FROM PALM_Righe_Fatture2 AS a
	INNER JOIN PALM_Geografia AS b 
	ON a.T_RF_CdCliDes = b.T_GEO_CdCliDes
WHERE b.T_GEO_DsNaz= 'Belgio'
GROUP BY b.T_GEO_DsNaz, year (a.T_RF_DataDoc)
ORDER BY b.T_GEO_DsNaz ASC, year (a.T_RF_DataDoc)ASC;

--query 14
SELECT 
	b.T_GEO_DsNaz
	, sum(a.T_RF_Prezzo * a.T_RF_Pezzi) AS invoiced
	, year (a.T_RF_DataDoc) AS yyyy
FROM PALM_Righe_Fatture2 AS a
	INNER JOIN PALM_Geografia AS b 
	ON a.T_RF_CdCliDes = b.T_GEO_CdCliDes
WHERE b.T_GEO_DsNaz like 'i%a'
GROUP BY b.T_GEO_DsNaz, year (a.T_RF_DataDoc)
ORDER BY b.T_GEO_DsNaz ASC, year (a.T_RF_DataDoc)ASC;

--query 15
SELECT 
	DISTINCT a.T_RF_NumFatt
	,c.T_CF_DsCliFat
	,c.T_CF_DsCentrale
	,b.P_Prod_Cd
	,a.T_RF_Pezzi
FROM PALM_Righe_Fatture As a
	INNER JOIN PALM_Prodotto AS b 
	ON a.T_RF_CdPRod = b.P_prod_Cd 
	INNER JOIN PALM_Cliente_Fatturazione AS c
	ON a.T_RF_NumFatt= c.T_CF_CdCliFat
ORDER BY T_CF_DsCliFat DESC;
