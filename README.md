# Preprint-review metadata in Crossref and DataCite
SQL code accompanying the section *Linking preprint and review metadata* in the report **Mapping the preprint review metadata transfer workflows**

* Report: https://doi.org/10.31222/osf.io/yu4sm
* Dataset: https://doi.org/10.5281/zenodo.14274273

The repository contains the folllowing SQL scripts:
* [crossref_relation_hasreview.sql](sql/crossref_relation_hasreview.sql)
* [crossref_relation_isrefviewof.sql](sql/crossref_relation_isreviewof.sql)
* [datacite_relation_isreviewedby.sql](sql/datacite_relation_isreviewedby.sql)
* [datacite_relation_reviews.sql](sql/datacite_relation_reviews.sql)


The scripts are used to identify reviewed preprints with publication year 2023 in both Crossref and DataCite, as well as preprint reviews with publication year 2023 in both systems. For reviewed preprints, information is collected about the preprint platform and, for all reviews that themselves have a DOI, the review platform. For preprint reviews, information is similarly collected about the review platform and the preprint platform. 

This analysis was performed using [Curtin Open Knowledge Initiative (COKI)](https://openknowledge.community/) infrastructure, which is documented on GitHub: https://github.com/The-Academic-Observatory. Here, a number of open data sources (including Crossref and DataCite) are ingested into a Google Big Query environment, which can then be queried via SQL.

In particular,the script uses the following data sources:
- Crossref (data snapshot 2024-07-31), provided by Crossref to COKI as Metadata Plus subscriber
- DataCite (data snapshot 2024-04-30 for records up to 2023-12-31), provided by DataCite as [public data file](https://doi.org/10.14454/zhaw-tm22) (see https://datacite.org/blog/announcing-datacites-first-public-data-file/), ingested by COKI in Google Big Query

![Preprint-review links in Crossref and DataCite](https://github.com/bmkramer/preprint_review_metadata/blob/main/figures/preprint_review_metadata.png)

