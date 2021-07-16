# dissertation
This repo contains all of the code for my dissertation research, Age Differences in Contraceptive Use. 

Predictably, as my defense date approached, things got... a little messy. I no longer have access to SAS 9.4 and want to keep all of my code for posterity, so I elected not to do a clean-up on these files. Here are a few points of interest:

## aim1*.sas
Individual scripts for each analysis that contributed to aim 1. They are very similar and include unadjusted and adjusted logistic regression models with natural cubic splines and include estimate statements for the prevalence estimates.

Macros I wrote to do the estimation, restructure the output, and chart using proc sgplot.

## nsfg_analysis_vartx.sas
How I derived variables for inclusion in models for aims 1 & 2. Mostly if/then statements for clarity.

## nsfg_CMcWFormats.sas
Formats and labels I created for each variable.

## NLSY (folder) > aim3.sas
Code for the complementary log-log model, including the predictive mean matching imputation I performed. 
