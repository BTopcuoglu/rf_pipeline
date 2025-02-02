######################################################################
# Author: Begum Topcuoglu
# Date: 2019-01-15
# Title: Generate files that has cv and test AUCs for 1 data-split 
######################################################################

######################################################################
# Dependencies and Outputs: 
# This function accept files generated in main.R
#    Filename to put to function: 
#   "Random_Forest"


# Call as source when using the function. The function is:
#   get_AUCs()

# The output:
#  A results .csv file with:
#     1. AUCs  for cv of 1 data-split
#     2. AUCS for test of 1 data-split
######################################################################

######################################################################
#----------------- Read in necessary libraries -------------------#
######################################################################

deps = c("reshape2", "kernlab","LiblineaR", "doParallel","pROC", "caret", "gtools", "tidyverse", "ggpubr", "ggplot2","knitr","rmarkdown","vegan");
for (dep in deps){
  if (dep %in% installed.packages()[,"Package"] == FALSE){
    install.packages(as.character(dep), quiet=TRUE);
  }
  library(dep, verbose=FALSE, character.only=TRUE)
}

######################################################################
#------------------------- DEFINE FUNCTION -------------------#
######################################################################
get_AUCs <- function(dataset, models, split_number){
  for(ml in models){
    
    # Save results of the modeling pipeline as a list
    results <- pipeline(dataset, ml) 
    
    # ------------------------------------------------------------------ 
    # Create a matrix with cv_aucs and test_aucs from 100 data splits
    aucs <- matrix(c(results[[1]], results[[2]]), ncol=2) 
    # Convert to dataframe and add a column noting the model name
    aucs_dataframe <- data.frame(aucs) %>% 
      rename(cv_aucs=X1, test_aucs=X2) %>% 
      mutate(model=ml) %>% 
      write.csv(file=paste0("data/temp/best_hp_results_", ml,"_", split_number, ".csv"), row.names=F)
    # ------------------------------------------------------------------   
    
    # ------------------------------------------------------------------   
    # Save all tunes from 100 data splits and corresponding AUCs
    all_results <- results[3]
    # Convert to dataframe and add a column noting the model name
    dataframe <- data.frame(all_results) %>% 
      mutate(model=ml) %>% 
      write.csv(file=paste0("data/temp/all_hp_results_", ml,"_", split_number, ".csv"), row.names=F)
    # ------------------------------------------------------------------ 
  }
}

