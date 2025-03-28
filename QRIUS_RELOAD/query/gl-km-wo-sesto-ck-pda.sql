	
select * from (
SELECT
0 AS CNT,
WO.WONUM||WO.SITEID AS KDOC,
'WORKORDER - ' || WO.WONUM || CASE WHEN WO.DESCRIPTION IS NOT NULL THEN ' - ' || WO.DESCRIPTION ELSE '' END AS title,
'
http://ix1gmarsprd.am.lilly.com/maximo/ui/maximo.jsp?event=loadapp&value=wotrack&additionalevent=sqlwhere&additionaleventvalue=WONUM%3D'''||WO.WONUM||'''&forcereload=true'
AS url,
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
WO.LLYOPERCODE AS ref_llyopercode,
WO.LLYOPERCODE AS lbl_llyopercode,
WO.LLYPROCCODE AS ref_llyproccode,
WO.LLYPROCCODE AS lbl_llyproccode,
WO.LLYTOLERANCE AS lbl_llytolerance,
WO.LLYPAPERFILE AS lbl_llypaperfile,
WO.LLYIMPACTCLASS AS lbl_llyimpactclass,
cast(WO.WOPRIORITY as int) AS lbl_wopriority,
WO.ASSETLOCPRIORITY AS lbl_assetlocpriority,
WO.REPORTEDBY AS lbl_reportedby,
PE.DISPLAYNAME AS lbl_reportedbyname,
LO.LOCATION AS lbl_LOCATIONid,
LO.DESCRIPTION AS lbl_LOCATIONdesc,
LISTAGG(CONCAT('- ', L.LDTEXT), ' ') WITHIN GROUP (ORDER BY wlog.MODIFYDATE ASC) AS lbl_longdesc_init,
WO.LLYQREASON || ' - ' || WO.LLYSAFREASON || ' - ' || WO.LLYENVREASON AS lbl_reasonforpm,
cast(WO.WOPRIORITY as int) AS ref_wopriority,
WO.STATUS AS ref_status,
WT.WTYPEDESC AS ref_type,
CASE WHEN WO.SITEID LIKE '%SESTO%' THEN 'Sesto'
WHEN WO.SITEID LIKE '%CK%' THEN 'Kinsale'
WHEN WO.SITEID IS NULL THEN 'n.p.'
ELSE 'n.a.'
END AS lbl_site,
CASE WHEN WO.SITEID LIKE '%SESTO%' THEN 'Sesto'
WHEN WO.SITEID LIKE '%CK%' THEN 'Kinsale'
WHEN WO.SITEID IS NULL THEN 'n.p.'
ELSE 'n.a.'
END AS ref_site,
CASE WHEN WO.SITEID LIKE '%SESTO%' THEN 'Parenteral'
WHEN WO.SITEID LIKE '%CK%' THEN 'API'
WHEN WO.SITEID IS NULL THEN 'n.p.'
ELSE 'n.a.'
END AS lbl_network,
CASE WHEN WO.SITEID LIKE '%SESTO%' THEN 'Parenteral'
WHEN WO.SITEID LIKE '%CK%' THEN 'API'
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
LEFT JOIN gmdf_ref.ref_maximo_WORKLOG wlog
ON WO.WONUM = wlog.RECORDKEY
and WO.SITEID = WLOG.SITEID
LEFT JOIN gmdf_ref.ref_maximo_LONGDESCRIPTION L ON L.LDKEY = wlog.WORKLOGID
AND WO.R_SRC_ID = L.R_SRC_ID
WHERE WO.ISTASK = 0
AND WO.R_RCRD_STS_CD = 'A'
AND (WO.SITEID LIKE '%SESTO%' OR WO.SITEID LIKE '%CK%')
group by cnt, kdoc, title, url, lbl_url, lbl_number, lbl_status, lbl_type_code, lbl_type_desc, lbl_desc, lbl_targstartdate, lbl_date, ref_date, lbl_actfinish, lbl_llyreqdcompdate,ref_llyopercode, lbl_llyopercode, ref_llyproccode, lbl_llyproccode, lbl_llytolerance, lbl_llypaperfile, lbl_llyimpactclass, lbl_wopriority, lbl_assetlocpriority, lbl_reportedby, lbl_reportedbyname, lbl_locationid, lbl_locationdesc, lbl_reasonforpm, ref_wopriority, ref_status, ref_type, lbl_site, ref_site, lbl_network, ref_network, srt_date, ref_source, lbl_source, tmstmp) A