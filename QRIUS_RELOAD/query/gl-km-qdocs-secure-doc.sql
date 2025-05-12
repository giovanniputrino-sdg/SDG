select distinct
0 AS cnt
, DOC_VRSN_CD
,'https://soag-z1.am.lilly.com:8443/IEP/qdocs/getDocument?documentID=' || DOC_CD || '&major version=' || left("LABEL", len("LABEL") - CHARINDEX('.', REVERSE("LABEL"))) || '&minor version=' || right ("LABEL",len("LABEL") - CHARINDEX('.',
"LABEL")) || '&rendition=pdf' as kdoc
,'https://soag-z1.am.lilly.com:8443/IEP/qdocs/getDocument?documentID=' || DOC_CD || '&major version=' || left("LABEL", len("LABEL") - CHARINDEX('.', REVERSE("LABEL"))) || '&minor version=' || right ("LABEL",
len("LABEL") - CHARINDEX('.',
"LABEL")) || '&rendition=pdf' as url
, UPD.UPDATE_TMSTMP AS updt_tmstmp
from gmdf_core.mdm_qdocs_doc_vrsn doc_vrsn
inner join
(select distinct DOC_CD as upd_id,
"LABEL" as upd_lbl,
max(UPDATE_TMSTMP) over (partition by DOC_CD, "LABEL") as UPDATE_TMSTMP
from gmdf_core.mdm_qdocs_doc_vrsn
where src_cd = 'QDOCS'
and DOC_STS = 'Effective') UPD
on doc_vrsn.DOC_CD = UPD.upd_id and doc_vrsn."LABEL" = UPD.upd_lbl
where 1 = 1
and src_cd = 'QDOCS'
and DOC_STS = 'Effective'
and SECURE_FLG <> 'Yellow-Public'
and (
AREA in (select AREA from gmdf_core.qrius_qdocs_filters
where AREA is not null and DEPT is null)
OR
LOCATION in (select LOCATION from gmdf_core.qrius_qdocs_filters where LOCATION is not null)
OR
(AREA, DEPT) in (select AREA, DEPT from gmdf_core.qrius_qdocs_filters
where AREA is not null and DEPT is not null)
)
and (SECURE_FLG, SECURITY_GROUP) not in (select SECURE_FLG, SECURITY_GROUP
from gmdf_core.qrius_qdocs_excluded_security_groups)
order by updt_tmstmp asc
limit 20000
;