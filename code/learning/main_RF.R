######################################################################
# Author: Begum Topcuoglu
# Date: 2018-12-20
# Title: Main pipeline in R programming language
######################################################################

######################################################################
# Description: 

# This script will read in data from Baxter et al. 2016
#     - 0.03 subsampled OTU dataset
#     - CRC metadata: SRN information


# It will run the following machine learning pipelines:
#   Random Forest
######################################################################

######################################################################
# Dependencies and Outputs: 

# Be in the project directory.

# The outputs are:
#   (1) AUC values for cross-validation and testing for each data-split 
#   (2) meanAUC values for each hyper-parameter tested during each split.
######################################################################


################### IMPORT LIBRARIES and FUNCTIONS ###################
# The dependinces for this script are consolidated in the first part
deps = c("randomForest", "reshape2", "kernlab","LiblineaR", "doParallel","pROC", "caret", "gtools", "tidyverse");
for (dep in deps){
  if (dep %in% installed.packages()[,"Package"] == FALSE){
    install.packages(as.character(dep), quiet=TRUE, repos = "http://cran.us.r-project.org");
  }
  library(dep, verbose=FALSE, character.only=TRUE)
}

# Load in needed functions and libraries
source('code/learning/model_selection_RF.R')
source('code/learning/model_pipeline_RF.R')
source('code/learning/generateAUCs_RF.R')
######################################################################

######################## DATA PREPARATION #############################
# Features: Hemoglobin levels and 16S rRNA gene sequences in the stool 
# Labels: - Colorectal lesions of 490 patients. 
#         - Defined as cancer or not.(Cancer here means: SRN)
# Read in metadata and select only sample Id and diagnosis columns
meta <- read.delim('data/metadata.tsv', header=T, sep='\t') %>%
  select(sample, Dx_Bin, fit_result)
# Read in OTU table and remove label and numOtus columns
shared <- read.delim('data/baxter.0.03.subsample.shared', header=T, sep='\t') %>%
  select(-label, -numOtus)
# Merge metadata and OTU table.
# Group advanced adenomas and cancers together as cancer and normal, high risk normal and non-advanced adenomas as normal
# Then remove the sample ID column
data <- inner_join(meta, shared, by=c("sample"="Group")) %>%
  mutate(dx = case_when(
    Dx_Bin== "Adenoma" ~ "normal",
    Dx_Bin== "Normal" ~ "normal",
    Dx_Bin== "High Risk Normal" ~ "normal",
    Dx_Bin== "adv Adenoma" ~ "cancer",
    Dx_Bin== "Cancer" ~ "cancer"
  )) %>%
  select(-sample, -Dx_Bin) %>%
  drop_na()
# We want the diagnosis column to a factor
data$dx <- factor(data$dx, labels=c("normal", "cancer"))
###################################################################

######################## RUN PIPELINE #############################
start_time <- Sys.time()

input <- commandArgs(trailingOnly=TRUE) # recieve input from model
# Get variables from command line
seed <- as.numeric(input[1])
model <- input[2]

set.seed(seed)
get_AUCs(data, model, input[1])

# Usage in command-line:
#   Rscript code/main_RF.R $seed "Random_Forest"


end_time <- Sys.time()
print(end_time - start_time)
###################################################################




