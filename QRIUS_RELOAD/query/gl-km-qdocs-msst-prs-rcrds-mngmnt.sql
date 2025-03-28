select distinct
0 AS cnt
,'PRD Records Management' as msst_config
, "LABEL" AS doc_version
,'https://soag-z1.am.lilly.com:8443/IEP/qdocs/getDocument?documentID=' || DOC_CD || '&major version=' || left("LABEL", len("LABEL") - CHARINDEX('.', REVERSE("LABEL"))) || '&minor version=' || right ("LABEL",len("LABEL") - CHARINDEX('.',
"LABEL")) || '&rendition=pdf' as kdoc
,'https://soag-z1.am.lilly.com:8443/IEP/qdocs/getDocument?documentID=' || DOC_CD || '&major version=' || left("LABEL", len("LABEL") - CHARINDEX('.', REVERSE("LABEL"))) || '&minor version=' || right ("LABEL",
len("LABEL") - CHARINDEX('.',
"LABEL")) || '&rendition=pdf' as url
, 'https://lilly-qualitydocs.veevavault.com/ui/#doc_info/' || DOC_CD || '/' || left("LABEL", len("LABEL") - CHARINDEX('.', REVERSE("LABEL"))) || '/' || right ("LABEL",
len("LABEL") - CHARINDEX('.',
"LABEL")) as visualization_url
, 'lilly-qualitydocs.veevavault.com' as base_url
, 'Veeva QDocs - ' || DOC_NM || case when DOC_DESC is null then '' else ' - ' || DOC_DESC end as title
, DOC_NM as file_name
, ATHR_PRSN_CD as author
, TO_CHAR(EFCTV_IN_DT, 'YYYY-MM-DD') as date_in
, TO_CHAR(LAST_RVW_DT, 'YYYY-MM-DD') as last_review_date
, TO_CHAR(NEXT_RVW_DT, 'YYYY-MM-DD') as next_review_date
, INITCAP(DOC_TYP) as doc_type
, AREA as business_area
, DEPT AS dept
, LOC.SITE AS sites
, SUB_PRCS AS sub_process
, 'Veeva QDocs' as source
, UPD.UPDATE_TMSTMP as updt_tmstmp
, SECURE_FLG as INFORMATION_CLASSIFICATION
, SECURITY_GROUP as SECURITY_GROUP
, GVRNG_DOC_CTRL as GOVERNING_DOC_CONTROL_GROUP
from
gmdf_core.mdm_qdocs_doc_vrsn doc_vrsn
inner join (select DOC_CD as loc_id, "LABEL" as loc_lbl,
listagg(LOCATION, '|') as SITE
from (select distinct DOC_CD, "LABEL",
case
when CHARINDEX(' site',LOCATION) > 0 then left(LOCATION, len(LOCATION) - (CHARINDEX(' ',REVERSE(LOCATION))))
else LOCATION
end as LOCATION
from gmdf_core.mdm_qdocs_doc_vrsn
where src_cd = 'QDOCS'
and DOC_STS = 'Effective') LOC_DISTINCT group by DOC_CD, "LABEL")
LOC
on doc_vrsn.DOC_CD = LOC.loc_id and doc_vrsn."LABEL" = LOC.loc_lbl
inner join
(select distinct DOC_CD as upd_id,
"LABEL" as upd_lbl,
max(UPDATE_TMSTMP) over (partition by DOC_CD, "LABEL") as UPDATE_TMSTMP
from gmdf_core.mdm_qdocs_doc_vrsn
where src_cd = 'QDOCS'
and DOC_STS = 'Effective') UPD
on doc_vrsn.DOC_CD = UPD.upd_id and doc_vrsn."LABEL" = UPD.upd_lbl
where 1 = 1
and doc_vrsn.path LIKE '/PRD Records Management%'
and src_cd = 'QDOCS'
and DOC_STS = 'Effective'