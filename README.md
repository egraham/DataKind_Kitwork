# DataKind_Kitwork
Work with DataKind Data Kit 2024

The initial R script, DataKit_explore.R, is the first step towards reproducing the DataKind 2024 Data Kit for Challenge 2 - Anticipating Household Displacement in Communities California.  

The reasons for reproducing the data set are to (1) familiarize myself with the data (and there are also more data in the online available sets than are presented in the DataKit data sets), (2) allow others to build alternative US county "Data Kit" data sets (beyond CA and FL) to apply their analyses on those, and (3) possibly leverage any work done on the data sets by others to apply their work to King County, WA. 

The script goes through each data source and tries to match a subset of what is found in both the data_dictionary_1-CA.csv and data_dictionary_2-CA.csv files.

Challenge #2: https://github.com/datakind/datakit-housing-fall-2024/discussions/2

Working from the document, data_dictionary_1-CA.csv, the list of sources is:

1. American Community Survey (ACS) Census Data
2. Community Development Financial Institutions Fund - Areas of Economic Distress.
3. Community Development Financial Institutions Fund - Areas of Investment.
4. HUD - Opportunity Zones (U.S. Department of Housing and Urban Development)
5. U.S. Federal Financial Institutions Examination Council (FFIEC)
6. U.S. Small Business Administration (SBA)

Working from the document, data_dictionary_2-CA.csv, *additional* sources are:

7. CEJST - Communities Data, Climate and Economic Justice Screening Tool (CEJST)
8. EJScreen - Indexes, Environmental Protection Agency (EPA)
9. Low Income Housing Tax Credit (LIHTC) Program - Qualified Census Tracts, U.S. Department of Housing and Urban Development (HUD)

For the most part, I was able to find the specific data sets, download, and process the data to match the DataKind Data Kit CA data sets.  However, some I failed to reproduce some subsets.  Specifically:

1. American Community Survey (ACS) Census Data - Success

2. CDFI Fund (Areas of Economic Distress) - Success, with notes:
# part (a): "yes if at least 20 percent of households in the census tract are very low-income [50% of the area median income] renters or owners who pay more than half their income for housing.  no if otherwise."
# Note: the above statement is ambiguous: do owners also need to be very low-income?  Do very low-income renters need to pay more than half their income for housing?
# Note: Will assume that both renters and owners are very low income and also both pay more than half their income towards housing.
# part (d): "yes if greater than 20% of households in the census tract have incomes below the poverty rate and the census tract has a rental vacancy rate of at least 10 percent. no if otherwise."
# Note: These criteria are ambiguous. Will assume that "below the poverty rate" is the same as "very low-income [50% of the area median income]"
# part (e)" "yes if greater than 20% of households in the census tract have incomes below the poverty rate and the census tract has an owner vacancy rate of at least 10 percent. no if otherwise."
# Note: These criteria are ambiguous. Will assume that "below the poverty rate" is the same as "very low-income [50% of the area median income]"
# Note: Owner vacancy rate does not appear to be calculable from the HUD CHAS housing data.  "Vacant for sale" is perhaps the closest?
# part (f): "yes if census tract is (1) a non-metropolitan area that: (i) qualifies as a low-income area; and (ii) is experiencing economic distress evidenced by 30 percent or more of resident households with one or more of these four housing conditions in the most recent census for which data are available: (a) lacking complete plumbing, (b) lacking complete kitchen, (c) paying 30 percent or more of income for owner costs or tenant rent, or (d) having more than 1 person per room.  no if otherwise.  "
# Note: These criteria are ambiguous. Will assume that "low-income area" is not the same as "very low income" (above) and is thus: "greater than 50% but less than or equal to 80% of HAMFI"
# Note: No CHAS designations for "non-metropolitan areas". Will need to cross-reference census data for Block-level Urban Area information for the 2020 Census from this page: https://www.census.gov/programs-surveys/geography/guidance/geo-areas/urban-rural.html

3. CDFI Fund (Investment Areas) - Success

4. HUD - Opportunity Zones - Success

5. U.S. Federal Financial Institutions Examination Council (FFIEC) - Success

6. U.S. Small Business Administration (SBA) - Fail
# These data are NOT granular to census tract, but include address and zip codes.
# Rather than do an address lookup for each entry in a county, a zipcode-to-tract-lookup will be used.  This results in a different value compared with the Data Kit values.
# Using a Zip code Census tract crosswalk file is an approximation: https://www.huduser.gov/portal/datasets/usps_crosswalk.html

7. Climate and Economic justice Screening Data - Fail
# Note: CEJST_communities_list_data for energy and burden are all integers, no real numbers. Data Kit values for energy_burden_percentile are all real numbers; for burden, half are real.  Matches seem suspect.

8. EPA EJScreen Data - Success

9. Low Income Housing Tax Credit (LIHTC) Program - Success
