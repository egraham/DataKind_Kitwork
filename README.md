## Work with DataKind Data Kit 2024 - R script for Challenge #2
Challenge #2: [https://github.com/datakind/datakit-housing-fall-2024/discussions/2](https://github.com/datakind/datakit-housing-fall-2024/discussions/2)

`DataKit_generate_formatted.R`, is the first step towards reproducing the DataKind 2024 Data Kit for Challenge 2 - Anticipating Household Displacement in Communities California.

The reasons for reproducing the data set are to (1) familiarize myself with the data, (2) allow others to build alternative US state or county "Data Kit" data sets (beyond CA and FL) to apply their analyses on those, and (3) possibly leverage any work done on the data sets by others to apply their work to King County, WA. And to practice my R skills.

These data are also available via the DataKind website interface, but on a county-level web-form basis (not state-wide, as far as I can tell).  This script will download and format state-level data, selecting only the data in the DataKit (other values are available in the downloaded data but are not saved in a CSV output file here).

`DataKit_generate_formatted.R` goes through each data **source** and tries to match what is found in both the data_dictionary_1-CA.csv and data_dictionary_2-CA.csv files.

Working from the document, data_dictionary_1-CA.csv, the list of sources is:

1. American Community Survey (ACS) Census Data
2. Community Development Financial Institutions Fund - Areas of Economic Distress.
3. Community Development Financial Institutions Fund - Areas of Investment.
4. HUD - Opportunity Zones (U.S. Department of Housing and Urban Development)
5. U.S. Federal Financial Institutions Examination Council (FFIEC)
6. U.S. Small Business Administration (SBA)
7. Working from the document, data_dictionary_2-CA.csv, additional sources are: 7. CEJST - Communities Data, Climate and 8. Economic Justice Screening Tool (CEJST) 8. EJScreen - Indexes, Environmental Protection Agency (EPA) 
9. Low Income Housing Tax Credit (LIHTC) Program - Qualified Census Tracts, U.S. Department of Housing and Urban Development (HUD)

For the most part, I was able to find the specific data sets, download, and process the data to match the DataKind Data Kit CA data sets. Please see the end of this document for a list and the following section for details:

### Each source:

1. American Community Survey (ACS) Census Data - Success, a match with the DataKind Data Kit values.

2. CDFI Fund (Areas of Economic Distress) - Success, with notes: Is there a source here that I'm missing so that this index does not have to be calculated here?

   - Part (a): "yes if at least 20 percent of households in the census tract are very low-income [50% of the area median income] renters or owners who pay more than half their income for housing. no if otherwise."

     - **Note:** the above statement is ambiguous: do owners also need to be very low-income? Do very low-income renters need to pay more than half their income for housing?

     - **Note:** Will assume that both renters and owners are very low income and also both pay more than half their income towards housing.
   
   - Part (d): "yes if greater than 20% of households in the census tract have incomes below the poverty rate and the census tract has a rental vacancy rate of at least 10 percent. no if otherwise."

     - **Note:** These criteria are ambiguous. Will assume that "below the poverty rate" is the same as "very low-income [50% of t. he area median income]"

   - Part (e)" "yes if greater than 20% of households in the census tract have incomes below the poverty rate and the census tract has an owner vacancy rate of at least 10 percent. no if otherwise."

     - **Note:** These criteria are ambiguous. Will assume that "below the poverty rate" is the same as "very low-income [50% of the area median income]"

     - **Note:** Owner vacancy rate does not appear to be calculable from the HUD CHAS housing data. "Vacant for sale" is perhaps the closest?

   - Part (f): "yes if census tract is (1) a non-metropolitan area that: (i) qualifies as a low-income area; and (ii) is experiencing economic distress evidenced by 30 percent or more of resident households with one or more of these four housing conditions in the most recent census for which data are available: (a) lacking complete plumbing, (b) lacking complete kitchen, (c) paying 30 percent or more of income for owner costs or tenant rent, or (d) having more than 1 person per room. no if otherwise. "

     - **Note:** These criteria are ambiguous. Will assume that "low-income area" is not the same as "very low income" (above) and is thus: "greater than 50% but less than or equal to 80% of HAMFI"

     - **Note:** No CHAS designations for "non-metropolitan areas". Will need to cross-reference census data for Block-level Urban Area information for the 2020 Census from this page:
[https://www.census.gov/programs-surveys/geography/guidance/geo-areas/urban-rural.html](https://www.census.gov/programs-surveys/geography/guidance/geo-areas/urban-rural.html)

3. CDFI Fund (Investment Areas)
   - Investment Areas - Success
   - Transaction Level Report - Success

4. HUD - Opportunity Zones - Success

5. U.S. Federal Financial Institutions Examination Council (FFIEC) - Success

6. U.S. Small Business Administration (SBA) - **Fail**
   - The SBA source data are not immediately compatible with current Data Kit information.
   - Source download lacks census tract (geoid) information.
   - Source data include address, city, state, and zip codes.  A lookup per address to gain census tract information is possible: [https://geocoding.geo.census.gov/geocoder/geographies/address?](https://geocoding.geo.census.gov/geocoder/geographies/address?)
   - Rather than do an address lookup for each entry in a county, a zipcode-to-tract-lookup was be used.  This results in a different value compared with the Data Kit values.
   - Using a Zip code Census tract crosswalk file is an approximation: [https://www.huduser.gov/portal/datasets/usps_crosswalk.html](https://www.huduser.gov/portal/datasets/usps_crosswalk.html)

7. Climate and Economic justice Screening Data - moderate success
   - **Note:** CEJST_communities_list_data match for most of the data values in the Data Kit set.  Non-matches may be updates?

8. EPA EJScreen Data - Success

9. Low Income Housing Tax Credit (LIHTC) Program - Success

Inconsistencies with DataKit and this output data_1.csv file
- All data from SBA:
  - median_sba504_loan_amount
  - median_sba7a_loan_amount
  - number_of_sba504_loans
  - number_of_sba7a_loans

These data do not appear in the online DataKind set:
- CDFI Fund (Areas of Economic Distress):
  - economic_distress_pop_agg
  - economic_distress_simple_agg
