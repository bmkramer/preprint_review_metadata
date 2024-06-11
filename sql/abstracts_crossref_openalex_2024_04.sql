--- create 'truthtable' for presence and length of abstracts in Crossref
WITH truthtable_crossref AS (
SELECT
UPPER(TRIM(doi)) as doi,
type,
member,
IF(ARRAY_LENGTH(issued.date_parts) > 0, issued.date_parts[offset(0)], null) as published_year,
CASE
WHEN (abstract is not null) THEN TRUE
ELSE FALSE
END
as has_abstract,
LENGTH(abstract) as length_abstract,

FROM `academic-observatory.crossref_metadata.crossref_metadata20240331`),


--- deduplicate DOIs in OpenAlex on descending order of OpenAlex ID and number of citations
table_cleaned_openalex AS (
SELECT
papers.*

FROM (SELECT doi, ARRAY_AGG(id ORDER BY cited_by_count DESC, id DESC)[offset(0)] as id
FROM `academic-observatory.openalex_snapshot.works20240425` as papers
WHERE papers.doi IS NOT NULL
GROUP BY doi) as dois

LEFT JOIN `academic-observatory.openalex_snapshot.works20240425` as papers ON papers.id = dois.id
),


--- create 'truthtable' for presence and length of abstracts in OpenAlex
truthtable_openalex AS (
SELECT
UPPER(TRIM(SUBSTRING(doi, 17))) as doi,
-- Abstracts
CASE
WHEN ARRAY_LENGTH(abstract_inverted_index.keys) > 0 THEN TRUE
ELSE FALSE
END
as has_abstract,
ARRAY_LENGTH(abstract_inverted_index.keys) as length_abstract,

FROM table_cleaned_openalex
),

-- Join tables on doi
qdoi_table AS (
SELECT

crossref.doi,
crossref.published_year,
crossref.type,
crossref.member,

crossref.has_abstract as crossref_has_abstract,
crossref.length_abstract as crossref_length_abstract,

openalex.has_abstract as openalex_has_abstract,
openalex.length_abstract as openalex_length_abstract,

FROM
truthtable_crossref as crossref
INNER JOIN truthtable_openalex as openalex on crossref.doi = openalex.doi
),

--- aggregate counts per Crossref member ID
table_agg AS (

SELECT
member,
COUNT(DISTINCT doi) as crossref_dois
, COUNT(DISTINCT IF(crossref_has_abstract, doi, null)) as crossref_has_abstract
, COUNT(DISTINCT IF(openalex_has_abstract, doi, null)) as openalex_has_abstract

, COUNT(DISTINCT IF((NOT openalex_has_abstract AND crossref_has_abstract), doi, null)) as crossref_abstract_adds_presence
, COUNT(DISTINCT IF((openalex_length_abstract < crossref_length_abstract), doi, null)) as crossref_abstract_adds_length

, COUNT(DISTINCT IF((NOT crossref_has_abstract AND openalex_has_abstract), doi, null)) as openalex_abstract_adds_presence
, COUNT(DISTINCT IF((crossref_length_abstract < openalex_length_abstract), doi, null)) as openalex_abstract_adds_length

FROM qdoi_table
WHERE published_year in (2022, 2023, 2024) AND type in ('journal-article')
GROUP BY member
ORDER BY crossref_dois DESC
),

--- calculate percentages, add publisher names from crossref member route
--- R script Crossref member data table: 
--- https://github.com/bmkramer/crossref_issn_member_location/blob/main/01b_crossref_members_location.R
table_final AS (

SELECT

a.*,
ROUND(SAFE_DIVIDE(a.crossref_has_abstract, crossref_dois)*100, 1) as pc_crossref_abstracts,
ROUND(SAFE_DIVIDE(a.openalex_has_abstract, crossref_dois)*100, 1) as pc_openalex_abstracts,
b.member_primary_name as publisher_name

FROM TABLE_AGG as a
LEFT JOIN `utrecht-university.crossref.member_data_20240123` as b
ON (a.member) = (b.member_id)

ORDER BY crossref_dois DESC

)

SELECT * FROM table_final