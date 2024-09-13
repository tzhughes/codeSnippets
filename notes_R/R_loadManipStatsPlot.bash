## Notes of plotting with ggplot2


############ INSPECTING an object ##################

attributes(object)

#Compactly display the internal *str*ucture of an R object, a diagnostic function and an alternative to ‘summary’
str(object)

# Attempt to coerce the argument to a name
as.name()
# And then call eval on this to get the object with that name
eval(as.name("someObjectName"))



########### LOADING AND MANIPULATING DATA ###################################################################
library("reshape")
library("plyr")
library("ggplot2")
quartz()

## Loading and very basic manipulatin
allData <- read.table("/Users/timothyh/home/proj_vrk2/data/mRNAvsDiag/VRK2_mRNA_to_Tim.tab" , header = TRUE, sep = "\t")

# Basic manipulation of a dataframe
subset(allData, myVar>1) # subsetting has the DROP option
with(allData,) # Useful for computing a new variable when if is a complex function of existing variables
names(allData)[names(allData)=="value"] <- "id" # renaming variable

## Factors
commonTissue=droplevels(commonTissue) # Removes unused levels in factors


## RESHAPE
# Nice doc at http://seananderson.ca/2013/10/19/reshape.html
library("reshape")
# Has the melt and cast functions: melt goes from wide format to long, cast goes from long format to wide
# Useful for breaking a table up when it does not quite have the right structure
tissueExpressionMelted=melt(tissueExpression,id=1:12)

## PLYR
library("plyr")

# Has a nice function for renaming columns
rename(d, c("beta"="two", "gamma"="three"))

# Key functions are:
# * summarise: does not create a new dataframe
# * transform: creates a new dataframe
# * subset: enables subsets to be computed when the subsetting depends on subgroups.

# subset function
to select the top (or bottom) n (or x%) of observations in a group, or observations above some group-specific threshold
ddply(diamonds, .(color), subset, order(carat) <= 2)
ddply(diamonds, .(color), subset, price > mean(price))

## transform and summarise functions

# Use length to compute the number of records in a group
# Counts the number of individuals in each genotype,phenotype group, NB: count function does something else.
ddply(allData, .(Phenotype,Genotype), summarise, out=length(ENST_474360_2.CNRQ))

# Possible to create several new variables
ddply(allData, .(Phenotype,Genotype), summarise, out=length(ENST_474360_2.CNRQ), to=sum(ENST_474360_2.CNRQ))

######### SEE END OF FILE FOR Heavy data manipulation performed for loading brainspan data



######### BASIC STATS #####################################################################################

sum(variants$HET) # 24056 sum a variable

nrow(variants) # 2181 counts the rows

summary(df) # computes basic stats on a dataframe



########### GGPLOT2 #######################################################################################
library("ggplot2")
quartz()

# typical call
ggplot() + geom_density(data=allData, aes(x=ENST_474360_2.CNRQ,colour=Phenotype, fill=Phenotype),binwidth = 0.05, alpha=1/4, position="identity")

# Note that "colour" defines the line colour around a shape but not the colour that it is filled with


## Axes ##
xlim(0,2.5)
xlab("Relative expression") + ylab("Number of individuals")

scale_x_log10()
scale_y_log10() 

scale_x_continuous(breaks = seq(-10, 10, 2))

## Title ##
+ opts(title = "My super title")



## Legend ##

opts(legend.position = "none")


## SAVING ##
ggsave(file="brainspan_rpkm_timeSeries_crossBrainStructure.pdf")



## Facets ##

# Creates a 2d grid using two variables
+ facet_grid(Phenotype~Genotype)

# Creates a 1d wrap using one variable (it may wrap around onto several lines)
+ facet_wrap(~Phenotype)



###################################################
## Specifics of certain types of plot
###################################################


# 2d density
# use the density2d stat and geom="polygon" to get a clean coloured filled contour map (clean in the sense of the edge of the density being well defined)


# Position in bar charts
dodge AND stack AND identity
position='identity'

## Removing whiskers from a boxplot ##
f <- function(x) {
    r <- quantile(x, probs = c(0.25, 0.25, 0.5, 0.75, 0.75))
    names(r) <- c("ymin", "lower", "middle", "upper", "ymax")
    r
}
p + stat_summary(aes(fill = factor(start.position),width=0.5), fun.data=f, geom="boxplot", position="dodge", alpha=1/3, outlier.size=1,outlier.shape = NA)


## Adding a smoother ##
stat_smooth(aes(group=start.position, colour=factor(start.position)), size=1, alpha=1/3, se=FALSE, method="loess", formula=y~x^3+x^2+x)

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

