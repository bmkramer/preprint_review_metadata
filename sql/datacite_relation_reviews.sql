--- get all reviews from DataCite (n=6551)
WITH TABLE_PR AS (
SELECT


doi as pr_doi,
publicationYear as pr_publicationYear,
types.resourceType as pr_resourceType,
types.resourceTypeGeneral as pr_resourceTypeGeneral,
container.title as pr_container_title,
container.type as pr_container_type,
publisher as pr_publisher,
relatedIdentifier.relatedIdentifier as pr_relatedIdentifier,
relatedIdentifier.relatedIdentifierType as pr_relatedIdentifierType,
relatedIdentifier.relationType as pr_relationType,


FROM `[project].datacite.datacite20231231`
LEFT JOIN UNNEST(relatedIdentifiers) as relatedIdentifier


WHERE publicationYear = 2023 AND relationType = "Reviews"


),


--- select preprints from Crossref for matching
TABLE_P_CROSSREF AS (


SELECT


doi as cr_p_doi,
type as cr_p_type,
subtype as cr_p_subtype,
created.date_parts[SAFE_OFFSET(0)] as cr_p_year,
container_title[SAFE_OFFSET(0)] as cr_p_container_title,
institution[SAFE_OFFSET(0)].name as cr_p_institution,
group_title as cr_p_group_title,
publisher as cr_p_publisher


FROM `academic-observatory.crossref_metadata.crossref_metadata20240731`
WHERE ((type = "posted-content" and subtype = "preprint")
OR prefix = "10.12688" --- F1000-hosted platforms
OR prefix = "10.2139" --- all of SSRN
)




),


--- select preprints from DataCite for matching
TABLE_P_DATACITE AS (


SELECT


doi as dc_p_doi,
publicationYear as dc_p_publicationYear,
types.resourceType as dc_p_resourceType,
types.resourceTypeGeneral as dc_p_resourceTypeGeneral,
container.title as dc_p_container_title,
container.type as dc_p_container_type,
publisher as dc_p_publisher,


FROM `academic-observatory.datacite.datacite20231231`
WHERE types.resourceType IN ("Preprint", "Working paper") OR types.resourceTypeGeneral = "Preprint"
--- NB resourceType checked manually for relationType = "Reviews" - many more permutations of preprint / working paper exist in full database
),


--- match peer reviews to Crossref and DataCite preprints
TABLE_JOIN AS (


SELECT DISTINCT


a.*,
b.*,
c.*


FROM TABLE_PR as a
LEFT JOIN TABLE_P_CROSSREF as b
ON UPPER(a.pr_relatedIdentifier) = UPPER(b.cr_p_doi)
LEFT JOIN TABLE_P_DATACITE as c
ON UPPER(a.pr_relatedIdentifier) = UPPER(c.dc_p_doi)




),


--- keep only peer reviews matched to Crossref and DataCite preprints
TABLE_SELECT AS (


SELECT * FROM TABLE_JOIN
WHERE cr_p_doi is not null OR dc_p_doi is not null




),


--- add names of preprint/review platforms
TABLE_NAMES AS (


SELECT


*,


CASE
WHEN pr_publisher = "Zenodo" THEN "Zenodo"
WHEN pr_publisher = "F1000 Research Limited" THEN "F1000 Research"
WHEN pr_publisher = "Gates Open Research" THEN "F1000 Research"
WHEN pr_publisher = "HRB Open Research" THEN "F1000 Research"
ELSE null END as pr_platform,


CASE
WHEN dc_p_publisher = "arXiv" THEN "arXiv (DataCite)"
WHEN dc_p_publisher = "Zenodo" THEN "Zenodo (DataCite)"
WHEN dc_p_publisher = "AfricArXiv" THEN "AfricArXiv (DataCite)"
WHEN cr_p_institution = "bioRxiv" THEN "bioRxiv"
WHEN cr_p_institution = "medRxiv" THEN "medRxiv"
WHEN cr_p_publisher = "F1000 Research Ltd" THEN "F1000 Research"
WHEN cr_p_publisher = "California Digital Library (CDL)" THEN "CDL (EcoEvoRxiv)"
WHEN cr_p_publisher = "Center for Open Science" THEN "Center for Open Science"
WHEN cr_p_publisher = "MDPI AG" THEN "Preprints.org (MDPI)"
WHEN cr_p_publisher = "FapUNIFESP (SciELO)" THEN "SciELO"
ELSE null END as p_platform


FROM TABLE_SELECT


)


SELECT DISTINCT * FROM TABLE_NAMES