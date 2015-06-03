
############ Data frames
allData <- read.table("/Users/timothyh/home/proj_vrk2/data/mRNAvsDiag/VRK2_mRNA_to_Tim.tab" , header = TRUE, sep = "\t")


# Basic manipulation of a dataframe
subset(allData, myVar>1) # subsetting has the DROP option
with(allData,) # Useful for computing a new variable when if is a complex function of existing variables


############# Factors

commonTissue=droplevels(commonTissue) # Removes unused levels in factors

############# PLYR

library("plyr")

# Key functions are:
# * summarise: does not create a new dataframe
# * transform: creates a new dataframe
# * subset: enables subsets to be computed when the subsetting depends on subgroups.

## SUBSET
to select the top (or bottom) n (or x%) of observations in a group, or observations above some group-specific threshold
ddply(diamonds, .(color), subset, order(carat) <= 2)
ddply(diamonds, .(color), subset, price > mean(price))

## TRANSFORM and SUMMARISE

# Use length to compute the number of records in a group
# Counts the number of individuals in each genotype,phenotype group, NB: count function does something else.
ddply(allData, .(Phenotype,Genotype), summarise, out=length(ENST_474360_2.CNRQ))

# Possible to create several new variables
ddply(allData, .(Phenotype,Genotype), summarise, out=length(ENST_474360_2.CNRQ), to=sum(ENST_474360_2.CNRQ))





######### RESHAPE

library("reshape")

# Has the melt and cast functions
# Useful for breaking a table up when it does not quite have the right structure






######### Heavy data manipulation performed for loading brainspan data

# Load the data
dir="/Users/timothyh/home/proj_srdjan_ank3/expresData_brainspanData_exonCounts/current/"

# Columns are 524 rows and 12 cols: describing all the samples
columns <- read.csv(paste(dir,"Columns.csv",sep=""))

# Rows are 50 rows and 9 columns: describes the exons of ANK3
rows <- read.csv(paste(dir,"Rows.csv",sep=""))

# Expression is (50 rows and 1+524 columns): expression for each exon and sample combination
expression <- read.csv(paste(dir,"Expression.csv",sep=""), header=FALSE)

# Transpose the expression data so that we have samples in the rows
tExpression=t(expression)

# Make the first row that now contains the exonIDs into the variable names (50 columns)
colnames(tExpression)=tExpression[1,]
tExpression=tExpression[-1,] # what does this do? Remove the first data row?
 
# Pasting the 524x12 columns with the 524x50 tExpression
tissueExpression=data.frame(columns, tExpression)

# Melting all the columns with measurements for each exon
# Results in 12 columns describing the sample, followed by exonID and expression measurement
tissueExpressionMelted=melt(tissueExpression,id=1:12)

# Fix the exonIDs by chopping off the "X" that got prepended
# Calling the variable ID so that it automatically works in the join with rows
tissueExpressionMelted$id=substring(tissueExpressionMelted$variable,2)

# Perform the join on the exon id: rows=524x50, columns=12+1value+9 from rows + 1 for the create variable from the melt
# Adds columns containing all the details for each exon
finalData=merge(rows, tissueExpressionMelted)