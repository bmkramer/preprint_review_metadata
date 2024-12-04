--- get all reviewed preprints from DataCite (n=63)
WITH TABLE_P AS (
SELECT


doi as p_doi,
publicationYear as p_publicationYear,
types.resourceType as p_resourceType,
types.resourceTypeGeneral as p_resourceTypeGeneral,
container.title as p_container_title,
container.type as p_container_type,
publisher as p_publisher,
relatedIdentifier.relatedIdentifier as p_relatedIdentifier,
relatedIdentifier.relatedIdentifierType as p_relatedIdentifierType,
relatedIdentifier.relationType as p_relationType,


FROM `[project].datacite.datacite20231231`
LEFT JOIN UNNEST(relatedIdentifiers) as relatedIdentifier


WHERE publicationYear = 2023 AND relationType = "IsReviewedBy"
AND (types.resourceType IN ("working_paper", "preprint") OR types.resourceTypeGeneral = "Preprint")
--- NB resourceType checked manually for all records with relationType = "IsReviewedBy" (n=294_ - as many more permutations of 'working paper' exist in full database
),




--- select peer reviews from Crossref for matching
TABLE_PR_CROSSREF AS (


SELECT


doi as cr_pr_doi,
type as cr_pr_type,
subtype as cr_pr_subtype,
created.date_parts[SAFE_OFFSET(0)] as cr_pr_year,
container_title[SAFE_OFFSET(0)] as cr_pr_container_title,
institution[SAFE_OFFSET(0)].name as cr_pr_institution,
group_title as cr_pr_group_title,
publisher as cr_pr_publisher


FROM `[project].crossref_metadata.crossref_metadata20240731`
),


--- select peer reviews from DataCite for matching
TABLE_PR_DATACITE AS (


SELECT


doi as dc_pr_doi,
publicationYear as dc_pr_publicationYear,
types.resourceType as dc_pr_resourceType,
types.resourceTypeGeneral as dc_pr_resourceTypeGeneral,
container.title as dc_pr_container_title,
container.type as dc_pr_container_type,
publisher as dc_pr_publisher,


FROM `[project].datacite.datacite20231231`


),


TABLE_JOIN AS (


SELECT DISTINCT


a.*,
b.*,
c.*


FROM TABLE_P as a
LEFT JOIN TABLE_PR_CROSSREF as b
ON UPPER(a.p_relatedIdentifier) = UPPER(b.cr_pr_doi)
LEFT JOIN TABLE_PR_DATACITE as c
ON UPPER(a.p_relatedIdentifier) = UPPER(c.dc_pr_doi)




)


SELECT DISTINCT * FROM TABLE_JOIN