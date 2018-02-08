# Chapter 5 - Exploratory Data Analysis -----

# Libraries -----
library(tidyverse)
library(nycflights13)
library(ggstance)
library(ggbeeswarm)
library(lvplot)
library(hexbin)
library(modelr)

# Data ----

smaller <- diamonds %>% 
  filter(carat < 3)

# *** Introduction *** -----

# *** Questions *** -----

# *** Variation *** -----

# _ Visualizing Distributions -----

# A variable is categorical if it can only take one of a small set of values.
# In R, categorical variables are usually saved as factors or character vectors. 

# + To examine the distribution of a categorical variable, use a bar chart: ----

# geom_bar() ---- 
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut))

# count()----
diamonds %>% 
  count(cut)

diamonds %>%
  group_by(cut) %>% 
  summarize(
    n = n()
  )

# A variable is continuous if it can take any of an infinite set of ordered values. 
# Numbers and date-times are two examples of continuous variables. 

# + To examine the distribution of a continuous variable, use a histogram: ----

# geom_histogram() ----
ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = carat), binwidth = 0.5)

# cut_width() ----
diamonds %>% 
  count(cut_width(carat, 0.5))

diamonds %>% 
  group_by(cut_width(carat, 0.5)) %>% 
  summarize(
    n = n()
  )

# Here is how the graph above looks when we filter into just the diamonds with 
# a size of less than three carats and choose a smaller binwidth.

smaller <- diamonds %>% 
  filter(carat < 3)

ggplot(data = smaller, mapping = aes(x = carat)) +
  geom_histogram(binwidth = 0.1)

# If you wish to overlay multiple histograms in the same plot, 
# use geom_freqpoly() instead of geom_histogram(). 
# 
# geom_freqpoly() performs the same calculation as geom_histogram(), 
# but instead of displaying the counts with bars, uses lines instead. 
# 
# It’s much easier to understand overlapping lines than bars.

# geom_freqpoly() ----
ggplot(data = smaller, mapping = aes(x = carat, color = cut)) +
  geom_freqpoly(binwidth = 0.1)

# _ Typical Values -----

ggplot(data = smaller, mapping = aes(x = carat)) +
  geom_histogram(binwidth = .01)

# + Clusters of similar values suggest that subgroups exist in your data. ---- 
# To understand the subgroups, ask:
#   - How are the observations within each cluster similar to each other?
#   - How are the observations in separate clusters different from each other?
#   - How can you explain or describe the clusters?
#   - Why might the appearance of clusters be misleading?

# The histogram below shows the length (in minutes) of 272 eruptions of the Old Faithful Geyser 
# in Yellowstone National Park. Eruption times appear to be clustered into two groups: 
# there are short eruptions (of around 2 minutes) and long eruptions (4-5 minutes), but little in between.

ggplot(data = faithful, mapping = aes(x = eruptions)) +
  geom_histogram(binwidth = 0.25)

# _Unusual Values -----

# + outliers ----
# Sometimes outliers are data entry errors; 
# other times outliers suggest important new science. 
# When you have a lot of data, outliers are sometimes difficult to see in a histogram. 

# + The only evidence of outliers is the unusually wide limits on the x-axis.
ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = y), binwidth = 0.5) 
# note: x, y and z are literally variables in the dataset, being length, width, depth in mm.

# To make it easy to see the unusual values, we need to zoom to small values of the y-axis with coord_cartesian():

# coord_cartesian(), xlim() and ylim() ----
ggplot(data = diamonds) + 
  geom_histogram(mapping = aes(x = y), binwidth = 0.5) +
  coord_cartesian(ylim = c(0, 20))

# (coord_cartesian() also has an xlim() argument for when you need to zoom 
# into the x-axis. ggplot2 also has xlim() and ylim() functions that work 
# slightly differently: they throw away the data outside the limits.)
# 
# This allows us to see that there are three unusual values: 0, ~30, and ~60. 
# We pluck them out with dplyr:

unusual <- diamonds %>% 
  filter(y < 3 | y > 20) %>% 
  arrange(y)
unusual

# Exercises -----

# 1. Explore the distribution of each of the x, y, and z variables in diamonds. 
#    What do you learn? Think about a diamond and how you might decide which 
#    dimension is the length, width, and depth.

ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = x), bins = 200)
# 4mm < x < 9mm
# length

ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = y), bins = 500) +
  coord_cartesian(xlim = c(0,10))
# 3.75mm < y < 8.75mm
#width

ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = z), bins = 200) +
  coord_cartesian(xlim = c(1,6))
# 2mm < z < 5 mm
# most shallow. makes since as depth.

# 2. Explore the distribution of price. Do you discover anything unusual or surprising? 
#    (Hint: Carefully think about the binwidth and make sure you try a wide range of values.)

ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = price), binwidth = 10)
  #coord_cartesian(x = c(500, 1000))

# 3. How many diamonds are 0.99 carat? How many are 1 carat? What do you think is 
#    the cause of the difference?

diamonds %>%
  count(carat) %>%
  #filter(between(carat, 0.99, 1.00))
  filter(carat == 0.99 | carat == 1.00)

# A tibble: 2 x 2
#       carat  n
#       <dbl> <int>
#   1   0.99    23
#   2   1.00  1558
  
# 4. Compare and contrast coord_cartesian() vs xlim() or ylim() when zooming in on a histogram. 
#    What happens if you leave binwidth unset? 
#    What happens if you try and zoom so only half a bar shows?

str(diamonds)

# + Clippling ----

#zoom without clipping
ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = depth), binwidth = .5) +
  coord_cartesian(xlim = c(0,150), ylim = c(0,10)) 

#zoom with clipping 
ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = depth), binwidth = .5) +
  xlim(0,150) +
  ylim(0,10)

# without setting binwidth
ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = depth, color = cut)) +
  coord_cartesian(xlim = c(0,150), ylim = c(0,10))
# granularity is not controlled. e.g., wider bins show fewer discrete observations, 
# and counts increase relative to how many observations are aggregated in said wider bins.

# just for grins
ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = depth, fill = cut), binwidth = 1, position = "fill")

# *** Missing Values *** -----

# If you’ve encountered unusual values in your dataset, and simply want to move on 
# to the rest of your analysis, you have two options.

# + Option 1. Drop the entire row with the strange values: ----

diamonds2 <- diamonds %>% 
  filter(between(y, 3, 20))


# This option is not recommended because just because one measurement is invalid, 
# doesn’t mean all the measurements are. Additionally, if you have low quality data, 
# by time that you’ve applied this approach to every variable you might find that you 
# don’t have any data left!

# + Option 2. Instead, I recommend replacing the unusual values with missing values. ----
# The easiest way to do this is to use mutate() to replace the variable with a modified copy. 
# You can use the ifelse() function to replace unusual values with NA:
diamonds2 <- diamonds %>% 
  mutate(y = ifelse(y < 3 | y > 20, NA, y)) #ifelse(TRUE?, yes, no)

# ifelse() ----
# ifelse() has three arguments:
#  - The first argument test should be a logical vector. 
# The result will contain the value of the second argument, yes, when test is TRUE, 
# and the value of the third argument, no, when it is false.


# ggplot2 doesn’t include missing values (NAs) in the plot, 
# but it does warn that they’ve been removed:
ggplot(data = diamonds2, mapping = aes(x = x, y = y)) + 
  geom_point()
# Warning message:
# Removed 9 rows containing missing values (geom_point).

na.rm
#To suppress that warning, set na.rm = TRUE:
ggplot(data = diamonds2, mapping = aes(x = x, y = y)) + 
  geom_point(na.rm = TRUE)

# is.na() ----
# Other times you want to understand what makes observations with missing values 
# different to observations with recorded values. For example, in nycflights13::flights, 
# missing values in the dep_time variable indicate that the flight was cancelled. 
# So you might want to compare the scheduled departure times for cancelled and non-cancelled times. 
# You can do this by making a new variable with is.na().

nycflights13::flights %>% 
  mutate(
    cancelled      = is.na(dep_time),
    sched_hour     = sched_dep_time %/% 100,
    sched_min      = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>% 
  ggplot(mapping = aes(sched_dep_time)) + 
  geom_freqpoly(mapping = aes(colour = cancelled), binwidth = 1/4)
# However this plot isn’t great because there are many more non-cancelled flights than 
# cancelled flights. In the next section we’ll explore some techniques for improving this comparison.

# Exercises -----

# 1. What happens to missing values in a histogram? - They are removed with a warning
#    What happens to missing values in a bar chart? - They are removed with a warning
#    Why is there a difference? 
# geom_histogram: stat_bin bins data in ranges and counts the cases in each range. 
# geom_bar: stat_count counts the number of cases at each x position (without binning into ranges). 
# stat_bin requires continuous x data, whereas stat_count can be used for both discrete and continuous x data.

summary(nycflights13::flights)
str(flights)

?geom_histogram #single continuous variable:
# na.rm() :
# If FALSE, the default, missing values are removed with a warning. 
# If TRUE, missing values are silently removed.
ggplot(data = flights, aes(x = dep_time)) +
  geom_histogram(binwidth = 1)
# Warning message:
#  Removed 8255 rows containing non-finite values (stat_bin). 

?geom_bar #single discrete variable (typically, but bins will aggregate times)
# na.rm() :
# If FALSE, the default, missing values are removed with a warning. 
# If TRUE, missing values are silently removed.
ggplot(data = flights, aes(x = dep_time)) +
  geom_bar()
# Warning message:
#   Removed 8255 rows containing non-finite values (stat_count).

# for grins
flights %>% 
  mutate(
    dep_hour = dep_time %/% 100,
    dep_min  = dep_time %% 100,
    dep_time = dep_hour + dep_min / 60
  ) %>% 
  ggplot()+
  geom_histogram(aes(x = dep_time), fill = "blue", color = "yellow", binwidth = .5)
  #coord_cartesian(xlim = c(7,9))


# 2. What does na.rm = TRUE do in mean() and sum()?

?mean
# na.rm - logical value indicating whether NA values should be stripped 
# before the computation proceeds.

?sum()
# If na.rm is FALSE an NA or NaN value in any of the arguments will cause a 
# value of NA or NaN to be returned, otherwise NA and NaN values are ignored.


# *** Covariation *** -----

# If variation describes the behavior within a variable, covariation describes 
# the behavior between variables. Covariation is the tendency for the values of 
# two or more variables to vary together in a related way. The best way to spot 
# covariation is to visualise the relationship between two or more variables. 
# How you do that should again depend on the type of variables involved.

# _ One Categorical and one Continuous variable ----
# + freqploy where y = ..density, or a boxplot where x = reorder(x, ...) ----

# It’s common to want to explore the distribution of a continuous variable broken 
# down by a categorical variable, as in the previous frequency polygon. The default 
# appearance of geom_freqpoly() is not that useful for that sort of comparison because 
# the height is given by the count. That means if one of the groups is much smaller 
# than the others, it’s hard to see the differences in shape. For example, let’s 
# explore how the price of a diamond varies with its quality:

ggplot(data = diamonds, mapping = aes(x = price)) +
  geom_freqpoly(mapping = aes(color = cut), binwidth = 500)
# It’s hard to see the difference in distribution because the overall counts differ so much:

ggplot(diamonds) + 
  geom_bar(mapping = aes(x = cut))

# y = ..density.. ----
# To make the comparison easier we need to swap what is displayed on the y-axis. 
# Instead of displaying count, we’ll display density, which is the count standardised 
# so that the area under each frequency polygon is one.

ggplot(data = diamonds, mapping = aes(x = price, y = ..density..)) + 
  geom_freqpoly(mapping = aes(colour = cut), binwidth = 500)

# There’s something rather surprising about this plot - it appears that fair diamonds 
# (the lowest quality) have the highest average price! But maybe that’s because 
# frequency polygons are a little hard to interpret - there’s a lot going on in this plot.

# Another alternative to display the distribution of a continuous variable broken down by a 
# categorical variable is the boxplot. 

# Let’s take a look at the distribution of price by cut using geom_boxplot():
# 
# geom_boxplot() ----

ggplot(data = diamonds, mapping = aes(x = cut, y = price)) +
  geom_boxplot()

# We see much less information about the distribution, but the boxplots are much 
# more compact so we can more easily compare them (and fit more on one plot). 
# It supports the counterintuitive finding that better quality diamonds are 
# cheaper on average! In the exercises, you’ll be challenged to figure out why.
# 
# reorder() ----
# 
# cut is an ordered factor: fair is worse than good, which is worse than very good 
# and so on. Many categorical variables don’t have such an intrinsic order, so you 
# might want to reorder them to make a more informative display. One way to do that 
# is with the reorder() function.

# For example, take the class variable in the mpg dataset. You might be interested 
# to know how highway mileage varies across classes:

ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot()

# To make the trend easier to see, we can reorder class based on the median value of hwy:
  
ggplot(data = mpg) +
  geom_boxplot(mapping = aes(x = reorder(class, hwy, FUN = median), y = hwy))

# flip due to long variable names 
ggplot(data = mpg) +
  geom_boxplot(mapping = aes(x = reorder(class, hwy, FUN = median), y = hwy)) +
  coord_flip()

# Exercises ----

# 1. Use what you’ve learned to improve the visualisation of the departure times of 
# cancelled vs. non-cancelled flights.

# prior
nycflights13::flights %>% 
  mutate(
    cancelled      = is.na(dep_time),
    sched_hour     = sched_dep_time %/% 100,
    sched_min      = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>% 
  ggplot(mapping = aes(sched_dep_time)) + 
  geom_freqpoly(mapping = aes(colour = cancelled), binwidth = 1/4)
  
# improved
nycflights13::flights %>% 
  mutate(
    cancelled      = is.na(dep_time),
    sched_hour     = sched_dep_time %/% 100,
    sched_min      = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>% 
  ggplot(mapping = aes(sched_dep_time, y = ..density..)) + 
  geom_freqpoly(mapping = aes(colour = cancelled), binwidth = 1/4)

# 2.What variable in the diamonds dataset is most important for predicting the price of a diamond? 
#   How is that variable correlated with cut? Why does the combination of those two relationships 
#   lead to lower quality diamonds being more expensive? 

ggplot(data = diamonds, mapping = aes(x = carat, y = price)) + 
  geom_point(aes(color = cut, alpha = .10)) +
  geom_smooth(se = FALSE)

ggplot(data = diamonds, mapping = aes(x = reorder(cut, carat, FUN = median), y = carat)) + 
  geom_boxplot()

#play around
# ggplot(data = <DATA>) + 
#   <GEOM_FUNCTION>(
#     mapping = aes(<MAPPINGS>),
#     stat = <STAT>, 
#     position = <POSITION>
#   ) +
#   <COORDINATE_FUNCTION> +
#   <FACET_FUNCTION>

ggplot(diamonds) +
  geom_point(aes(carat, price, color = cut)) +
  facet_wrap(~clarity)

ggplot(diamonds) +
  geom_point(aes(cut, carat))

# ggstance ---- 
#' 3. Install the ggstance package, and create a horizontal boxplot. 
#' How does this compare to using coord_flip()?

#install.packages("ggstance")

# While coord_flip() can only flip a plot as a whole, ggstance provides flipped 
# versions of Geoms, Stats and Positions. This makes it easier to build horizontal 
# layer or use vertical positioning (e.g. vertical dodging). Also, horizontal Geoms 
# draw horizontal legend keys to keep the appearance of your plots consistent.
# https://cran.r-project.org/web/packages/ggstance/README.html

# prior
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot() +
  coord_flip()

# with ggstance (in this case it's the same, i.e, flips the plot as a whole)
ggplot(data = mpg, mapping = aes(x = hwy, y = class)) +
  geom_boxploth()

#' One problem with boxplots is that they were developed in an era of much smaller datasets 
#' and tend to display a prohibitively large number of “outlying values”. One approach to 
#' remedy this problem is the letter value plot. Install the lvplot package, and try using 
#' geom_lv() to display the distribution of price vs cut. What do you learn? How do you 
#' interpret the plots?

# install.packages("lvplot")

# geom_lv() ----
ggplot(data = diamonds, mapping = aes(x = cut, y = price)) +
  geom_lv()

# geom_violin() ----
# 5. Compare and contrast geom_violin() with a facetted geom_histogram(), 
# or a coloured geom_freqpoly(). What are the pros and cons of each method?
#   Hist and freqpoly visualize counts on the y-axis, whereas violin visualizes
#   distibution of values.  

# A violin plot is a compact display of a continuous distribution. 
  # It is a blend of geom_boxplot and geom_density: a violin plot is a mirrored density 
  # plot displayed in the same way as a boxplot.
  # Two vars, Discrete X, Continuous Y

ggplot(data = diamonds) +
  geom_violin(aes(clarity, price))

# A histogram plot visualises the distribution of a single Continuous X variable by 
# dividing the x axis into bins and counting the number of observations in each bin.

ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = price), binwidth = 100) +
  facet_wrap(~ clarity)

# Frequency polygons display the counts with lines. Frequency polygons are more suitable 
# when you want to compare the distribution across a the levels of a categorical variable.
# Single Continuous X

ggplot(data = diamonds) +
  geom_freqpoly(mapping = aes(x = price, color = clarity), binwidth = 100)

# geom_beeswarm() and geom_quasirandom() ----

# 6. If you have a small dataset, it’s sometimes useful to use geom_jitter() to see 
  # the relationship between a continuous and categorical variable. The ggbeeswarm 
  # package provides a number of methods similar to geom_jitter(). List them and 
  # briefly describe what each one does.

# As for geom_jiter, it is a convenient shortcut for geom_point(position = "jitter"). 
  # It adds a small amount of random variation to the location of each point, and is 
  # a useful way of handling overplotting caused by discreteness in smaller datasets.

ggplot(data = mpg, mapping = aes(class, hwy)) +
  geom_jitter()

ggplot(data = mpg, mapping = aes(class, hwy)) +
  geom_beeswarm()

ggplot(data = mpg, mapping = aes(class, hwy)) +
  geom_quasirandom()

ggplot(data = mpg, mapping = aes(class, hwy)) +
  geom_beeswarm() +
  geom_quasirandom(width = .1)

ggplot(data = mpg, mapping = aes(class, hwy, color = factor(cyl))) +
  geom_beeswarm() 
  #+ geom_quasirandom()

# Many other alternative methods at https://github.com/eclarke/ggbeeswarm

# _ Two Categorical variables ----

# + To visualise the covariation between categorical variables, you’ll need to count 
# the number of observations for each combination. 
# 
# geom_count() ----
# (1) One way to do that is to rely on the built-in geom_count():

ggplot(data = diamonds) +
  geom_count(mapping = aes(x = cut, y = color))

# (2) Another approach is to compute the count with dplyr:

diamonds %>% 
  count(color, cut)

# Then visualise with geom_tile() and the fill aesthetic:
# geom_tile() ----

diamonds %>% 
  count(color, cut) %>%  
  ggplot(mapping = aes(x = color, y = cut)) +
    geom_tile(mapping = aes(fill = n))

# If the categorical variables are unordered, you might want to use the seriation package 
# to simultaneously reorder the rows and columns in order to more clearly reveal 
# interesting patterns. For larger plots, you might want to try the d3heatmap or 
# heatmaply packages, which create interactive plots.

# Exercises ----

# 1. How could you rescale the count dataset above to more clearly show the distribution 
#    of cut within colour, or colour within cut?

# original
diamonds %>% 
  count(color, cut)

# cut within color
diamonds %>%
  group_by(color) %>% 
  count(cut)

# color within cut
diamonds %>%
  group_by(cut) %>% 
  count(color)

# scale_fill_gradient2() ----
diamonds %>% 
  count(color, cut) %>%  
  ggplot(mapping = aes(x = color, y = cut)) +
    geom_tile(mapping = aes(fill = n)) +
  scale_fill_gradient2()

# 2. Use geom_tile() together with dplyr to explore how average flight delays vary by destination 
#    and month of year. What makes the plot difficult to read? How could you improve it?

str(flights)

flights %>% 
  group_by(month, dest) %>% 
  summarize(
    avg = mean(dep_delay, na.rm = "TRUE")
  ) %>% 
  ggplot(data = ggg, mapping = aes(x = month, y = dest)) +
  geom_tile(mapping = aes(fill = avg))

# Too many data points to make sense of, and the months need to be factors.

# factor month
flights %>% 
  group_by(month, dest) %>% 
  summarize(
    avg = mean(dep_delay, na.rm = "TRUE")
  ) %>% 
  ggplot(data = ggg, mapping = aes(x = factor(month), y = dest)) +
  geom_tile(mapping = aes(fill = avg))

# filter out less common destinations

flights %>% 
  group_by(month, dest) %>% 
  summarize(
    n = n(),
    avg = mean(dep_delay, na.rm = "TRUE")
  ) %>% 
  filter(n > 500) %>% 
  ggplot(mapping = aes(x = factor(month), y = dest)) +
  geom_tile(mapping = aes(fill = avg))
# This does not look right. What is the missing data, e.g., for SJU in Jan and Feb?
# Find out...
flights %>% 
  group_by(month, dest) %>% 
  summarize(
    n = n(),
    avg = mean(dep_delay, na.rm = "TRUE")
  ) %>% 
  filter(dest == 'SJU')
# The missing data is for month-dest combos where there were less than 500 flights.
# Therefore, we need to filter by the destinations with the most total flights in the year.

flights %>% 
  group_by(dest) %>% 
  summarize(
    n = n()
  ) %>% 
  arrange(desc(n))
# the top 10 dests had more than 9700 flights

top_10_dests <- flights %>% 
  group_by(dest) %>% 
  summarize(
    n = n()
  ) %>% 
  filter(n > 9700)

flights %>% 
  filter(dest %in% top_10_dests$dest) %>% 
  group_by(dest, month) %>% 
  summarize(
    avg_dep_delay = mean(dep_delay, na.rm = "TRUE")
  ) %>% 
  ggplot(mapping = aes(x = factor(month), y = dest)) +
  geom_tile(mapping = aes(fill = avg_dep_delay))
  #scale_fill_gradientn(colours = terrain.colors(12))
  # the one below happens to be the default
  #scale_fill_gradient(low = "#132B43", high = "#56B1F7", space = "Lab", na.value = "grey50", guide = "colourbar")

  
# The highest average departure delays by month at the the top 10 destinations are Atlanta and San Francisco, 
# both in July. Possibly this could be due to thunderstorms (Atlanta) and fog (San Francisco). 
# The lowest average departure delays across the board appear to be in November. Possibly this could be
# due to airlines emphasizing minimal delays during holiday travel and staffing accordingly.

flights %>% 
  filter(dest %in% top_10_dests$dest) %>% 
  group_by(month) %>% 
  summarize(
    avg_dep_delay = mean(dep_delay, na.rm = "TRUE")
  ) %>% 
  arrange(avg_dep_delay)
# Confirms November has the lowest average departure delays across the board as above.

# 3. Why is it slightly better to use aes(x = color, y = cut) rather than 
#    aes(x = cut, y = color) in the example above?

diamonds %>% 
  count(color, cut) %>% 
  ggplot(mapping = aes(x = color, y = cut)) +
  geom_tile(mapping = aes(fill = n))

diamonds %>% 
  count(color, cut) %>% 
  ggplot(mapping = aes(x = cut, y = color)) +
  geom_tile(mapping = aes(fill = n))

# Because in this particular case the lables for the colors are shorter, thus creating a narrower 
# column width across the x-axis which results in a more visually pleasing presentation such that
# the width of each tile is less than the height.

# _ Two Continuous variables  ----

# geom_point() ----
# You’ve already seen one great way to visualise the covariation between two continuous variables: 
# draw a scatterplot with geom_point(). You can see covariation as a pattern in the points. 
# For example, you can see an exponential relationship between the carat size and price of a diamond.

ggplot(data = diamonds) +
  geom_point(mapping = aes(x = carat, y = price))

# Scatterplots become less useful as the size of your dataset grows, because points begin to 
# overplot, and pile up into areas of uniform black (as above). You’ve already seen one way 
# to fix the problem: using the alpha aesthetic to add transparency.

ggplot(data = diamonds) + 
  geom_point(mapping = aes(x = carat, y = price), alpha = 1 / 100)

# geom_bin2d() and geom_hex() ----
# But using transparency can be challenging for very large datasets. 
# Another solution is to use bin. Previously you used geom_histogram() and 
# geom_freqpoly() to bin in one dimension. Now you’ll learn how to use 
# geom_bin2d() and geom_hex() to bin in two dimensions.

# geom_bin2d() and geom_hex() divide the coordinate plane into 2d bins and 
# then use a fill color to display how many points fall into each bin. 
# geom_bin2d() creates rectangular bins. geom_hex() creates hexagonal bins. 
# You will need to install the hexbin package to use geom_hex().

ggplot(data = smaller) +
  geom_bin2d(mapping = aes(x = carat, y = price))

# install.packages("hexbin")
ggplot(data = smaller) +
  geom_hex(mapping = aes(x = carat, y = price))

# Another option is to bin one continuous variable so it acts like a categorical variable. 
# Then you can use one of the techniques for visualising the combination of a categorical 
# and a continuous variable that you learned about. For example, you could bin carat and 
# then for each group, display a boxplot:

# geom_boxplot() using group = cut_width ----
ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_boxplot(mapping = aes(group = cut_width(carat, 0.1)))

# cut_width(x, width), as used above, divides x into bins of width width. 
# By default, boxplots look roughly the same (apart from number of outliers) regardless of 
# how many observations there are, so it’s difficult to tell that each boxplot summarises 
# a different number of points. One way to show that is to make the width of the boxplot 
# proportional to the number of points with varwidth = TRUE.

# Another approach is to display approximately the same number of points in each bin. 
# That’s the job of cut_number():

# geom_boxplot() using group = cut_number ----
ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_boxplot(mapping = aes(group = cut_number(carat, 20)))

# 7.5.3.1 Exercises ----

# 1. Instead of summarising the conditional distribution with a boxplot, you could use a 
#    frequency polygon. What do you need to consider when using cut_width() vs cut_number()? 
#    How does that impact a visualisation of the 2d distribution of carat and price?

# Originals. Boxplots. These work.
ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_boxplot(mapping = aes(group = cut_width(carat, 0.1)))

ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_boxplot(mapping = aes(group = cut_number(carat, 20)))

# New. Frequency Polygrams. These do not work (yet).

ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_freqpoly(mapping = aes(group = cut_width(carat, 0.1)))

ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_freqpoly(mapping = aes(group = cut_number(carat, 20)))

# Error: stat_count() must not be used with a y aesthetic.
# 
# Tell me more about this error and related considertations:
#   (1) geom_freqpoly uses the same aesthetics as geom_line.
#   (2) boxplot uses stat = "boxplot"
#   (3) freqpoly uses stat = "bin". stat_bin is suitable only for continuous x data. 
#       If your x data is discrete, you probably want to use stat_count.
#   (4) stat="count" makes the height of the bar proportional to the number of cases 
#       in each group (or if the weight aethetic is supplied, the sum of the weights). 
#       If you want the heights of the bars to represent values in the data, use 
#       stat="identity" and map a variable to the y aesthetic.

# Stat = "Count" produces the same error: stat_count() must not be used with a y aesthetic.
# Stat = "Identity" works, although it produces ugly plots. 

ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_freqpoly(mapping = aes(group = cut_width(carat, .1)), stat = "Identity")

# better
ggplot(data = smaller, mapping = aes(x = price, y = carat)) + 
  geom_freqpoly(mapping = aes(group = cut_width(carat, .05)), stat = "Identity")

ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_freqpoly(mapping = aes(group = cut_number(carat, 20)), stat = "Identity")

# + cut_width() vs. cut_number()
# cut_interval makes n groups with equal range, 
# cut_number makes n groups with (approximately) equal numbers of observations; 
# cut_width makes groups of width width.

#original
ggplot(data = smaller) +
  geom_bin2d(mapping = aes(x = carat, y = price), color = "red") +
  labs(title = "Original")

# new
ggplot(data = smaller) +
  geom_bin2d(mapping = aes(x = carat, y = price, group = cut_width(carat, .1)), color = "red") +
  labs(title = "cut_width")

ggplot(data = smaller) +
  geom_bin2d(mapping = aes(x = carat, y = price, group = cut_number(carat, 20)), color = "red") +
  labs(title = "cut_number")
  

# The sizes of the rectangles in the plane do not change. geom_bin2d() uses stat_bin_2d 
# which uses bins = 30. However, the counts of the number of cases (the density) in each 
# rectangle does change. Why?
# 
# Because when you bin the values of a continuous variable to make it act like a categorical
# and then force it into plot bins, the density of the plot bins changes according to the 
# binning of the data. To see this more clearly, change the number of plot bins or plot bin 
# widths, and notice the legend for counts which changes accordingly:

#original
ggplot(data = smaller) +
  geom_bin2d(mapping = aes(x = carat, y = price), color = "red", bins = 10) +
  labs(title = "Original")

# new
ggplot(data = smaller) +
  geom_bin2d(mapping = aes(x = carat, y = price, group = cut_width(carat, .1)), 
    color = "red", bins = 10) +
  labs(title = "cut_width")

ggplot(data = smaller) +
  geom_bin2d(mapping = aes(x = carat, y = price, group = cut_number(carat, 20)), 
    color = "red", bins = 10) +
  labs(title = "cut_number")

# 2. Visualise the distribution of carat, partitioned by price.

ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = carat))

ggplot(data = diamonds) +
  geom_boxplot(mapping = aes(x = price, y = carat, group = cut_width(carat, .75))) +
  labs(title = "Cut_Width")

ggplot(data = diamonds) +
  geom_boxplot(mapping = aes(x = price, y = carat, group = cut_number(carat, 2))) +
  labs(title = "Cut_Number")

ggplot(data = diamonds) +
  geom_boxplot(mapping = aes(x = cut_width(carat, 1), y = price)) +
  labs(title = "Cut_Width")

# better
ggplot(data = diamonds) +
  geom_bin2d(mapping = aes(x = cut_width(carat, 1), y = price)) +
  labs(title = "Cut_Width")

# 3. How does the price distribution of very large diamonds compare to small diamonds. 
#    Is it as you expect, or does it surprise you?
#    
#    While all diamonds priced below $5000 are less than 2 carats, it is surprising that
#    diamonds costing over $15000 can be any size, from about 1 carat up to 5 carats.

# 4. Combine two of the techniques you’ve learned to visualise the combined distribution 
#    of cut, carat, and price.

ggplot(data = diamonds) +
  geom_boxplot(mapping = aes(x = cut_width(carat, 1), y = price, color = cut))

ggplot(data = diamonds) +
  geom_boxplot(mapping = aes(x = cut_width(carat, 1), y = price, color = cut)) +
  facet_wrap(~color)


# 5. Two dimensional plots reveal outliers that are not visible in one dimensional plots. 
#    For example, some points in the plot below have an unusual combination of x and y values, 
#    which makes the points outliers even though their x and y values appear normal when 
#    examined separately.

ggplot(data = diamonds) +
  geom_point(mapping = aes(x = x, y = y)) +
  coord_cartesian(xlim = c(4, 11), ylim = c(4, 11))

# Why is a scatterplot a better display than a binned plot for this case?
# 
# Because the outliers would get binned in with the others in their group as parts of the 
# groups density or distribution.

# *** Patterns and Models *** ----

# Patterns in your data provide clues about relationships. If a systematic relationship 
# exists between two variables it will appear as a pattern in the data. If you spot a 
# pattern, ask yourself:

# - Could this pattern be due to coincidence (i.e. random chance)?
# 
# - How can you describe the relationship implied by the pattern?
# 
# - How strong is the relationship implied by the pattern?
# 
# - What other variables might affect the relationship?
# 
# - Does the relationship change if you look at individual subgroups of the data?
# 
# - A scatterplot of Old Faithful eruption lengths versus the wait time between eruptions 
#   shows a pattern: longer wait times are associated with longer eruptions. The scatterplot 
#   also displays the two clusters that we noticed above.

ggplot(data = faithful) + 
  geom_point(mapping = aes(x = eruptions, y = waiting))

# Patterns provide one of the most useful tools for data scientists because they reveal covariation. 
# If you think of variation as a phenomenon that creates uncertainty, covariation is a phenomenon 
# that reduces it. If two variables covary, you can use the values of one variable to make better 
# predictions about the values of the second. If the covariation is due to a causal relationship 
# (a special case), then you can use the value of one variable to control the value of the second.

# Models are a tool for extracting patterns out of data. For example, consider the diamonds data. 
# It’s hard to understand the relationship between cut and price, because cut and carat, and carat 
# and price are tightly related. It’s possible to use a model to remove the very strong relationship 
# between price and carat so we can explore the subtleties that remain. The following code fits a 
# model that predicts price from carat and then computes the residuals (the difference between the 
# predicted value and the actual value). The residuals give us a view of the price of the diamond, 
# once the effect of carat has been removed.

# library(modelr) ----

mod <- lm(log(price) ~ log(carat), data = diamonds)

diamonds2 <- diamonds %>% 
  add_residuals(mod) %>% 
  mutate(resid = exp(resid))

ggplot(data = diamonds2) + 
  geom_point(mapping = aes(x = carat, y = resid))

# Once you’ve removed the strong relationship between carat and price, you can see what you 
# expect in the relationship between cut and price: relative to their size, better quality 
# diamonds are more expensive.

ggplot(data = diamonds2) + 
  geom_boxplot(mapping = aes(x = cut, y = resid))

# You’ll learn how models, and the modelr package, work in the final part of the book, model. 
# We’re saving modelling for later because understanding what models are and how they work is 
# easiest once you have tools of data wrangling and programming in hand.

# *** ggplot2 calls *** ----

# As we move on from these introductory chapters, we’ll transition to a more concise expression 
# of ggplot2 code. So far we’ve been very explicit, which is helpful when you are learning:

ggplot(data = faithful, mapping = aes(x = eruptions)) + 
  geom_freqpoly(binwidth = 0.25)

# Typically, the first one or two arguments to a function are so important that you should know 
# them by heart. The first two arguments to ggplot() are data and mapping, and the first two 
# arguments to aes() are x and y. In the remainder of the book, we won’t supply those names. 
# That saves typing, and, by reducing the amount of boilerplate, makes it easier to see what’s 
# different between plots. That’s a really important programming concern that we’ll come back 
# in functions.

# Rewriting the previous plot more concisely yields:

ggplot(faithful, aes(eruptions)) + 
  geom_freqpoly(binwidth = 0.25)

# Sometimes we’ll turn the end of a pipeline of data transformation into a plot. 
# Watch for the transition from %>% to +. I wish this transition wasn’t necessary 
# but unfortunately ggplot2 was created before the pipe was discovered.

diamonds %>% 
  count(cut, clarity) %>% 
  ggplot(aes(clarity, cut, fill = n)) + 
    geom_tile()

# *** Learning more **** ----

# If you want to learn more about the mechanics of ggplot2, I’d highly recommend grabbing a 
# copy of the ggplot2 book: https://amzn.com/331924275X. It’s been recently updated, so it 
# includes dplyr and tidyr code, and has much more space to explore all the facets of visualisation. 
# Unfortunately the book isn’t generally available for free, but if you have a connection to a 
# university you can probably get an electronic version for free through SpringerLink.

# Another useful resource is the R Graphics Cookbook by Winston Chang. Much of the contents are 
# available online at http://www.cookbook-r.com/Graphs/.

# I also recommend Graphical Data Analysis with R, by Antony Unwin. This is a book-length treatment 
# similar to the material covered in this chapter, but has the space to go into much greater depth.

