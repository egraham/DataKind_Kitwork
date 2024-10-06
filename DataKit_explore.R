# Initial script for step 1 of reproducing the DataKind 2024 Data kit for Anticipating 
#   Household Displacement in Communities California: Challenge #2.
#   https://github.com/datakind/datakit-housing-fall-2024/discussions/2

# I would like to reproduce this for any county in the US, but specifically for King County, WA

# Working from the document, data_dictionary_1-CA, the list of sources is:
#   1. American Community Survey (ACS) Census Data
#   2. Community Development Financial Institutions Fund - Areas of Economic Distress.
#   3. Community Development Financial Institutions Fund - Areas of Investment.
#   4. HUD - Opportunity Zones (U.S. Department of Housing and Urban Development)
#   5. U.S. Federal Financial Institutions Examination Council (FFIEC)
#   6. U.S. Small Business Administration (SBA)

# Working from the document, data_dictionary_2-CA, *additional* sources are:
#   7. CEJST - Communities Data, Climate and Economic Justice Screening Tool (CEJST)
#   8. EJScreen - Indexes, Environmental Protection Agency (EPA)
#   9. Low Income Housing Tax Credit (LIHTC) Program - Qualified Census Tracts, U.S. Department of Housing and Urban Development (HUD)

# Needed packages: an attempt was made to keep it as simple as possible:
# Install and load the package "tidycensus" for downloading and manipulating US census data, 
#   as outlined here: https://walker-data.com/census-r/an-introduction-to-tidycensus.html. Much
#   of the comments about usage here are copy-pasted from this document.
#install.packages("tidycensus")

# One data set is in Excel BINARY format: Do NOT install or use "readxlsb" package - described as "eye wateringly slow", which I also confirm.  Instead, use:
#install.packages("RODBC")

# load libraries 
library(tidycensus)
library(tidyverse)
# Need to load readxl explicitly, not a core tidyverse package
library(readxl)
library(RODBC)

# Each data source will be tested, below, for import into R and initial verification with one CA 
#   datum to make sure that I am correctly accessing the data set:

###############################################################################################
# 1. ################## American Community Survey (ACS) Census Data ###########################
###############################################################################################
# Success

# API keys can be obtained at https://api.census.gov/data/key_signup.html. After you’ve 
#   signed up for an API key, be sure to activate the key from the email you receive.
# Declaring install = TRUE when calling census_api_key() will install the key for use in future R sessions

#census_api_key("YOUR KEY GOES HERE", install = TRUE)
census_api_key <- Sys.getenv("CENSUS_API_KEY")

# Variable IDs are required to fetch data from the Census and ACS APIs. There are thousands of variables available across the different datasets and summary files. The 'load_variables()' function obtains a dataset of variables and formats it for fast searching. Because this function requires processing thousands of variables from the Census Bureau, the user can specify 'cache = TRUE' to store the data in the user’s cache directory; on subsequent calls, ' of the load_variables() function, 'cache = TRUE' will direct the function to look in the cache directory for the variables rather than the Census website.

# ACS Detailed Tables (contains prefix "B" in a Variable ID, example: "b23025_004e"):
ACS5_2020 <- load_variables(2020, "acs5", cache = TRUE)
# Data Profile (prefix P), Summary (prefix S), and Comparison Profile (prefix CP) tables 
#   within the ACS:
ACS5_2020_Profile <- load_variables(2020, "acs5/profile", cache = TRUE)
ACS5_2020_Subject <- load_variables(2020, "acs5/subject", cache = TRUE)
ACS5_2020_Comparison <- load_variables(2020, "acs5/cprofile", cache = TRUE)

# # Previous years:
#ACS5_2010 <- load_variables(2010, "acs5", cache = TRUE)

# The 2020 1-year ACS was released as a set of experimental estimates that was not published
#   to the Census API and is in turn not available in tidycensus.
#ACS1_2020 <- load_variables(2020, "acs1", cache = TRUE)

################ Manually explore tidycensus to compare to Data Kit data ######################

# Find an ACS code and value in the DataKind Challenge #2 Data Kit
#   and determine if tidycensus will return the same value
# Will do this for Summary, Subject, and Profile tables, just because

# ACS code copy-pasted from DataKind Data Kit "data_1-CA.csv", first line of data
#   columns 103-104.  Make upper-case for query:
ACS_code_summary <- str_to_upper("b23025_004e", locale = "en")
# Remove the trailing letter (E for estimate or M for margin of error) because
#   tidycensus will return both
ACS_code_summary <- substring(ACS_code_summary, 1, str_length(ACS_code_summary)-1)

# Search for the ACS code in the list of codes downloaded and cached above,
#   main summary table because ACS code stars with "b":
#ACS5_2020[ACS5_2020$name==ACS_code_summary,]

# Pull the data from the online source:
number_employed_Tract_2022 <- get_acs(
  geography = "tract", 
  state = "CA", 
  variables = "B23025_004",
  year = 2022
)

#### Data for 2022 matches from three sources
# Data from Data Kit:
#  06001400400,estimate = 2538, error = 423
# Data from online
#   https://data.census.gov/table?q=B23025&g=1400000US06001400400&y=2022
#   Filters: Census Tract 4004, year = 2022
#   Employed, 2538 +/- 423
# Results from the tidycensus poll below:
#  06001400400, 2538, 423
number_employed_Tract_2022[number_employed_Tract_2022$GEOID=="06001400400",]

# ACS code copy-pasted from DataKind Data Kit "data_1-CA.csv", first line of data
#   columns 18-19.
ACS_code_subject <- str_to_upper("s0101_c03_032e", locale = "en")
ACS_code_subject <- substring(ACS_code_subject, 1, str_length(ACS_code_subject)-1)

# Search for the ACS code in the list of codes downloaded and cached above,
#   sub-table Subject because ACS code stars with "s":
#ACS5_2020_Subject[ACS5_2020_Subject$name==ACS_code_subject,]

# Pull the data
median_pop_male_age_Tract_2022 <- get_acs(
  geography = "tract", 
  state = "CA", 
  variables = "S0101_C03_032",
  year = 2022
)

#### Data for 2022 matches from three sources
# Data from Data Kit:
#  06001400400, s0101_c03_032m = 4.3, s0101_c03_032e = 39.2
# Data from online
#   https://data.census.gov/table?q=S0101:%20Age%20and%20Sex&g=1400000US06001400400&y=2022
#   Filters: Census Tract 4004, year = 2022
#   39.2 +/- 4.3
# Results from the tidycensus poll below:
#  06001400400, 39.2, 4.3
median_pop_male_age_Tract_2022[median_pop_male_age_Tract_2022$GEOID=="06001400400",]

# ACS code copy-pasted from DataKind Data Kit "data_1-CA.csv", first line of data
#   column 100 (no error column).  Make upper-case for query:
ACS_code_profile <- str_to_upper("dp05_0044pe", locale = "en")
ACS_code_profile <- substring(ACS_code_profile, 1, str_length(ACS_code_profile)-1)

# Search for the ACS code in the list of codes downloaded and cached above,
#   sub-table Subject because ACS code stars with "s":
#ACS5_2020_Profile[ACS5_2020_Profile$name==ACS_code_profile,]

# Pull the data
pop_percent_by_race_Asian_alone_Tract <- get_acs(
  geography = "tract", 
  state = "CA", 
  variables = "DP05_0044P",
  year = 2022
)
#### Data for 2022 matches from three sources! ####
# Data from Data Kit:
#  06001400400, 8.7
# Data from online
#   https://data.census.gov/table/ACSDP5Y2022.DP05?q=DP05&g=1400000US06001400400&y=2022
#   Filters: Census Tract 4004, year = 2022
#   8.7 +/- 2.7
# Results from the tidycensus poll below:
#  06001400400, 8.7, 2.7
pop_percent_by_race_Asian_alone_Tract[pop_percent_by_race_Asian_alone_Tract$GEOID=="06001400400",]

###############################################################################################
# 2. ######################## CDFI Fund (Areas of Economic Distress) ##########################
###############################################################################################
# Success, with notes

# CDFI Fund - Aggregated by Land (census tract)
# API does not allow for census tract-level query, file downloads required

# Procedure:
# Population weighting aggregation methodology: yes if any of any of items (a) - (f) is yes.  no if otherwise:

###########################################################################
# (a) yes if at least 20 percent of households in the census tract are very low-income [50% of the area median income] renters or owners who pay more than half their income for housing.  no if otherwise.

# Note: the above statement is ambiguous: do owners also need to be very low-income?  Do very low-income renters need to pay more than half their income for housing?
# Note: Will assume that both renters and owners are very low income and also both pay more than half their income towards housing.

# source: american community survey special tabulations (CHAS) 2013 5-year estimates and u.s. department of housing and urban development. on july 6, 2016 HUD released updated CHAS data for the 2009-2013 period. 

# Manual download from web form and save zip in downloaded data sets directory for 
#   repeated, multiple sheet access.

# https://www.huduser.gov/portal/datasets/cp.html. To match DataKind Data Kit, use form submission on this page for Data tab: 2009-2013 ACS 5-year avg data, Census Tracts resolution.

# # Data are in Zip format, so need to download manually, unzip:
HUD_CHAS_tract_Table3 <- read_csv(unz("downloaded_data_sets/2009thru2013-140-csv.zip", "Table3.csv"))

# Tables that are needed to fulfill the above item:
# T3_est1	Total	Total: Occupied housing units
# T3_est2	Subtotal	Owner occupied
# T3_est22 Owner occupied AND with housing cost burden greater than 50%, none of the needs above AND household income is less than or equal to 30% of HAMFI
# T3_est23 Owner occupied AND with housing cost burden greater than 50%, none of the needs above AND household income is greater than 30% but less than or equal to 50% of HAMFI

# T3_est45 Subtotal Renter occupied
# T3_est65 Detail Renter occupied AND with housing cost burden greater than 50%, none of the needs above AND household income is less than or equal to 30% of HAMFI
# T3_est66 Detail	Renter occupied AND with housing cost burden greater than 50%, none of the needs above AND household income is greater than 30% but less than or equal to 50% of HAMFI

# Subset for energy values and for California, Alameda tract 06001400400 to compare to 
#   CA Alameda County census tract 06001400400 Data Kit values:
pay_half <- HUD_CHAS_tract_Table3 |> 
  select(tract=tract, st=st, total_occupied_housing_units=T3_est1, subtotal_owner_occupied=T3_est2, owner_30_HAMFI=T3_est22, owner_50_HAMFI=T3_est23, subtotal_renter_occupied=T3_est45, renter_30_HAMFI=T3_est65, renter_50_HAMFI=T3_est66) |> 
  filter(st == "06") |> # California
  filter(tract == "400400")

# Calculate
percent_pay_half <- (pay_half$owner_30_HAMFI + pay_half$owner_50_HAMFI + pay_half$renter_30_HAMFI + pay_half$renter_50_HAMFI) /pay_half$total_occupied_housing_units * 100

# Test if 20% are low-income and pay more than half
criterion_a <- percent_pay_half > 20.0
criterion_a
# FALSE

###########################################################################
# (b) yes if the census tract a designated qualified opportunity zones under 26 u.s. code section 1400z-1. no if otherwise.; https://www.cdfifund.gov/sites/cdfi/files/documents/designated-qozs.12.14.18.xlsx
# source: cdfi fund opportunity fund database

# # Data are in Excel format, so need to download manually, reset column names:

# # # Data are in Excel format, so need to download, read Excel file:
# destfile <- path.expand("~/temp.xlsx")
# url <- "https://www.cdfifund.gov/sites/cdfi/files/documents/designated-qozs.12.14.18.xlsx"
# download.file(url, destfile = destfile, mode = "wb")
# qualified_opp_zones <- read_excel(destfile, sheet = 1)
# unlink(destfile)

# # Save the data to avoid repeat calls
# saveRDS(qualified_opp_zones, file="downloaded_data_sets/qualified_opp_zones.RDS")

# Load the data from the saved file and display names
qualified_opp_zones <- readRDS(file="downloaded_data_sets/qualified_opp_zones.RDS")

names(qualified_opp_zones) <- c("state","county","tract","type","ACS_source")
#summary(qualified_opp_zones)

# Subset for type values and for California, Alameda tract 06001400400 to compare to 
#   CA Alameda County census tract 06001400400 Data Kit values:
qualified_opp_zones_specific <- qualified_opp_zones |> 
  filter(tract == "06001400400") |> 
  select(type)

# exists "Low-Income Community"
qualified_opp_zones_specific_TF <- dim(qualified_opp_zones_specific)[1] > 0

# Test if the criteria match a "yes" (TRUE) or a "no" (FALSE)
criterion_b  <- qualified_opp_zones_specific_TF 
criterion_b
# FALSE

###########################################################################
# (c) whether the tract is eligible as a low-income housing tax credit (lihtc) qualified census tract, january 1, 2021, https://qct.huduser.gov/ ; https://www.huduser.gov/portal/datasets/qct/qct2021csv.zip

# # Data are in zip format, so need to download and unzip:
# destfile <- path.expand("~/temp.zip")
# url <- "https://www.huduser.gov/portal/datasets/qct/qct2021csv.zip"
# download.file(url, destfile = destfile, mode = "wb")
# lihtc <- read_csv(unz(destfile, "QCT2021.csv"))
# unlink(destfile)

# # Save the data to avoid repeat calls
# saveRDS(lihtc, file="downloaded_data_sets/lihtc.RDS")

# Load the data from the saved file and display names
lihtc <- readRDS(file="downloaded_data_sets/lihtc.RDS")
#colnames(lihtc)

# If the tract exists in the document, assume lihtc eligability. 
#   Look for California, Alameda tract 06001400400 to compare to 
#   CA Alameda County census tract 06001400400 Data Kit values:
lihtc_specific <- lihtc |> 
  filter(fips == "06001400400")

# exists or not
lihtc_specific_TF <- dim(lihtc_specific)[1] > 0

# Test if the criteria match a "yes" (TRUE) or a "no" (FALSE)
criterion_c <- lihtc_specific_TF
criterion_c
# FALSE

###########################################################################
# (d) yes if greater than 20% of households in the census tract have incomes below the poverty rate and the census tract has a rental vacancy rate of at least 10 percent. no if otherwise.  
# 
# source: american community survey special tabulations (chas) 2013 5-year estimates and u.s. department of housing and urban development.

# Note: These criteria are ambiguous. Will assume that "below the poverty rate" is the same as "very low-income [50% of the area median income]"

# Tables that are needed to fulfill the above item:
# Calculate total owner + renter percentage that is below 50% HAMFI:
#   T7_est2	Subtotal Owner occupied	
#   T7_est3	Subtotal Owner occupied AND household income is less than or equal to 30% of HAMFI
#   T7_est29 Subtotal Owner occupied AND household income is greater than 30% but less than or equal to 50% of HAMFI
#   T7_est133 Subtotal Renter occupied
#   T7_est134	Subtotal Renter occupied AND household income is less than or equal to 30% of HAMFI
#   T7_est160	Subtotal Renter occupied AND household income is greater than 30% but less than or equal to 50% of HAMFI
# Calculate rental vacancy rate:
#   T14B_est1 Total Total: Vacant-for-rent housing units

# # Data are in Zip format from manually-downloaded file in working directory, unzip:
HUD_CHAS_tract_Table7 <- read_csv(unz("downloaded_data_sets/2009thru2013-140-csv.zip", "Table7.csv"))
HUD_CHAS_tract_Table14B <- read_csv(unz("downloaded_data_sets/2009thru2013-140-csv.zip", "Table14B.csv"))

# Select and filter for calculating percent households below 50% area median income and for California, Alameda tract 06001400400:
households_under <- HUD_CHAS_tract_Table7 |> 
  select(tract=tract, st=st, owner_occupied=T7_est2, owner_occupied_30=T7_est3, owner_occupied_50=T7_est29, renter_occupied=T7_est133, renter_occupied_30=T7_est134, renter_occupied_50=T7_est160) |> 
  filter(st == "06") |> # California
  filter(tract == "400400")

# calculate percent below 50% area median income
percent_under <- (households_under$owner_occupied_30 + 
                    households_under$owner_occupied_50 +
                    households_under$renter_occupied_30 +
                    households_under$renter_occupied_50) / 
  (households_under$owner_occupied +
     households_under$renter_occupied) * 100

# Select and filter for calculating rental vacancy rate
rental_vac <- HUD_CHAS_tract_Table14B |>
  select(tract=tract, st=st, vacant_for_rent=T14B_est1) |> 
  filter(st == "06") |> # California
  filter(tract == "400400")

percent_rental_vac_rate <- rental_vac$vacant_for_rent / (rental_vac$vacant_for_rent + households_under$renter_occupied) * 100

# Test if the percent households below 50% area median income AND percent rental 
#    vacany rate >= 10%
criterion_d <- percent_under < 20.0 & percent_rental_vac_rate >= 10.0
criterion_d
# FALSE

###########################################################################
# (e) yes if greater than 20% of households in the census tract have incomes below the poverty rate and the census tract has an owner vacancy rate of at least 10 percent. no if otherwise.  
# 
# source: american community survey special tabulations (chas) 2013 5-year estimates and u.s. department of housing and urban development.

# Note: These criteria are ambiguous. Will assume that "below the poverty rate" is the same as "very low-income [50% of the area median income]"
# Note: Owner vacancy rate does not appear to be calculable from the HUD CHAS housing data.  
#   "Vacant for sale" is perhaps the closest?

# Tables needed to calculate owner vacant for sale rate:
# T3_est1	Total	Total: Occupied housing units
# T14A_est1 Total Total: Vacant-for-sale housing units

total_occupied <- HUD_CHAS_tract_Table3 |> 
  select(tract=tract, st=st, total_occupied_housing=T3_est1) |> 
  filter(st == "06") |> # California
  filter(tract == "400400")

# # Data are in Zip format from manually-downloaded file in working directory, unzip:
HUD_CHAS_tract_Table14A <- read_csv(unz("downloaded_data_sets/2009thru2013-140-csv.zip", "Table14A.csv"))

# Select and filter for calculating percent households below 50% area median income and for California, Alameda tract 06001400400:
owner_vacant <- HUD_CHAS_tract_Table14A |> 
  select(tract=tract, st=st, owner_vacant=T14A_est1) |> 
  filter(st == "06") |> # California
  filter(tract == "400400")

# Calculate owner vacancy rate
owner_vacant_percent <- owner_vacant$owner_vacant / (total_occupied$total_occupied_housing +
                           owner_vacant$owner_vacant) *100

# Test if the percent households below 50% area median income and owner vacancy rate is at least 10%:
criterion_e <- percent_under < 20.0 & owner_vacant_percent > 10.0
criterion_e
# FALSE

###########################################################################
# (f) yes if census tract is (1) a non-metropolitan area that: (i) qualifies as a low-income area; and (ii) is experiencing economic distress evidenced by 30 percent or more of resident households with one or more of these four housing conditions in the most recent census for which data are available: (a) lacking complete plumbing, (b) lacking complete kitchen, (c) paying 30 percent or more of income for owner costs or tenant rent, or (d) having more than 1 person per room.  no if otherwise.  
# 
# source: american community survey special tabulations (chas) 2013 5-year estimates.

# Note: These criteria are ambiguous. Will assume that "low-income area" is not the same as "very low income" (above) and is thus: "greater than 50% but less than or equal to 80% of HAMFI"

# Note: No CHAS designations for "non-metropolitan areas". Will need to cross-reference census
#   data for Block-level Urban Area information for the 2020 Census from this page:
#   https://www.census.gov/programs-surveys/geography/guidance/geo-areas/urban-rural.html
# "A list of 2020 Census tabulation blocks classified as urban in the 2020 Census with associated 2020 Census Urban Area Census (UACE) codes and names for the U.S. and Puerto Rico [282 MB]"
#   https://www2.census.gov/geo/docs/reference/ua/2020_UA_BLOCKS.txt

# UA_Blocks_2020 <- read_delim("https://www2.census.gov/geo/docs/reference/ua/2020_UA_BLOCKS.txt", delim="|")

# # Save the data to avoid repeat calls
# saveRDS(UA_Blocks_2020, file="downloaded_data_sets/UA_Blocks_2020.RDS")

# Load the data from the saved file
UA_Blocks_2020 <- readRDS(file="downloaded_data_sets/UA_Blocks_2020.RDS")
# colnames(UA_Blocks_2020)
# head(UA_Blocks_2020)
# 
UA_Blocks_2020_exists <- UA_Blocks_2020 |>
  filter(STATE=="06") |>
  filter(TRACT=="400400")

# Test if urban area.  If exists, then FALSE, if not exists, then TRUE
UA_Blocks_2020_exists_TF <- dim(UA_Blocks_2020_exists)[1] == 0
# FALSE

# Tables needed to calculate owner vacant for sale rate:
# Owners:
#   T1_est61 Subtotal Owner occupied AND has none of the 4 housing unit problems AND household income is greater than 50% but less than or equal to 80% of HAMFI
#   T1_est20 Subtotal Owner occupied AND has 1 or more of the 4 housing unit problems AND household income is greater than 50% but less than or equal to 80% of HAMFI.
# Renters:
#   T1_est185	Subtotal Renter occupied AND has none of the 4 housing unit problems AND household income is greater than 50% but less than or equal to 80% of HAMFI
#   T1_est144	Subtotal Renter occupied AND has 1 or more of the 4 housing unit problems AND household income is greater than 50% but less than or equal to 80% of HAMFI

# # Data are in Zip format, so need to download manually, unzip:
HUD_CHAS_tract_Table1 <- read_csv(unz("downloaded_data_sets/2009thru2013-140-csv.zip", "Table1.csv"))

# Select and filter for calculating percent households below 50% area median income and for California, Alameda tract 06001400400:
low_income_housing_problems <- HUD_CHAS_tract_Table1 |> 
  select(tract=tract, st=st, owner_none=T1_est61, owner_some=T1_est20, renter_none=T1_est185, renter_some=T1_est144) |> 
  filter(st == "06") |> # California
  filter(tract == "400400")

probs_percent <- (low_income_housing_problems$owner_some + low_income_housing_problems$renter_some) / (low_income_housing_problems$owner_some + low_income_housing_problems$renter_some + low_income_housing_problems$owner_none + low_income_housing_problems$renter_none) * 100

# test if low income AND housing problems exist in over 30%
criterion_f <- UA_Blocks_2020_exists_TF & probs_percent > 30
criterion_f
# FALSE

###########################################################################

# test if any (a) - (f) are true (logical ORs). If so, then TRUE.
criterion_a | criterion_b | criterion_c | criterion_d | criterion_e | criterion_f
# FALSE
# Data Kit == FALSE

###############################################################################################
# 3. ######################### CDFI Fund (Investment Areas) ###################################
###############################################################################################
# Success

# Updated CDFI Program Investment Areas
#   https://www.cdfifund.gov/news/498
#   Investment Area Eligibility ACS Data 2016-2020 ACS Data
#     https://www.cdfifund.gov/sites/cdfi/files/2023-01/CDFI_Investment_Areas_ACS_2016_2020.xlsb

# # # Data are in Excel BINARY format, so need to download, read like SQL file:
# destfile <- path.expand("~/temp.xlsb")
# url <- "https://www.cdfifund.gov/sites/cdfi/files/2023-01/CDFI_Investment_Areas_ACS_2016_2020.xlsb"
# download.file(url, destfile = destfile, mode = "wb")
# con2 <- odbcConnectExcel2007(destfile)
# CDFI_invest <- sqlFetch(con2, "DATA") # Provide name of sheet
# unlink(destfile)

# # Save the data to avoid repeat calls
# saveRDS(CDFI_invest, file="downloaded_data_sets/CDFI_invest.RDS")

# Load the data from the saved file and display names
CDFI_invest <- readRDS(file="downloaded_data_sets/CDFI_invest.RDS")
#colnames(CDFI_invest)

# Select and filter for calculating percent households below 50% area median income and for California, Alameda tract 06001400400:
CDFI_invest_TF <- CDFI_invest |> 
  select(tract=ct2020, st=statename2020, invest=ia2020) |> 
  filter(tract == 06001400400)

# YES or NO
CDFI_invest_TF$invest
# No
# Data Kit == "No"

###############################################################################################
# 4. ############################### HUD - Opportunity Zones ##################################
###############################################################################################
# Success

# This service provides spatial data for all U.S. Decennial Census tracts designated as 
#   Qualified Opportunity Zones (QOZs)

# Data can be downloaded manually via web form submission from:
#   https://hudgis-hud.opendata.arcgis.com/datasets/HUD::opportunity-zones/about
#   data may also be queried through API, did not attempt

HUD_qualified_opportunity_zones <- read_csv("downloaded_data_sets/Opportunity_Zones_-5617125383102974896.csv")
#head(HUD_qualified_opportunity_zones)

# If tract exists, then TRUE qualified opportunityt zone
# Select and filter for calculating percent households below 50% area median income and for California, Alameda tract 06001400400:
HUD_qualified_opportunity_zones_specific <- HUD_qualified_opportunity_zones |> 
  select(tract=GEOID10, st=STATE) |> 
  filter(tract == 06001400400)

# exists or not
HUD_qualified_opportunity_zones_TF <- dim(HUD_qualified_opportunity_zones_specific)[1] > 0

# Test if the criteria match a "yes" (TRUE) or a "no" (FALSE)
HUD_qualified_opportunity_zones_TF
# Data Kis == FALSE

###############################################################################################
# 5. ########## U.S. Federal Financial Institutions Examination Council (FFIEC) ###############
###############################################################################################
# Success

# Home Mortgage Disclosure Act (HMDA) Modified Loan/Application Register (LAR) - 2022
#   From here: https://ffiec.cfpb.gov/data-publication/modified-lar/2022

# Combined Modified LAR for ALL Institutions, Include File Header 
# From website: 
#   Warning: Large file - 492.21 MB
#   Special software is required to open this file

# Data dictionary here:
#   https://ffiec.cfpb.gov/documentation/publications/modified-lar/modified-lar-schema

# Note: assume all loan purposes are for mortgage.

# # Data are in zip format, so need to download and unzip:
# destfile <- path.expand("~/temp.zip")
# url <- "https://s3.amazonaws.com/cfpb-hmda-public/prod/dynamic-data/combined-mlar/2022/header/2022_combined_mlar_header.zip"
# download.file(url, destfile = destfile, mode = "wb")
# HMDA_LAR <- read_delim(unz(destfile, "2022_combined_mlar_header.txt"), delim="|")
# unlink(destfile)
# colnames(HMDA_LAR)

# # Save subset of the data to reduce processing time and to avoid repeat calls
# save only: 
#   census tract stuff and then:
#     Median Mortgage Loan Amount (HMDA LAR)
#     Median Property Value (HDMA LAR)
#     Number of Mortgage Denials (HMDA LAR) <- action_taken == 3
#     Number of Mortgage Loans (HMDA LAR) <- action_taken == 6
#     Number of Mortgages Originated (HMDA LAR) <- action_taken == 1
# note: activity_year all == 2022
# HMDA_LAR_subset <- HMDA_LAR |>
#   filter(state_code == "CA") |>
#   select(census_tract, loan_amount, property_value, action_taken)

# saveRDS(HMDA_LAR_subset, file="downloaded_data_sets/HMDA_LAR_subset.RDS")

# Load the data from the saved file and display names
HMDA_LAR_subset <- readRDS(file="downloaded_data_sets/HMDA_LAR_subset.RDS")

median_mortgage_amount <- HMDA_LAR_subset |> 
  filter(census_tract == "06001400400") |> 
  filter(!is.na(loan_amount)) |> 
  summarize(la_median = median(loan_amount))

median_property_val <- HMDA_LAR_subset |> 
  filter(census_tract == "06001400400") |> 
  filter(!is.na(property_value)) |> 
  summarize(pv_median = median(as.numeric(property_value)))

num_mortgage_denials <- HMDA_LAR_subset |> 
  filter(census_tract == "06001400400") |> 
  filter(action_taken == 3) |> 
  summarize(denials = n())

# # Action_taken = 6. Purchased loan is not equal to number of loans
# num_mortgage_loans <- HMDA_LAR_subset |> 
#   filter(census_tract == "06001400400") |> 
#   filter(action_taken == 6) |> 
#   summarize(loans = n())

num_mortgage_loans <- HMDA_LAR_subset |> 
  filter(census_tract == "06001400400") |> 
  filter(!is.na(loan_amount)) |> 
  summarize(loans = n())

num_mortgage_orig <- HMDA_LAR_subset |> 
  filter(census_tract == "06001400400") |> 
  filter(action_taken == 1) |> 
  summarize(origin = n())

median_mortgage_amount
median_property_val
num_mortgage_denials
num_mortgage_loans
num_mortgage_orig
# analysis vs. data kit values:
#   la_median: 82500 vs 825000
#   pv_median: 1790000 vs 1775000
#   denials: 15 vs 15
#   loans: 144 vs 144
#   origin: 89 vs 89

###############################################################################################
# 6. ##################### U.S. Small Business Administration (SBA) ###########################
###############################################################################################
# Fail, with notes

# These data are NOT granular to census tract, but include address and zip codes
# Rather than do an address lookup for each entry in a county, a zipcode-to-tract-lookup 
#   will be used.  This results in a different value compared with the Data Kit values.
# Using a Zip code Census tract crosswalk file is an approximation:
#   https://www.huduser.gov/portal/datasets/usps_crosswalk.html

ZIP_tract <- read_excel("downloaded_data_sets/ZIP_TRACT_062024.xlsx", sheet = 1) |> 
  mutate(TRACT = as.numeric(TRACT)) |> 
  mutate(ZIP = as.numeric(ZIP))

# When more than one ZIP occurs per tract, pick the one with the largest TOT_RATIO value,
#   indicating the highest probability of a correct match? This is one option.
# # Reduce the file to the single tracts with the most area per zip 
# #   Results in multiple zips per tract, but preserves all tracts.
# ZIP_tract_uniq <- ZIP_tract |> 
#   group_by(TRACT) |> 
#   filter(TOT_RATIO==max(TOT_RATIO))

# Get these data from links on: https://data.sba.gov/en/dataset/7-a-504-foia
# looking for:
#   Median SBA 504 Loan Amount (FY2010-Present)
#   Median SBA 7(a) Loan Amount (FY2020-Present)
#   Number of SBA 504 Loans (FY2010-Present)
#   Number of SBA 7(a) Loans (FY2020-Present)

# # Download csv:
# SBA_504 <- read_csv("https://data.sba.gov/dataset/0ff8e8e9-b967-4f4e-987c-6ac78c575087/resource/7ce2e7e8-31d0-42e3-9bae-29b933efe409/download/foia-504-fy2010-present-asof-240630.csv")
# SBA_7 <- read_csv("https://data.sba.gov/dataset/0ff8e8e9-b967-4f4e-987c-6ac78c575087/resource/39a27935-52a7-4156-bf0f-8eaac127fdfc/download/foia-7afy2020-present-asof-240630.csv")

# saveRDS(SBA_504, file="downloaded_data_sets/SBA_504.RDS")
# saveRDS(SBA_7, file="downloaded_data_sets/SBA_7.RDS")

# Load the data from the saved file and display names
SBA_504 <- readRDS(file="downloaded_data_sets/SBA_504.RDS")
SBA_7 <- readRDS(file="downloaded_data_sets/SBA_7.RDS")

# Subset the 504 data to just include California
SBA_504_subset <- SBA_504 |> 
  select(ZIP=borrzip, state=borrstate, loan=grossapproval) |> 
  filter(state == "CA")

# Left-join on ZIP codes to add TRACT values to the data set
# This results in multiple zip codes per tract, multiple tracts per zip
SBA_504_tract <- left_join(SBA_504_subset, ZIP_tract, by = "ZIP", relationship = "many-to-many")

# Median of loans for the tract. This includes multiple zip codes.
median_504 <- SBA_504_tract |> 
  filter(TRACT == 6001400400) |> 
  summarize(loan_median = median(loan))

# Number of loans
num_504 <- SBA_504_tract |> 
  filter(TRACT == 6001400400) |> 
  summarize(loans = n())

# Subset the 7(a) data to just include California
SBA_7_subset <- SBA_7 |> 
  select(ZIP=borrzip, state=borrstate, loan=grossapproval) |> 
  filter(state == "CA")

# Left-join on ZIP codes to add TRACT values to the data set
SBA_7_tract <- left_join(SBA_7_subset, ZIP_tract, by = "ZIP", relationship = "many-to-many")

# Median of loans
median_7 <- SBA_7_tract |> 
  filter(TRACT == 6001400400) |> 
  summarize(loan_median = median(loan))

# Number of loans
num_7 <- SBA_7_tract |> 
  filter(TRACT == 6001400400) |> 
  summarize(loans = n())

median_504
num_504
median_7
num_7
# Computed values below, followed by Data Kit values:
#   median_504 = 633500; 0
#   num_504 = 22; 0
#   median_7 = 306000; 206000
#   num_7 = 38; 4


###############################################################################################
# 7. ################## Climate and Economic justice Screening Data ###########################
###############################################################################################
# Fail, partial?

# Get the data from a link on this page:
#    https://screeningtool.geoplatform.gov/en/downloads
# Note: "This tool has been updated. The 1.0 version of the tool was released on Nov 22, 2022."
# CEJST_communities_list_data <- read_csv("https://static-data-screeningtool.geoplatform.gov/data-versions/1.0/data/score/downloadable/1.0-communities.csv")

# Save the data to avoid repeat calls
# saveRDS(CEJST_communities_list_data, file="downloaded_data_sets/CEJST_communities_list_data.RDS")

# Load the data from the saved file and display names
CEJST_communities_list_data <- readRDS(file="downloaded_data_sets/CEJST_communities_list_data.RDS")
#colnames(CEJST_communities_list_data)

# Subset for energy values and for California, Alameda tract 06001400400 to compare to 
#   CA Alameda County census tract 06001400400 Data Kit values:
Energy_burden <- CEJST_communities_list_data |> 
  select(tract = `Census tract 2010 ID`, county=`County Name`, state=`State/Territory`,
         energy_burden = `Energy burden`, energy_burden_percent = `Energy burden (percentile)`) |> 
  filter(tract == "06001400400")

Energy_burden
# Data from 2022 download (above) and from earlier (not shown) do NOT match the DataKind
#   Data Kit 2018 values.  
#   CEJST_communities_list_data indicates energy burden = 1, energy burden percentile = 3.
#   Data Kit indicates energy burden = 0.998305026, percentile = 14.84630248.

# Note: CEJST_communities_list_data for energy and burden are all integers, no real numbers.
# Data Kit values for energy_burden_percentile are all real numbers, for burden, half real.

###############################################################################################
# 8. ############################# EPA EJScreen Data ##########################################
###############################################################################################
# Success

# Get the data from this page:
#   https://www.epa.gov/ejscreen/download-ejscreen-data
#   Link leads to 2023 data here:
#   https://gaftp.epa.gov/EJScreen/2023/2.22_September_UseMe/

# # Data are in Zip format, so need to download, unzip:
# temp <- tempfile()
# download.file("https://gaftp.epa.gov/EJScreen/2023/2.22_September_UseMe/EJSCREEN_2023_Tracts_with_AS_CNMI_GU_VI.csv.zip",temp)
# EJScreen_tract <- read_csv(unz(temp, "EJSCREEN_2023_Tracts_with_AS_CNMI_GU_VI.csv"))
# unlink(temp)
# 
# # Save the data to avoid repeat calls
# saveRDS(EJScreen_tract, file="downloaded_data_sets/EJScreen_tract.RDS")

# Load the data from the saved file and display names
EJScreen_tract <- readRDS(file="downloaded_data_sets/EJScreen_tract.RDS")
#colnames(EJScreen_tract)

# Subset for energy values and for California, Alameda tract 06001400400 to compare to 
#   CA Alameda County census tract 06001400400 Data Kit values:
Cancer <- EJScreen_tract |> 
  select(tract = ID, county=CNTY_NAME, state=ST_ABBREV, cancer_1 = CANCER, cancer_2 = D2_CANCER, cancer_3 = D5_CANCER) |> 
  filter(tract == "06001400400")

Cancer
# Data from 2023 download (above) match the DataKind Data Kit 2023 values.  
#   EJScreen CANCER = 20, D2_CANCER = 1.45, D5_CANCER = 0.403
#   Data Kit cancer	 = 20, d2_cancer = 1.447308396, d5_cancer = 0.402662478

###############################################################################################
# 9. ###################### Low Income Housing Tax Credit (LIHTC) Program #####################
###############################################################################################
# Success

# Note: all values in the Qualified Census Tract (qct) column in the DataKind Data Kit are zero.

# # Get the 2018 data from this page:
# # Data are in Excel format, so need to download, read Excel file:
# destfile <- path.expand("~/temp.xlsx")
# url <- "https://docs.huduser.gov/portal/datasets/qct/qct_data_2018.xlsx"
# download.file(url, destfile = destfile, mode = "wb")
# QCT_tract <- read_excel(destfile, sheet = 1)
# unlink(destfile)

# # Save the data to avoid repeat calls
# saveRDS(QCT_tract, file="downloaded_data_sets/QCT_tract.RDS")

# Get the 2024 data here: https://docs.huduser.gov/portal/datasets/qct/qct_data_2024.xlsx

# Load the data from the saved file and display names
QCT_tract <- readRDS(file="downloaded_data_sets/QCT_tract.RDS")
#colnames(QCT_tract)

# Subset QCT and for California, Alameda tract 06001400400 to compare to 
#   CA Alameda County census tract 06001400400 Data Kit values:
QCT <- QCT_tract |> 
  select(tract = tract_id, county=cntyname, state=stusab, QCT=qct) |> 
  filter(tract == "06001400400")

QCT
# Data from 2018 download (above) match the DataKind Data Kit 2018 values.  
#   QCT_tract QCT = 0
#   Data Kit qct = 0



