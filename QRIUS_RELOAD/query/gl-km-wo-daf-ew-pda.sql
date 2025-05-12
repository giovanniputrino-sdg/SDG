SELECT
    WO.WONUM || WO.SITEID AS KDOC,
    'WORKORDER - ' || WO.WONUM || CASE WHEN WO.DESCRIPTION IS NOT NULL THEN ' - ' || WO.DESCRIPTION ELSE '' END AS title,
    'http://ix1gmarsprd.am.lilly.com/maximo/ui/maximo.jsp?event=loadapp&value=wotrack&additionalevent=sqlwhere&additionaleventvalue=WONUM%3D''' || WO.WONUM || '''&forcereload=true' AS url,
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
    CAST(WO.WOPRIORITY AS int) AS lbl_wopriority,
    WO.ASSETLOCPRIORITY AS lbl_assetlocpriority,
    WO.REPORTEDBY AS lbl_reportedby,
    PE.DISPLAYNAME AS lbl_reportedbyname,
    LO.LOCATION AS lbl_LOCATIONid,
    LO.DESCRIPTION AS lbl_LOCATIONdesc,
    SUM(LENGTH(CONCAT('- ', L.LDTEXT))) AS total_ldtext_length,
    CASE
        WHEN SUM(LENGTH(CONCAT('- ', L.LDTEXT))) < 60000
        THEN LISTAGG(CONCAT('- ', L.LDTEXT), ' ') WITHIN GROUP (ORDER BY wlog.MODIFYDATE ASC)
        ELSE '...'
    END AS lbl_longdesc_init,
    WO.LLYQREASON || ' - ' || WO.LLYSAFREASON || ' - ' || WO.LLYENVREASON AS lbl_reasonforpm,
    CAST(WO.WOPRIORITY AS int) AS ref_wopriority,
    WO.STATUS AS ref_status,
    WT.WTYPEDESC AS ref_type,
    CASE WHEN WO.SITEID LIKE '%EW%' THEN 'Erl Wood'
         WHEN WO.SITEID LIKE '%DAF%' THEN 'AFM'
         WHEN WO.SITEID IS NULL THEN 'n.p.'
         ELSE 'n.a.'
    END AS lbl_site,
    CASE WHEN WO.SITEID LIKE '%DAF%' THEN 'Other'
         WHEN WO.SITEID LIKE '%EW%' THEN 'Development'
         WHEN WO.SITEID IS NULL THEN 'n.p.'
         ELSE 'n.a.'
    END AS lbl_network,
    TO_CHAR(WO.ACTSTART, 'YYYY-MM-DD') AS srt_date,
    'GMARS - Workorders' AS ref_source,
    'GMARS - Workorders' AS lbl_source,
    GREATEST(
        NVL(PE.GMDM_STG_TMSTMP, '1950-01-01'),
        NVL(CAST(CASE WHEN WO.R_UPD_TMSTMP <> '' THEN WO.R_UPD_TMSTMP ELSE WO.R_INS_TMSTMP END AS TIMESTAMP), '1950-01-01'),
        NVL(CAST(CASE WHEN WT.R_UPD_TMSTMP <> '' THEN WT.R_UPD_TMSTMP ELSE WT.R_INS_TMSTMP END AS TIMESTAMP), '1950-01-01'),
        NVL(CAST(CASE WHEN L.R_UPD_TMSTMP <> '' THEN L.R_UPD_TMSTMP ELSE L.R_INS_TMSTMP END AS TIMESTAMP), '1950-01-01')
    ) TMSTMP
FROM
    gmdf_ref.ref_maximo_workorder WO
LEFT JOIN (
    SELECT PERSONID, MAX(DISPLAYNAME) AS DISPLAYNAME, MAX(CAST(CASE WHEN R_UPD_TMSTMP <> '' THEN R_UPD_TMSTMP ELSE R_INS_TMSTMP END AS TIMESTAMP)) AS GMDM_STG_TMSTMP
    FROM gmdf_ref.ref_maximo_person
    GROUP BY PERSONID
) PE
ON WO.REPORTEDBY = PE.PERSONID
LEFT JOIN (
    SELECT Z.LOCATION, Z.DESCRIPTION
    FROM (
        SELECT Z.LOCATION, LISTAGG(DESCRIPTION, '##') AS DESCRIPTION
        FROM gmdf_ref.ref_maximo_locations Z
        GROUP BY Z.LOCATION
    ) Z
    INNER JOIN (
        SELECT LOCATION
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
AND WO.SITEID = WLOG.SITEID
LEFT JOIN gmdf_ref.ref_maximo_LONGDESCRIPTION L
ON L.LDKEY = wlog.WORKLOGID
AND WO.R_SRC_ID = L.R_SRC_ID
WHERE WO.ISTASK = 0
AND WO.R_RCRD_STS_CD = 'A'
AND (WO.SITEID LIKE '%DAF%' OR WO.SITEID LIKE '%EW%')
GROUP BY 
    WO.WONUM, WO.SITEID, WO.WORKTYPE, WT.WTYPEDESC, WO.DESCRIPTION, 
    WO.TARGSTARTDATE, WO.ACTSTART, WO.ACTFINISH, WO.LLYREQDCOMPDATE, 
    WO.LLYOPERCODE, WO.LLYPROCCODE, WO.LLYTOLERANCE, WO.LLYPAPERFILE, 
    WO.LLYIMPACTCLASS, WO.WOPRIORITY, WO.ASSETLOCPRIORITY, WO.REPORTEDBY, 
    PE.DISPLAYNAME, LO.LOCATION, LO.DESCRIPTION, 
    WO.LLYQREASON, WO.LLYSAFREASON, WO.LLYENVREASON, 
    WO.STATUS, WT.WTYPEDESC, WO.SITEID, WO.ACTSTART, 
    GREATEST(NVL(PE.GMDM_STG_TMSTMP, '1950-01-01'),
              NVL(CAST(CASE WHEN WO.R_UPD_TMSTMP <> '' THEN WO.R_UPD_TMSTMP ELSE WO.R_INS_TMSTMP END AS TIMESTAMP), '1950-01-01'),
              NVL(CAST(CASE WHEN WT.R_UPD_TMSTMP <> '' THEN WT.R_UPD_TMSTMP ELSE WT.R_INS_TMSTMP END AS TIMESTAMP), '1950-01-01'),
              NVL(CAST(CASE WHEN L.R_UPD_TMSTMP <> '' THEN L.R_UPD_TMSTMP ELSE L.R_INS_TMSTMP END AS TIMESTAMP), '1950-01-01')
             )