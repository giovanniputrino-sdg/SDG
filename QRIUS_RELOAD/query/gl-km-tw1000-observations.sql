SELECT
t1.tr_nbr AS KDOC,
t1.tr_nbr AS tr_number,
'OBSERVATION - '||t1.tr_nbr ||CASE WHEN o.ttl_txt IS NOT NULL THEN ' - '|| o.ttl_txt
ELSE '' end AS title,
'pharmatrackwise.am.lilly.com' AS LBL_URL,
'https://pharmatrackwise.am.lilly.com/trackwiseprd1000/Gateway.html?'|| t1.TR_NBR AS URL,
t1.dvsn_cd AS division,
TR_TYP_CD as lbl_type,
t1.plant AS LBL_PLANT,
t1.plant AS REF_PLANT,
t1.flow_team as lbl_flow_team,
t1.flow_team as REF_flow_team,
t1.prcs_team AS LBL_process_team,
o.obsrvtn_typ AS LBL_observation_type,
t1.tr_desc AS SNIPPET,
COALESCE( o.clsfctn_q, o.intl_clsfctn_q) AS lbl_quality_classification,
coalesce(o.CLSFCTN_HS, o.intl_CLSFCTN_HS) as lbl_HS_classification,
coalesce(o.CLSFCTN_E, o.intl_CLSFCTN_E) as lbl_env_classification,
coalesce(o.CLSFCTN_PSM,o.intl_CLSFCTN_PSM) as lbl_psm_classification,
t1.sts_cd AS lbl_status,
t1.sts_cd AS ref_status,
t3.org_area_cd AS LBL_SITE,
t3.org_area_cd AS REF_SITE,
TO_CHAR(CRTN_DT, 'YYYY-MM-DD') AS LBL_DATE,
TO_CHAR(CRTN_DT, 'YYYY/MM/DD') AS REF_DATE,
TO_CHAR(CRTN_DT, 'YYYY/MM/DD') AS SRT_DATE,
TO_CHAR(APRVL_DT, 'YYYY-MM-DD') as lbl_approval_date,
CASE
WHEN t3.org_area_cd = 'Affiliate' THEN 'Elanco'
WHEN t3.org_area_cd = 'Alcobendas' THEN 'Dry'
WHEN t3.org_area_cd = 'API External Mfg' THEN 'API'
WHEN t3.org_area_cd = 'Branchburg' THEN 'Other'
WHEN t3.org_area_cd = 'Brazil' THEN 'Dry'
WHEN t3.org_area_cd = 'EMEAA' THEN 'Contract Manufacturing'
WHEN t3.org_area_cd = 'EMS - Americas' THEN 'Other'
WHEN t3.org_area_cd = 'EU-PPMD' THEN 'Other'
WHEN t3.org_area_cd = 'Fegersheim' THEN 'Parenteral'
WHEN t3.org_area_cd = 'Global Quality Labs' THEN 'Other'
WHEN t3.org_area_cd = 'Global Quality Systems' THEN 'Other'
WHEN t3.org_area_cd = 'Indy API' THEN 'API'
WHEN t3.org_area_cd = 'Indy Device Mfg' THEN 'Device'
WHEN t3.org_area_cd = 'Indy Dry' THEN 'Dry'
WHEN t3.org_area_cd = 'Indy Facilities Management' THEN 'Other'
WHEN t3.org_area_cd = 'Indy Parenteral' THEN 'Parenteral'
WHEN t3.org_area_cd = 'KINSALE' THEN 'API'
WHEN t3.org_area_cd = 'NA Logistics Ops' THEN 'Other'
WHEN t3.org_area_cd = 'NULL' THEN ''
WHEN t3.org_area_cd = 'PR&D' THEN 'r&d'
WHEN t3.org_area_cd = 'PR01' THEN 'Dry'
WHEN t3.org_area_cd = 'PR05' THEN 'API'
WHEN t3.org_area_cd = 'Seishin' THEN 'Parenteral'
WHEN t3.org_area_cd = 'Sesto' THEN 'Parenteral'
WHEN t3.org_area_cd = 'Suzhou' THEN 'Dry'
ELSE 'NA'
END AS LBL_NETWORK,
CASE
WHEN t3.org_area_cd = 'Affiliate' THEN 'Elanco'
WHEN t3.org_area_cd = 'Alcobendas' THEN 'Dry'
WHEN t3.org_area_cd = 'API External Mfg' THEN 'API'
WHEN t3.org_area_cd = 'Branchburg' THEN 'Other'
WHEN t3.org_area_cd = 'Brazil' THEN 'Dry'
WHEN t3.org_area_cd = 'EMEAA' THEN 'Contract Manufacturing'
WHEN t3.org_area_cd = 'EMS - Americas' THEN 'Other'
WHEN t3.org_area_cd = 'EU-PPMD' THEN 'Other'
WHEN t3.org_area_cd = 'Fegersheim' THEN 'Parenteral'
WHEN t3.org_area_cd = 'Global Quality Labs' THEN 'Other'
WHEN t3.org_area_cd = 'Global Quality Systems' THEN 'Other'
WHEN t3.org_area_cd = 'Indy API' THEN 'API'
WHEN t3.org_area_cd = 'Indy Device Mfg' THEN 'Device'
WHEN t3.org_area_cd = 'Indy Dry' THEN 'Dry'
WHEN t3.org_area_cd = 'Indy Facilities Management' THEN 'Other'
WHEN t3.org_area_cd = 'Indy Parenteral' THEN 'Parenteral'
WHEN t3.org_area_cd = 'KINSALE' THEN 'API'
WHEN t3.org_area_cd = 'NA Logistics Ops' THEN 'Other'
WHEN t3.org_area_cd = 'NULL' THEN ''
WHEN t3.org_area_cd = 'PR&D' THEN 'r&d'
WHEN t3.org_area_cd = 'PR01' THEN 'Dry'
WHEN t3.org_area_cd = 'PR05' THEN 'API'
WHEN t3.org_area_cd = 'Seishin' THEN 'Parenteral'
WHEN t3.org_area_cd = 'Sesto' THEN 'Parenteral'
WHEN t3.org_area_cd = 'Suzhou' THEN 'Dry'
ELSE 'NA'
END AS REF_NETWORK,
'TW1000 - Observations' as ref_source,
'TW1000 - Observations' as lbl_source
FROM gmdf_core.mdm_tr_dim_1 t1
INNER JOIN gmdf_core.mdm_tr_dim_2 t2
ON t1.mdm_tr_dim_id = t2.mdm_tr_dim_id
AND t1.src_inst_cd = t2.src_inst_cd
INNER JOIN gmdf_core.mdm_tr_dim_3 t3
ON t2.mdm_tr_dim_id = t3.mdm_tr_dim_id
AND t2.src_inst_cd = t3.src_inst_cd
INNER JOIN gmdf_core.mdm_tr_obsrvtn_1 o
ON t3.mdm_tr_dim_id = o.mdm_tr_dim_id
AND t3.src_inst_cd = o.src_inst_cd
WHERE t1.src_cd = 'TRW1000'
AND COALESCE( o.clsfctn_q, o.intl_clsfctn_q) NOT IN ('Deviation','Major')
AND t1.sts_cd <> 'Closed - Cancelled'
AND o.rcrd_sts_cd <> 'D'
AND t3.org_area_cd <> 'Affiliate'