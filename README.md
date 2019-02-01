# Run random forest pipeline on Flux

1. You need to change the email etc on the pbs file. 
2. The ```#PBS -t 1-100``` part means that we will run the model 100 times. The arrayID will also set the seed for each run.
3. You need to load R/3.5.0 and r-biomed-libs/3.5.0 libraries

```qsub random_forest.pbs```
