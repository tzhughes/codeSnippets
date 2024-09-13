library(ggplot2)
library(dplyr)

# plot the mtcars dataset with ggplot
ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point(size = 20)
if (!file.exists("mtcars.png")) {
    ggsave("mtcars.png")
}


if (!file.exists("mtcars.png")) {
    stop("mtcars.png not found")
}

one <- 1
two <- 2

one == two
if (one == two) {
    print("one equals two")
} else {
    print("one does not equal two")
}

# create a function
text <- "dfdssf"
something <- function(text) {
    print(text)
}
something(text)

more <- 1
