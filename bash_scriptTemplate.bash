#!/bin/bash

# Load the needed functions to handle the most tricky issue which is the transfer of 
# compressed files which need to be decompressed after transfer.
# Basic idea is that the decompressed versions of the files are excluded from the transfer but the compressed 
# versions are transferred over and decompressed on the receiver.
# We can combine the above with the --delete option (which keeps the receiver tidy and synced) bcse
# the --delete option ignores files in the --exclude options (thus the decompressed files do not get deleted)
abspath="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
dirPath=`dirname $abspath`
source ${dirPath}/dataRepoDecompressionFunctions.bash


########################## PARSING COMMAND LINE ############################
function usage()
{
cat 1>&2 <<USAGE

This code will copy over from a dataRepo to a distro all the files that are required in the distro.
The copying is done using rsync -auP to ensure that all time stamps are maintained.
Thus, we can use this script to **update** an existing distro or for **creating** a new one from scratch.

The default is to run in dry run mode which means nothing is actually done: only an output of 
what would get copied is produced.

IMPORTANT: some files in the repo are compressed. Some of these compressed files must stay compressed
to be usable by their respective applications. Some need to be decompressed to be usable. For those that 
need to be decompressed, we perform decompression on the user machine (rather than in the repo) so
as to keep the distro to a reasonable size.

Inputs:
*	src: a dataRepo directory eg dataRepo_r01
*	dest: a dataDistro directory e.g. dataDistro_r01_d01. If the dataDistro directory is empty, then
the files in the repo are copied over to the distro directory. If the dataDistro dir already contains
distro files then it is updated from the repo.

Outputs:
*	a summary of what WAS done or WOULD have been done (dry run).
*	if this is not a dry run, then files are actually copied over.

  
Usage: `basename $0` [OPTIONS] src dest
  
Options:
     -e actually execute the transfer (default is to do a dry run)
     
Example: `basename $0` [OPTIONS] dataRepo_r01 dataDistro_r01_d01
     
USAGE

  exit 85
}
# Exit anyway if no args provided
if [ $# -eq "0" ]; then usage; fi  

############### SET OPTION VARS TO DEFAULTS #############
declare -i e=0;

################### PARSE THE OPTIONS ########################
while getopts "e" Option
do
  case $Option in
    e ) e=1;;    
    * ) usage;;   # Default.
  esac
done

#################### PARSE NON-FLAG ARGS #####################

shift $(($OPTIND - 1)) # updates all the positiona parameters which should leave first non-option arg in $1

src=$1
dest=$2

#################### CHECK READY TO PROCEED #################
# Checking essential values are set
if [ -z "$e" ] || [ -z "$src" ] || [ -z "$dest" ]; then
	usage;
fi


############################### SCRIPT #############################################################

rsyncCommand="rsync -auh --progress --stats" # basic rsync command
# Fix dry run
if [ $e -eq 0 ]; then
	rsyncCommand+=" -n ";
fi

# Remove from the distro anything that is no longer in the repo
rsyncCommand+=" --delete "

rsyncCommand+=" --exclude=.DS_Store "

# Make sure to exclude any of the decompressed files, so that they do not get transferred and are not deleted on the receiver
rsyncCommand+=`getRsyncExclStringForDecompFiles`




## FILES THAT ARE IN THE REPO BUT SHOULD NOT BE IN THE DISTRO

# Capture kits and clinical gene packages ###############################
rsyncCommand+=" --exclude=00_download "
rsyncCommand+=" --exclude=00_intermediateFiles "

# Genomic ###############################################################
rsyncCommand+=" --exclude=*.md5 " # * no need to copy over the md5 files (decompressing most to md5 irrelevant)
rsyncCommand+=" --exclude=human_g1k_v37.* " # * we limit ourselves to the human_g1k_v37_decoy
#rsyncCommand+=" --exclude=1000G_phase1.snps.high_confidence.b37.vcf* " # Ying made a request for this to be included, so commented out the exclude
rsyncCommand+=" --exclude=gatkBundle_2.5/CEUTrio.HiSeq.WGS.b37* " # be specific on directory here bcse file pattern found in test part of repo
rsyncCommand+=" --exclude=NA12878.HiSeq.WGS.bwa.cleaned.raw.subset.b37* "

# FuncAnnot #############################################################
# * snpEff has its own compressed files in .bin format (we do nothing)
# * VEP has files which are gz but these MUST NOT be decompressed
# dbNSFP has one file which is gz compressed and its huge and thus must be left compressed and be decompressed

# testData ##############################################################
# Nothing to exclude

# variantDbs ############################################################
# * most databases are small, so might as well decompress
# * for very big dbs like clinvar, we probably have to decompress as part of the install.

# igv ###################################################################
# Nothing to exclude

# Create destination dir if does not already exist
# Need to do this before executing the rsync command both in DRY_RUN and EXECUTE mode
if [[ ! -e ${dest} ]]; then
echo "The destination dir does not exist and will be created: ${dest}";
mkdir -p ${dest};
fi


# Finally add source and destination, and EXECUTE
rsyncCommand+=" "${src}/*" "${dest} # * after src bcse do not want to copy over dataRepo dir (only contents)
# ACTUALLY EXECUTE: capture output to be able to summarise most important later and to stdout so that user can monitor progress
${rsyncCommand} | tee rsyncTemp.txt 


echo # for spacing
echo "## Summarising  the most important part of rsync output (see above) ##########################"
# Cannot do this directly when running the command above bcse cannot then see progress
 # remove lines with just directories unless a delete and remove progress lines
cat rsyncTemp.txt  | grep -E '^deleting|[^/]$' | grep -v "files\.\.\." | grep -v "to-check" > rsyncTempClean.txt # save for logging
cat rsyncTempClean.txt


# Analyse rsyncTemp.txt to locate compressed files that may require decompression
# Ignore any files in rsyncTemp.txt that are being deleted
transferredCompFiles=`grep -e ".*gz$" -e ".*.zip" rsyncTemp.txt | grep -v "deleting" | tr -s " " "\t" | cut -f 2`


# DRY RUN SCENARIO
if [[ $e -eq 0 ]]; then # this is a dry run so the files are still on the src and we just want to list them
	echo # for spacing
	echo "## Overview of transferred compressed files which will be decompressed IF run in EXECUTE mode"
	echo "## (this can take a while if it is the first transfer)"
	for file in $transferredCompFiles; do
	decomp=`isToBeDecomp ${file}`
		if [ $decomp -eq 1 ]; then # only list a transferred compressed file here if it is on the list of files requiring decompression
			# NB: there are many compressed files that do not need or must not be decompressed before use.
			# Need to fix file path so that ls can locate file
			ls -lh ${src}/${file} | awk 'BEGIN{OFS="\t";};{print $5, $9};END{}'
		fi
	done
fi

# EXECUTE SCENARIO: the files have been copied over to dest and need decompressing
if [[ $e -eq 1 ]]; then
	echo # for spacing
	echo "## Transferred compressed files requiring decompression to be usable"
	echo "## (this can take a while if it is the first transfer)"	
	for file in $transferredCompFiles; do
		# Need to fix file path so that ls can locate file on dest ie user machine
		# File starts with last element of src which is usually something like dataRepo_r01 which we need in path
		destFile=${dest}/${file}
		decomp=`isToBeDecomp ${destFile}`
		if [ $decomp -eq 1 ]; then # only list the file here if it is on the list of files requiring decompression
		# Now do the decompression
		echo "Decompressing:" ${destFile}
		decompress ${destFile}
		fi
	done
	# Update the log	
	echo `date`"---------------------------------" >> ${dest}/dataRepoToDistro_syncLog.txt
	cat rsyncTempClean.txt >> ${dest}/dataRepoToDistro_syncLog.txt

fi

# Clean up
rm -f rsyncTemp.txt;
rm -f rsyncTempClean.txt;


echo
echo

echo "## The command that was run ######################################################################"
echo ${rsyncCommand}
echo
# Remind the user if this was a dry run that nothing was actually done
if [ $e -eq 0 ]; then
	echo "*****DRY RUN********: nothing was actually copied over (or decompressed)"
fi



