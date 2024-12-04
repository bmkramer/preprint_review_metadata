WITH TABLE_SUBJECT AS (
SELECT


doi as pr_doi,
type as pr_type,
subtype as pr_subtype,
created.date_parts[SAFE_OFFSET(0)] as pr_year,
container_title[SAFE_OFFSET(0)] as pr_container_title,
institution[SAFE_OFFSET(0)].name as pr_institution,
group_title as pr_group_title,
publisher as pr_publisher,
var.id as pr_id_object,
var.id_type as pr_id_type_object


FROM `[project].crossref_metadata.crossref_metadata20240731` ,
UNNEST (relation.is_review_of) as var


WHERE created.date_parts[SAFE_OFFSET(0)] = 2023
),




TABLE_OBJECT AS (


SELECT


a.*,
b.doi as p_doi,
b.type as p_type,
b.subtype as p_subtype,
b.created.date_parts[SAFE_OFFSET(0)] as p_year,
b.container_title[SAFE_OFFSET(0)] as p_container_title,
b.institution[SAFE_OFFSET(0)].name as p_institution,
b.group_title as p_group_title,
b.publisher as p_publisher


FROM TABLE_SUBJECT as a
LEFT JOIN `academic-observatory.crossref_metadata.crossref_metadata20240731` as b
ON UPPER(a.pr_id_object) = UPPER(b.doi)


WHERE (
(b.type = "posted-content" and subtype = "preprint")
OR b.prefix = "10.12688" --- F1000-hosted platforms
OR b.prefix = "10.2139" --- all of SSRN
)


),


--- add names of preprint/review platforms
TABLE_NAMES AS (


SELECT


*, 


CASE
WHEN pr_institution = "Review Commons" THEN "Review Commons"
WHEN pr_publisher = "ScienceOpen" THEN "ScienceOpen"
WHEN pr_publisher = "Copernicus GmbH" THEN "Copernicus"
WHEN pr_publisher = "Qeios Ltd" THEN "Qeios"
WHEN pr_publisher = "eLife Sciences Publications, Ltd" THEN "eLife"
WHEN pr_publisher = "Microbiology Society" THEN "Access Microbiology (MS)"
WHEN pr_publisher = "MIT Press" THEN "Rapid Reviews (MIT Press)"
WHEN (pr_publisher = "Peer Community In" OR pr_container_title LIKE "%Peer Community In%") THEN "Peer Community In"
WHEN pr_publisher = "PeerRef" THEN "PeerRef"
WHEN pr_publisher = "PubPub" THEN "PubPub"
WHEN pr_publisher = "The Company of Biologists" THEN "PreLights"
WHEN pr_container_title LIKE "%Faculty Opinions%" THEN "Faculty Opinions"
ELSE null END AS pr_platform,




CASE
WHEN p_institution = "bioRxiv" THEN "bioRxiv"
WHEN p_institution = "medRxiv" THEN "medRxiv"
WHEN p_institution = "ScienceOpen" THEN "ScienceOpen"
WHEN p_publisher = "Copernicus GmbH" THEN "Copernicus"
WHEN p_publisher = "Qeios Ltd" THEN "Qeios"
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


FROM TABLE_OBJECT


)


SELECT DISTINCT * FROM TABLE_NAMES


--- saved as `utrecht-university.PPR.crossref_pr_p_2023`
--- n = 37778 of which 36492 distinct
--- duplicates are all Copernicus - unclear why as only one preprint relation included in pr_doi