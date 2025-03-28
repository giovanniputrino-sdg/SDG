SELECT
0 AS CNT,
WO.WONUM||WO.SITEID AS KDOC,
'WORKORDER - ' || WO.WONUM || CASE WHEN WO.DESCRIPTION IS NOT NULL THEN ' - ' || WO.DESCRIPTION ELSE '' END AS title,
COALESCE(WO.DESCRIPTION, '') || ' ' || COALESCE(L.LDTEXT, '') AS snippet,
'http://ix1gmarsprd.am.lilly.com/maximo/ui/maximo.jsp?event=loadapp&value=wotrack&additionalevent=sqlwhere&additionaleventvalue=WONUM%3D'''||WO.WONUM||'''&forcereload=true' AS url,
'ix1gmarsprd.am.lilly.com' AS lbl_url,
WO.WONUM AS lbl_number,
WO.STATUS AS lbl_status,
WO.WORKTYPE AS lbl_type_code,
WT.WTYPEDESC AS lbl_type_desc,
WO.DESCRIPTION AS lbl_desc,
TO_CHAR(WO.TARGSTARTDATE, 'YYYY-MM-DD') AS lbl_targstartdate,
TO_CHAR(WO.ACTSTART, 'YYYY-MM-DD') AS lbl_date,
TO_CHAR(WO.ACTSTART, 'YYYY/MM/DD') AS ref_date,
TO_CHAR(WO.ACTFINISH, 'YYYY-MM-DD') AS lbl_actfinish,
TO_CHAR(WO.LLYREQDCOMPDATE, 'YYYY-MM-DD') AS lbl_llyreqdcompdate,
WO.LLYOPERCODE AS lbl_llyopercode,
WO.LLYPROCCODE AS lbl_llyproccode,
WO.LLYTOLERANCE AS lbl_llytolerance,
WO.LLYPAPERFILE AS lbl_llypaperfile,
WO.LLYIMPACTCLASS AS lbl_llyimpactclass,
WO.WOPRIORITY AS lbl_wopriority,
WO.ASSETLOCPRIORITY AS lbl_assetlocpriority,
WO.REPORTEDBY AS lbl_reportedby,
PE.DISPLAYNAME AS lbl_reportedbyname,
LO.LOCATION AS lbl_LOCATIONid,
LO.DESCRIPTION AS lbl_LOCATIONdesc,
L.LDTEXT AS lbl_longdesc_init,
WO.LLYQREASON || ' - ' || WO.LLYSAFREASON || ' - ' || WO.LLYENVREASON AS lbl_reasonforpm,
WO.WOPRIORITY AS ref_wopriority,
WO.STATUS AS ref_status,
WT.WTYPEDESC AS ref_type,
CASE WHEN WO.SITEID LIKE '%USDIST%' THEN 'US Distribution'
WHEN WO.SITEID LIKE '%MRO%' THEN 'MRO Storeroom Site'
WHEN WO.SITEID IS NULL THEN 'n.p.'
ELSE 'n.a.'
END AS lbl_site,
CASE WHEN WO.SITEID LIKE '%USDIST%' THEN 'US Distribution'
WHEN WO.SITEID LIKE '%MRO%' THEN 'MRO Storeroom Site'
WHEN WO.SITEID IS NULL THEN 'n.p.'
ELSE 'n.a.'
END AS ref_site,
CASE WHEN WO.SITEID LIKE '%USDIST%' THEN 'Other'
WHEN WO.SITEID LIKE '%MRO%' THEN 'Other'
WHEN WO.SITEID IS NULL THEN 'n.p.'
ELSE 'n.a.'
END AS lbl_network,
CASE WHEN WO.SITEID LIKE '%USDIST%' THEN 'Other'
WHEN WO.SITEID LIKE '%MRO%' THEN 'Other'
WHEN WO.SITEID IS NULL THEN 'n.p.'
ELSE 'n.a.'
END AS ref_network,
TO_CHAR(WO.ACTSTART, 'YYYY-MM-DD') AS srt_date,
'GMARS - Workorders' AS ref_source,
'GMARS - Workorders' AS lbl_source,
greatest(
nvl(PE.GMDM_STG_TMSTMP, '1950-01-01'),
nvl(cast(case when WO.R_UPD_TMSTMP <> '' then WO.R_UPD_TMSTMP else WO.R_INS_TMSTMP end as timestamp), '1950-01-01'),
nvl(cast(case when WT.R_UPD_TMSTMP <> '' then WT.R_UPD_TMSTMP else WT.R_INS_TMSTMP end as timestamp), '1950-01-01'),
nvl(cast(case when L.R_UPD_TMSTMP <> '' then L.R_UPD_TMSTMP else L.R_INS_TMSTMP end as timestamp), '1950-01-01')
) TMSTMP
FROM
gmdf_ref.ref_maximo_workorder WO
LEFT JOIN (
SELECT PERSONID, MAX(DISPLAYNAME) AS DISPLAYNAME, MAX(cast(case when R_UPD_TMSTMP <> '' then R_UPD_TMSTMP else R_INS_TMSTMP end as timestamp)) AS GMDM_STG_TMSTMP
FROM gmdf_ref.ref_maximo_person
GROUP BY PERSONID
) PE
ON WO.REPORTEDBY=PE.PERSONID
LEFT JOIN(
SELECT Z.LOCATION, Z.DESCRIPTION
FROM (
SELECT Z.LOCATION, listagg(DESCRIPTION, '##') AS "DESCRIPTION"
FROM gmdf_ref.ref_maximo_locations Z
GROUP BY Z.LOCATION
) Z
INNER JOIN (SELECT LOCATION
FROM gmdf_ref.ref_maximo_locations
GROUP BY LOCATION
) TMP
ON Z.LOCATION = TMP.LOCATION
) LO
ON WO.LOCATION = LO.LOCATION
LEFT JOIN gmdf_ref.ref_maximo_worktype WT
ON WO.WORKTYPE = WT.WORKTYPE
AND WO.R_SRC_ID = WT.R_SRC_ID
AND WO.ORGID = WT.ORGID
LEFT JOIN gmdf_ref.ref_maximo_longdescription L
ON WO.WORKORDERID = L.LDKEY
AND WO.R_SRC_ID = L.R_SRC_ID
WHERE (L.LDOWNERTABLE = 'WORKORDER' OR L.LDOWNERTABLE IS NULL) AND (L.LDOWNERCOL = 'DESCRIPTION' OR L.LDOWNERCOL IS NULL)
AND WO.ISTASK = 0
AND WO.R_RCRD_STS_CD = 'A'
AND (WO.SITEID LIKE '%USDIST%' OR WO.SITEID LIKE '%MRO%')