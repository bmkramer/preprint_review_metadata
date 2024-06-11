# More open abstracts
SQL code accompanying blogpost **'More open abstracts! Comparing abstract coverage in Crossref and OpenAlex'**

SQL script to collect data on abstract coverage (and abstract length) for Crossref DOIs in Crossref and OpenAlex, aggregated by publisher.

Blogpost: [link] 
Dataset: [link]

The repository contains the folllowing SQL script:
* abstracts_crossref_openalex_2024_04.sql

The script is used to collect data on abstract coverage (and abstract length) for Crossref DOIs in Crossref and OpenAlex, and aggregate the data by publisher.

This analysis was performed using [Curtin Open Knowledge Initiative (COKI)](https://openknowledge.community/) infrastructure, which is documented on GitHub: https://github.com/The-Academic-Observatory. Here, a number of open data sources (including Crossref, OpenAlex and OpenAIRE) are ingested into a Google Big Query environment, which can then be queried via SQL.

In particular,the script uses the following data sources:
- Crossref (data snapshot 2024-03-31), provided by Crossref to COKI as Metadata Plus subscriber
- OpenAlex (data snapshot 2024-04-25), provided by OurResearch via Amazon AWS (see https://docs.openalex.org/download-all-data/openalex-snapshot), ingested by COKI in Google Big Query
- Data on Crossref members (member ID and member name) derived from Crossref member route API: [crossref.member_data_20240123.csv](https://github.com/bmkramer/crossref_issn_member_location/blob/main/data/2024-01-23/crossref_members_location_2024-01-23.csv) using a custom [R-script](https://github.com/bmkramer/crossref_issn_member_location/blob/main/01b_crossref_members_location.R) 

