select
0 AS cnt
, 'https://soag-z1.am.lilly.com:8443/IEP/qdocs/getDocument?documentID=' || DOC_CD || '&major version=' || LEFT("LABEL", len("LABEL") - CHARINDEX('.', REVERSE("LABEL"))) || '&minor version=' || right ("LABEL", len("LABEL") - CHARINDEX('.',"LABEL")) || '&rendition=pdf' AS kdoc
, 'https://soag-z1.am.lilly.com:8443/IEP/qdocs/getDocument?documentID=' || DOC_CD || '&major version=' || LEFT("LABEL", len("LABEL") - CHARINDEX('.', REVERSE("LABEL"))) || '&minor version=' || right ("LABEL", len("LABEL") - CHARINDEX('.',"LABEL")) || '&rendition=pdf' AS url
, EFCTV_OUT_DT as lbl_dateout
from gmdf_core.mdm_qdocs_doc_vrsn
where 1 = 1
and src_cd = 'QDOCS'
and DOC_STS = 'Effective'
and SECURE_FLG = 'Yellow-Public'
and (
AREA in (select AREA from gmdf_core.qrius_qdocs_filters where AREA is not null and DEPT is null)
OR
LOCATION in (select LOCATION from gmdf_core.qrius_qdocs_filters where LOCATION is not null)
OR
(AREA, DEPT) in (select AREA, DEPT from gmdf_core.qrius_qdocs_filters where AREA is not null and DEPT is not null)
)
and (SECURE_FLG, SECURITY_GROUP) not in (select SECURE_FLG, SECURITY_GROUP from gmdf_core.qrius_qdocs_excluded_security_groups)
limit 2000