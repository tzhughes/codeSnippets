library("ggplot2")



allData <- read.table("/Volumes/runScratch/cardioBRCA/allHaloCardioSamples/advancedVcf/allSamples.realigned.recal.targetAndBait.allSites.annot.vcf_asTable" , header = TRUE, sep = "\t")



# Building the dbCount variable which counts the number of dbs the variant is present in

allData$dbCount <- (!is.na(allData$HAPMAP)) +

(!is.na(allData$OMNI)) +

(!is.na(allData$ALL.KGPROD)) +

(!is.na(allData$CLINVAR.CLNHGVS)) +

(!is.na(allData$HGMDPRO.HGMDID))



# Building the truth variable which indicates whether the site is variant in a reliable db.

allData$truth <- (!is.na(allData$HAPMAP)) | (!is.na(allData$OMNI))



# Separating into snps and indels

snps=allData[allData$TYPE == "SNP",]

indels=allData[allData$TYPE == "INDEL",]



# Picking the variants to be analysed

variants=snps



# Quick count of the number of variants

sum(variants$HET) # 24056

sum(variants$HOM.VAR) # 17227

(sum(variants$HET) + sum(variants$HOM.VAR))/98 # 421

nrow(variants) # 2181





#########################

# Region: targetAndBait >> sensitivity and specificity will only be calculated on the target region variants only

# Type of variant SNPs

########################



# QUAL is the basic measure of the probability of a site being variant:

# * It is the **phred scaled probability of the site being non-variant assuming all reads are correctly aligned**

# * It is a **function of the mapping quality of the reads** covering the site and **the quality of the bases** that align to the site.

# * Thus, factors affecting QUAL are:

#   * base qualities

#   * read mapping qualities

#   * sequencing depth

#   * number of samples that are variant AND homoz heteros balance in genotypes

#   * skewness in sequencing of alleles!!!! What can be causing this?





# QUAL against DP

# QUAL correlates well with being a known SNP (proxy for TP):

# * positive correlation between DP and QUAL

# * tendency for known variants to have higher QUAL than unknown variants

# * No known variants with QUAL below 30 - this can be our first filtering cutoff but is clearly not enough.

# BUT, it is not a perfect measure

# * impossible to get high QUAL at low DP!!

# * But no clear separation between known and unknown variants on QUAL

#  * explanation is most likely to be that sequencing errors cause FP variant calls (these are the high DP but low qual variants) which mix with TP present in HET in 1 sample

#  * a solution to this use QD as the measure of quality instead of QUAL (QD=QUAL/unfiltered depth of non-reference samples)



standardTitle="All variant sites (dbCount as proxy for TP snp)"



p <- ggplot(variants, aes(DP, QUAL, colour=dbCount));

p + geom_point(alpha=0.4) + 

scale_colour_gradientn(colours=rainbow(5)) + 

ylim(0,40000) + # only two variants with QUAL above 40000  

scale_y_log10() + # log scale to emphasize what is hapening at low values of QUAL

geom_smooth(aes(DP,QUAL,group=dbCount>0), colour="black", se=FALSE) + # lines to make the trend clear

geom_hline(y=30) +

opts(title = standardTitle)



# Same as QUAL plot but QD instead

# * We clearly obtain better separation between database variants and other variants

# * We see that sites with low DP can obtain high QD

# * However, we still see a considerable number of known variants with QD less than 2.0 (which is the GATK recommended cutoff)

p <- ggplot(variants, aes(DP, QD, colour=dbCount));

p + geom_point(alpha=0.4) + 

scale_colour_gradientn(colours=rainbow(5)) + 

scale_y_log10() + # log scale to emphasize what is hapening at low values of QUAL

geom_hline(y=2) + 

opts(title = standardTitle)







### QD


# Plotting QD against QUAL to make clear the improvment in separation

# * QD is a very strong filter which provides excellent separation between known and unknow

# * BUT a non-negliable number of known variants at QD < 2

p <- ggplot(variants, aes(QUAL, QD, colour=dbCount));

p + geom_point(alpha=0.5) +

geom_hline(y=2) + geom_hline(y=1) +

scale_x_log10() +

scale_colour_gradientn(colours=rainbow(5)) + 

opts(title = standardTitle)



nrow(variants[variants$QD<1 & variants$dbCount>0,]) # gives 24

nrow(variants[variants$QD<2 & variants$dbCount>0,]) # gives 39



# Distribution of QD to answer the big question: **should we use a QD cutoff or NOT?**

# * This is a highly sensitive question bcse this is a very **dense part** of the distribution of variants

# * It would appear that setting a hard cutoff would exclude TP

# * In addition, we may leave in FP where QD > 2.0

# The alternative is to use other filtering variables to perform all filtering:

# * other features do not tend to be very strong filters over the full range of QD values (they mainly detect misalignment)

# * BUT, they can be quite strong when applied to variants with low QD values 

p <- ggplot();

p + geom_freqpoly(data=variants, aes(QD, colour=dbCount>1), binwidth=1) +

ylim(0,300) + geom_vline(x=2)  + 

opts(title = standardTitle)





# FS ###############################



## Plotted FS against QD

# * shows how low QD correlates with high FS ie most high FS has very low QD.

# * Setting a low FS cutoff eliminates few FP while eliminating some TP 

# * no need to set FS so low >> may be 500. But could go to 250 without eliminating too many TP

# * FS > 500

p = ggplot(variants, aes(QD, FS, colour=dbCount))

p + geom_point(alpha=0.5) + scale_colour_gradientn(colours=rainbow(5))



# Testing whether we could use a double condition on QD and FS

# * Could apply a tightening: (QD < 3.0 & FS > 75)

p <- ggplot(variants, aes(QD, FS, colour=dbCount));

p + geom_point(alpha=0.5) +

scale_colour_gradientn(colours=rainbow(5)) + 

xlim(0,5) + ylim(0,200)



# ReadPosRankSum #################



## Plotting ReadPosRankSum against QD

# * We see clearly how low QD variants are a separate class of variant

p <- ggplot(variants, aes(QD, ReadPosRankSum, colour=dbCount));

p + geom_point(alpha=0.5) + 

scale_colour_gradientn(colours=rainbow(5))

# >> no known SNPs with value less than -40 and only 3 with value less than -20

# >> ReadPosRankSum < -12



# Testing whether we could use a double condition on QD and ReadPosRankSum

# >> ReadPosRankSum < -5 & QD < 3

p <- ggplot(variants, aes(QD, ReadPosRankSum, colour=dbCount));

p + geom_point(alpha=0.5) + 

scale_colour_gradientn(colours=rainbow(5)) +

xlim(0,5)



# HaplotypeScore ################



# HaplotypeScore

# * can definitely eliminate anything above 50

# * can probably also eliminate anything above 25 BUT note that have snp with dbcount=5 at HaplotypeScore=20

# * HaplotypeScore > 25

p <- ggplot(variants, aes(QD, HaplotypeScore, colour=dbCount));

p + geom_point(alpha=0.5) + 

scale_colour_gradientn(colours=rainbow(5))



# Testing whether we could use a double condition on QD and HaplotypeScore:

# * HaplotypeScore > 10 & QD < 3

p <- ggplot(variants, aes(QD, HaplotypeScore, colour=dbCount));

p + geom_point(alpha=0.5) + 

scale_colour_gradientn(colours=rainbow(5)) + 

xlim(0,5) + ylim(0,50)



# InbreedingCoeff #################



# InbreedingCoeff

# >> InbreedingCoeff < -0.3

p <- ggplot(variants, aes(QD, InbreedingCoeff, colour=dbCount));

p + geom_point(alpha=0.5) + 

scale_colour_gradientn(colours=rainbow(5))



# Testing whether we could use a double condition on QD and InbreedingCoeff

# *  (QD < 3.0 & InbreedingCoeff < -0.25)

p <- ggplot(variants, aes(QD, InbreedingCoeff, colour=dbCount));

p + geom_point(alpha=0.5) + 

scale_colour_gradientn(colours=rainbow(5)) +

xlim(0,5)



# RMS Mapping Quality #############



# MQ RMS Mapping Quality

# * few MQ values below 100 but about same number of known and unknown variants in this regions

# * probably not wise to filter on this.

p <- ggplot(variants, aes(QD, MQ, colour=dbCount));

p + geom_point(alpha=0.5) + 

scale_colour_gradientn(colours=rainbow(5))



# double condition?

# * MQ < 125 & QD < 3

p <- ggplot(variants, aes(QD, MQ, colour=dbCount));

p + geom_point(alpha=0.5) + 

scale_colour_gradientn(colours=rainbow(5)) + xlim(0,5)



# MQRankSum ######################



# MQRankSum

p <- ggplot(variants, aes(QD, MQRankSum, colour=dbCount));

p + geom_point(alpha=0.5) + 

scale_colour_gradientn(colours=rainbow(5))

# >> poor separator between FP and TP, just like MQ



# Investigating double condition:

# * interesting pattern at low values of QD

# * MQRankSum < -10 & QD < 3

p <- ggplot(variants, aes(QD, MQRankSum, colour=dbCount));

p + geom_point(alpha=0.5) + 

scale_colour_gradientn(colours=rainbow(5)) + 

xlim(0,3)



# MQ0 ################################



# MQ0 Total Mapping Quality Zero Reads

p <- ggplot(variants, aes(QD, MQ0, colour=dbCount));

p + geom_point(alpha=0.5) + 

scale_colour_gradientn(colours=rainbow(5))

# >> no good separation provided

# >> can also see from this plot that there is no point in double condition





# BaseQRankSum #####################



# BaseQRankSum

# * does not provide any good separation on the whole range of QD

# * BUT: VERY VERY interesting patterns in the data

p <- ggplot(variants, aes(QD, BaseQRankSum, colour=dbCount));

p + geom_point(alpha=0.5) + 

scale_colour_gradientn(colours=rainbow(5))



# Double condition which almost certainly must be applied

# *  (BaseQRankSum < -12 & QD < 3)

p <- ggplot(variants, aes(QD, BaseQRankSum, colour=dbCount));

p + geom_point(alpha=0.5) + 

scale_colour_gradientn(colours=rainbow(5)) +

xlim(0,5) + ylim(-40,40)



# All other combinations of features #########################



# Trying all other combinations of features to see if can find other combinations for tightening at low QD

variantsLowQD=variants[variants$QD < 3,]

p <- ggplot();

p + geom_point(data=variantsLowQD, aes(MQRankSum, BaseQRankSum ,colour=dbCount), alpha=0.2) +

scale_colour_gradientn(colours=rainbow(5))

# >> some interesting patterns but all were already acted upon by existing filters





# Applying the filters ###########################


# setting the QD level at which to apply the conditional filters

QDlevel=3 # there seems to be a quantitative difference in the distributions below QD=3


# Basically we want failure of any filter to cause failure of expression

# and when all filters are passed but some cannot be evaluated, we want the record to pass filters



# Variables with NA will evaluate to NA but, since we are ORing failure of filters,

# anything that is TRUE (failed filter) will mean that the whole expression evaluates as TRUE

# There is one case where there can be a problem:

# no individual filter evaluates as TRUE (no failed filter) and some filters are missing NA, thus whole expr is NA

variants$failfilter= variants$FS > 500 | (variants$FS > 75 & variants$QD < QDlevel) |   

variants$ReadPosRankSum < -12 | (variants$ReadPosRankSum < -5 & variants$QD < QDlevel) | 

variants$HaplotypeScore > 25 | (variants$HaplotypeScore > 10 & variants$QD < QDlevel) |

variants$InbreedingCoeff < -0.3 | (variants$InbreedingCoeff < -0.25 & variants$QD < QDlevel) | 

(variants$MQ < 125 & variants$QD < QDlevel) |

(variants$MQRankSum < -10 & variants$QD < QDlevel) |

(variants$BaseQRankSum < -12 & variants$QD < QDlevel) | 

(variants$QUAL < 30)


# There will be some rows that have failfilter==NA bcse they do not fail any filters (most terms FALSE) but have some filters that are NA

# Since there are some filters that are always assessed, it seems reasonable to consider these variants as passing filters.

variants$failfilter = !(variants$failfilter==FALSE | is.na(variants$failfilter)) ### IMPORTANT VARIABLE

variantsPassingFilter=variants[variants$failfilter==FALSE | is.na(variants$failfilter),]

nrow(variantsPassingFilter) # 1786



## Evaluation of the results of our filtering:

# * we have successfully eliminated many FPs without applying a QD cutoff in a very dense part of the distribution
# * we have **eliminated some known variants at low QD but these had clear features of FP calls**
# * we still have a small peak at QD=1: are these TP with special features OR FP that are also in known databases?
# * we have tried to retain sensitivity, so there are probably many FPs left in the data

knowCutoff=1

knownVariants=variants[variants$dbCount > knowCutoff,]

unknownVariants=variants[variants$dbCount <= knowCutoff,]

knownVariantsPassingFilter=variantsPassingFilter[variantsPassingFilter$dbCount > knowCutoff,]

unknownVariantsPassingFilter=variantsPassingFilter[variantsPassingFilter$dbCount <= knowCutoff,]

p <- ggplot();

p + geom_freqpoly(data=knownVariants, aes(QD), colour="lightblue", binwidth=1) +

geom_freqpoly(data=knownVariantsPassingFilter, aes(QD), colour="darkblue", binwidth=1) +

geom_freqpoly(data=unknownVariants, aes(QD), colour="pink", binwidth=1) +

geom_freqpoly(data=unknownVariantsPassingFilter, aes(QD), colour="red", binwidth=1) +

ylim(0,300) +

opts(title = "Unknown (red) - Known (blue) AND Pre-filt (light) - Post-filt (dark)")


# Did we eliminate anything that is likely to be functionally important?
# * known to be in HGMDPro?
# * with a strong deleterious effect
variants[variants$failFilter==TRUE & !is.na(variants$HGMDPRO.HGMDID)]
variants[variants$failFilter==TRUE & variants$SNPEFF_IMPACT == "HIGH"]



# What are the features of the variants with low QD which pass filters? ##############



# Remember these are variants that pass ALL FILTERS



# Extract these variants into their own dataframe

variantsLowQDandPassFilter=variants[variants$QD < QDlevel & variants$failfilter==FALSE,]



# How many are we extremely confident in?

variantsLowQDandPassFilter[variantsLowQDandPassFilter$dbCount > 2,] # 7 of which 4 with QD less than 1 



# Battery of plot to characterise these variants

p <- ggplot();

p + geom_point(data=variantsLowQDandPassFilter, aes(QUAL, DP,colour=dbCount) ) +

scale_colour_gradientn(colours=rainbow(5)) 



p <- ggplot();

p + geom_point(data=variantsLowQDandPassFilter, aes(QD, InbreedingCoeff,colour=dbCount) )



p <- ggplot();

p + geom_point(data=variantsLowQDandPassFilter, aes(QUAL, HET,colour=dbCount) ) +

scale_colour_gradientn(colours=rainbow(5))



p <- ggplot();

p + geom_point(data=variantsLowQDandPassFilter, aes(DP, QD,colour=dbCount) ) +

scale_colour_gradientn(colours=rainbow(5)) 



# Could a better handling of extreme GC regions resolve filtration of variants with low QD that pass filters

p <- ggplot(variantsLowQDandPassFilter, aes(GC, DP, colour=dbCount));

p + geom_jitter(alpha=0.5) + 

scale_colour_gradientn(colours=rainbow(5)) + geom_vline(x=30) + geom_vline(x=70) + xlim(10,90)

# CONCLUSION: unlikely.



# location?

p <- ggplot(variantsLowQDandPassFilter, aes(CHROM, POS, colour=dbCount));

p + geom_jitter(alpha=0.5) + 

scale_colour_gradientn(colours=rainbow(5))

# Nothing particular found




# Summary of features of these variants

# * for each variant just a few individuals that are HET (usually just one for unknown, or a few for known)

# * all other individuals HOM.REF 

# * QUALs are low

# * coverage is decent (unknown) or even good (known)

# * QD ends up low



# Inspection of rare heterozygotes that pass filters######################



# * many rare HETS obtain high QD >> so it is not just that they are in few samples

# * so what is special about the hets that have low QD but pass all filters? 

p <- ggplot();

p + geom_point(data=variantsPassingFilter, aes(QD, HET,colour=dbCount)) +

scale_colour_gradientn(colours=rainbow(5))



p <- ggplot();

p + geom_point(data=variantsPassingFilter, aes(QD, HET, colour=ABHet)) +

scale_colour_gradientn(colours=rainbow(5))





# Investigating the allele balance

variantsPassingFilter[variantsPassingFilter$QD<2 & variantsPassingFilter$dbCount > 0, "ID"]

# We notice a consistency in skewness across sites

61,23

79,18

83,17

68,26

68,26

83,17

28,8

54,39

82,18

72,27

# grep -e "#CHROM" -e "rs78961574" allSamples.realigned.recal.targetAndBait.allSites.annot.vcf | tabTranspose.bash | grep -v "0/0"



# checking on consistency across samples at same site

variantsPassingFilter[variantsPassingFilter$QD<3 & variantsPassingFilter$dbCount > 0 & variantsPassingFilter$HET > 3, "ID"]

67,19

74,25

63,28

78,20

75,20

# confirms consistency across samples

# >> unlikely to be caused by random sampling

# CONCLUSION: 

# * seems like we are vindicated in our filtering strategy of not just cutting at QD < 1 or 2

# * especially given that many of these variants are in many dbs + consistency across samples

# * visual inspectio of several of these rare HETs does show any signs of FP



# Compute the ti/tv ratios as a final check

variants[variants$failfilter==FALSE & variants$QD < QDlevel & variants$dbCount == 0,c("REF","ALT")]



% cat lowQDandUnknown.txt  | tr -s " " | tr " " "\t" | cut -f 2-3 | sort | uniq -c  

Tv: 30

Ti: 25



cat lowQDandKnown.txt  | tr -s " " | tr " " "\t" | cut -f 2-3 | sort | uniq -c  

Tv: 12

Ti: 30



cat highQDandUnknown.txt  | tr -s " " | tr " " "\t" | cut -f 2-3 | sort | uniq -c  

Tv: 128

Ti: 198



% cat highQDandKnown.txt  | tr -s " " | tr " " "\t" | cut -f 2-3 | sort | uniq -c  

Tv: 342

Ti: 1006



# Seems like the known are TP

# Seems like the unknown at low QD are mainly FP

# Seems like the unknown at high QD contain FP



# Let us take a precise look at HGMDPRO which is probably the most curated db

# This suggests a QD cutoff at 1.5

p <- ggplot();

p + geom_freqpoly(data=variantsLowQDandPassFilter, aes(QD,colour=!is.na(HGMDPRO.HGMDID)), binwidth=0.2)

 

# Does this make a positive difference to our TiTv

# Compute the ti/tv ratios as a final check: still find about same number of ti and tv when using QD cutoff

variants[variants$failfilter==FALSE & variants$QD > 1.5 & variants$QD < QDlevel & variants$dbCount == 0,c("REF","ALT")]











# GC affect on coverage #############################################



# Clearly demonstrates lack of coverage at high GC

p <- ggplot(allData, aes(GC, NCALLED));

p + geom_bin2d(binwidth=c(1,1)) + scale_fill_gradient2(trans="log10") + geom_vline(x=20) + geom_vline(x=80)



# Inspection of coverage of known variants ONLY

# Distribution of number of samples called at all known sites

p <- ggplot(allData[allData$dbCount>0,], aes(NCALLED));

p + geom_histogram(binwidth=5)



# How much of the lack of coverage of known variants is driven by GC content?

# * not really that significant

# * but does not mean that does not matter for unknown variants. Could be that dbs have undersampled GC rich regions.

p <- ggplot(allData[allData$dbCount>0,], aes(GC, NCALLED))

p + geom_jitter() + 

opts(title="For known variant sites: Does GC content drive lack of coverage?", plot.title=theme_text(size=10,vjust=1)) +

geom_vline(x=50) + geom_hline(y=40)







# Exploration of QD definition #######################################



# QD against DP >> demonstrates how QD is a much better separator

# >> makes clear that the limit lies at about one

# >> known variants at low DP have much higher QD on average than unknow variants

# >> however, still have quite a few known variants at high DP and low QD

# >> these could be errors in the dbs or variants that are found in very few samples 

# (and if these samples have low coverage,the variant will have poor QD despite good coverage across all samples)

p <- ggplot(variants, aes(DP, QD, colour=dbCount, alpha=1/VAR));

p + geom_point() +

scale_alpha(breaks=c(0.02,0.1,1)) +

scale_colour_gradientn(colours=rainbow(5)) + 

scale_y_log10()

# Almost correct: QUAL / ( (DP/NCALLED)*VAR )

# Another def: QUAL / ( DP/(NCALLED*2)*(HOM.VAR*2+HET) )

# Small remaining differences are probably due to filtering

p <- ggplot(variants, aes( QD, QUAL / ( DP/(NCALLED*2)*(HOM.VAR*2+HET) ) , colour=dbCount,  alpha=1/VAR))

p + geom_point() +

scale_colour_gradientn(colours=rainbow(5)) +

scale_alpha(breaks=c(0.02,0.1,1)) +

xlim(0,3) + ylim(0,3) + 

geom_text(data=variants[variants$dbCount>1,], aes(label=ID, size=0.25, hjust=1), colour="black", angle=0) +

geom_vline(x=1) + geom_hline(y=1) + geom_abline(intercept=0, slope=1) #+

#scale_x_log10() +

#scale_y_log10() 





##########################################################################
##########################################################################



# Specificity: keeping FP down ######################

# Of all the variants (seen at decent freq in our samples), how many have not been seen before

# Pre-filtering
nrow(variants)
freqCutoff=0.02
freqCutoff=0.05
freqCutoff=0.10
nrow(variants[((variants$HET + variants$HOM.VAR)/variants$NCALLED > freqCutoff),])
nrow(variants[((variants$HET + variants$HOM.VAR)/variants$NCALLED > freqCutoff) & variants$dbCount == 0,])

# Post filtering
# * we expect the number of variants at a certain frequency to have fallen (most of the drop due to FP not seen before)
# * so, the number of variants at certain freq seen before should not have fallen much.
# * thus, specificity should have increased

nrow(variantsPassingFilter) # 1786
freqCutoff=0.02 # 19/667=0.028
freqCutoff=0.05 # 32/848=0.037
freqCutoff=0.10 # 72/1158=0.062
nrow(variantsPassingFilter[((variantsPassingFilter$HET + variantsPassingFilter$HOM.VAR)/variantsPassingFilter$NCALLED > freqCutoff),])
nrow(variantsPassingFilter[((variantsPassingFilter$HET + variantsPassingFilter$HOM.VAR)/variantsPassingFilter$NCALLED > freqCutoff) & variantsPassingFilter$dbCount == 0,])


# Recall that these results are for bait and that a lot of annotation is focused on coding regions >> results could be even better





# Plot of the same data which reveals some possible FPs at high freq

p <- ggplot(variantsPassingFilter, aes((HET + HOM.VAR)/NCALLED, fill=dbCount>0))

p + geom_bar(binwidth=0.05) 





# Investigating potential FPs at high freq

nrow(variantsPassingFilter)
variantsPassingFilter[(variantsPassingFilter$HET + variantsPassingFilter$HOM.VAR)/variantsPassingFilter$NCALLED>0.2 & variantsPassingFilter$dbCount==0,]

#       CHROM       POS         ID REF ALT      QUAL FILTER HET HOM.REF HOM.VAR
#32109      1 237580061  rs5023789   C   G  49087.62   PASS  53      10      32
#32112      1 237580063  rs4382712   C   G  64381.07   PASS  36       5      54
#52555      1 237791674   rs477075   C   T  13853.98   PASS  20       7      64
#321610     6   7579394 rs59581305   A   G 229651.87   PASS  40       8      50
#388863    12  22014161  rs2418018   C   A  63356.22   PASS  41       5      51
#388866    12  22014163  rs2418019   C   T  66808.34   PASS  53       5      39
#388869    12  22014165  rs2418020   C A,T  75792.84   PASS  61       0      36

#       NO.CALL NSAMPLES NCALLED TYPE VAR    QD HaplotypeScore MQRankSum
#32109        3       98      95  SNP  85 24.43        19.3855    -5.951
#32112        3       98      95  SNP  90 29.24        13.7002   -13.634
#52555        7       98      91  SNP  84 15.76         0.3017    -6.821
#321610       0       98      98  SNP  90 25.58         3.0444   -55.540
#388863       1       98      97  SNP  92 13.62        18.5022    11.967
#388866       1       98      97  SNP  92 14.36        18.1258    11.649
#388869       1       98      97  SNP  97 15.27        17.2924     6.253

#       ReadPosRankSum BaseQRankSum InbreedingCoeff MQ0      FS     MQ    GC
#32109          -1.935       28.302         -0.2095  34   0.000 184.96 45.54
#32112          -2.015       28.668         -0.0530  34   0.000 184.96 45.54
#52555           3.541       -9.525          0.1164   9   0.000  20.44 53.47
#321610         14.732       37.800          0.0000 258 321.931 184.69 38.61
#388863          4.783        8.778         -0.0926  20   6.027 151.04 39.60
#388866          4.663        3.623         -0.2609  20  12.071 151.03 39.60
#388869          5.475        1.511          0.6621  20   0.000 150.85 38.61


# Conclusions:
# * all of these appear to be FP that have just failed to be filtered out: lie very close to limits set in filtering
# * Notice that they are all in dbSNP
# * we can do this kind of squashing of variants using the annotation

# ATTEMPT to use the GMAF to get a more refined measure of DB membership, but not giving good results
# probably bcse GMAF is a minor allele and not variant + this is global and not pop specific.

variantsPFWithPopFreq=variantsPassingFilter[!is.na(variantsPassingFilter$ALL.GMAF),]
nrow(variantsPFWithPopFreq)
summary(variantsPFWithPopFreq)
nrow(variantsPFWithPopFreq[(variantsPFWithPopFreq$HET + variantsPFWithPopFreq$HOM.VAR > 20) & variantsPFWithPopFreq$ALL.GMAF < 0.05,])



# SENSITIVITY

# for all sites in capture that are known to be variant, how many do we find to be variant?

# There are lots of known variants which are not found in our dataset
# * This is probably because they are variants that are at low frequency in the population
# * Thus, we need a condition on frequency that imposes high frequency in a matching population
nrow(allData) # 500280
nrow( allData[allData$dbCount > 0,] ) # 8499
nrow( allData[allData$dbCount > 0 & allData$VAR > 0,] ) # 1547

# What is the best set of variants to use in sensitivity analysis?
# * it needs to be sites that are sure to be variant at high frequency in the population from which the samples were drawn
#   * condition on high frequency of variation for the known sites
#   * condition on being in several dbs (proxy for trying to get a match on population)

# Using only GMAF without a population match gives poor results
nrow( allData[!is.na(allData$ALL.GMAF),] ) # 6341
freq=0.02 #  1208 942
freq=0.05 # 850 735
freq=0.10 # 627 562
nrow( allData[!is.na(allData$ALL.GMAF) & allData$ALL.GMAF > freq,] )
nrow( allData[!is.na(allData$ALL.GMAF) & allData$ALL.GMAF > freq & allData$VAR > 0,] )

freq=0.02 # 252 278 = 91 %
freq=0.05 # 220 227 = 97 %
freq=0.10 # 171 173 = 99 %
nrow( allData[!is.na(allData$ALL.GMAF) & allData$ALL.GMAF > freq & allData$dbCount > 2,] )
nrow( allData[!is.na(allData$ALL.GMAF) & allData$ALL.GMAF > freq & allData$dbCount > 2 & allData$VAR > 0,] )

NEW 
#Pre-filtering - should be almost the same numbers as above
freq=0.02 # 
freq=0.05 # 
freq=0.10 # 
nrow( variants[!is.na(allData$ALL.GMAF) & allData$ALL.GMAF > freq & allData$dbCount > 2,] ) # all sites that should be variant in our dataset
nrow( variants[!is.na(variants$ALL.GMAF) & variants$ALL.GMAF > freq & variants$dbCount > 2 & variants$VAR > 0,] ) # sites that actually are variant

# Post-filtering
freq=0.02 # 
freq=0.05 # 
freq=0.10 # 
nrow( variants[!is.na(allData$ALL.GMAF) & allData$ALL.GMAF > freq & allData$dbCount > 2,] ) # the sites should be irrespective of whether we find them variant (before or after filter)
nrow( variants[!is.na(variants$ALL.GMAF) & variants$ALL.GMAF > freq & variants$dbCount > 2 & variants$VAR > 0 & variants$failFilter == FALSE,] ) # sites that are variant and pass filters


# How many of known variant sites are variant in our dataset?
# * difficult to see due to very large number of variants with low pop freq
# * so restricting to higher values of GMAF
allDataWithGMAF5= allData[!is.na(allData$ALL.GMAF) & allData$ALL.GMAF > 0.05,]
p <- ggplot(allDataWithGMAF5, aes(ALL.GMAF, fill=VAR > 0))
p + geom_bar(binwidth=0.05)


# If we in addition include a dbCount condition in the sensitivity calculation
# * not missing anything at higher GMAF
# * those missing a lower GMAF may just be not in our dataset or could be among what we eliminated in the filtering
p <- ggplot(allDataWithGMAF5[allDataWithGMAF5$dbCount > 2,], aes(ALL.GMAF, fill=VAR > 0))
p + geom_bar(binwidth=0.05)







# Rescuing variants #############################

# In other words improving sensitivity
# Sensitivity is our primary concern.
# Specificity is less important: in a context where all finds will be validated by Sanger, specificity's role is only to keep the work load down.


# By definition, variants to be rescued will have failed a filter.
# We will generally want to rescue boldly ie rescue anything that has been seen in a db.
# If we wish to rescue slightly less boldly, we can:
# * only rescue if the filter was failed by a small margin
# * not rescue variants that are at high frequency in our data as these are likely FP (even dbs of known variants contain FP)



# High estimate of what could be rescued

nrow(variants[variants$failfilter == TRUE & variants$dbCount>0,]) # gives 47, but most of these are clear FPs with big failure of filters

# basically we are rescuing FPs registered in dbs >> if we only allowed rescued the borderline cases we would rescue very few

# Slightly more cautious rescue to avoid loads of rubbish being pulled back in (after having been filtered out)

nrow(variants[variants$failfilter == TRUE & variants$dbCount>0 & variants$VAR/variants$NCALLED < 0.2,]) # 29

# note that this is across samples, so in practice would only be rescuing maybe one variant per sample.



# Sinking variants ##############################

# In other words improving specificity

# In a world where Sanger validation takes place, we would only need to tighten specificity if we had too much validation to do

# Generally we want to be cautious about sinking and would normally require all of the following conditions to be fullfilled to sink a variant:
# * only just passed all filters
# * is at high frequency in the samples: low frequencies could be a new find, whereas high freq is likely FP
# * is not in a db (although there are several definite FP SNPs that are in a db)

# High estimate of what could be sunk (only satisfying high freq, but would probably also satisfy only just passed filters)
variantsPassingFilter[(variantsPassingFilter$HET + variantsPassingFilter$HOM.VAR)/variantsPassingFilter$NCALLED>0.2 &
variantsPassingFilter$dbCount==0,] # gives 13 that would be sunk, all are border line on at least 1 filter and 10 are in dbSNP





# Detection of known pathogenic variants ##################



# Distribution of disease causing mutations across samples
nrow(variantsPassingFilter[!is.na(variantsPassingFilter$HGMDPRO.HGMDVC),]) #64 which are mostly DM or DM?



# almost all variants are heterozygous (so not bothering with the homozygotes)
p = ggplot(variantsPassingFilter[!is.na(variantsPassingFilter$HGMDPRO.HGMDVC),], aes(HET, fill=HGMDPRO.HGMDVC))
p + geom_histogram()



# HIGH IMPACT VARIANTS

nrow(variantsPassingFilter[variantsPassingFilter$SNPEFF_IMPACT=="HIGH",]) # gives us 18

nrow(variantsPassingFilter[!is.na(variantsPassingFilter$HGMDPRO.HGMDVC) & variantsPassingFilter$SNPEFF_IMPACT=="HIGH",]) # gives us 7



# not all samples were sequenced in all 16, 6 genes for some samples and 7 for some other samples
sangerSequencedGenes = c("MYL2", "MYL3", "MYBPC3", "LMNA", "MYH7", "TNNI3", "TNNT2",  "DSG2", "PKP2", "RYR2", "DSP")
# Checking that all names match
summary(variantsPassingFilter[,c("SNPEFF_GENE_NAME")])



# What are the ones that were probably detected before

nrow(variantsPassingFilter[(variantsPassingFilter$SNPEFF_IMPACT=="HIGH" | !is.na(variantsPassingFilter$HGMDPRO.HGMDVC)) & 

(variantsPassingFilter$SNPEFF_GENE_NAME %in% sangerSequencedGenes),]) # 59 



# What are the ones that are likely to be novel

nrow(variantsPassingFilter[(variantsPassingFilter$SNPEFF_IMPACT=="HIGH" | !is.na(variantsPassingFilter$HGMDPRO.HGMDVC)) & 

!(variantsPassingFilter$SNPEFF_GENE_NAME %in% sangerSequencedGenes),]) # 16 new 



# What are these variants

variantsPassingFilter[(variantsPassingFilter$SNPEFF_IMPACT=="HIGH" | !is.na(variantsPassingFilter$HGMDPRO.HGMDVC)) & 

!(variantsPassingFilter$SNPEFF_GENE_NAME %in% sangerSequencedGenes),]

# Many of the variants that were previously undetected are in HGMDPro and many of thesre are just NON_SYNONYMOUS_CODING

# There are 4 variants which are not in HGMD and which have HIGH IMPACT

# It is likely that we will find many more with MODERATE_IMPACT



HGMDPRO.HGMDVC         SNPEFF_EFFECT SNPEFF_IMPACT

160161           <NA>  SPLICE_SITE_ACCEPTOR          HIGH

221485             DM NON_SYNONYMOUS_CODING      MODERATE

288722             DP NON_SYNONYMOUS_CODING      MODERATE

296147            DM? NON_SYNONYMOUS_CODING      MODERATE

296700           <NA>  SPLICE_SITE_ACCEPTOR          HIGH

297394             DM NON_SYNONYMOUS_CODING      MODERATE

298003             DM NON_SYNONYMOUS_CODING      MODERATE

327826             DM              UPSTREAM      MODIFIER

351061             DM NON_SYNONYMOUS_CODING      MODERATE

363218             DM NON_SYNONYMOUS_CODING      MODERATE

389893             DP NON_SYNONYMOUS_CODING      MODERATE

391445             DP                INTRON      MODIFIER

409346           <NA>     SPLICE_SITE_DONOR          HIGH

435975            DM? NON_SYNONYMOUS_CODING      MODERATE

477563           <NA>           STOP_GAINED          HIGH

479155             DM NON_SYNONYMOUS_CODING      MODERATE



SNPEFF_GENE_NAME SNPEFF_GENE_BIOTYPE SNPEFF_TRANSCRIPT_ID

160161              TTN      protein_coding      ENST00000342175

221485              TTN      protein_coding      ENST00000342992

288722              DES      protein_coding      ENST00000373960

296147           TMEM43      protein_coding      ENST00000306077

296700           TMEM43      protein_coding      ENST00000306077

297394           TMEM43      protein_coding      ENST00000306077

298003           TMEM43      protein_coding      ENST00000306077

327826          SNRNP48      protein_coding      ENST00000342415

351061             LDB3      protein_coding      ENST00000263066

363218            CSRP3      protein_coding      ENST00000265968

389893            ABCC9      protein_coding      ENST00000544039

391445            ABCC9      protein_coding      ENST00000261200

409346             TMPO      protein_coding      ENST00000548911

435975             MYH6      protein_coding      ENST00000356287

477563             DSC2      protein_coding      ENST00000438199

479155             DSC2      protein_coding      ENST00000438199