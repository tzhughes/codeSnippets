# File decompression commands

## ZIP
# zip leaves copy of original archive by default, no need to do anything specific
# zip will prompt user if inflating will cause overwriting of existing file, so need to force it with -o
# zip will decompress to pwd, so need to provide the destination directory (which is dir of file to be decompressed)
unzip -o ${destFile} -d `dirname ${destFile}` 

## GZIP
# gzip will not leave copy of original archive, thus the -c option
# We explicitly specify output file, solving overwriting and location issues
gunzip -c ${destFile} > ${destFile%.*} 
