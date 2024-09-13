# Data transfer commands

# Downloading with wget #############################################################################

# no-directories avoids creation locally of all the remote directory structure above the directory of interest
# --reject regex allows files in the directory structure to be excluded
wget --no-directories -r ftp://ftp.broadinstitute.org/pub


# Transfer and unpacking large public datasets ######################################

# 1. Locate the dataset using Geo Omnibus
# 2. Use DNANEXUS to get a table of all the relevant samples and download their URLs
# 3. Use aspera to download at fast transfer speeds
rootDir="/sra/sra-instant/reads/ByRun/sra/SRR/SRR104"

declare -i nb=1047864

while [[ ${nb} < 1047875 ]]; do file=${rootDir}/SRR${nb}/SRR${nb}.sra; echo $file; /usit/abel/u1/timothyh/.aspera/connect/bin/ascp -i /usit/abel/u1/timothyh/.aspera/connect/etc/asperaweb_id_dsa.openssh -k1 -Tr -l100M --user=anonftp --mode=recv --host=ftp-trace.ncbi.nlm.nih.gov ${file} /work/users/timothyh; nb=${nb}+1; done

# 4. Transform from SRA to fastq format with gz compression 
for file in SRR10478*.sra; do echo $file; (nohup $h/bin/sratoolkit.2.4.0-1-centos_linux64/bin/fastq-dump --split-files --gzip -v ${file} &); done


# MD5 check #########################################################################

find . -type f -print0 | xargs -0 md5sum > md5sum_file