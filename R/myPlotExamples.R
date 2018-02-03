# Libraries ----

library(tidyverse)
library(nycflights13)
library(ggstance)
library(ggbeeswarm)
library(lvplot)
library(hexbin)

# Data

smaller <- diamonds %>% 
  filter(carat < 3)

# The layered grammar of graphics ----

# ggplot(data = <DATA>) + 
#   <GEOM_FUNCTION>(
#     mapping = aes(<MAPPINGS>),
#     stat = <STAT>, 
#     position = <POSITION>
#   ) +
#   <COORDINATE_FUNCTION> +
#   <FACET_FUNCTION>

# Data ----
data("mpg")
data("diamonds")


# Structure of mpg ----

str(mpg)
# Classes ‘tbl_df’, ‘tbl’ and 'data.frame':	234 obs. of  11 variables:
#   $ manufacturer: chr  "audi" "audi" "audi" "audi" ...
# $ model       : chr  "a4" "a4" "a4" "a4" ...
# $ displ       : num  1.8 1.8 2 2 2.8 2.8 3.1 1.8 1.8 2 ...
# $ year        : int  1999 1999 2008 2008 1999 1999 2008 1999 1999 2008 ...
# $ cyl         : int  4 4 4 4 6 6 6 4 4 4 ...
# $ trans       : chr  "auto(l5)" "manual(m5)" "manual(m6)" "auto(av)" ...
# $ drv         : chr  "f" "f" "f" "f" ...
# $ cty         : int  18 21 20 21 16 18 18 18 16 20 ...
# $ hwy         : int  29 29 31 30 26 26 27 26 25 28 ...
# $ fl          : chr  "p" "p" "p" "p" ...
# $ class       : chr  "compact" "compact" "compact" "compact" ...

# Structure of diamonds ----

str(diamonds)
# Classes ‘tbl_df’, ‘tbl’ and 'data.frame':	53940 obs. of  10 variables:
#   $ carat  : num  0.23 0.21 0.23 0.29 0.31 0.24 0.24 0.26 0.22 0.23 ...
# $ cut    : Ord.factor w/ 5 levels "Fair"<"Good"<..: 5 4 2 4 2 3 3 3 1 3 ...
# $ color  : Ord.factor w/ 7 levels "D"<"E"<"F"<"G"<..: 2 2 2 6 7 7 6 5 2 5 ...
# $ clarity: Ord.factor w/ 8 levels "I1"<"SI2"<"SI1"<..: 2 3 5 4 2 6 7 3 4 5 ...
# $ depth  : num  61.5 59.8 56.9 62.4 63.3 62.8 62.3 61.9 65.1 59.4 ...
# $ table  : num  55 61 65 58 58 57 57 55 61 61 ...
# $ price  : int  326 326 327 334 335 336 336 337 337 338 ...
# $ x      : num  3.95 3.89 4.05 4.2 4.34 3.94 3.95 4.07 3.87 4 ...
# $ y      : num  3.98 3.84 4.07 4.23 4.35 3.96 3.98 4.11 3.78 4.05 ...
# $ z      : num  2.43 2.31 2.31 2.63 2.75 2.48 2.47 2.53 2.49 2.39 ...

# For brevity, assign data and ggplot to objects

pmpg <- ggplot(data = mpg)

pdmd <- ggplot(data = diamonds)

# *** Basis: One variable, Discrete X **** ====

# ---- geom_bar() ----

# Description: Height of the bar proportional to the number of cases in each group 
  # (or if the weight aethetic is supplied, the sum of the weights). 

# Stat: geom_bar uses stat_count by default: it counts 
  # the number of cases at each x position.

pmpg + geom_bar(mapping = aes(manufacturer))

pmpg + geom_col(mapping = aes(manufacturer))


# flip to read long variable names

pmpg + geom_bar(mapping = aes(manufacturer)) +
   coord_flip()

# Multiple discrete variables ----

# Color and  fill ----

pmpg + geom_bar(mapping = aes(manufacturer, color = class), show.legend = TRUE) +
  coord_flip()

pmpg + geom_bar(mapping = aes(manufacturer, fill = class), show.legend = TRUE) +
  coord_flip()
 
# Facet_wrap ----

pmpg + geom_bar(mapping = aes(manufacturer)) +
  facet_wrap(~ drv) +
  coord_flip()

pdmd + geom_bar(mapping = aes(cut)) +
  facet_wrap(~ color) +
  coord_flip()

# Position ----

# Stacking within one factor level. Usually not as good as Dodging. 

pdmd + geom_bar(aes(cut == 'ideal', fill = color))

# Dodge 

pdmd + geom_bar(aes(cut == 'ideal', fill = color), position = "dodge")

# Sometimes: filter the data first, then plot ----
# rather than trying to do everything in ggplot

ideal <- diamonds %>% 
  filter(cut == "Ideal")

# and then plot against a second discrete variable

ggplot(ideal, aes(color, fill = color)) +
  geom_bar(show.legend = FALSE) +
  labs(x = "Color dist of Ideal cut")

# Position - STACK vs. DODGE vs. FILL ----

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = color), position = "stack")  +
  labs(title = "STACKED")

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = color), position = "dodge")  +
  labs(title = "DODGED")

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = color), position = "fill")  +
  facet_wrap(~ clarity) +
  labs(title = "FILLED")

# this is a good one
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = color), position = "fill")  +
  facet_wrap(~ clarity) +
  coord_flip() +
  labs(title = "FILLED")

# Note: geom_histogrom() with stat = "count" is the same as geom_bar() ----
ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = cut, fill = color), stat = "count", position = "fill")  +
  labs(title = "FILLED")

# ---- geom_col() ----
  
# A second type of bar charts.
  # If you want the heights of the bars to represent values in the data, 
  # use geom_col instead.  

# Stat: geom_col uses stat_identity: it leaves the data as is.
  # Requires assignment of a y-axis
  
# *** Basis: One variable, Continuous X **** ====
  
# ---- geom_histogram() -----

# Visualise the distribution of a single continuous variable by dividing the 
# x axis into bins and counting the number of observations in each bin. 
# 
# Histograms (geom_histogram) display the count with bars; frequency polygons 
# (geom_freqpoly), display the counts with lines. Frequency polygons are more 
# suitable when you want to compare the distribution across a the levels of a 
# categorical variable.

# stat_bin is suitable only for continuous x data. 
# If your x data is discrete, you probably want to use stat_count (which is 
# effectively the same as geom_bar)

pdmd + geom_histogram(mapping = aes(x = carat), binwidth = 0.5)

# facet wrap with categorical variable
ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = price), binwidth = 100) +
  facet_wrap(~ clarity)

# --- geom_freqpoly() ----

# Frequency polygons display the counts with lines. Frequency polygons are more suitable 
# when you want to compare the distribution across a the levels of a categorical variable.

ggplot(data = diamonds) +
  geom_freqpoly(mapping = aes(x = price), binwidth = 100)

# colored with a categorical variable
# 
ggplot(data = diamonds, mapping = aes(x = price)) +
  geom_freqpoly(mapping = aes(color = cut), binwidth = 500)

# colored with a categorical variable
# and y = ..density.. for a better comparison when 
# the overall counts differ so much

ggplot(data = diamonds, mapping = aes(x = price, y = ..density..)) + 
  geom_freqpoly(mapping = aes(colour = cut), binwidth = 500)

  
# *** Basis: Two variables, Continuous X, Continuous Y *** ====
  
# ---- geom_point() -----

# Description: The point geom is used to create scatterplots. 
  # The scatterplot is most useful for displaying the relationship between 
  # two continuous variables. It can be used to compare one continuous and 
  # one categorical variable, or two categorical variables, but a variation 
  # like geom_jitter, geom_count, or geom_bin2d is usually more appropriate.

  # The bubblechart is a scatterplot with a third variable mapped to the size of points. 
  # There are no special names for scatterplots where another variable is mapped to 
  # point shape or colour, however.

# Stat: Identity, which leaves the data as is. 
  
pmpg + geom_point(aes(cty, hwy))

pmpg + geom_point(mapping = aes(x = displ, y = hwy))

pmpg + geom_point(mapping = aes(x = displ, y = hwy, color = class))

pmpg + geom_point(mapping = aes(x = displ, y = hwy, color = displ < 5))

pmpg + geom_point(mapping = aes(x = displ, y = hwy, size = class))

pmpg + geom_point(mapping = aes(x = displ, y = hwy, alpha = class))

pmpg + geom_point(mapping = aes(x = displ, y = hwy, shape = class))

pmpg + geom_point(mapping = aes(x = displ, y = hwy), color = "blue")

pmpg + geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ class, nrow = 2)

pmpg + geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_grid(drv ~ cyl)

# ---- geom_smooth() -----

pmpg + geom_smooth(mapping = aes(x = displ, y = hwy))


# ---- geom_bin2d() ----

# ---- geom_hex() ----

# geom_boxplot() using group = cut_width ----
# can use one of the techniques for visualising the combination of a categorical 
# and a continuous variable, in this case boxplot
# shows variance, but not sense of relative number of observations
ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_boxplot(mapping = aes(group = cut_width(carat, 0.1)))

# geom_boxplot() using group = cut_number ----
# shows variance and sense of relative number of observations
ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_boxplot(mapping = aes(group = cut_number(carat, 20)))

# *** Basis: Two variables, Discrete X, Continuous Y *** ====

# ---- geom_violin() -----

# Description: A violin plot is a compact display of a continuous distribution. 
  # It is a blend of geom_boxplot and geom_density: a violin plot is a mirrored 
  # density plot displayed in the same way as a boxplot.

# Stat: stat = "ydensity"

ggplot(data = diamonds) +
  geom_violin(aes(clarity, price))

# *** Basis: Two variables, Discrete X, Discrete Y *** ====

# ---- geom_count() -----

# Description: This is a variant geom_point that counts the number of observations 
#   at each location, then maps the count to point area. It useful when you have 
#   discrete data and overplotting.

ggplot(data = diamonds) +
  geom_count(mapping = aes(x = cut, y = color))

# ---- geom_tile() ----
  # used with count for fill = n

diamonds %>% 
  count(color, cut) %>%  
  ggplot(mapping = aes(x = color, y = cut)) +
    geom_tile(mapping = aes(fill = n))

mpg %>% 
  count(cyl, displ) %>% 
  ggplot(mapping = aes(x = cyl, y = displ)) +
    geom_tile(mapping = aes(fill = n))

# factor to avoid gaps
mpg %>% 
  count(cyl = factor(cyl), displ = factor(displ)) %>% 
  ggplot(mapping = aes(x = cyl, y = displ)) +
    geom_tile(mapping = aes(fill = n))


