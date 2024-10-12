# Script for reproducing the DataKind 2024 Data kit for Anticipating 
#   Household Displacement in Communities California: Challenge #2.
#   https://github.com/datakind/datakit-housing-fall-2024/discussions/2

# This script should reproduce the data set for any county in the US, within the issues described
#   in the script "DataKit_explore_sources.R", which describes the inconsistencies (echoed below also).

# Note: this script is also terrible for memory management (multiple variable names are kept) 
#   and efficiency (but not loops!) to allow for more easy error checking, since this is going to
#   have to be manually run anyway.
# Also note: this script should be run in numbered order, because there are functions that depend
#   on previous values (e.g., "geoid_state" near line 500). "Geoid" is used for census tract, as per
#   the ACS survey data (but not other sources).

# Working from the document, data_dictionary_1-CA and data_1-CA, the list of sources and columns is:
#
#   0. geoid, geoid_year, state, county, state_fips_code, county_fips_code
#
#   1. American Community Survey (ACS) Census Data:
#     (1) b23025_004e; ACS - Employment Status for the Population 16 Years and Over (In the Labor Forces) - By Employment Status - Number Employed - Estimate
#     (2) b23025_004m; ACS - Employment Status for the Population 16 Years and Over (In the Labor Forces) - By Employment Status - Number Employed - Margin of Error
#     (3) b23025_006e; ACS - Employment Status for the Population 16 Years and Over (In the Labor Forces) - By Employment Status - Number in Armed Forces - Estimate
#     (4) b23025_006m; ACS - Employment Status for the Population 16 Years and Over (In the Labor Forces) - By Employment Status - Number in Armed Forces - Margin of Error
#     (5) b23025_005e; ACS - Employment Status for the Population 16 Years and Over (In the Labor Forces) - By Employment Status - Number Unemployed - Estimate
#     (6) b23025_005m; ACS - Employment Status for the Population 16 Years and Over (In the Labor Forces) - By Employment Status - Number Unemployed - Margin of Error
#     (7) b23025_002e; ACS - Employment Status for the Population 16 Years and Over (In the Labor Forces) - Estimate
#     (8) b23025_002m; ACS - Employment Status for the Population 16 Years and Over (In the Labor Forces) - Margin of Error
#     (9) b19083_001e; ACS - Gini Index of Income Inequality - Estimate
#     (10) b19083_001m; ACS - Gini Index of Income Inequality - Margin of Error
#     (11) s2001_c05_002e; ACS - Median Earnings (Dollars) in the Past 12 Months (in 2022 Inflation-Adjusted Dollars) - By Sex - Median Female Earnings - Estimate
#     (12) s2001_c05_002m; ACS - Median Earnings (Dollars) in the Past 12 Months (in 2022 Inflation-Adjusted Dollars) - By Sex - Median Female Earnings - Margin of Error
#     (13) s2001_c03_002e; ACS - Median Earnings (Dollars) in the Past 12 Months (in 2022 Inflation-Adjusted Dollars) - By Sex - Median Male Earnings - Estimate
#     (14) s2001_c03_002m; ACS - Median Earnings (Dollars) in the Past 12 Months (in 2022 Inflation-Adjusted Dollars) - By Sex - Median Male Earnings - Margin of Error
#     (15) s2001_c01_002e; ACS - Median Earnings (Dollars) in the Past 12 Months (in 2022 Inflation-Adjusted Dollars) - Estimate
#     (16) s2001_c01_002m; ACS - Median Earnings (Dollars) in the Past 12 Months (in 2022 Inflation-Adjusted Dollars) - Margin of Error
#     (17) s1903_c03_011e; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Age of Householder - 15 to 24 years - Estimate
#     (18) s1903_c03_011m; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Age of Householder - 15 to 24 years - Margin of Error
#     (19) s1903_c03_012e; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Age of Householder - 25 to 44 years - Estimate
#     (20) s1903_c03_012m; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Age of Householder - 25 to 44 years - Margin of Error
#     (21) s1903_c03_013e; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Age of Householder - 45 to 64 years - Estimate
#     (22) s1903_c03_013m; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Age of Householder - 45 to 64 years - Margin of Error
#     (23) s1903_c03_014e; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Age of Householder - 65 years and over - Estimate
#     (24) s1903_c03_014m; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Age of Householder - 65 years and over - Margin of Error
#     (25) s1903_c03_004e; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Race of Householder - American Indian and Alaska Native - Estimate
#     (26) s1903_c03_004m; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Race of Householder - American Indian and Alaska Native - Margin of Error
#     (27) s1903_c03_005e; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Race of Householder - Asian - Estimate
#     (28) s1903_c03_005m; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Race of Householder - Asian - Margin of Error
#     (29) s1903_c03_003e; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Race of Householder - Black or African American - Estimate
#     (30) s1903_c03_003m; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Race of Householder - Black or African American - Margin of Error
#     (31) s1903_c03_009e; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Race of Householder - Hispanic or Latino origin (of any race) - Estimate
#     (32) s1903_c03_009m; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Race of Householder - Hispanic or Latino origin (of any race) - Margin of Error
#     (33) s1903_c03_006e; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Race of Householder - Native Hawaiian and Other Pacific Islander - Estimate
#     (34) s1903_c03_006m; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Race of Householder - Native Hawaiian and Other Pacific Islander - Margin of Error
#     (35) s1903_c03_007e; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Race of Householder - Some other race - Estimate
#     (36) s1903_c03_007m; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Race of Householder - Some other race - Margin of Error
#     (37) s1903_c03_008e; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Race of Householder - Two or more races - Estimate
#     (38) s1903_c03_008m; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Race of Householder - Two or more races - Margin of Error
#     (39) s1903_c03_002e; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Race of Householder - White - Estimate
#     (40) s1903_c03_002m; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Race of Householder - White - Margin of Error
#     (41) s1903_c03_010e; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Race of Householder - White alone, not Hispanic or Latino - Estimate
#     (42) s1903_c03_010m; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - By Race of Householder - White alone, not Hispanic or Latino - Margin of Error
#     (43) s1903_c03_001e; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - Estimate
#     (44) s1903_c03_001m; ACS - Median Household Income last 12 months (in 2022 Inflation-Adjusted Dollars) - Margin of Error
#     (45) s0101_c05_032e; ACS - Median Population Age - By Sex - Median Female Age - Estimate
#     (46) s0101_c05_032m; ACS - Median Population Age - By Sex - Median Female Age - Margin of Error
#     (47) s0101_c03_032e; ACS - Median Population Age - By Sex - Median Male Age - Estimate
#     (48) s0101_c03_032m; ACS - Median Population Age - By Sex - Median Male Age - Margin of Error
#     (49) s0101_c01_032e; ACS - Median Population Age - Estimate
#     (50) s0101_c01_032m; ACS - Median Population Age - Margin of Error
#     (51) s1701_c03_007e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Age - 18 to 34 years - Estimate
#     (52) s1701_c03_007m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Age - 18 to 34 years - Margin of Error
#     (53) s1701_c03_006e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Age - 18 to 64 years - Estimate
#     (54) s1701_c03_006m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Age - 18 to 64 years - Margin of Error
#     (55) s1701_c03_008e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Age - 35 to 64 years - Estimate
#     (56) s1701_c03_008m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Age - 35 to 64 years - Margin of Error
#     (57) s1701_c03_004e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Age - 5 to 17 years - Estimate
#     (58) s1701_c03_004m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Age - 5 to 17 years - Margin of Error
#     (59) s1701_c03_009e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Age - 60 years and over - Estimate
#     (60) s1701_c03_009m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Age - 60 years and over - Margin of Error
#     (61) s1701_c03_010e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Age - 65 years and over - Estimate
#     (62) s1701_c03_010m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Age - 65 years and over - Margin of Error
#     (63) s1701_c03_002e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Age - Under 18 years - Estimate
#     (64) s1701_c03_002m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Age - Under 18 years - Margin of Error
#     (65) s1701_c03_003e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Age - Under 5 years - Estimate
#     (66) s1701_c03_003m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Age - Under 5 years - Margin of Error
#     (67) s1701_c03_015e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Race - American Indian and Alaska Native - Estimate
#     (68) s1701_c03_015m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Race - American Indian and Alaska Native - Margin of Error
#     (69) s1701_c03_016e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Race - Asian - Estimate
#     (70) s1701_c03_016m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Race - Asian - Margin of Error
#     (71) s1701_c03_014e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Race - Black or African American - Estimate
#     (72) s1701_c03_014m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Race - Black or African American - Margin of Error
#     (73) s1701_c03_020e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Race - Hispanic or Latino origin (of any race) - Estimate
#     (74) s1701_c03_020m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Race - Hispanic or Latino origin (of any race) - Margin of Error
#     (75) s1701_c03_017e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Race - Native Hawaiian and Other Pacific Islander - Estimate
#     (76) s1701_c03_017m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Race - Native Hawaiian and Other Pacific Islander - Margin of Error
#     (77) s1701_c03_018e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Race - Some other race - Estimate
#     (78) s1701_c03_018m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Race - Some other race - Margin of Error
#     (79) s1701_c03_019e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Race - Two or more races - Estimate
#     (80) s1701_c03_019m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Race - Two or more races - Margin of Error
#     (81) s1701_c03_013e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Race - White - Estimate
#     (82) s1701_c03_013m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Race - White - Margin of Error
#     (83) s1701_c03_021e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Race - White alone, not Hispanic or Latino - Estimate
#     (84) s1701_c03_021m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Race - White alone, not Hispanic or Latino - Margin of Error
#     (85) s1701_c03_012e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Sex - Female - Estimate
#     (86) s1701_c03_012m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Sex - Female - Margin of Error
#     (87) s1701_c03_011e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Sex - Male - Estimate
#     (88) s1701_c03_011m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - By Sex - Male - Margin of Error
#     (89) s1701_c03_001e; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - Estimate
#     (90) s1701_c03_001m; ACS - Percentage Below Poverty Level (Poverty Status in the Past 12 Months) - Margin of Error
#     (91) s2701_c03_004e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 19 to 25 years - Estimate
#     (92) s2701_c03_004m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 19 to 25 years - Margin of Error
#     (93) s2701_c03_012e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 19 to 64 years - Estimate
#     (94) s2701_c03_012m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 19 to 64 years - Margin of Error
#     (95) s2701_c03_005e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 26 to 34 years - Estimate
#     (96) s2701_c03_005m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 26 to 34 years - Margin of Error
#     (97) s2701_c03_006e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 35 to 44 years - Estimate
#     (98) s2701_c03_006m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 35 to 44 years - Margin of Error
#     (99) s2701_c03_007e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 45 to 54 years - Estimate
#     (100) s2701_c03_007m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 45 to 54 years - Margin of Error
#     (101) s2701_c03_008e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 55 to 64 years - Estimate
#     (102) s2701_c03_008m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 55 to 64 years - Margin of Error
#     (103) s2701_c03_003e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 6 to 18 years - Estimate
#     (104) s2701_c03_003m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 6 to 18 years - Margin of Error
#     (105) s2701_c03_009e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 65 to 74 years - Estimate
#     (106) s2701_c03_009m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 65 to 74 years - Margin of Error
#     (107) s2701_c03_013e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 65 years and over - Estimate
#     (108) s2701_c03_013m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 65 years and over - Margin of Error
#     (109) s2701_c03_010e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 75 years and over - Estimate
#     (110) s2701_c03_010m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - 75 years and over - Margin of Error
#     (111) s2701_c03_011e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - Under 19 years - Estimate
#     (112) s2701_c03_011m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - Under 19 years - Margin of Error
#     (113) s2701_c03_002e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - Under 6 years - Estimate
#     (114) s2701_c03_002m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Age - Under 6 years - Margin of Error
#     (115) s2701_c03_018e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Race - American Indian and Alaska Native - Estimate
#     (116) s2701_c03_018m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Race - American Indian and Alaska Native - Margin of Error
#     (117) s2701_c03_019e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Race - Asian - Estimate
#     (118) s2701_c03_019m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Race - Asian - Margin of Error
#     (119) s2701_c03_017e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Race - Black or African American - Estimate
#     (120) s2701_c03_017m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Race - Black or African American - Margin of Error
#     (121) s2701_c03_023e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Race - Hispanic or Latino origin (of any race) - Estimate
#     (122) s2701_c03_023m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Race - Hispanic or Latino origin (of any race) - Margin of Error
#     (123) s2701_c03_020e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Race - Native Hawaiian and Other Pacific Islander - Estimate
#     (124) s2701_c03_020m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Race - Native Hawaiian and Other Pacific Islander - Margin of Error
#     (125) s2701_c03_021e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Race - Some other race - Estimate
#     (126) s2701_c03_021m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Race - Some other race - Margin of Error
#     (127) s2701_c03_022e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Race - Two or more races - Estimate
#     (128) s2701_c03_022m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Race - Two or more races - Margin of Error
#     (129) s2701_c03_016e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Race - White - Estimate
#     (130) s2701_c03_016m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Race - White - Margin of Error
#     (131) s2701_c03_024e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Race - White alone, not Hispanic or Latino - Estimate
#     (132) s2701_c03_024m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Race - White alone, not Hispanic or Latino - Margin of Error
#     (133) s2701_c03_015e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Sex - Percentage Female - Estimate
#     (134) s2701_c03_015m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Sex - Percentage Female - Margin of Error
#     (135) s2701_c03_014e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Sex - Percentage Male - Estimate
#     (136) s2701_c03_014m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - By Sex - Percentage Male - Margin of Error
#     (137) s2701_c03_001e; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - Estimate
#     (138) s2701_c03_001m; ACS - Percentage of Noninstitutionalized Population with Health Insurance (Insured) - Margin of Error
#     (139) s2701_c05_004e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 19 to 25 years - Estimate
#     (140) s2701_c05_004m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 19 to 25 years - Margin of Error
#     (141) s2701_c05_012e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 19 to 64 years - Estimate
#     (142) s2701_c05_012m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 19 to 64 years - Margin of Error
#     (143) s2701_c05_005e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 26 to 34 years - Estimate
#     (144) s2701_c05_005m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 26 to 34 years - Margin of Error
#     (145) s2701_c05_006e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 35 to 44 years - Estimate
#     (146) s2701_c05_006m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 35 to 44 years - Margin of Error
#     (147) s2701_c05_007e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 45 to 54 years - Estimate
#     (148) s2701_c05_007m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 45 to 54 years - Margin of Error
#     (149) s2701_c05_008e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 55 to 64 years - Estimate
#     (150) s2701_c05_008m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 55 to 64 years - Margin of Error
#     (151) s2701_c05_003e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 6 to 18 years - Estimate
#     (152) s2701_c05_003m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 6 to 18 years - Margin of Error
#     (153) s2701_c05_009e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 65 to 74 years - Estimate
#     (154) s2701_c05_009m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 65 to 74 years - Margin of Error
#     (155) s2701_c05_013e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 65 years and over - Estimate
#     (156) s2701_c05_013m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 65 years and over - Margin of Error
#     (157) s2701_c05_010e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 75 years and over - Estimate
#     (158) s2701_c05_010m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - 75 years and over - Margin of Error
#     (159) s2701_c05_011e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - Under 19 years - Estimate
#     (160) s2701_c05_011m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - Under 19 years - Margin of Error
#     (161) s2701_c05_002e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - Under 6 years - Estimate
#     (162) s2701_c05_002m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Age - Under 6 years - Margin of Error
#     (163) s2701_c05_018e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Race - American Indian and Alaska Native - Estimate
#     (164) s2701_c05_018m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Race - American Indian and Alaska Native - Margin of Error
#     (165) s2701_c05_019e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Race - Asian - Estimate
#     (166) s2701_c05_019m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Race - Asian - Margin of Error
#     (167) s2701_c05_017e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Race - Black or African American - Estimate
#     (168) s2701_c05_017m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Race - Black or African American - Margin of Error
#     (169) s2701_c05_023e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Race - Hispanic or Latino origin (of any race) - Estimate
#     (170) s2701_c05_023m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Race - Hispanic or Latino origin (of any race) - Margin of Error
#     (171) s2701_c05_020e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Race - Native Hawaiian and Other Pacific Islander - Estimate
#     (172) s2701_c05_020m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Race - Native Hawaiian and Other Pacific Islander - Margin of Error
#     (173) s2701_c05_021e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Race - Some other race - Estimate
#     (174) s2701_c05_021m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Race - Some other race - Margin of Error
#     (175) s2701_c05_022e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Race - Two or more races - Estimate
#     (176) s2701_c05_022m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Race - Two or more races - Margin of Error
#     (177) s2701_c05_016e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Race - White - Estimate
#     (178) s2701_c05_016m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Race - White - Margin of Error
#     (179) s2701_c05_015e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Sex - Percentage Female - Estimate
#     (180) s2701_c05_015m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Sex - Percentage Female - Margin of Error
#     (181) s2701_c05_014e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Sex - Percentage Male - Estimate
#     (182) s2701_c05_014m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - By Sex - Percentage Male - Margin of Error
#     (183) s2701_c05_001e; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - Estimate
#     (184) s2701_c05_001m; ACS - Percentage of Noninstitutionalized Population without Health Insurance (Uninsured) - Margin of Error
#     (185) s0101_c06_021e; ACS - Population Percentage by Age (15 to 17 years) - By Sex - Percentage of Total Female Population - Estimate
#     (186) s0101_c06_021m; ACS - Population Percentage by Age (15 to 17 years) - By Sex - Percentage of Total Female Population - Margin of Error
#     (187) s0101_c04_021e; ACS - Population Percentage by Age (15 to 17 years) - By Sex - Percentage of Total Male Population - Estimate
#     (188) s0101_c04_021m; ACS - Population Percentage by Age (15 to 17 years) - By Sex - Percentage of Total Male Population - Margin of Error
#     (189) s0101_c02_021e; ACS - Population Percentage by Age (15 to 17 years) - Estimate
#     (190) s0101_c02_021m; ACS - Population Percentage by Age (15 to 17 years) - Margin of Error
#     (191) s0101_c06_024e; ACS - Population Percentage by Age (15 to 44 years) - By Sex - Percentage of Total Female Population - Estimate
#     (192) s0101_c06_024m; ACS - Population Percentage by Age (15 to 44 years) - By Sex - Percentage of Total Female Population - Margin of Error
#     (193) s0101_c04_024e; ACS - Population Percentage by Age (15 to 44 years) - By Sex - Percentage of Total Male Population - Estimate
#     (194) s0101_c04_024m; ACS - Population Percentage by Age (15 to 44 years) - By Sex - Percentage of Total Male Population - Margin of Error
#     (195) s0101_c02_024e; ACS - Population Percentage by Age (15 to 44 years) - Estimate
#     (196) s0101_c02_024m; ACS - Population Percentage by Age (15 to 44 years) - Margin of Error
#     (197) s0101_c06_025e; ACS - Population Percentage by Age (16 years and older) - By Sex - Percentage of Total Female Population - Estimate
#     (198) s0101_c06_025m; ACS - Population Percentage by Age (16 years and older) - By Sex - Percentage of Total Female Population - Margin of Error
#     (199) s0101_c04_025e; ACS - Population Percentage by Age (16 years and older) - By Sex - Percentage of Total Male Population - Estimate
#     (200) s0101_c04_025m; ACS - Population Percentage by Age (16 years and older) - By Sex - Percentage of Total Male Population - Margin of Error
#     (201) s0101_c02_025e; ACS - Population Percentage by Age (16 years and older) - Estimate
#     (202) s0101_c02_025m; ACS - Population Percentage by Age (16 years and older) - Margin of Error
#     (203) s0101_c06_023e; ACS - Population Percentage by Age (18 to 24 years) - By Sex - Percentage of Total Female Population - Estimate
#     (204) s0101_c06_023m; ACS - Population Percentage by Age (18 to 24 years) - By Sex - Percentage of Total Female Population - Margin of Error
#     (205) s0101_c04_023e; ACS - Population Percentage by Age (18 to 24 years) - By Sex - Percentage of Total Male Population - Estimate
#     (206) s0101_c04_023m; ACS - Population Percentage by Age (18 to 24 years) - By Sex - Percentage of Total Male Population - Margin of Error
#     (207) s0101_c02_023e; ACS - Population Percentage by Age (18 to 24 years) - Estimate
#     (208) s0101_c02_023m; ACS - Population Percentage by Age (18 to 24 years) - Margin of Error
#     (209) s0101_c06_026e; ACS - Population Percentage by Age (18 years and older) - By Sex - Percentage of Total Female Population - Estimate
#     (210) s0101_c06_026m; ACS - Population Percentage by Age (18 years and older) - By Sex - Percentage of Total Female Population - Margin of Error
#     (211) s0101_c04_026e; ACS - Population Percentage by Age (18 years and older) - By Sex - Percentage of Total Male Population - Estimate
#     (212) s0101_c04_026m; ACS - Population Percentage by Age (18 years and older) - By Sex - Percentage of Total Male Population - Margin of Error
#     (213) s0101_c02_026e; ACS - Population Percentage by Age (18 years and older) - Estimate
#     (214) s0101_c02_026m; ACS - Population Percentage by Age (18 years and older) - Margin of Error
#     (215) s0101_c06_027e; ACS - Population Percentage by Age (21 years and older) - By Sex - Percentage of Total Female Population - Estimate
#     (216) s0101_c06_027m; ACS - Population Percentage by Age (21 years and older) - By Sex - Percentage of Total Female Population - Margin of Error
#     (217) s0101_c04_027e; ACS - Population Percentage by Age (21 years and older) - By Sex - Percentage of Total Male Population - Estimate
#     (218) s0101_c04_027m; ACS - Population Percentage by Age (21 years and older) - By Sex - Percentage of Total Male Population - Margin of Error
#     (219) s0101_c02_027e; ACS - Population Percentage by Age (21 years and older) - Estimate
#     (220) s0101_c02_027m; ACS - Population Percentage by Age (21 years and older) - Margin of Error
#     (221) s0101_c06_020e; ACS - Population Percentage by Age (5 to 14 years) - By Sex - Percentage of Total Female Population - Estimate
#     (222) s0101_c06_020m; ACS - Population Percentage by Age (5 to 14 years) - By Sex - Percentage of Total Female Population - Margin of Error
#     (223) s0101_c04_020e; ACS - Population Percentage by Age (5 to 14 years) - By Sex - Percentage of Total Male Population - Estimate
#     (224) s0101_c04_020m; ACS - Population Percentage by Age (5 to 14 years) - By Sex - Percentage of Total Male Population - Margin of Error
#     (225) s0101_c02_020e; ACS - Population Percentage by Age (5 to 14 years) - Estimate
#     (226) s0101_c02_020m; ACS - Population Percentage by Age (5 to 14 years) - Margin of Error
#     (227) s0101_c06_028e; ACS - Population Percentage by Age (60 years and older) - By Sex - Percentage of Total Female Population - Estimate
#     (228) s0101_c06_028m; ACS - Population Percentage by Age (60 years and older) - By Sex - Percentage of Total Female Population - Margin of Error
#     (229) s0101_c04_028e; ACS - Population Percentage by Age (60 years and older) - By Sex - Percentage of Total Male Population - Estimate
#     (230) s0101_c04_028m; ACS - Population Percentage by Age (60 years and older) - By Sex - Percentage of Total Male Population - Margin of Error
#     (231) s0101_c02_028e; ACS - Population Percentage by Age (60 years and older) - Estimate
#     (232) s0101_c02_028m; ACS - Population Percentage by Age (60 years and older) - Margin of Error
#     (233) s0101_c06_029e; ACS - Population Percentage by Age (62 years and older) - By Sex - Percentage of Total Female Population - Estimate
#     (234) s0101_c06_029m; ACS - Population Percentage by Age (62 years and older) - By Sex - Percentage of Total Female Population - Margin of Error
#     (235) s0101_c04_029e; ACS - Population Percentage by Age (62 years and older) - By Sex - Percentage of Total Male Population - Estimate
#     (236) s0101_c04_029m; ACS - Population Percentage by Age (62 years and older) - By Sex - Percentage of Total Male Population - Margin of Error
#     (237) s0101_c02_029e; ACS - Population Percentage by Age (62 years and older) - Estimate
#     (238) s0101_c02_029m; ACS - Population Percentage by Age (62 years and older) - Margin of Error
#     (239) s0101_c06_030e; ACS - Population Percentage by Age (65 years and older) - By Sex - Percentage of Total Female Population - Estimate
#     (240) s0101_c06_030m; ACS - Population Percentage by Age (65 years and older) - By Sex - Percentage of Total Female Population - Margin of Error
#     (241) s0101_c04_030e; ACS - Population Percentage by Age (65 years and older) - By Sex - Percentage of Total Male Population - Estimate
#     (242) s0101_c04_030m; ACS - Population Percentage by Age (65 years and older) - By Sex - Percentage of Total Male Population - Margin of Error
#     (243) s0101_c02_030e; ACS - Population Percentage by Age (65 years and older) - Estimate
#     (244) s0101_c02_030m; ACS - Population Percentage by Age (65 years and older) - Margin of Error
#     (245) s0101_c06_031e; ACS - Population Percentage by Age (75 years and older) - By Sex - Percentage of Total Female Population - Estimate
#     (246) s0101_c06_031m; ACS - Population Percentage by Age (75 years and older) - By Sex - Percentage of Total Female Population - Margin of Error
#     (247) s0101_c04_031e; ACS - Population Percentage by Age (75 years and older) - By Sex - Percentage of Total Male Population - Estimate
#     (248) s0101_c04_031m; ACS - Population Percentage by Age (75 years and older) - By Sex - Percentage of Total Male Population - Margin of Error
#     (249) s0101_c02_031e; ACS - Population Percentage by Age (75 years and older) - Estimate
#     (250) s0101_c02_031m; ACS - Population Percentage by Age (75 years and older) - Margin of Error
#     (251) s0101_c06_022e; ACS - Population Percentage by Age (Under 18 years) - By Sex - Percentage of Total Female Population - Estimate
#     (252) s0101_c06_022m; ACS - Population Percentage by Age (Under 18 years) - By Sex - Percentage of Total Female Population - Margin of Error
#     (253) s0101_c04_022e; ACS - Population Percentage by Age (Under 18 years) - By Sex - Percentage of Total Male Population - Estimate
#     (254) s0101_c04_022m; ACS - Population Percentage by Age (Under 18 years) - By Sex - Percentage of Total Male Population - Margin of Error
#     (255) s0101_c02_022e; ACS - Population Percentage by Age (Under 18 years) - Estimate
#     (256) s0101_c02_022m; ACS - Population Percentage by Age (Under 18 years) - Margin of Error
#     (257) dp05_0039pe; ACS - Population Percentage by Race (American Indian and Alaska Native alone)
#     (258) dp05_0044pe; ACS - Population Percentage by Race (Asian alone)
#     (259) dp05_0038pe; ACS - Population Percentage by Race (Black or African American alone)
#     (260) dp05_0052pe; ACS - Population Percentage by Race (Native Hawaiian and Other Pacific Islander alone)
#     (261) dp05_0057pe; ACS - Population Percentage by Race (Some Other Race Alone)
#     (262) dp05_0035pe; ACS - Population Percentage by Race (Two or More Races)
#     (263) dp05_0037pe; ACS - Population Percentage by Race (White alone)
# Note: From data_dictionary_2-CA (not in data_1 file):
#     (264) b23025_003e	ACS - Employment Status for the Population 16 Years and Over (In the Labor Forces) - Total in Civilian Labor Force - Estimate
#     (265) b23025_003m	ACS - Employment Status for the Population 16 Years and Over (In the Labor Forces) - Total in Civilian Labor Force - Margin of Error
#     (266) b23025_007e	ACS - Employment Status for the Population 16 Years and Over (In the Labor Forces) - Total not in Labor Force - Estimate
#     (267) b23025_007m	ACS - Employment Status for the Population 16 Years and Over (In the Labor Forces) - Total not in Labor Force - Margin of Error
#     (268) s2503_c03_024e	ACS - Median Monthly Housing Cost (Occupied Housing Units) - By ownership status - Owner-occupied Housing Units - Estimate
#     (269) s2503_c03_024m	ACS - Median Monthly Housing Cost (Occupied Housing Units) - By ownership status - Owner-occupied Housing Units - Margin of Error
#     (270) s2503_c05_024e	ACS - Median Monthly Housing Cost (Occupied Housing Units) - By ownership status - Renter-occupied Housing Units - Estimate
#     (271) s2503_c05_024m	ACS - Median Monthly Housing Cost (Occupied Housing Units) - By ownership status - Renter-occupied Housing Units - Margin of Error
#     (272) s2503_c01_024e	ACS - Median Monthly Housing Cost (Occupied Housing Units) - Estimate
#     (273) s2503_c01_024m	ACS - Median Monthly Housing Cost (Occupied Housing Units) - Margin of Error
#
#   2. Community Development Financial Institutions Fund - Areas of Economic Distress.
#     (1) economic_distress_pop_agg; CDFI Fund (Areas of Economic Distress) - Aggregated by Land
#     (2) economic_distress_simple_agg; CDFI Fund (Areas of Economic Distress) - Simple Aggregation
# Note: currently, items (1) and (2) have identical methodology descriptions, yet different DataKit data. 
#
#   3. Community Development Financial Institutions Fund (CDFI Fund)
#     (1) investment_areas; CDFI Fund Investment Areas
#     (2) loan_amount; Total CDFI Lending Reported (CDFI Fund Transaction Level Report)
#
#   4. HUD - Opportunity Zones (U.S. Department of Housing and Urban Development)
#     (1) opzone; HUD - Opportunity Zones (U.S. Department of Housing and Urban Development)
#
#   5. U.S. Federal Financial Institutions Examination Council (FFIEC)
#     (1) median_mortgage_amount; Median Mortgage Loan Amount (HMDA LAR)
#     (2) median_prop_value; Median Property Value (HDMA LAR)
#     (3) num_mortgage_denials; Number of Mortgage Denials (HMDA LAR)
#     (4) num_mortgage; Number of Mortgage Loans (HMDA LAR)
#     (5) num_mortgage_originated; Number of Mortgages Originated (HMDA LAR)
#
#   6. U.S. Small Business Administration (SBA)
#     (1) median_sba504_loan_amount; Median SBA 504 Loan Amount (FY2010-Present)
#     (2) median_sba7a_loan_amount; Median SBA 7(a) Loan Amount (FY2020-Present)
#     (3) number_of_sba504_loans; Number of SBA 504 Loans (FY2010-Present)
#     (4) number_of_sba7a_loans; Number of SBA 7(a) Loans (FY2020-Present)
#
# Working from the document, data_dictionary_2-CA, *additional* sources are:
#   7. CEJST - Communities Data, Climate and Economic Justice Screening Tool (CEJST)
#     (1) energy_burden; DOE (2018) - Energy burden
#     (2) energy_burden_percentile; DOE (2018) - Energy burden (percentile)
#     (3) expected_agricultural_loss_rate_natural_hazards_risk_index; FEMA (2014-2021) - Expected agricultural loss rate (Natural Hazards Risk Index)
#     (4) expected_agricultural_loss_rate_natural_hazards_risk_index_percentile; FEMA (2014-2021) - Expected agricultural loss rate (Natural Hazards Risk Index) (percentile)
#     (5) expected_building_loss_rate_natural_hazards_risk_index; FEMA (2014-2021) - Expected building loss rate (Natural Hazards Risk Index)
#     (6) expected_building_loss_rate_natural_hazards_risk_index_percentile; FEMA (2014-2021) - Expected building loss rate (Natural Hazards Risk Index) (percentile)
#     (7) expected_population_loss_rate_natural_hazards_risk_index; FEMA (2014-2021) - Expected population loss rate (Natural Hazards Risk Index)
#     (8) expected_population_loss_rate_natural_hazards_risk_index_percentile; FEMA (2014-2021) - Expected population loss rate (Natural Hazards Risk Index) (percentile)
#     (9) share_of_properties_at_risk_of_fire_in_30_years; First Street Foundation (2022) - Share of properties at risk of fire in 30 years
#     (10) share_of_properties_at_risk_of_fire_in_30_years_percentile; First Street Foundation (2022) - Share of properties at risk of fire in 30 years (percentile)
#     (11) share_of_properties_at_risk_of_flood_in_30_years; First Street Foundation (2022) - Share of properties at risk of flood in 30 years
#     (12) share_of_properties_at_risk_of_flood_in_30_years_percentile; First Street Foundation (2022) - Share of properties at risk of flood in 30 years (percentile)
#
#   8. EJScreen - Indexes, Environmental Protection Agency (EPA)
#     (1) cancer; EJScreen - Air toxics cancer risk - Air toxics cancer risk
#     (2) d2_cancer; EJScreen - Air toxics cancer risk - Air toxics cancer risk - EJ Index
#     (3) d5_cancer; EJScreen - Air toxics cancer risk - Air toxics cancer risk - Supplemental Index
#     (4) resp; EJScreen - Air toxics respiratory HI - Air toxics respiratory HI
#     (5) d2_resp; EJScreen - Air toxics respiratory HI - Air toxics respiratory HI - EJ Index
#     (6) d5_resp; EJScreen - Air toxics respiratory HI - Air toxics respiratory HI - Supplemental Index
#     (7) dslpm; EJScreen - Diesel particulate matter - Diesel particulate matter
#     (8) d2_dslpm; EJScreen - Diesel particulate matter - Diesel particulate matter - EJ Index
#     (9) d5_dslpm; EJScreen - Diesel particulate matter - Diesel particulate matter - Supplemental Index
#     (10) ptsdf; EJScreen - Hazardous waste proximity - Hazardous waste proximity
#     (11) d2_ptsdf; EJScreen - Hazardous waste proximity - Hazardous waste proximity - EJ Index
#     (12) d5_ptsdf; EJScreen - Hazardous waste proximity - Hazardous waste proximity - Supplemental Index
#     (13) pre1960; EJScreen - Housing units built before 1960 - Housing units built before 1960
#     (14) pre1960pct; EJScreen - Lead Paint - Lead Paint
#     (15) d2_ldpnt; EJScreen - Lead Paint - Lead Paint - EJ Index
#     (16) d5_ldpnt; EJScreen - Lead Paint - Lead Paint - Supplemental Index
#     (17) ozone; EJScreen - Ozone - Ozone
#     (18) d2_ozone; EJScreen - Ozone - Ozone - EJ Index
#     (19) d5_ozone; EJScreen - Ozone - Ozone - Supplemental Index
#     (20) pm25; EJScreen - Particulate Matter 2.5 - Particulate Matter 2.5
#     (21) d2_pm25; EJScreen - Particulate Matter 2.5 - Particulate Matter 2.5 - EJ Index
#     (22) d5_pm25; EJScreen - Particulate Matter 2.5 - Particulate Matter 2.5 - Supplemental Index
#     (23) p_cancer; EJScreen - Percentile for Air toxics cancer risk - Percentile for Air toxics cancer risk
#     (24) p_d2_cancer; EJScreen - Percentile for Air toxics cancer risk - Percentile for Air toxics cancer risk - EJ Index
#     (25) p_d5_cancer; EJScreen - Percentile for Air toxics cancer risk - Percentile for Air toxics cancer risk - Supplemental Index
#     (26) p_resp; EJScreen - Percentile for Air toxics respiratory HI - Percentile for Air toxics respiratory HI
#     (27) p_d2_resp; EJScreen - Percentile for Air toxics respiratory HI - Percentile for Air toxics respiratory HI - EJ Index
#     (28) p_d5_resp; EJScreen - Percentile for Air toxics respiratory HI - Percentile for Air toxics respiratory HI - Supplemental Index
#     (29) p_dslpm; EJScreen - Percentile for Diesel particulate matter - Percentile for Diesel particulate matter
#     (30) p_d2_dslpm; EJScreen - Percentile for Diesel particulate matter - Percentile for Diesel particulate matter - EJ Index
#     (31) p_d5_dslpm; EJScreen - Percentile for Diesel particulate matter - Percentile for Diesel particulate matter - Supplemental Index
#     (32) p_ptsdf; EJScreen - Percentile for Hazardous waste proximity - Percentile for Hazardous waste proximity
#     (33) p_d2_ptsdf; EJScreen - Percentile for Hazardous waste proximity - Percentile for Hazardous waste proximity - EJ Index
#     (34) p_d5_ptsdf; EJScreen - Percentile for Hazardous waste proximity - Percentile for Hazardous waste proximity - Supplemental Index
#     (35) p_ldpnt; EJScreen - Percentile for Lead Paint - Percentile for Lead Paint
#     (36) p_d2_ldpnt; EJScreen - Percentile for Lead Paint - Percentile for Lead Paint - EJ Index
#     (37) p_d5_ldpnt; EJScreen - Percentile for Lead Paint - Percentile for Lead Paint - Supplemental Index
#     (38) p_ozone; EJScreen - Percentile for Ozone - Percentile for Ozone
#     (39) p_d2_ozone; EJScreen - Percentile for Ozone - Percentile for Ozone - EJ Index
#     (40) p_d5_ozone; EJScreen - Percentile for Ozone - Percentile for Ozone - Supplemental Index
#     (41) p_pm25; EJScreen - Percentile for Particulate Matter 2.5 - Percentile for Particulate Matter 2.5
#     (42) p_d2_pm25; EJScreen - Percentile for Particulate Matter 2.5 - Percentile for Particulate Matter 2.5 - EJ Index
#     (43) p_d5_pm25; EJScreen - Percentile for Particulate Matter 2.5 - Percentile for Particulate Matter 2.5 - Supplemental Index
#     (44) p_prmp; EJScreen - Percentile for RMP facility proximity - Percentile for RMP facility proximity
#     (45) p_d2_prmp; EJScreen - Percentile for RMP facility proximity - Percentile for RMP facility proximity - EJ Index
#     (46) p_d5_prmp; EJScreen - Percentile for RMP facility proximity - Percentile for RMP facility proximity - Supplemental Index
#     (47) p_pnpl; EJScreen - Percentile for Superfund proximity - Percentile for Superfund proximity
#     (48) p_d2_pnpl; EJScreen - Percentile for Superfund proximity - Percentile for Superfund proximity - EJ Index
#     (49) p_d5_pnpl; EJScreen - Percentile for Superfund proximity - Percentile for Superfund proximity - Supplemental Index
#     (50) p_rsei_air; EJScreen - Percentile for Toxic Releases to Air - Percentile for Toxic Releases to Air
#     (51) p_d2_rsei_air; EJScreen - Percentile for Toxic Releases to Air - Percentile for Toxic Releases to Air - EJ Index
#     (52) p_d5_rsei_air; EJScreen - Percentile for Toxic Releases to Air - Percentile for Toxic Releases to Air - Supplemental Index
#     (53) p_ptraf; EJScreen - Percentile for Traffic proximity - Percentile for Traffic proximity
#     (54) p_d2_ptraf; EJScreen - Percentile for Traffic proximity - Percentile for Traffic proximity - EJ Index
#     (55) p_d5_ptraf; EJScreen - Percentile for Traffic proximity - Percentile for Traffic proximity - Supplemental Index
#     (56) p_ust; EJScreen - Percentile for Underground storage tanks - Percentile for Underground storage tanks
#     (57) p_d2_ust; EJScreen - Percentile for Underground storage tanks - Percentile for Underground storage tanks - EJ Index
#     (58) p_d5_ust; EJScreen - Percentile for Underground storage tanks - Percentile for Underground storage tanks - Supplemental Index
#     (59) p_pwdis; EJScreen - Percentile for Wastewater discharge - Percentile for Wastewater discharge
#     (60) p_d2_pwdis; EJScreen - Percentile for Wastewater discharge - Percentile for Wastewater discharge - EJ Index
#     (61) p_d5_pwdis; EJScreen - Percentile for Wastewater discharge - Percentile for Wastewater discharge - Supplemental Index
#     (62) prmp; EJScreen - RMP facility proximity - RMP facility proximity
#     (63) d2_prmp; EJScreen - RMP facility proximity - RMP facility proximity - EJ Index
#     (64) d5_prmp; EJScreen - RMP facility proximity - RMP facility proximity - Supplemental Index
#     (65) pnpl; EJScreen - Superfund proximity - Superfund proximity
#     (66) d2_pnpl; EJScreen - Superfund proximity - Superfund proximity - EJ Index
#     (67) d5_pnpl; EJScreen - Superfund proximity - Superfund proximity - Supplemental Index
#     (68) rsei_air; EJScreen - Toxic Releases to Air - Toxic Releases to Air
#     (69) d2_rsei_air; EJScreen - Toxic Releases to Air - Toxic Releases to Air - EJ Index
#     (70) d5_rsei_air; EJScreen - Toxic Releases to Air - Toxic Releases to Air - Supplemental Index
#     (71) ptraf; EJScreen - Traffic proximity - Traffic proximity
#     (72) d2_ptraf; EJScreen - Traffic proximity - Traffic proximity - EJ Index
#     (73) d5_ptraf; EJScreen - Traffic proximity - Traffic proximity - Supplemental Index
#     (74) ust; EJScreen - Underground storage tanks - Underground storage tanks
#     (75) d2_ust; EJScreen - Underground storage tanks - Underground storage tanks - EJ Index
#     (76) d5_ust; EJScreen - Underground storage tanks - Underground storage tanks - Supplemental Index
#     (77) pwdis; EJScreen - Wastewater discharge - Wastewater discharge
#     (78) d2_pwdis; EJScreen - Wastewater discharge - Wastewater discharge - EJ Index
#     (79) d5_pwdis; EJScreen - Wastewater discharge - Wastewater discharge - Supplemental Index
#
#   9. Low Income Housing Tax Credit (LIHTC) Program - Qualified Census Tracts, U.S. Department of Housing and Urban Development (HUD)
#     (1) qct; HUD - Low Income Housing Tax Credit (LIHTC) program - Qualified Census Tracts
#
# Needed packages: an attempt was made to keep it as simple as possible:
# Install and load the package "tidycensus" for downloading and manipulating US census data, 
#   as outlined here: https://walker-data.com/census-r/an-introduction-to-tidycensus.html. Much
#   of the comments about usage here are copy-pasted from this document.
#install.packages("tidycensus")

# One data set is in Excel BINARY format: Do NOT install or use "readxlsb" package - described as
#   "eye wateringly slow", which I also confirm.  Instead, use:
#install.packages("RODBC")

# load libraries 
library(tidycensus)
library(tidyverse)
# Need to load readxl explicitly, not a core tidyverse package
library(readxl)
library(RODBC)

# # Set the state and county abbreviations for queries:
query_state_full <- "California"
query_state_2 <- "CA"
query_state_code_string <- "06"

# Set the state and county abbreviations for queries:
query_state_full <- "Washington"
query_state_2 <- "WA"
query_state_code_string <- "53"

# ACS API keys can be obtained at https://api.census.gov/data/key_signup.html. After you’ve 
#   signed up for an API key, be sure to activate the key from the email you receive.
# Declaring install = TRUE when calling census_api_key() will install the key for use in future 
#   R sessions.
#census_api_key("YOUR KEY GOES HERE", install = TRUE)
census_api_key <- Sys.getenv("CENSUS_API_KEY")

###############################################################################################
# 0. ######################## Download Needed Data Files ######################################
###############################################################################################

# Create a downloaded data directory to put these data sets into
#   I use "downloaded_data_sets/"

# 1. ################## American Community Survey (ACS) Census Data ###########################
# Uses API for all calls

# 2. ######################## CDFI Fund (Areas of Economic Distress) ##########################
# (a) Source: american community survey special tabulations (CHAS) 2013 5-year estimates and u.s. department of housing and urban development. on july 6, 2016 HUD released updated CHAS data for the 2009-2013 period. 
# MANUAL download from web form and save zip in "downloaded_data_sets" sub-directory for 
#   repeated, multiple sheet access. Visit this URL in web browser and use form submission 
#   on this page for Data tab: 
#   2009-2013 ACS 5-year avg data, Census Tracts resolution.:

# https://www.huduser.gov/portal/datasets/cp.html. 

# (b) Data are in Excel format, so need to download manually, reset column names:
# Data are in Excel format, so need to download, read Excel file:
destfile <- path.expand("~/temp.xlsx")
url <- "https://www.cdfifund.gov/sites/cdfi/files/documents/designated-qozs.12.14.18.xlsx"
download.file(url, destfile = destfile, mode = "wb")
qualified_opp_zones <- read_excel(destfile, sheet = 1)
unlink(destfile)

# Save the data to avoid repeat calls
saveRDS(qualified_opp_zones, file="downloaded_data_sets/qualified_opp_zones.RDS")

# (c) Data are in zip format, so need to download and unzip:
destfile <- path.expand("~/temp.zip")
url <- "https://www.huduser.gov/portal/datasets/qct/qct2021csv.zip"
download.file(url, destfile = destfile, mode = "wb")
lihtc <- read_csv(unz(destfile, "QCT2021.csv"))
unlink(destfile)

# Save the data to avoid repeat calls
saveRDS(lihtc, file="downloaded_data_sets/lihtc.RDS")

# (f) 
# Note: No CHAS designations for "non-metropolitan areas". Will need to cross-reference census
#   data for Block-level Urban Area information for the 2020 Census from this page:
#   https://www.census.gov/programs-surveys/geography/guidance/geo-areas/urban-rural.html
# "A list of 2020 Census tabulation blocks classified as urban in the 2020 Census with associated 2020 Census Urban Area Census (UACE) codes and names for the U.S. and Puerto Rico [282 MB]"
#   https://www2.census.gov/geo/docs/reference/ua/2020_UA_BLOCKS.txt

UA_Blocks_2020 <- read_delim("https://www2.census.gov/geo/docs/reference/ua/2020_UA_BLOCKS.txt", delim="|")

# Save the data to avoid repeat calls
saveRDS(UA_Blocks_2020, file="downloaded_data_sets/UA_Blocks_2020.RDS")

# 3. ################################### CDFI Fund ############################################
# Investment Areas

# Updated CDFI Program Investment Areas
#   https://www.cdfifund.gov/news/498
#   Investment Area Eligibility ACS Data 2016-2020 ACS Data
#     https://www.cdfifund.gov/sites/cdfi/files/2023-01/CDFI_Investment_Areas_ACS_2016_2020.xlsb

# Data are in Excel BINARY format, so need to download, read like SQL file:
destfile <- path.expand("~/temp.xlsb")
url <- "https://www.cdfifund.gov/sites/cdfi/files/2023-01/CDFI_Investment_Areas_ACS_2016_2020.xlsb"
download.file(url, destfile = destfile, mode = "wb")
con2 <- odbcConnectExcel2007(destfile)
CDFI_invest <- sqlFetch(con2, "DATA") # Provide name of sheet
unlink(destfile)

# Save the data to avoid repeat calls
saveRDS(CDFI_invest, file="downloaded_data_sets/CDFI_invest.RDS")

# Transaction Level Report - Fail!

# Description in the Data Dictionary: 
#   Item: loan_amount = Total CDFI Lending Reported (CDFI Fund Transaction Level Report)
#   original loan/investment amount
#   CDFI Fund (TLR)
#   U.S. Department of the Treasury Community Development Financial Institutions Fund (CDFI Fund)
#   2021

# Data Kit data_1-CA.csv, "loan_amount"
#   6001400400 = 614.43
#   6001400700 = 7888.64
#   6001400800 = 88162.75

# Files from: https://www.cdfifund.gov/news/529
# File: "2021 CDFI Program and NACA Program Data Release: Data, Documentation, and Instructions (.zip)"
#   https://www.cdfifund.gov/sites/cdfi/files/2023-07/FY2021_Data_Documentation_Instruction.zip
#   "ReleaseTLRfy21.csv": 
#   6001400400 = no data
#   6001400700 = no data
#   6001400800 = 73200.
# No match
#   "ReleaseCLRfy21.csv": 
#   6001400400 = 539
#   6001400700 = 7483
#   6001400800 = 1000
#   6001400800 = 6705, total = 7705
# No match

# Files from: https://www.cdfifund.gov/documents/data-releases?page=0
# File: "FY 2023 NMTC Public Data Release: 2003-2021 Data File"
#   https://www.cdfifund.gov/sites/cdfi/files/2023-08/NMTC_Public_Data_Release_includes_FY_2021_Data_final.xlsx
# Financial notes and Projects tabs: 
#   No data for geoids 6001400400, 6001400700, 
#   6001400800 = $700,000.00.
# No match

# No matches for other files: 
#   FY_2020_NMTC_Public_Data_Release.xlsx
#   NMTC_Public_Data_Release_Includes_FY2020_Data_revised.xlsx
#   NMTC_Public_Data_Release_includes_FY_2022_Data_final.xlsx
#   ReleaseTLRfy20.csv
#   ReleaseCLRfy20.csv

# Will use "ReleaseTLRfy21.csv" because descriptions of data sources match

# Data are in zip format, so need to download and unzip:
destfile <- path.expand("~/temp.zip")
url <- "https://www.cdfifund.gov/sites/cdfi/files/2023-07/FY2021_Data_Documentation_Instruction.zip"
download.file(url, destfile = destfile, mode = "wb")
CDFI_TLR <- read_csv(unz(destfile, "releaseTLR_fy21.csv"))
unlink(destfile)
#str(CDFI_TLR)

saveRDS(CDFI_TLR, file="downloaded_data_sets/CDFI_TLR.RDS")

# 4. ############################### HUD - Opportunity Zones ##################################
# This service provides spatial data for all U.S. Decennial Census tracts designated as 
#   Qualified Opportunity Zones (QOZs)

# Data can be downloaded MANUALLY via web form submission from:
#   https://hudgis-hud.opendata.arcgis.com/datasets/HUD::opportunity-zones/about
#   data may also be queried through API, did not attempt

# Place file, "Opportunity_Zones_-5617125383102974896.csv", into "downloaded_data_sets/"

# 5. ########## U.S. Federal Financial Institutions Examination Council (FFIEC) ###############
# Home Mortgage Disclosure Act (HMDA) Modified Loan/Application Register (LAR) - 2022
#   From here: https://ffiec.cfpb.gov/data-publication/modified-lar/2022

# Combined Modified LAR for ALL Institutions, Include File Header 
# From website: 
#   Warning: Large file - 492.21 MB
#   Special software is required to open this file

# Data dictionary here:
#   https://ffiec.cfpb.gov/documentation/publications/modified-lar/modified-lar-schema

# Note: assume all loan purposes are for mortgage.

# Data are in zip format, so need to download and unzip:
# Note: with a slow internet connection, this will time-out before the file is downloaded!
#   You will need to manually download the file.
destfile <- path.expand("downloaded_data_sets/2022_combined_mlar_header.zip")
url <- "https://s3.amazonaws.com/cfpb-hmda-public/prod/dynamic-data/combined-mlar/2022/header/2022_combined_mlar_header.zip"
download.file(url, destfile = destfile, mode = "wb")
unlink(destfile)
# colnames(HMDA_LAR)

# In case of slow internet connection, download manually from url above and place into 
#   download directory.

# 6. ##################### U.S. Small Business Administration (SBA) ###########################
# These are not consistent with DataKind Data Kit!

# These data are NOT granular to census tract, but include address and zip codes
# Rather than do an address lookup for each entry in a county, a zipcode-to-tract-lookup 
#   will be used.  This results in a different value compared with the Data Kit values.
# Using a Zip code Census tract crosswalk file is an approximation:
#   https://www.huduser.gov/portal/datasets/usps_crosswalk.html

# put "ZIP_TRACT_062024.xlsx" into downloaded data sets folder

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

# Download csv:
SBA_504 <- read_csv("https://data.sba.gov/dataset/0ff8e8e9-b967-4f4e-987c-6ac78c575087/resource/7ce2e7e8-31d0-42e3-9bae-29b933efe409/download/foia-504-fy2010-present-asof-240630.csv")
SBA_7 <- read_csv("https://data.sba.gov/dataset/0ff8e8e9-b967-4f4e-987c-6ac78c575087/resource/39a27935-52a7-4156-bf0f-8eaac127fdfc/download/foia-7afy2020-present-asof-240630.csv")

saveRDS(SBA_504, file="downloaded_data_sets/SBA_504.RDS")
saveRDS(SBA_7, file="downloaded_data_sets/SBA_7.RDS")

# 7. ################## Climate and Economic justice Screening Data ###########################
# These are NOT consistent with DataKind Data Kit!

# Get the data from a link on this page:
#    https://screeningtool.geoplatform.gov/en/downloads
# Note: "This tool has been updated. The 1.0 version of the tool was released on Nov 22, 2022."

CEJST_communities_list_data <- read_csv("https://static-data-screeningtool.geoplatform.gov/data-versions/1.0/data/score/downloadable/1.0-communities.csv")

# Save the data to avoid repeat calls
saveRDS(CEJST_communities_list_data, file="downloaded_data_sets/CEJST_communities_list_data.RDS")

# 8. ############################# EPA EJScreen Data ##########################################
# Get the data from this page:
#   https://www.epa.gov/ejscreen/download-ejscreen-data
#   Link leads to 2023 data here:
#   https://gaftp.epa.gov/EJScreen/2023/2.22_September_UseMe/

# Data are in Zip format, so need to download, unzip:
temp <- tempfile()
download.file("https://gaftp.epa.gov/EJScreen/2023/2.22_September_UseMe/EJSCREEN_2023_Tracts_with_AS_CNMI_GU_VI.csv.zip",temp)
EJScreen_tract <- read_csv(unz(temp, "EJSCREEN_2023_Tracts_with_AS_CNMI_GU_VI.csv"))
unlink(temp)

# Save the data to avoid repeat calls
saveRDS(EJScreen_tract, file="downloaded_data_sets/EJScreen_tract.RDS")

# 9. ###################### Low Income Housing Tax Credit (LIHTC) Program #####################
# Note: all values in the Qualified Census Tract (qct) column in the DataKind Data Kit are zero.

# Get the 2018 data from this page:
# Data are in Excel format, so need to download, read Excel file:
destfile <- path.expand("~/temp.xlsx")
url <- "https://docs.huduser.gov/portal/datasets/qct/qct_data_2018.xlsx"
download.file(url, destfile = destfile, mode = "wb")
QCT_tract <- read_excel(destfile, sheet = 1)
unlink(destfile)

# Save the data to avoid repeat calls
saveRDS(QCT_tract, file="downloaded_data_sets/QCT_tract.RDS")

# Get the 2024 data here: https://docs.huduser.gov/portal/datasets/qct/qct_data_2024.xlsx

###############################################################################################
#            Process the raw data and export state-specific formatted files
###############################################################################################

###############################################################################################
# 1. ################## American Community Survey (ACS) Census Data ###########################
###############################################################################################

# # Variable IDs are required to fetch data from the Census and ACS APIs. There are thousands of 
# #   variables available across the different datasets and summary files. The 'load_variables()' 
# #   function obtains a dataset of variables and formats it for fast searching. Because this 
# #   function requires processing thousands of variables from the Census Bureau, the user can 
# #   specify 'cache = TRUE' to store the data in the user’s cache directory; on subsequent calls, 
# #   of the load_variables() function, 'cache = TRUE' will direct the function to look in the cache 
# #   directory for the variables rather than the Census website.
# 
# # ACS Detailed Tables (contains prefix "B" in a Variable ID, example: "b23025_004e"):
# ACS5_2020 <- load_variables(2020, "acs5", cache = TRUE)
# # Data Profile (prefix P), Summary (prefix S), and Comparison Profile (prefix CP) tables 
# #   within the ACS:
# ACS5_2020_Profile <- load_variables(2020, "acs5/profile", cache = TRUE)
# ACS5_2020_Subject <- load_variables(2020, "acs5/subject", cache = TRUE)

################################### b-coded values #############################################
# ACS codes copy-pasted from DataKind Data Kit "data_dictionary_1-CA.csv" and 
#   "data_dictionary_2-CA.csv"
bcodes <- c("b23025_004e","b23025_004m","b23025_006e","b23025_006m","b23025_005e","b23025_005m","b23025_002e","b23025_002m","b23025_003e","b23025_003m","b23025_007e","b23025_007m","b19083_001e","b19083_001m")

# Make upper-case for query:
bcodes_upper <- str_to_upper(bcodes, locale = "en")

# Remove the trailing letter (E for estimate or M for margin of error) because
#   tidycensus will return both. Nice vector apply for substring! Remove redundant codes
bcodes_upper_clean <- substring(bcodes_upper, 1, str_length(bcodes_upper)-1)
bcodes_upper_clean_unique <- unique(bcodes_upper_clean)

# Query the API db, put the results in the holding document

# Pull the data for the bcodes from the online source:
bcodes_all_tracts_2022 <- get_acs(
  geography = "tract", 
  state = query_state_2, 
  variables = bcodes_upper_clean_unique,
  year = 2022
) |> 
  select(!"NAME")

# Put the data in the same format as the DataKind Data Kit, wide
bcodes_all_tracts_2022_format <- bcodes_all_tracts_2022 |> 
  pivot_wider(
    names_from = variable, 
    values_from = c(estimate, moe), 
    names_glue = "{variable}{.value}",
    names_vary = "slowest")

###############################################################################################
# Save geoid for joining with incomplete lists
geoid_state <- bcodes_all_tracts_2022_format |> 
  select(geoid = GEOID)
saveRDS(geoid_state, file=paste("exported_data_sets/geoid_state-", query_state_2, ".RDS", sep=""))
###############################################################################################

# Lower-case and abbreviate "estimate" to "e" and "moe" to "m"
newnames <- tolower(names(bcodes_all_tracts_2022_format))
newnames <- substring(newnames, 1, str_length(bcodes_upper_clean_unique)+1)
names(bcodes_all_tracts_2022_format) <- newnames

# save for later assembly
saveRDS(bcodes_all_tracts_2022_format, file=paste("exported_data_sets/ACS_bcodes-", query_state_2, ".RDS", sep=""))

################################### s-coded values #############################################
# ACS codes copy-pasted from DataKind Data Kit "data_dictionary_1-CA.csv" and 
#   "data_dictionary_2-CA.csv"
# Note: There is a limitation of R, from the official manual An Introduction to R: "Command 
#   lines entered at the console are limited to about 4095 bytes (not characters)."
scodes1 <- c("s2001_c05_002e","s2001_c05_002m","s2001_c03_002e","s2001_c03_002m","s2001_c01_002e","s2001_c01_002m","s1903_c03_011e","s1903_c03_011m","s1903_c03_012e","s1903_c03_012m","s1903_c03_013e","s1903_c03_013m","s1903_c03_014e","s1903_c03_014m","s1903_c03_004e","s1903_c03_004m","s1903_c03_005e","s1903_c03_005m","s1903_c03_003e","s1903_c03_003m","s1903_c03_009e","s1903_c03_009m","s1903_c03_006e","s1903_c03_006m","s1903_c03_007e","s1903_c03_007m","s1903_c03_008e","s1903_c03_008m","s1903_c03_002e","s1903_c03_002m","s1903_c03_010e","s1903_c03_010m","s1903_c03_001e","s1903_c03_001m","s2503_c03_024e","s2503_c03_024m","s2503_c05_024e","s2503_c05_024m","s2503_c01_024e","s2503_c01_024m","s0101_c05_032e","s0101_c05_032m","s0101_c03_032e","s0101_c03_032m","s0101_c01_032e","s0101_c01_032m","s1701_c03_007e","s1701_c03_007m","s1701_c03_006e","s1701_c03_006m","s1701_c03_008e","s1701_c03_008m","s1701_c03_004e","s1701_c03_004m","s1701_c03_009e","s1701_c03_009m","s1701_c03_010e","s1701_c03_010m","s1701_c03_002e","s1701_c03_002m","s1701_c03_003e","s1701_c03_003m","s1701_c03_015e","s1701_c03_015m","s1701_c03_016e","s1701_c03_016m","s1701_c03_014e","s1701_c03_014m","s1701_c03_020e","s1701_c03_020m","s1701_c03_017e","s1701_c03_017m","s1701_c03_018e","s1701_c03_018m","s1701_c03_019e","s1701_c03_019m","s1701_c03_013e","s1701_c03_013m","s1701_c03_021e","s1701_c03_021m","s1701_c03_012e","s1701_c03_012m","s1701_c03_011e","s1701_c03_011m","s1701_c03_001e","s1701_c03_001m","s2701_c03_004e","s2701_c03_004m","s2701_c03_012e","s2701_c03_012m","s2701_c03_005e","s2701_c03_005m","s2701_c03_006e","s2701_c03_006m","s2701_c03_007e","s2701_c03_007m","s2701_c03_008e","s2701_c03_008m","s2701_c03_003e","s2701_c03_003m","s2701_c03_009e","s2701_c03_009m","s2701_c03_013e","s2701_c03_013m","s2701_c03_010e","s2701_c03_010m","s2701_c03_011e","s2701_c03_011m","s2701_c03_002e","s2701_c03_002m","s2701_c03_018e","s2701_c03_018m","s2701_c03_019e","s2701_c03_019m","s2701_c03_017e","s2701_c03_017m","s2701_c03_023e","s2701_c03_023m","s2701_c03_020e","s2701_c03_020m","s2701_c03_021e","s2701_c03_021m","s2701_c03_022e","s2701_c03_022m","s2701_c03_016e","s2701_c03_016m","s2701_c03_024e","s2701_c03_024m","s2701_c03_015e","s2701_c03_015m","s2701_c03_014e","s2701_c03_014m","s2701_c03_001e","s2701_c03_001m","s2701_c05_004e","s2701_c05_004m","s2701_c05_012e","s2701_c05_012m","s2701_c05_005e","s2701_c05_005m","s2701_c05_006e","s2701_c05_006m","s2701_c05_007e","s2701_c05_007m","s2701_c05_008e","s2701_c05_008m","s2701_c05_003e")
scodes2 <- c("s2701_c05_003m","s2701_c05_009e","s2701_c05_009m","s2701_c05_013e","s2701_c05_013m","s2701_c05_010e","s2701_c05_010m","s2701_c05_011e","s2701_c05_011m","s2701_c05_002e","s2701_c05_002m","s2701_c05_018e","s2701_c05_018m","s2701_c05_019e","s2701_c05_019m","s2701_c05_017e","s2701_c05_017m","s2701_c05_023e","s2701_c05_023m","s2701_c05_020e","s2701_c05_020m","s2701_c05_021e","s2701_c05_021m","s2701_c05_022e","s2701_c05_022m","s2701_c05_016e","s2701_c05_016m","s2701_c05_015e","s2701_c05_015m","s2701_c05_014e","s2701_c05_014m","s2701_c05_001e","s2701_c05_001m","s0101_c06_021e","s0101_c06_021m","s0101_c04_021e","s0101_c04_021m","s0101_c02_021e","s0101_c02_021m","s0101_c06_024e","s0101_c06_024m","s0101_c04_024e","s0101_c04_024m","s0101_c02_024e","s0101_c02_024m","s0101_c06_025e","s0101_c06_025m","s0101_c04_025e","s0101_c04_025m","s0101_c02_025e","s0101_c02_025m","s0101_c06_023e","s0101_c06_023m","s0101_c04_023e","s0101_c04_023m","s0101_c02_023e","s0101_c02_023m","s0101_c06_026e","s0101_c06_026m","s0101_c04_026e","s0101_c04_026m","s0101_c02_026e","s0101_c02_026m","s0101_c06_027e","s0101_c06_027m","s0101_c04_027e","s0101_c04_027m","s0101_c02_027e","s0101_c02_027m","s0101_c06_020e","s0101_c06_020m","s0101_c04_020e","s0101_c04_020m","s0101_c02_020e","s0101_c02_020m","s0101_c06_028e","s0101_c06_028m","s0101_c04_028e","s0101_c04_028m","s0101_c02_028e","s0101_c02_028m","s0101_c06_029e","s0101_c06_029m","s0101_c04_029e","s0101_c04_029m","s0101_c02_029e","s0101_c02_029m","s0101_c06_030e","s0101_c06_030m","s0101_c04_030e","s0101_c04_030m","s0101_c02_030e","s0101_c02_030m","s0101_c06_031e","s0101_c06_031m","s0101_c04_031e","s0101_c04_031m","s0101_c02_031e","s0101_c02_031m","s0101_c06_022e","s0101_c06_022m","s0101_c04_022e","s0101_c04_022m","s0101_c02_022e","s0101_c02_022m","s2503_c01_024e","s2503_c01_024m","s2503_c03_024e","s2503_c03_024m","s2503_c05_024e","s2503_c05_024m")
scodes <- c(scodes1, scodes2)

# Make upper-case for query:
scodes_upper <- str_to_upper(scodes, locale = "en")

# Remove the trailing letter (E for estimate or M for margin of error) because
#   tidycensus will return both. Nice vector apply for substring! Remove redundant codes
scodes_upper_clean <- substring(scodes_upper, 1, str_length(scodes_upper)-1)
scodes_upper_clean_unique <- unique(scodes_upper_clean)

# Query the API db, put the results in the holding document

# Pull the data for the scodes from the online source:
# It looks like the API chunks the request, here into 6 different queries but
#   the result is > 1 M entries.
scodes_all_tracts_2022 <- get_acs(
  geography = "tract", 
  state = query_state_2, 
  variables = scodes_upper_clean_unique,
  year = 2022
) |> 
  select(!"NAME")

# Put the data in the same format as the DataKind Data Kit, wide
scodes_all_tracts_2022_format <- scodes_all_tracts_2022 |> 
  pivot_wider(
    names_from = variable, 
    values_from = c(estimate, moe), 
    names_glue = "{variable}{.value}",
    names_vary = "slowest")

# Lower-case and abbreviate "estimate" to "e" and "moe" to "m"
newnames <- tolower(names(scodes_all_tracts_2022_format))
newnames <- substring(newnames, 1, str_length(scodes_upper_clean_unique)+1)
names(scodes_all_tracts_2022_format) <- newnames

# save for later assembly
saveRDS(scodes_all_tracts_2022_format, file=paste("exported_data_sets/ACS_scodes-", query_state_2, ".RDS", sep=""))

################################### p-coded values #############################################
# ACS codes copy-pasted from DataKind Data Kit "data_dictionary_1-CA.csv" and 
#   "data_dictionary_2-CA.csv"
pcodes <- c("dp05_0039pe","dp05_0044pe","dp05_0038pe","dp05_0052pe","dp05_0057pe","dp05_0035pe","dp05_0037pe")

# Make upper-case for query:
pcodes_upper <- str_to_upper(pcodes, locale = "en")

# Remove the trailing letter (E for estimate or M for margin of error) because
#   tidycensus will return both. Nice vector apply for substring! Remove redundant codes
pcodes_upper_clean <- substring(pcodes_upper, 1, str_length(pcodes_upper)-1)
pcodes_upper_clean_unique <- unique(pcodes_upper_clean)

# Query the API db, put the results in the holding document

# Pull the data for the scodes from the online source:
# It looks like the API chunks the request, here into 6 different queries but
#   the result is > 1 M entries.
pcodes_all_tracts_2022 <- get_acs(
  geography = "tract", 
  state = query_state_2, 
  variables = pcodes_upper_clean_unique,
  year = 2022
) |> 
  select(!"NAME")

# Put the data in the same format as the DataKind Data Kit, wide
pcodes_all_tracts_2022_format <- pcodes_all_tracts_2022 |> 
  pivot_wider(
    names_from = variable, 
    values_from = c(estimate, moe), 
    names_glue = "{variable}{.value}",
    names_vary = "slowest")

# Lower-case and abbreviate "estimate" to "e" and "moe" to "m"
newnames <- tolower(names(pcodes_all_tracts_2022_format))
newnames <- substring(newnames, 1, str_length(pcodes_upper_clean_unique)+1)
names(pcodes_all_tracts_2022_format) <- newnames

# save for later assembly
saveRDS(pcodes_all_tracts_2022_format, file=paste("exported_data_sets/ACS_pcodes-", query_state_2, ".RDS", sep=""))

###############################################################################################
# 2. ######################## CDFI Fund (Areas of Economic Distress) ##########################
###############################################################################################

# CDFI Fund - Aggregated by Land (census tract)
# API does not allow for census tract-level query, file downloads required

# Procedure:
# Population weighting aggregation methodology: yes if any of any of items (a) - (f) is yes.  no if otherwise:

################################## ???
# There MUST be a source for this, already calculated, rather than creating these
#   indices manually?
################################## ???

###########################################################################
# (a) yes if at least 20 percent of households in the census tract are very low-income [50% of the area median income] renters or owners who pay more than half their income for housing.  no if otherwise.

# Note: the above statement is ambiguous: do owners also need to be very low-income?  Do very low-income renters need to pay more than half their income for housing?
# Note: Will assume that both renters and owners are very low income and also both pay more than half their income towards housing.

# # Data are in Zip format, so need to unzip and read the contained file:
HUD_CHAS_tract_Table3 <- read_csv(unz("downloaded_data_sets/2009thru2013-140-csv.zip", "Table3.csv"))

# Tables that are needed to fulfill the above Item:
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
  filter(st == query_state_code_string) |> 
  mutate(geoid = paste(st, "001", tract, sep=""))

# Start the variable "criteria" and add criterion "a"
criteria_1 <- pay_half |> 
  mutate(percent_pay_half = (pay_half$owner_30_HAMFI + pay_half$owner_50_HAMFI + pay_half$renter_30_HAMFI + pay_half$renter_50_HAMFI) /pay_half$total_occupied_housing_units * 100) |> 
  mutate(criterion_a = percent_pay_half > 20.0) |> 
  select(geoid, criterion_a)

###########################################################################
# (b) yes if the census tract a designated qualified opportunity zones under 26 u.s. code section 1400z-1. no if otherwise.; https://www.cdfifund.gov/sites/cdfi/files/documents/designated-qozs.12.14.18.xlsx
# source: cdfi fund opportunity fund database

# Load the data from the saved file and display names
qualified_opp_zones <- readRDS(file="downloaded_data_sets/qualified_opp_zones.RDS")

names(qualified_opp_zones) <- c("state","county","tract","type","ACS_source")
#summary(qualified_opp_zones)

# Subset for type values and for state
qualified_opp_zones_state <- qualified_opp_zones |> 
  filter(state == query_state_full) |> 
  select(geoid=tract, type)

# Left-join with geoid_state to fill NA for locations not listed (not Low-Income)
#   and then make boolean
qualified_opp_zones_state_TF <- left_join(geoid_state, qualified_opp_zones_state, by = "geoid") |> 
  mutate(criterion_b = !is.na(type)) |> 
  select(geoid, criterion_b)

# Add criterion "b" to the criteria
criteria_2 <- left_join(criteria_1, qualified_opp_zones_state_TF, by="geoid")

###########################################################################
# (c) whether the tract is eligible as a low-income housing tax credit (lihtc) qualified census tract, january 1, 2021, https://qct.huduser.gov/ ; https://www.huduser.gov/portal/datasets/qct/qct2021csv.zip

# Load the data from the saved file and display names
lihtc <- readRDS(file="downloaded_data_sets/lihtc.RDS")
#colnames(lihtc)

# Subset for state, add TRUE for existing entries
lihtc_state <- lihtc |> 
  filter(statefp == query_state_code_string) |> 
  mutate(litc = TRUE) |> 
  select(geoid=fips, litc)

# Left-join with geoid_state to fill NA for locations not listed (not Low-Income tax credit)
lihtc_state_TF <- left_join(geoid_state, lihtc_state, by = "geoid") |> 
  mutate(criterion_c = !is.na(litc)) |> 
  select(geoid, criterion_c)

# Add criterion "c"
criteria_3 <- left_join(criteria_2, lihtc_state_TF, by="geoid")

###########################################################################
# (d) yes if greater than 20% of households in the census tract have incomes below the poverty rate and the census tract has a rental vacancy rate of at least 10 percent. no if otherwise.  
# 
# source: american community survey special tabulations (chas) 2013 5-year estimates and u.s. department of housing and urban development.

# Note: These criteria are ambiguous. Will assume that "below the poverty rate" is the same as "very low-income [50% of the area median income]"

# Tables that are needed to fulfill the above Item:
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
  filter(st == query_state_code_string) |> 
  select(geoid, owner_occupied=T7_est2, owner_occupied_30=T7_est3, owner_occupied_50=T7_est29, renter_occupied=T7_est133, renter_occupied_30=T7_est134, renter_occupied_50=T7_est160) |> 
  mutate(percent_under = (owner_occupied_30 + owner_occupied_50 + renter_occupied_30 + renter_occupied_50) / 
           (owner_occupied + renter_occupied) * 100)

# Get boolean for households percent under 
households_under_TF <- households_under |> 
  mutate(geoid = substring(geoid, 8, length(geoid))) |> 
  mutate(percent_under_TF = percent_under < 20.0) |> 
  select(geoid, percent_under_TF)

# Select and filter for calculating rental vacancy rate
rental_vac <- HUD_CHAS_tract_Table14B |>
  filter(st == query_state_code_string) |> 
  mutate(geoid = substring(geoid, 8, length(geoid))) |> 
  select(geoid, vacant_for_rent=T14B_est1) |> 
  mutate(vacant_percent = vacant_for_rent / (vacant_for_rent + households_under$renter_occupied) * 100) |> 
  mutate(vacant_TF = vacant_percent >= 10.0) |> 
  select(geoid, vacant_TF)

# criterion d
criterion_d <- left_join(households_under_TF, rental_vac, by = "geoid") |> 
  mutate(criterion_d = percent_under_TF & vacant_TF) |> 
  select(geoid, criterion_d)

# Add criterion "d" to the criteria df
criteria_4 <- left_join(criteria_3, criterion_d, by="geoid")

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
  filter(st == query_state_code_string) |> 
  select(geoid, total_occupied_housing=T3_est1)

# # Data are in Zip format from manually-downloaded file in working directory, unzip:
HUD_CHAS_tract_Table14A <- read_csv(unz("downloaded_data_sets/2009thru2013-140-csv.zip", "Table14A.csv"))

# Select and filter for calculating percent households below 50% area median income and for California, Alameda tract 06001400400:
owner_vacant <- HUD_CHAS_tract_Table14A |> 
  filter(st == query_state_code_string) |> 
  mutate(geoid = substring(geoid, 8, length(geoid))) |> 
  select(geoid, owner_vacant_num=T14A_est1)
  
# Calculate owner vacancy rate
owner_vacant_percent <- owner_vacant |> 
  mutate(vac_percent = owner_vacant_num / 
           (total_occupied$total_occupied_housing + 
              owner_vacant_num) *100) |> 
  mutate(vacant_percent_TF = vac_percent > 10.0) |> 
  select(geoid, vacant_percent_TF)

# criterion e
criterion_e <- left_join(households_under_TF, owner_vacant_percent, by = "geoid") |> 
  mutate(criterion_e = percent_under_TF & vacant_percent_TF) |> 
  select(geoid, criterion_e)

# Add criterion "e" to criteria
criteria_5 <- left_join(criteria_4, criterion_e, by="geoid")

###########################################################################
# (f) yes if census tract is (1) a non-metropolitan area that: (i) qualifies as a low-income area; and (ii) is experiencing economic distress evidenced by 30 percent or more of resident households with one or more of these four housing conditions in the most recent census for which data are available: (a) lacking complete plumbing, (b) lacking complete kitchen, (c) paying 30 percent or more of income for owner costs or tenant rent, or (d) having more than 1 person per room.  no if otherwise.  

# Note: These criteria are ambiguous. Will assume that "low-income area" is not the same as "very low income" (above) and is thus: "greater than 50% but less than or equal to 80% of HAMFI"

# Load the data from the saved file
UA_Blocks_2020 <- readRDS(file="downloaded_data_sets/UA_Blocks_2020.RDS")
# colnames(UA_Blocks_2020)
# head(UA_Blocks_2020)
# 
UA_Blocks_2020_exists <- UA_Blocks_2020 |>
  filter(STATE==query_state_code_string) |> 
  mutate(geoid = substring(GEOID, 1, 11)) |> 
  select(geoid) |> 
  distinct(geoid) |> # keep unique after decreasing granularity of geoid
  mutate(exists = TRUE) # add a column for the join below

# Test if urban area.  If exists, then FALSE, if not exists, then TRUE
UA_Blocks_2020_exists_TF <- left_join(geoid_state, UA_Blocks_2020_exists, by="geoid") |> 
  mutate(exists = !is.na(exists))

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
  filter(st == query_state_code_string) |> 
  mutate(geoid = substring(geoid, 8, length(geoid))) |> 
  select(geoid, owner_none=T1_est61, owner_some=T1_est20, renter_none=T1_est185, renter_some=T1_est144) |> 
  mutate(probs_percent = (owner_some + renter_some) / (owner_some + renter_some + owner_none + renter_none) * 100) |> 
  select(geoid, probs_percent)

# criterion f
criterion_f <- left_join(UA_Blocks_2020_exists_TF, low_income_housing_problems, by = "geoid") |> 
  mutate(criterion_f = exists & probs_percent > 30) |> 
  select(geoid, criterion_f)

# Add criterion "f" to criteria
criteria <- left_join(criteria_5, criterion_f, by="geoid")

###########################################################################

# test if any (a) - (f) are true (logical ORs). If so, then TRUE.

# Note: currently, "economic_distress_pop_agg" and "economic_distress_simple_agg" descriptions are
#   identical.  However, data in Data Kit are not!

# Current solution: duplicate "economic_distress_pop_agg" and label as "economic_distress_simple_agg"
economic_distress_agg <- criteria |> 
  mutate(economic_distress_pop_agg = criterion_a | criterion_b | criterion_c | criterion_d | criterion_e | criterion_f) |> 
  mutate(economic_distress_pop_agg = if_else(economic_distress_pop_agg, "YES", "NO")) |> # turn into yes or no to match Data Kit
  mutate(economic_distress_simple_agg = criterion_a | criterion_b | criterion_c | criterion_d | criterion_e | criterion_f) |> 
  mutate(economic_distress_simple_agg = if_else(economic_distress_simple_agg, "YES", "NO")) |> # turn into yes or no to match Data Kit
  select(geoid, economic_distress_pop_agg, economic_distress_simple_agg) |> 
  distinct()

saveRDS(economic_distress_agg, file=paste("exported_data_sets/economic_distress_agg-", query_state_2, ".RDS", sep=""))

###############################################################################################
# 3. ################################### CDFI Fund ############################################
###############################################################################################
# Investment Areas

# Load the data from the saved file and display names
CDFI_invest <- readRDS(file="downloaded_data_sets/CDFI_invest.RDS") |> 
  mutate(statename2020 = str_trim(statename2020)) |> # remove blank at beginning of state names
  filter(statename2020 == query_state_full) # note: ct2020 is numeric

# Select and filter for calculating percent households below 50% area median income0:
investment_areas <- CDFI_invest |> 
  mutate(ct2020_chr = as.character(ct2020)) |> 
  # add a leading zero if tract is only 10 characters to match others
  mutate(ct2020_chr = if_else(str_length(ct2020_chr) == 10, paste("0", ct2020_chr, sep=""), ct2020_chr)) |> 
  select(geoid=ct2020_chr, investment_areas=ia2020)
  
saveRDS(investment_areas, file=paste("exported_data_sets/CDFI_investment_areas-", query_state_2, ".RDS", sep=""))

###############################################################################################
# Transaction Level Report

CDFI_TLR <- readRDS(file="downloaded_data_sets/CDFI_TLR.RDS")

# Turn numeric fips code into string to match, then subset state
CDFI_TLR_subset <- CDFI_TLR |>
  mutate(projectfipscode_2010 = as.character(projectfipscode_2010)) |> 
  mutate(projectfipscode_2010 = if_else(str_length(projectfipscode_2010) == 10, paste("0", projectfipscode_2010, sep=""), projectfipscode_2010)) |> 
  filter(substring(projectfipscode_2010, 1, 2) == query_state_code_string) |> 
  group_by(projectfipscode_2010) |> 
  mutate(loan_amount = sum(originalamount)) |> 
  ungroup() |> 
  select(geoid = projectfipscode_2010, loan_amount) |> 
  distinct()
  
# Save
saveRDS(CDFI_TLR_subset, file=paste("exported_data_sets/CDFI_TLR_loans-", query_state_2, ".RDS", sep=""))

###############################################################################################
# 4. ############################### HUD - Opportunity Zones ##################################
###############################################################################################

HUD_qualified_opportunity_zones <- read_csv("downloaded_data_sets/Opportunity_Zones_-5617125383102974896.csv")

# If tract exists, then TRUE qualified opportunityt zone
# Select and filter for calculating percent households below 50% area median income and for California, Alameda tract 06001400400:
HUD_qualified_opportunity_zones_state <- HUD_qualified_opportunity_zones |> 
  filter(STATE_NAME == query_state_full) |> 
  mutate(opzone = 1) |>  # add a column for the join below
  select(geoid = GEOID10, opzone)

# # Test if urban area.  If exists, then FALSE, if not exists, then TRUE
# HUD_qualified_opportunity_zones_state_TF <- left_join(geoid_state, HUD_qualified_opportunity_zones_state, by="geoid") |> 
#   mutate(opzone = !is.na(opzone))

# Save
saveRDS(HUD_qualified_opportunity_zones_state, file=paste("exported_data_sets/opzone-", query_state_2, ".RDS", sep=""))

###############################################################################################
# 5. ########## U.S. Federal Financial Institutions Examination Council (FFIEC) ###############
###############################################################################################

# Load the data from the saved file
HMDA_LAR <- read_delim(unz("downloaded_data_sets/2022_combined_mlar_header.zip", "2022_combined_mlar_header.txt"), delim="|")
#str(HMDA_LAR)

# Note: HMDA_LAR census_tract values contain NA, loan_amount appears clean, property_value
#   contains NA and text (e.g. "Exempt"), action_taken appears all numeric
# Save subset of the data to reduce processing time
# save only:
#   census tract stuff and then:
#     Median Mortgage Loan Amount (HMDA LAR)
#     Median Property Value (HDMA LAR)
#     Number of Mortgage Denials (HMDA LAR) <- action_taken == 3
#     Number of Mortgage Loans (HMDA LAR) <- action_taken == 6
#     Number of Mortgages Originated (HMDA LAR) <- action_taken == 1
# note: activity_year all == 2022

HMDA_LAR_subset <- HMDA_LAR |>
  filter(state_code == query_state_2) |> 
  select(census_tract, loan_amount, property_value, action_taken)

# remove from memory if slowing things down
rm(HMDA_LAR)

median_mortgage_amount <- HMDA_LAR_subset |> 
  select(census_tract, loan_amount) |> # select only the two columns to then drop NAs
  drop_na() |> 
  group_by(geoid=census_tract) |> 
  summarize(median_mortgage_amount = median(loan_amount))

median_property_val <- HMDA_LAR_subset |> 
  select(census_tract, property_value) |> 
  drop_na() |> 
  filter(property_value != "Exempt") |> # some strings are not numbers!
  group_by(geoid=census_tract) |>
  summarize(median_prop_value = median(as.numeric(property_value)))

num_mortgage_denials <- HMDA_LAR_subset |> 
  filter(action_taken == 3) |> 
  group_by(geoid=census_tract) |>
  summarize(num_mortgage_denials = n())

# # Action_taken = 6. Purchased loan is not equal to number of loans
# num_mortgage_loans <- HMDA_LAR_subset |> 
#   filter(action_taken == 6) |> 
#   group_by(geoid=census_tract) |>
#   summarize(loans = n())

num_mortgage_loans <- HMDA_LAR_subset |> 
  filter(!is.na(loan_amount)) |> 
  group_by(geoid=census_tract) |>
  summarize(num_mortgage = n())

num_mortgage_orig <- HMDA_LAR_subset |> 
  filter(action_taken == 1) |> 
  group_by(geoid=census_tract) |>
  summarize(num_mortgage_originated = n())

# Build with full joins to avoid dropping info
# Note: this could be more memory efficient, but keeping variables allows for manual error checking
HMDA_LAR_values_1 <- full_join(median_mortgage_amount, median_property_val, by="geoid")
HMDA_LAR_values_2 <- full_join(HMDA_LAR_values_1, num_mortgage_denials, by="geoid")
HMDA_LAR_values_3 <- full_join(HMDA_LAR_values_2, num_mortgage_loans, by="geoid")
HMDA_LAR_values <- full_join(HMDA_LAR_values_3, num_mortgage_orig, by="geoid")

# # Build with original tracts
# HMDA_LAR_values <- left_join(geoid_state, HMDA_LAR_values_4, by="geoid")

# Save
saveRDS(HMDA_LAR_values, file=paste("exported_data_sets/HMDA_LAR_values-", query_state_2, ".RDS", sep=""))

###############################################################################################
# 6. ##################### U.S. Small Business Administration (SBA) ###########################
###############################################################################################

ZIP_tract <- read_excel("downloaded_data_sets/ZIP_TRACT_062024.xlsx", sheet = 1) |> 
  mutate(TRACT = as.numeric(TRACT)) |> 
  mutate(ZIP = as.numeric(ZIP))

# Load the data from the saved file and display names
SBA_504 <- readRDS(file="downloaded_data_sets/SBA_504.RDS")
SBA_7 <- readRDS(file="downloaded_data_sets/SBA_7.RDS")

# Subset the 504 data to just include California
SBA_504_subset <- SBA_504 |> 
  select(ZIP=borrzip, state=borrstate, loan=grossapproval) |> 
  filter(state == query_state_2)

# Left-join on ZIP codes to add TRACT values to the data set
# This results in multiple zip codes per tract, multiple tracts per zip
SBA_504_tract <- left_join(SBA_504_subset, ZIP_tract, by = "ZIP", relationship = "many-to-many")

# Median of loans for the tract. This includes multiple zip codes.
median_504 <- SBA_504_tract |> 
  group_by(TRACT) |> 
  summarize(median_sba504_loan_amount = median(loan))

# Number of loans
num_504 <- SBA_504_tract |> 
  group_by(TRACT) |> 
  summarize(number_of_sba504_loans = n())

# Subset the 7(a) data to just include California
SBA_7_subset <- SBA_7 |> 
  select(ZIP=borrzip, state=borrstate, loan=grossapproval) |> 
  filter(state == query_state_2)

# Left-join on ZIP codes to add TRACT values to the data set
SBA_7_tract <- left_join(SBA_7_subset, ZIP_tract, by = "ZIP", relationship = "many-to-many")

# Median of loans
median_7 <- SBA_7_tract |> 
  group_by(TRACT) |> 
  summarize(median_sba7a_loan_amount = median(loan))

# Number of loans
num_7 <- SBA_7_tract |> 
  group_by(TRACT) |> 
  summarize(number_of_sba7a_loans = n())

# Build with full joins to avoid dropping info
# Note: this could be more memory efficient, but keeping variables allows for manual error checking
SBA_1 <- full_join(median_504, num_504, by="TRACT")
SBA_2 <- full_join(SBA_1, median_7, by="TRACT")
SBA_3 <- full_join(SBA_2, num_7, by="TRACT")

# Repeat the function (!) that converts numeric TRACT to character geoid:
SBA_values <- SBA_3 |> 
  mutate(geoid = as.character(TRACT)) |> 
  # add a leading zero if tract is only 10 characters to match others
  mutate(geoid = if_else(str_length(geoid) == 10, paste("0", geoid, sep=""), geoid)) |> 
  select(!TRACT)

# # Build with original tracts
# SBA_values <- left_join(geoid_state, SBA_3, by="geoid")

# Save
saveRDS(SBA_values, file=paste("exported_data_sets/SBA_values-", query_state_2, ".RDS", sep=""))

###############################################################################################
# 7. ################## Climate and Economic justice Screening Data ###########################
###############################################################################################

# Load the data from the saved file and display names
CEJST_communities_list_data <- readRDS(file="downloaded_data_sets/CEJST_communities_list_data.RDS")
#str(CEJST_communities_list_data)

# Subset for energy values and for the state:
CEJST_Energy_burden_fire_flood <- CEJST_communities_list_data |> 
  filter(`State/Territory` == query_state_full) |> 
  select(geoid = `Census tract 2010 ID`, energy_burden = `Energy burden`,
         energy_burden_percentile = `Energy burden (percentile)`,
         expected_agricultural_loss_rate_natural_hazards_risk_index = `Expected agricultural loss rate (Natural Hazards Risk Index)`,
         expected_agricultural_loss_rate_natural_hazards_risk_index_percentile = `Expected agricultural loss rate (Natural Hazards Risk Index) (percentile)`,
         expected_building_loss_rate_natural_hazards_risk_index = `Expected building loss rate (Natural Hazards Risk Index)`,
         expected_building_loss_rate_natural_hazards_risk_index_percentile = `Expected building loss rate (Natural Hazards Risk Index) (percentile)`,
         expected_population_loss_rate_natural_hazards_risk_index = `Expected population loss rate (Natural Hazards Risk Index)`,
         expected_population_loss_rate_natural_hazards_risk_index_percentile = `Expected population loss rate (Natural Hazards Risk Index) (percentile)`,
         share_of_properties_at_risk_of_fire_in_30_years = `Share of properties at risk of flood in 30 years`,
         share_of_properties_at_risk_of_fire_in_30_years_percentile = `Share of properties at risk of flood in 30 years (percentile)`,
         share_of_properties_at_risk_of_flood_in_30_years = `Share of properties at risk of fire in 30 years`,
         share_of_properties_at_risk_of_flood_in_30_years_percentile = `Share of properties at risk of fire in 30 years (percentile)`
         )

# # Build with original tracts
# Energy_burden_fire_flood <- left_join(geoid_state, CEJST_Energy_burden, by="geoid")

# Save
saveRDS(CEJST_Energy_burden_fire_flood, file=paste("exported_data_sets/Energy_burden-", query_state_2, ".RDS", sep=""))

###############################################################################################
# 8. ############################# EPA EJScreen Data ##########################################
###############################################################################################

# Load the data from the saved file and display names
EJScreen_tract <- readRDS(file="downloaded_data_sets/EJScreen_tract.RDS")
#str(EJScreen_tract)

# columns from data dictionary 2 are:

# EJScreen codes copy-pasted from DataKind Data Kit "data_dictionary_2-CA.csv"
EJScodes <- c("cancer","d2_cancer","d2_dslpm","d2_ldpnt","d2_ozone","d2_pm25","d2_pnpl","d2_prmp","d2_ptraf","d2_ptsdf","d2_pwdis","d2_resp","d2_rsei_air","d2_ust","d5_cancer","d5_dslpm","d5_ldpnt","d5_ozone","d5_pm25","d5_pnpl","d5_prmp","d5_ptraf","d5_ptsdf","d5_pwdis","d5_resp","d5_rsei_air","d5_ust","dslpm","ozone","p_cancer","p_d2_cancer","p_d2_dslpm","p_d2_ldpnt","p_d2_ozone","p_d2_pm25","p_d2_pnpl","p_d2_prmp","p_d2_ptraf","p_d2_ptsdf","p_d2_pwdis","p_d2_resp","p_d2_rsei_air","p_d2_ust","p_d5_cancer","p_d5_dslpm","p_d5_ldpnt","p_d5_ozone","p_d5_pm25","p_d5_pnpl","p_d5_prmp","p_d5_ptraf","p_d5_ptsdf","p_d5_pwdis","p_d5_resp","p_d5_rsei_air","p_d5_ust","p_dslpm","p_ldpnt","p_ozone","p_pm25","p_pnpl","p_prmp","p_ptraf","p_ptsdf","p_pwdis","p_resp","p_rsei_air","p_ust","pm25","pnpl","pre1960","pre1960pct","prmp","ptraf","ptsdf","pwdis","resp","rsei_air","ust")
EJScodes_names <- c("geoid", EJScodes)

# Make upper-case for query:
EJScodes_upper <- str_to_upper(EJScodes, locale = "en")

# Subset for cancer values:
EJScreen_values <- EJScreen_tract |> 
  filter(ST_ABBREV == query_state_2) |> 
  select(geoid = ID, all_of(EJScodes_upper))

# Rename columns to match DataKit
names(EJScreen_values) <- c("geoid", EJScodes)

# # Build with original tracts
# EJScreen <- left_join(geoid_state, EJScreen_values, by="geoid")

# Save
saveRDS(EJScreen_values, file=paste("exported_data_sets/EJScreen-", query_state_2, ".RDS", sep=""))

###############################################################################################
# 9. ###################### Low Income Housing Tax Credit (LIHTC) Program #####################
###############################################################################################

# Load the data from the saved file and display names
QCT_tract <- readRDS(file="downloaded_data_sets/QCT_tract.RDS")
#colnames(QCT_tract)

# Subset QCT for the Data Kit values:
QCT_values <- QCT_tract |> 
  filter(State_name == query_state_full) |> 
  select(geoid = tract_id, qct)

# # Build with original tracts
# QCT_values <- left_join(geoid_state, QCT, by="geoid")

# Save
saveRDS(QCT_values, file=paste("exported_data_sets/QCT_values-", query_state_2, ".RDS", sep=""))

###############################################################################################
############################## Create the Data Kit csv files ##################################
###############################################################################################

# Data Kit data_1.csv contains the listed at the beginning of this script.  In case order of
#   columns is important to some analysis, the csv data sets will be constructed in the same column
#   order.

# Set up first 6 columns, some of which are redundant. Keep geoid as character to match 
data_1a <- tibble(geoid_state, "geoid_year" = 2020, "state" = as.numeric(substring(unname(unlist(geoid_state)), 1, 2)),
                 "county" = as.numeric(substring(unname(unlist(geoid_state)), 3, 5)), 
                 "state_fips_code" = as.numeric(substring(unname(unlist(geoid_state)), 1, 2)),
                 "county_fips_code" = as.numeric(substring(unname(unlist(geoid_state)), 3, 5)))

# Start data filling
# 7th Item: "loan_amount"
# Note: does NOT match DataKind Data Kit values.  See (3) CDFI FUND - Transaction-level report
CDFI_TLR_loans <- readRDS(file=paste("exported_data_sets/CDFI_TLR_loans-", query_state_2, ".RDS", sep=""))
data_1b <- left_join(data_1a, CDFI_TLR_loans, by = "geoid")

# Items: median_mortgage_amount, median_prop_value
HMDA_LAR_values <- readRDS(file=paste("exported_data_sets/HMDA_LAR_values-", query_state_2, ".RDS", sep=""))
HMDA_LAR_values_1 <- HMDA_LAR_values |> 
  select(geoid, median_mortgage_amount, median_prop_value)
data_1c <- left_join(data_1b, HMDA_LAR_values_1, by = "geoid")

# Items: median_sba504_loan_amount, median_sba7a_loan_amount
SBA_values<- readRDS(file=paste("exported_data_sets/SBA_values-", query_state_2, ".RDS", sep=""))
SBA_values_1 <- SBA_values |> 
  select(geoid, median_sba504_loan_amount, median_sba7a_loan_amount)
data_1d <- left_join(data_1c, SBA_values_1, by = "geoid")

# Items: num_mortgage, num_mortgage_denials, num_mortgage_originated
HMDA_LAR_values_2 <- HMDA_LAR_values |> 
  select(geoid, num_mortgage, num_mortgage_denials, num_mortgage_originated)
data_1e <- left_join(data_1d, HMDA_LAR_values_2, by = "geoid")

# Items: number_of_sba504_loans, number_of_sba7a_loans
SBA_values_2 <- SBA_values |> 
  select(geoid, number_of_sba504_loans, number_of_sba7a_loans)
data_1f <- left_join(data_1e, SBA_values_2, by = "geoid")

# Items: subset of scodes ACS, see "select" statement below
scodes_all_tracts_2022_format<- readRDS(file=paste("exported_data_sets/ACS_scodes-", query_state_2, ".RDS", sep=""))
scodes_all_tracts_2022_format_1 <- scodes_all_tracts_2022_format |> 
  select(geoid, s0101_c03_032m, s0101_c03_032e, s0101_c05_032e, s0101_c05_032m, 
       s0101_c01_032e, s0101_c01_032m, s0101_c04_021e, s0101_c04_021m, 
       s0101_c06_021e, s0101_c06_021m, s0101_c02_021e, s0101_c02_021m, 
       s0101_c04_024e, s0101_c04_024m, s0101_c06_024e, s0101_c06_024m, 
       s0101_c02_024e, s0101_c02_024m, s0101_c04_025e, s0101_c04_025m, 
       s0101_c06_025e, s0101_c06_025m, s0101_c02_025e, s0101_c02_025m, 
       s0101_c04_023e, s0101_c04_023m, s0101_c06_023e, s0101_c06_023m, 
       s0101_c02_023e, s0101_c02_023m, s0101_c04_026e, s0101_c04_026m, 
       s0101_c06_026e, s0101_c06_026m, s0101_c02_026e, s0101_c02_026m, 
       s0101_c04_027e, s0101_c04_027m, s0101_c06_027e, s0101_c06_027m, 
       s0101_c02_027e, s0101_c02_027m, s0101_c04_020e, s0101_c04_020m, 
       s0101_c06_020e, s0101_c06_020m, s0101_c02_020e, s0101_c02_020m, 
       s0101_c04_028e, s0101_c04_028m, s0101_c06_028e, s0101_c06_028m, 
       s0101_c02_028e, s0101_c02_028m, s0101_c04_029e, s0101_c04_029m, 
       s0101_c06_029e, s0101_c06_029m, s0101_c02_029e, s0101_c02_029m, 
       s0101_c04_030e, s0101_c04_030m, s0101_c06_030e, s0101_c06_030m, 
       s0101_c02_030e, s0101_c02_030m, s0101_c04_031e, s0101_c04_031m, 
       s0101_c06_031e, s0101_c06_031m, s0101_c02_031e, s0101_c02_031m, 
       s0101_c04_022e, s0101_c04_022m, s0101_c06_022e, s0101_c06_022m, 
       s0101_c02_022e, s0101_c02_022m)
data_1g <- left_join(data_1f, scodes_all_tracts_2022_format_1, by = "geoid")

# Items: subset from pcodes ACS
pcodes_all_tracts_2022_format <- readRDS(file=paste("exported_data_sets/ACS_pcodes-", query_state_2, ".RDS", sep=""))
pcodes_all_tracts_2022_format_1 <- pcodes_all_tracts_2022_format |> 
  select(geoid, dp05_0035pe, dp05_0037pe, dp05_0038pe, dp05_0039pe, dp05_0044pe, dp05_0052pe, dp05_0057pe)
data_1h <- left_join(data_1g, pcodes_all_tracts_2022_format_1, by = "geoid")

# items_ subset from bcodes ACS
bcodes_all_tracts_2022_format <- readRDS(file=paste("exported_data_sets/ACS_bcodes-", query_state_2, ".RDS", sep=""))
bcodes_all_tracts_2022_format_1 <- bcodes_all_tracts_2022_format |> 
  select(geoid, b23025_004e, b23025_004m, b23025_005e, b23025_005m, b23025_006e, 
       b23025_006m, b23025_002e, b23025_002m)
data_1i <- left_join(data_1h, bcodes_all_tracts_2022_format_1, by = "geoid")

# Items: subset of scodes ACS (again)
scodes_all_tracts_2022_format_2 <- scodes_all_tracts_2022_format |> 
  select(geoid, s2001_c03_002e, s2001_c03_002m, s2001_c05_002e, s2001_c05_002m, 
       s2001_c01_002e, s2001_c01_002m, s1903_c03_011e, s1903_c03_011m, s1903_c03_012e, 
       s1903_c03_012m, s1903_c03_013e, s1903_c03_013m, s1903_c03_014e, s1903_c03_014m, 
       s1903_c03_002e, s1903_c03_002m, s1903_c03_003e, s1903_c03_003m, s1903_c03_004e, 
       s1903_c03_004m, s1903_c03_005e, s1903_c03_005m, s1903_c03_006e, s1903_c03_006m, 
       s1903_c03_007e, s1903_c03_007m, s1903_c03_008e, s1903_c03_008m, s1903_c03_009e, 
       s1903_c03_009m, s1903_c03_010e, s1903_c03_010m, s1903_c03_001e, s1903_c03_001m, 
       s1701_c03_002e, s1701_c03_002m, s1701_c03_003e, s1701_c03_003m, s1701_c03_004e, 
       s1701_c03_004m, s1701_c03_006e, s1701_c03_006m, s1701_c03_007e, s1701_c03_007m, 
       s1701_c03_008e, s1701_c03_008m, s1701_c03_009e, s1701_c03_009m, s1701_c03_010e, 
       s1701_c03_010m, s1701_c03_013e, s1701_c03_013m, s1701_c03_014e, s1701_c03_014m, 
       s1701_c03_015e, s1701_c03_015m, s1701_c03_016e, s1701_c03_016m, s1701_c03_017e, 
       s1701_c03_017m, s1701_c03_018e, s1701_c03_018m, s1701_c03_019e, s1701_c03_019m, 
       s1701_c03_020e, s1701_c03_020m, s1701_c03_021e, s1701_c03_021m, s1701_c03_011e, 
       s1701_c03_011m, s1701_c03_012e, s1701_c03_012m, s1701_c03_001e, s1701_c03_001m, 
       s2701_c03_002e, s2701_c03_002m, s2701_c03_003e, s2701_c03_003m, s2701_c03_004e, 
       s2701_c03_004m, s2701_c03_005e, s2701_c03_005m, s2701_c03_006e, s2701_c03_006m, 
       s2701_c03_007e, s2701_c03_007m, s2701_c03_008e, s2701_c03_008m, s2701_c03_009e, 
       s2701_c03_009m, s2701_c03_010e, s2701_c03_010m, s2701_c03_011e, s2701_c03_011m, 
       s2701_c03_012e, s2701_c03_012m, s2701_c03_013e, s2701_c03_013m, s2701_c03_016e, 
       s2701_c03_016m, s2701_c03_017e, s2701_c03_017m, s2701_c03_018e, s2701_c03_018m, 
       s2701_c03_019e, s2701_c03_019m, s2701_c03_020e, s2701_c03_020m, s2701_c03_021e, 
       s2701_c03_021m, s2701_c03_022e, s2701_c03_022m, s2701_c03_023e, s2701_c03_023m, 
       s2701_c03_024e, s2701_c03_024m, s2701_c03_014e, s2701_c03_014m, s2701_c03_015e, 
       s2701_c03_015m, s2701_c03_001e, s2701_c03_001m, s2701_c05_002e, s2701_c05_002m, 
       s2701_c05_003e, s2701_c05_003m, s2701_c05_004e, s2701_c05_004m, s2701_c05_005e, 
       s2701_c05_005m, s2701_c05_006e, s2701_c05_006m, s2701_c05_007m, s2701_c05_007e, 
       s2701_c05_008e, s2701_c05_008m, s2701_c05_009e, s2701_c05_009m, s2701_c05_010e, 
       s2701_c05_010m, s2701_c05_011e, s2701_c05_011m, s2701_c05_012e, s2701_c05_012m, 
       s2701_c05_013e, s2701_c05_013m, s2701_c05_016e, s2701_c05_016m, s2701_c05_017e, 
       s2701_c05_017m, s2701_c05_018e, s2701_c05_018m, s2701_c05_019e, s2701_c05_019m, 
       s2701_c05_020e, s2701_c05_020m, s2701_c05_021e, s2701_c05_021m, s2701_c05_022e, 
       s2701_c05_023e, s2701_c05_022m, s2701_c05_023m, s2701_c05_014e, s2701_c05_014m, 
       s2701_c05_015e, s2701_c05_015m, s2701_c05_001e, s2701_c05_001m)
data_1j <- left_join(data_1i, scodes_all_tracts_2022_format_2, by = "geoid")

# Items: subset of bcodes from ACS (again)
bcodes_all_tracts_2022_format_2 <- bcodes_all_tracts_2022_format |> 
  select(geoid, b19083_001e, b19083_001m)
data_1k <- left_join(data_1j, bcodes_all_tracts_2022_format_2, by = "geoid")

# Items: economic_distress_pop_agg, economic_distress_simple_agg
# Note: Descriptions of both items is identical in the data dictionary,
#   but values in DataKind Data Kit are not!
economic_distress_agg<- readRDS(file=paste("exported_data_sets/economic_distress_agg-", query_state_2, ".RDS", sep=""))
data_1l <- left_join(data_1k, economic_distress_agg, by = "geoid")

# Item: investment_areas
CDFI_investment_areas <- readRDS(file=paste("exported_data_sets/CDFI_investment_areas-", query_state_2, ".RDS", sep=""))
data_1m <- left_join(data_1l, CDFI_investment_areas, by = "geoid")

# Item: opzone
# Note: convert NA to 0
HUD_qualified_opportunity_zones_state <- readRDS(file=paste("exported_data_sets/opzone-", query_state_2, ".RDS", sep=""))
data_1n <- left_join(data_1m, HUD_qualified_opportunity_zones_state, by = "geoid") |> 
  mutate(opzone = if_else(is.na(opzone), 0, opzone))

# Write newly constructed csv file data_1
write_csv(data_1n, file=paste("data_1-", query_state_2, "_new.csv", sep=""))

############# Inconsistencies with DataKit and this output data_1.csv file ##################
# loan_amount
# median_sba504_loan_amount
# median_sba7a_loan_amount
# number_of_sba504_loans
# number_of_sba7a_loans
# economic_distress_pop_agg
# economic_distress_simple_agg

###############################################################################################
# Data Kit data_2.csv contains the listed at the beginning of this script.  In case order of
#   columns is important to some analysis, the csv data sets will be constructed in the same column
#   order.

# Set up first 6 columns, some of which are redundant. Keep geoid as character to match 
data_2a <- tibble(geoid_state, "geoid_year" = 2020, "state" = as.numeric(substring(unname(unlist(geoid_state)), 1, 2)),
                  "county" = as.numeric(substring(unname(unlist(geoid_state)), 3, 5)), 
                  "state_fips_code" = as.numeric(substring(unname(unlist(geoid_state)), 1, 2)),
                  "county_fips_code" = as.numeric(substring(unname(unlist(geoid_state)), 3, 5)))

# Start data filling
# Items: cancer, d2_cancer, d5_cancer, d2_resp, resp, d5_resp
EJScreen_values <- readRDS(file=paste("exported_data_sets/EJScreen-", query_state_2, ".RDS", sep=""))
EJScreen_values_subset1 <- EJScreen_values |> 
  select(geoid, cancer, d2_cancer, d5_cancer, d2_resp, resp, d5_resp, d2_dslpm, d5_dslpm, 
         dslpm, d2_ptsdf, d5_ptsdf, ptsdf, pre1960, d2_ldpnt, d5_ldpnt, pre1960pct, 
         d2_ozone, d5_ozone, ozone, d2_pm25, d5_pm25, pm25, p_cancer, p_d2_cancer, 
         p_d5_cancer, p_d2_resp, p_d5_resp, p_resp, p_d2_dslpm, p_d5_dslpm, p_dslpm, 
         p_d2_ptsdf, p_d5_ptsdf, p_ptsdf, p_d2_ldpnt, p_d5_ldpnt, p_ldpnt, p_d2_ozone, 
         p_d5_ozone, p_ozone, p_d2_pm25, p_d5_pm25, p_pm25, p_d2_prmp, p_d5_prmp, p_prmp, 
         p_d2_pnpl, p_d5_pnpl, p_pnpl, p_d5_rsei_air, p_d2_rsei_air, p_rsei_air, p_d2_ptraf, 
         p_d5_ptraf, p_ptraf, p_d2_ust, p_d5_ust, p_ust, p_d2_pwdis, p_d5_pwdis, p_pwdis, 
         d2_prmp, d5_prmp, prmp, d2_pnpl, d5_pnpl, pnpl, d2_rsei_air, rsei_air, d5_rsei_air, 
         d2_ptraf, d5_ptraf, ptraf, d2_ust, d5_ust, ust, d2_pwdis, d5_pwdis, pwdis)
data_2b <- left_join(data_2a, EJScreen_values_subset1, by = "geoid")

# Items: energy_burden, energy_burden_percentile
CEJST_Energy_burden_fire_flood <- readRDS(file=paste("exported_data_sets/Energy_burden-", query_state_2, ".RDS", sep=""))
CEJST_Energy_burden_fire_flood_subset <- CEJST_Energy_burden_fire_flood |> 
  select(geoid, energy_burden, energy_burden_percentile,
         expected_agricultural_loss_rate_natural_hazards_risk_index,
         expected_agricultural_loss_rate_natural_hazards_risk_index_percentile,
         expected_building_loss_rate_natural_hazards_risk_index,
         expected_building_loss_rate_natural_hazards_risk_index_percentile,
         expected_population_loss_rate_natural_hazards_risk_index,
         expected_population_loss_rate_natural_hazards_risk_index_percentile,
         share_of_properties_at_risk_of_fire_in_30_years,
         share_of_properties_at_risk_of_fire_in_30_years_percentile,
         share_of_properties_at_risk_of_flood_in_30_years,
         share_of_properties_at_risk_of_flood_in_30_years_percentile
  )
data_2c <- left_join(data_2b, CEJST_Energy_burden_fire_flood_subset, by = "geoid")

# Items: subset of scodes ACS (again)
scodes_all_tracts_2022_format_3 <- scodes_all_tracts_2022_format |> 
  select(geoid, s2503_c03_024e, s2503_c03_024m, s2503_c05_024e, s2503_c05_024m, 
         s2503_c01_024e, s2503_c01_024m)
data_2d <- left_join(data_2c, scodes_all_tracts_2022_format_3, by = "geoid")

# Item: qtc
QCT_values <- readRDS(file=paste("exported_data_sets/QCT_values-", query_state_2, ".RDS", sep=""))
data_2e <- left_join(data_2d, QCT_values, by = "geoid")

# Items: subset of bcodes from ACS (again)
bcodes_all_tracts_2022_format_3 <- bcodes_all_tracts_2022_format |> 
  select(geoid, b23025_003e, b23025_003m, b23025_007e, b23025_007m)
data_2f <- left_join(data_2e, bcodes_all_tracts_2022_format_3, by = "geoid")

# Write newly constructed csv file data_1
write_csv(data_2f, file=paste("data_2-", query_state_2, "_new.csv", sep=""))

############# Inconsistencies with DataKit and this output data_2.csv file ##################
# All data from the CEJST communities data set:
#
# energy_burden
# energy_burden_percentile
# expected_agricultural_loss_rate_natural_hazards_risk_index
# expected_agricultural_loss_rate_natural_hazards_risk_index_percentile
# expected_building_loss_rate_natural_hazards_risk_index
# expected_building_loss_rate_natural_hazards_risk_index_percentile
# expected_population_loss_rate_natural_hazards_risk_index
# expected_population_loss_rate_natural_hazards_risk_index_percentile
# share_of_properties_at_risk_of_fire_in_30_years
# share_of_properties_at_risk_of_fire_in_30_years_percentile
# share_of_properties_at_risk_of_flood_in_30_years
# share_of_properties_at_risk_of_flood_in_30_years_percentile
