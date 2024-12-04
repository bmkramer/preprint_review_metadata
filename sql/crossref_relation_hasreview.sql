WITH TABLE_SUBJECT AS (
SELECT


doi as p_doi,
type as p_type,
subtype as p_subtype,
created.date_parts[SAFE_OFFSET(0)] as p_year,
container_title[SAFE_OFFSET(0)] as p_container_title,
institution[SAFE_OFFSET(0)].name as p_institution,
group_title as p_group_title,
publisher as p_publisher,
var.id as p_id_object,
var.id_type as p_id_type_object


FROM `[project].crossref_metadata.crossref_metadata20240731` ,
UNNEST (relation.has_review) as var


WHERE ((type = "posted-content" and subtype = "preprint")
OR prefix = "10.12688" --- F1000-hosted platforms
OR prefix = "10.2139" --- all of SSRN
)
AND created.date_parts[SAFE_OFFSET(0)] = 2023
),






TABLE_OBJECT AS (


SELECT


a.*,
b.doi as pr_doi,
b.type as pr_type,
b.subtype as pr_subtype,
b.created.date_parts[SAFE_OFFSET(0)] as pr_year,
b.container_title[SAFE_OFFSET(0)] as pr_container_title,
b.institution[SAFE_OFFSET(0)].name as pr_institution,
b.group_title as pr_group_title,
b.publisher as pr_publisher


FROM TABLE_SUBJECT as a
LEFT JOIN `academic-observatory.crossref_metadata.crossref_metadata20240731` as b
ON UPPER(a.p_id_object) = UPPER(b.doi)


),




--- add names of preprint/review platforms
TABLE_NAMES AS (


SELECT


*,


CASE
WHEN p_institution = "bioRxiv" THEN "bioRxiv"
WHEN p_institution = "medRxiv" THEN "medRxiv"
WHEN p_institution = "ScienceOpen" THEN "ScienceOpen"
WHEN p_publisher = "Copernicus GmbH" THEN "Copernicus"
WHEN p_publisher = "Qeios Ltd" THEN "Qeios"
WHEN p_publisher = "F1000 Research Ltd" THEN "F1000 Research"
WHEN p_publisher = "eLife Sciences Publications, Ltd" THEN "eLife"
WHEN p_publisher = "Microbiology Society" THEN "Access Microbiology (MS)"
WHEN p_publisher = "Center for Open Science" THEN "Center for Open Science"
WHEN p_publisher = "Research Square Platform LLC" THEN "Research Square"
WHEN p_publisher = "California Digital Library (CDL)" THEN "CDL (EcoEvoRxiv)"
WHEN p_publisher = "ZappyLab, Inc." THEN "Protocols.io"
WHEN p_publisher = "Authorea, Inc." THEN "Authorea"
WHEN p_publisher = "MDPI AG" THEN "Preprints.org (MDPI)"
WHEN (p_group_title LIKE "%SSRN%" OR p_container_title LIKE "%SSRN%") THEN "SSRN"
ELSE null END AS p_platform,


CASE
WHEN pr_institution = "Review Commons" THEN "Review Commons"
WHEN pr_publisher = "ScienceOpen" THEN "ScienceOpen"
WHEN pr_publisher = "Copernicus GmbH" THEN "Copernicus"
WHEN pr_publisher = "Qeios Ltd" THEN "Qeios"
WHEN pr_publisher = "eLife Sciences Publications, Ltd" THEN "eLife"
WHEN pr_publisher = "Microbiology Society" THEN "Access Microbiology (MS)"
WHEN pr_publisher = "MIT Press" THEN "Rapid Reviews (MIT Press)"
WHEN pr_publisher = "PeerRef" THEN "PeerRef"
WHEN pr_publisher = "PubPub" THEN "PubPub"
WHEN pr_publisher = "UCL Press" THEN "ScienceOpen"
WHEN (pr_publisher = "Peer Community In" OR pr_container_title LIKE "%Peer Community In%") THEN "Peer Community In"
WHEN pr_container_title LIKE "%Faculty Opinions%" THEN "Faculty Opinions"
ELSE null END AS pr_platform,


FROM TABLE_OBJECT


)


SELECT DISTINCT * FROM TABLE_NAMES

--- n = 36428 of which 34713 distinct
--- duplicates are all Copernicus where reviews are asserted by subject and object
