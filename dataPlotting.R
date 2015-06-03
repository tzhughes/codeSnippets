## Notes of plotting with ggplot2


########### GGPLOT2

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

# Creats a 1d wrap using one variable (it may wrap around onto several lines)
+ facet_wrap(~Phenotype)



###################################################
## Specifics of certain types of plot
###################################################

## Removing whiskers from a boxplot ##

f <- function(x) {
    r <- quantile(x, probs = c(0.25, 0.25, 0.5, 0.75, 0.75))
    names(r) <- c("ymin", "lower", "middle", "upper", "ymax")
    r
}

p + stat_summary(aes(fill = factor(start.position),width=0.5), fun.data=f, geom="boxplot", position="dodge", alpha=1/3, outlier.size=1,outlier.shape = NA)


## Adding a smoother ##

stat_smooth(aes(group=start.position, colour=factor(start.position)), size=1, alpha=1/3, se=FALSE, method="loess", formula=y~x^3+x^2+x)
