--query 16
SELECT *
FROM PALM_Testate_Fatture A 
	INNER JOIN PALM_Righe_Fatture2 B ON A.T_NF_NumFat = B.T_RF_NumFatt
WHERE A.T_NF_CdCliFat <> B.T_RF_CdCliDes

SELECT T.T_NF_NumFat
FROM PALM_Testate_Fatture T 
JOIN PALM_Cliente_Fatturazione ON T.T_NF_CdCliFat = PALM_Cliente_Fatturazione.T_CF_CdCliFat
JOIN PALM_Righe_Fatture2 R ON R.T_RF_CdCliDes= PALM_Cliente_Fatturazione.T_CF_CdCliFat
 WHERE  R.T_RF_CdCliDes<>T.T_NF_CdCliFat


--query 17
SELECT T_RF_NumFatt nfatture ,COUNT (DISTINCT T_RF_CdCliDes) totclienti
FROM PALM_Righe_Fatture2
GROUP BY T_RF_NumFatt
HAVING COUNT (DISTINCT T_RF_CdCliDes)>1

--query 18
SELECT T_RF_CdCliDes as cliente,  count(DISTINCT T_RF_NumFatt) AS tot_fatture
FROM PALM_Righe_Fatture2
GROUP BY T_RF_CdCliDes
ORDER BY tot_fatture desc;


---qury 19
SELECT COUNT(*) PRODUCT_NOT_SOLD
FROM PALM_Prodotto A 
LEFT JOIN PALM_Righe_Fatture2 B ON A.P_Prod_Cd = B.T_RF_CdProd
WHERE B.T_RF_NumFatt IS NULL

--query 20
SELECT COUNT(*) PRODUCT_NOT_SOLD
FROM PALM_Prodotto A 
LEFT JOIN PALM_Righe_Fatture2 B 
ON A.P_Prod_Cd = B.T_RF_CdProd AND YEAR(B.T_RF_DataDoc) = 2003 
WHERE B.T_RF_NumFatt IS NULL