# Submitting jobs to the cluser

sbatch SlurmScript

squeue -u username

squeue -j JobId # quick view of job status

scancel jobid # Cancel job with id jobid (as returned from sbatch)




# Template for jobScript ############################################################

#!/bin/bash                                                                                                                                    

# Job name:                                                                                                                                    
#SBATCH --job-name=SRS452446                                                                                                                   
#                                                                                                                                              
# Project:                                                                                                                                     
#SBATCH --account=uio                                                                                                                          
#                                                                                                                                              
# Wall clock limit:                                                                                                                            
#SBATCH --time=48:00:00                                                                                                                        
#                                                                                                                                              
# Max memory usage:                                                                                                                            
#SBATCH --mem-per-cpu=3G                                                                                                                       
#                                                                                                                                              
# Number of cores:                                                                                                                             
#SBATCH --cpus-per-task=6                                                                                                                      

## Set up job environment                                                                                                                      
source /cluster/bin/jobsetup

## Copy input files to the work directory:                                                                                                     
#cp MyInputFile $SCRATCH                                                                                                                       

## Make sure the results are copied back to the submit directory (see Work Directory below):                                                   
#chkfile MyResultFile                                                                                                                          

## Do some work:                                                                                                                               
cd /work/users/timothyh/SRS452446

tophat --num-threads 6 --read-realign-edit-dist 1 --no-coverage-search -o ./tophat_out_wg --GTF /usit/abel/u1/timothyh/home/refData/Mus_muscul\
us/UCSC/mm10/Annotation/Genes/genes.gtf /usit/abel/u1/timothyh/home/refData/Mus_musculus/UCSC/mm10/Sequence/Bowtie2Index/genome SRR921955_1.fa\
stq.gz,SRR921956_1.fastq.gz,SRR921957_1.fastq.gz,SRR921958_1.fastq.gz

# End of template for jobScript ############################################################