# Chapter 3 - Data Transformation with dypler -----

# Introduction ------

library(nycflights13)
library(dplyr)
library(ggplot2)
library(tidyverse)

# nyc flights tibble ---------------
flights

# variable types -----

# int stands for integers.
# dbl stands for doubles, or real numbers.
# chr stands for character vectors, or strings.
# dttm stands for date-times (a date + a time).
# lgl stands for logical, vectors that contain only TRUE or FALSE.
# fctr stands for factors, which R uses to represent categorical variables with fixed possible values.
# date stands for dates.

# dplyr Basics ---------------

# 5 key verbs

# Pick observations by their values (filter()).
# Reorder the rows (arrange()).
# Pick variables by their names (select()).
# Create new variables with functions of existing variables (mutate()).
# Collapse many values down to a single summary (summarise()).

# These can all be used in conjunction with group_by()

# ------ Filter rows with filter() ---------------

# print
filter(flights, month == 1, day == 1)

# assign
jan1 <- filter(flights, month == 1, day == 1)

# print and assign
(dec25 <- filter(flights, month == 12, day == 25))

# Comparisons ---------------

# R provides the standard suite: >, >=, <, <=, != (not equal), and == (equal).

# near()
sqrt(2) ^ 2 == 2          # FALSE
near(sqrt(2) ^ 2 == 2)    # TRUE
1/49 * 49 == 1            # FALSE
near(1/49 * 49 == 1)      # TRUE

# Logical Operators ---------------

# & is "and"
# ! is "not"
# | is "or"


filter(flights, month == 11 | month == 12)

# alternately
nov_dec <- filter(flights, month %in% c(11, 12))

# De Morgan’s law: !(x & y) is the same as !x | !y, and !(x | y) is the same as !x & !y

# equivalents
filter(flights, !(arr_delay > 120 | dep_delay > 120))
filter(flights, arr_delay <= 120, dep_delay <= 120)

# Missing Values ---------------

x = NA
is.na(x)

# filter() only includes rows where the condition is TRUE; 
# it excludes both FALSE and NA values. If you want to preserve missing values, 
# ask for them explicitly:

df <- tibble(x = c(1, NA, 3))
filter(df, x > 1)
#to include x is NA or x > 1
filter(df, is.na(x) | x > 1)

# Exercises ----

# 1. Find all flights that:

# a. Had an arrival delay of two or more hours
flights
filter(flights, arr_delay > 120)

# b. flew to Houston (IAH or HOU)
filter(flights, dest == "IAH" | dest == "HOU")

# c. Were operated by American, United, or Delta
levels(as.factor(flights$carrier))
# [1] "9E" "AA" "AS" "B6" "DL" "EV" "F9" "FL" "HA" "MQ" "OO" "UA" "US" "VX" "WN" "YV"
filter(flights, carrier =="AA" | carrier == "UA" | carrier =="DL")
filter(flights, carrier %in% c("AA", "UA", "DL"))

# d. Departed in summer (July, August, September)
filter(flights, month %in% c(7, 8, 9))

# e. Arrived more than two hours late, but did not leave late
filter(flights, arr_delay > 120 & dep_delay <= 0)

# f. Were delayed by at least an hour, but made up more than thirty minutes on flight
filter(flights, dep_delay > 60 & (arr_time < (sched_arr_time + 30)))

# g. Departed between midnight and 6:00 a.m. (inclusive)
filter(flights, dep_time >= 0000 & dep_time <= 0600)

# 2. Another useful dplyr filtering helper is between(). What does it do? 
# Can you use it to simplify the code needed to answer the previous challenges?
filter(flights, between(dep_time, 0000, 0600))

# 3. How many flights have a missing dep_time? 
filter(flights,is.na(dep_time))
# What other variables are missing?
# dep_delay, arr_time, arr_delay
# What might these rows represent?
# Cancelled flights

# 4. Why is NA ^ 0 not missing? 
# Why is NA | TRUE not missing? 
# Why is FALSE & NA not missing? 
# Can you figure out the general rule? (NA * 0 is a tricky counterexample!)

NA ^ 0
# [1] 1

NA | TRUE
# # [1] TRUE

NA & FALSE
# [1] FALSE

NA * 0
# [1] NA

# Arrange rows with arrange() ---------------

arrange(flights, year, month, day)

# Use desc() to re-order by a column in descending order:
arrange(flights, desc(arr_delay))

# Missing values are always sorted at the end
df <- tibble(x = c(5, 2, NA))
arrange(df, x)
arrange(df, desc(x))

# Exercises ----

1. # How could you use arrange() to sort all missing values to the start? (Hint: use is.na()).
arrange(df, desc(is.na(x)))

# 2. Sort flights to find the most delayed flights. Find the flights that left earliest.
arrange(flights, desc(dep_delay))
arrange(flights, dep_delay)

# 3. Sort flights to find the fastest flights.
arrange(flights, air_time)
select(arrange(flights, air_time), flight, month, day, year, air_time)      

# 4. Which flights travelled the longest? Which travelled the shortest?
select(arrange(flights, desc(air_time)), flight, month, day, year, air_time) 
select(arrange(flights, air_time), flight, month, day, year, air_time)

# Select columns with select() ---------------

# Select columns by name
select(flights, year, month, day)

# Select all columns between year and day (inclusive)
select(flights, year:day)

# Select all columns except those from year to day (inclusive)
select(flights, -(year:day))

# There are a number of helper functions you can use within select():
#   
# starts_with("abc"): matches names that begin with “abc”.
# 
# ends_with("xyz"): matches names that end with “xyz”.
# 
# contains("ijk"): matches names that contain “ijk”.
# 
# matches("(.)\\1"): selects variables that match a regular expression. 
# This one matches any variables that contain repeated characters. 
# You’ll learn more about regular expressions in strings.
# 
# num_range("x", 1:3) matches x1, x2 and x3.
# 
# See ?select for more details.

#rename
rename(flights, tail_num = tailnum) # new = old

#move some columns to front and include everything() else after
select(flights, time_hour, air_time, everything())

# Exercises ----

# 1. Brainstorm as many ways as possible to select dep_time, dep_delay, arr_time, 
# and arr_delay from flights.
select(flights, dep_time, dep_delay, arr_time, arr_delay) # YES x4
select(flights, starts_with("dep"), starts_with("arr")) # YES x4
select(flights, ends_with("_time"), ends_with("_delay")) #NO x7
select(flights, contains("arr"), contains("dep")) #NO x7

# 2. What happens if you include the name of a variable multiple times in a select() call?
select(flights, flight, year, year)
# it is returned once, not mulitple times

# 3. What does the one_of() function do? Why might it be helpful in conjunction with this vector?
vars <- c("year", "month", "day", "dep_delay", "arr_delay")
vars
# [1] "year"      "month"     "day"       "dep_delay" "arr_delay"
?one_of #variables in character vector.
select(flights, one_of(vars)) #returns each column in vars

# 4. Does the result of running the following code surprise you? 
# Answer: Yes, it is a surprise that helpers are not case sensitive.
# How do the select helpers deal with case by default? 
# Answer: ignore.case	If TRUE, the default, ignores case when matching names.
# How can you change that default?

select(flights, contains("TIME", ignore.case = FALSE))

# Add New Variables with mutate() --------------

View(flights)
names(flights)

flights_sml <- select(flights, 
                      year:day, 
                      ends_with("delay"), 
                      distance, 
                      air_time)
mutate(flights_sml,
       gain = arr_delay - dep_delay,
       speed = distance / air_time * 60)

# Note that you can refer to columns that you’ve just created:
mutate(flights_sml,
       gain = arr_delay - dep_delay,
       hours = air_time / 60,
       gain_per_hour = gain / hours
)

# If you only want to keep the new variables, use transmute()
transmute(flights,
          gain = arr_delay - dep_delay,
          hours = air_time / 60,
          gain_per_hour = gain / hours
          )

# Useful Creation Functions ---------------

# Exercises ----

# 1. Currently dep_time and sched_dep_time are convenient to look at, 
# but hard to compute with because they’re not really continuous numbers. 
# Convert them to a more convenient representation of number of minutes since midnight.

transmute(flights,
          dep_time,
          dep_hour = dep_time %/% 100,
          dep_min = dep_time %% 100,
          dep_mins_since_midnight = (dep_hour * 60) + dep_min,
          sched_dep_time,
          sched_dep_mins_since_midnight = ((sched_dep_time %/% 100) * 60) + sched_dep_time %% 100
          )
# 2. Compare air_time with arr_time - dep_time. 
# Note: From https://cran.r-project.org/web/packages/nycflights13/nycflights13.pdf:
#       air_time Amount of time spent in the air, in minutes
#       dep_time,arr_time Actual departure and arrival times, local tz (clock time)
# What do you expect to see? What do you see? 
# What do you need to do to fix it?
transmute(flights,
          air_time,
          enroute = arr_time - dep_time
          )
# To fix it, the arr_time and dep_time must be converted to minutes from midnight. However, 
# they are also given in local time zones, so that must be accounted for. As well, some flights
# could have departed before midnight and landed after midnight, which must also be accounted for. 
# Naive results show air_time can most often varies from arr_time - dep_time:
transmute(flights,
       dep_time = ((dep_time %/% 100) * 60) + (dep_time %% 100),
       arr_time = ((arr_time %/% 100) * 60) + (arr_time %% 100),
       enroute = arr_time - dep_time %% (60*24),
       air_time
)

# 3. Compare dep_time, sched_dep_time, and dep_delay. 
# How would you expect those three numbers to be related?
#   One might expect dep_time - sched_dep_time == dep_delay
transmute(flights, dep_time, sched_dep_time, dep_delay, x = dep_time - sched_dep_time, y = x == dep_delay)
#   However, since arr_time and dep_time are in clock times rather then minutes, 
#   an adjustment would need be made (as above) to effect the correct calculation.

# 4. Find the 10 most delayed flights using a ranking function. 
# How do you want to handle ties? Carefully read the documentation for min_rank().
?min_rank
x <- as.data.frame(select(flights, dep_delay))
head(min_rank(desc(x)), 10)

# 5. What does 1:3 + 1:10 return? Why?
1:3 + 1:10
# returns a warning message because the objects' lengths are different from each other

# 6. What trigonometric functions does R provide?
# Base R provides the following, with angles in radians
# cos(x), sin(x), tan(x), acos(x), asin(x), atan(x), atan2(y, x)
# cospi(x), sinpi(x), tanpi(x)

# Grouped Summaries with summarize() ---------------

summarize(flights, delay = mean(dep_delay, na.rm = TRUE))

# summarize() is not very useful inless paried with group_by()
by_day <- group_by(flights, year, month, day)
summarize(by_day, delay = mean(dep_delay, na.rm = TRUE))

# Combining Multiple Operations with the Pipe ---------------

names(flights)

# Using basic methods without piping:

# Group the flights by desitination. Data frame 336776 x 19 
by_dest <- group_by(flights, dest)

# Summarize to compute distance, average arrival delay, and number of flights.
# Data frame 105 X 4
delay = summarize(by_dest,
                  count = n(), # The number of observations in the current group.
                  avg_dist = mean(distance, na.rm = TRUE),
                  avg_delay = mean(arr_delay, na.rm = TRUE)
                  )
# Filter to remove noisy points and Honolulu airport, which is almost twice 
# as far as the next closest airport. 
# Data frame 96 x4 
delay = filter(delay, count > 20, dest != "HNL")
View(delay)

# plot the results

# ggplot(data = <DATA>) + 
#   <GEOM_FUNCTION>(
#     mapping = aes(<MAPPINGS>),
#     stat = <STAT>, 
#     position = <POSITION>
#   ) +
#   <COORDINATE_FUNCTION> +
#   <FACET_FUNCTION>

ggplot(data = delay, mapping = aes(x = avg_dist, y = avg_delay)) +
  geom_point(aes(size = count)) +
  geom_smooth(se = FALSE)

# Do the same as above with Piping

delays <- flights %>%
  group_by(dest) %>%
  summarize(count = n(),
            avg_dist = mean(distance, na.rm = TRUE),
            avg_delay = mean(arr_delay, na.rm = TRUE)
            ) %>%
  filter(count > 20, dest != "HNL")

ggplot(data = delay, mapping = aes(x = avg_dist, y = avg_delay)) +
  geom_point(aes(size = count)) +
  geom_smooth(se = FALSE)


flights%>%
  group_by(year, month, day) %>%
  summarize(mean = mean(dep_delay, na.rm = TRUE))

# Groups:   year, month [?]
# year month   day      mean
# <int> <int> <int>     <dbl>
#   1  2013     1     1 11.548926
# 2  2013     1     2 13.858824
# 3  2013     1     3 10.987832
# 4  2013     1     4  8.951595
# 5  2013     1     5  5.732218
# 6  2013     1     6  7.148014
# 7  2013     1     7  5.417204
# 8  2013     1     8  2.553073
# 9  2013     1     9  2.276477
# 10  2013     1    10  2.844995
# ... with 355 more rows

not_cancelled <- flights %>%
  filter(!is.na(dep_delay), !is.na(arr_delay))
# 327,346 x 19

not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(mean = mean(dep_delay))
# 365 x 4 year, month, day, mean

# Counts ---------------

# Whenever you do any aggregation, it’s always a good idea to include either a count 
# (n()), or a count of non-missing values (sum(!is.na(x))). That way you can check 
# that you’re not drawing conclusions based on very small amounts of data. 

# For example, let’s look at the planes (identified by their tail number) that have 
# the highest average delays:

delays <- not_cancelled %>%
  group_by(tailnum) %>%
  summarize(
    delay = mean(arr_delay)
  )

ggplot(delays, mapping = aes(x = delay)) +
  geom_freqpoly(binwidth = 10)

# Wow, there are some planes that have an average delay of 5 hours (300 minutes)!

# The story is actually a little more nuanced. We can get more insight if we draw 
# a scatterplot of number of flights vs. average delay:

delays <- not_cancelled %>%
  group_by(tailnum) %>%
  summarize(
    delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  )

ggplot(delays, mapping = aes(x = n, y = delay)) +
  geom_point(alpha = 1/10)

#' Not surprisingly, there is much greater variation in the average delay when there 
#' are few flights. The shape of this plot is very characteristic: whenever you plot 
#' a mean (or other summary) vs. group size, you’ll see that the variation decreases 
#' as the sample size increases.

#' When looking at this sort of plot, it’s often useful to filter out the groups 
#' with the smallest numbers of observations, so you can see more of the pattern 
#' and less of the extreme variation in the smallest groups. This is what the 
#' following code does, as well as showing you a handy pattern for integrating 
#' ggplot2 into dplyr flows. It’s a bit painful that you have to switch 
#' from %>% to +, but once you get the hang of it, it’s quite convenient.

delays %>%
  filter(n > 25) %>%
  ggplot(mapping = aes(x = n, y = delay)) +
  geom_point(alpha = 1/10)

#' There’s another common variation of this type of pattern. 
#' Let’s look at how the average performance of batters in baseball is related 
#' to the number of times they’re at bat. Here I use data from the Lahman package 
#' to compute the batting average (number of hits / number of attempts) of every 
#' major league baseball player.

#' When I plot the skill of the batter (measured by the batting average, ba) 
#' against the number of opportunities to hit the ball (measured by at bat, ab), 
#' you see two patterns:
  
#' - As above, the variation in our aggregate decreases as we get more data points.

#' - There’s a positive correlation between skill (ba) and opportunities to hit the 
#' ball (ab). This is because teams control who gets to play, and obviously they’ll 
#' pick their best players.

# Convert to a tibble so it prints nicely
batting <- as_tibble(Lahman::Batting)

batters <-  batting %>%
  group_by(playerID) %>%
  summarize(
    ba = sum(H, na.rm = TRUE) / sum(AB, na.rm = TRUE),
    ab = sum(AB, na.rm = TRUE)
    )

batters %>%
  filter(ab > 100) %>%
  ggplot(mapping = aes(x = ab, y = ba)) +
  geom_point(alpha = 1/10) +
  geom_smooth(se = FALSE)

#' This also has important implications for ranking. 
#' If you naively sort on desc(ba), the people with the best batting 
#' averages are clearly lucky, not skilled:

batters %>%
  # filter(ba > .25 & ab > 1000) %>%
  arrange(desc(ba))

#' You can find a good explanation of this problem at 
#' http://varianceexplained.org/r/empirical_bayes_baseball/ and 
#' http://www.evanmiller.org/how-not-to-sort-by-average-rating.html.

# Useful Summary Functions ----------------

#' Just using means, counts, and sum can get you a long way, but R provides 
#' many other useful summary functions:
#' 
#' Measures of location ---------------
#' 
#' We’ve used mean(x), but median(x) is also useful. 
#' - The mean is the sum divided by the length; 
#' - The median is a value where 50% of x is above it, and 50% is below it.
#' 
#' It’s sometimes useful to combine aggregation with logical subsetting. 
#' We haven’t talked about this sort of subsetting yet, but you’ll learn more 
#' about it in subsetting.

not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(
    #average delay:
    avg_delay = mean(arr_delay),
    med_delay = median(arr_delay),
    #average postitive delay:
    avg_delay_2 = mean(arr_delay[arr_delay > 0]),
    med_delay_2 = median(arr_delay[arr_delay >0])
  )
# 365 x 5 (x 7 with medians included)

# Measures of spread ----------------

#' Measures of spread: sd(x), IQR(x), mad(x). 
#' The mean squared deviation, or standard deviation or sd for short, is the standard measure of spread. 
#' The interquartile range IQR() and median absolute deviation mad(x) are robust equivalents that may be 
#' more useful if you have outliers.

# Why is distance to some destinations more variable than to others?
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(distance_sd = sd(distance)) %>% 
  arrange(desc(distance_sd))
#104 x 2

# Measures of rank: min(x), quantile(x, 0.25), max(x).---------------

#' Quantiles are a generalisation of the median. 
#' For example, quantile(x, 0.25) will find a value of x that is greater than 25% of the values, 
#' and less than the remaining 75%.

# When do the first and last flights leave each day?
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(
    first = min(dep_time),
    last = max(dep_time)
  )

# Measures of position: first(x), nth(x, 2), last(x). ---------------- 

# These work similarly to x[1], x[2], and x[length(x)] but let you set a default value if 
# that position does not exist (i.e. you’re trying to get the 3rd element from a group that 
# only has two elements). For example, we can find the first and last departure for each day:

not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarize(
    first_dep = first(dep_time), 
    last_dep = last(dep_time)
  )

#' These functions are complementary to filtering on ranks. 
#' Filtering gives you all variables, with each observation in a separate row:

not_cancelled %>% 
  group_by(year, month, day) %>% 
  mutate(r = min_rank(desc(dep_time))) %>% 
  filter(r %in% range(r))

# Counts ---------------

#' Counts: You’ve seen n(), which takes no arguments, and returns the size of the current group. 
#' To count the number of non-missing values, use sum(!is.na(x)). 
#' To count the number of distinct (unique) values, use n_distinct(x).

# Which destinations have the most carriers?
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(carriers = n_distinct(carrier)) %>% 
  arrange(desc(carriers))

# Counts are so useful that dplyr provides a simple helper if all you want is a count:

not_cancelled %>% 
  count(dest)

#' You can optionally provide a weight variable. 
#' For example, you could use this to “count” (sum) the total number of miles a plane flew:

not_cancelled %>% 
  count(tailnum, wt = distance)

# Counts and proportions of logical values: ------ 

#' sum(x > 10), mean(y == 0). 
#' When used with numeric functions, TRUE is converted to 1 and FALSE to 0. 
#' This makes sum() and mean() very useful: sum(x) gives the number of TRUEs in x, 
#' and mean(x) gives the proportion.

# How many flights left before 5am? (these usually indicate delayed
# flights from the previous day)
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(n_early = sum(dep_time < 500))

# What proportion of flights are delayed by more than an hour?
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(hour_perc = mean(arr_delay > 60))

# Grouping by Multiple Variables -----

#' When you group by multiple variables, each summary peels off one level of the grouping. 
#' That makes it easy to progressively roll up a dataset:

daily <- group_by(flights, year, month, day)

(per_day <- summarise(daily, flights = n()))

(per_month <- summarise(per_day, flights = sum(flights)))

(per_year  <- summarise(per_month, flights = sum(flights)))

#' Be careful when progressively rolling up summaries: 
#' it’s OK for sums and counts, but you need to think about weighting means and variances, 
#' and it’s not possible to do it exactly for rank-based statistics like the median. 
#' In other words, the sum of groupwise sums is the overall sum, but the median of groupwise 
#' medians is not the overall median.

# Ungrouping -----

# If you need to remove grouping, and return to operations on ungrouped data, use ungroup().

daily %>% 
  ungroup() %>%             # no longer grouped by date
  summarise(flights = n())  # all flights

# Exercises ---  ----

#' Brainstorm at least 5 different ways to assess the typical delay characteristics of a group of flights. 
#' Consider the following scenarios:

#  A flight is 15 minutes early 50% of the time, and 15 minutes late 50% of the time.
#' This would use mean().
#' Use flights. Then group by flight. Then summarize by mean as a proportion.

# First, just a prototype against some logical numbers:

not_cancelled %>%
  group_by(flight, carrier)%>%
  summarize(
    n = n(),
    n_early_15 = sum(arr_delay <= -15),
    n_late_15  = sum(arr_delay >= 15)
    )

# Next, the real deal:
# Limit to at least 20 flights to remove small samples
# Group by carrier, flight and destination to eliminate overlapping designations.
# Flights which arrived more than 15 minutes or more early 50% of the time, OR 15 minutes or more late 50% of the time.
# (No flights averaged both.)

not_cancelled %>%
  group_by(carrier, flight, dest)%>%
  summarize(
    n = n(),
    pct_early_15 = mean(arr_delay <= -15),
    pct_late_15  = mean(arr_delay >= 15)
  ) %>%
  filter(n >= 20, pct_early_15 >= .5 | pct_late_15 >= .5)

# A flight is always 10 minutes late.

not_cancelled %>%
  group_by(carrier, flight, dest)%>%
  summarize(
    n = n(),
    pct_late_10 = mean(arr_delay >= 10)
  ) %>%
  filter(n >= 5, pct_late_10 == 1)

# A flight is 30 minutes early 50% of the time, and 30 minutes late 50% of the time.

not_cancelled %>%
  group_by(carrier, flight, dest)%>%
  summarize(
    n = n(),
    pct_early_30 = mean(arr_delay <= -30),
    pct_late_30 = mean(arr_delay >= 30)
  ) %>%
  filter(n >= 5, pct_early_30 >= .3, pct_late_30 >= .3)

# 99% of the time a flight is on time. 1% of the time it’s 2 hours late.

# Solve
not_cancelled %>%
  group_by(carrier, flight, dest) %>%
  summarize(
    n = n(),
    on_time   = mean(arr_delay <= 0),
    late_2hrs = mean(arr_delay >= 120)
  ) %>%
  filter(n >20, on_time >= .99 | late_2hrs >= .01)

# Explore/check:
flight_2901_9E <- not_cancelled %>%
  filter(carrier =='9E', flight == 2901) %>%
  arrange(desc(arr_delay))
View(flight_2901_9E)
# Yes, 3 out of 55 flights were more than 2 hours late = 5.45%

# Which is more important: arrival delay or departure delay?

#' 2. Come up with another approach that will give you the same output as 
#'    not_cancelled %>% count(dest) and not_cancelled %>% count(tailnum, wt = distance) 
#'    (without using count()).

not_cancelled %>% 
  count(dest)

not_cancelled %>%
  group_by(dest) %>%
  summarize(n = n())

not_cancelled %>% 
  count(tailnum, wt = distance)

not_cancelled %>%
  group_by(tailnum) %>%
  summarize(n = sum(distance))

#' 3. Our definition of cancelled flights (is.na(dep_delay) | is.na(arr_delay) ) is slightly suboptimal. 
#'    Why? Which is the most important column?
#'    
#'    Answer: NA's for dep_delay and dep_time are both the same (8255), whereas arr_time (8713) and 
#'    arr_delay (9430) likely include missing data that was simply not recorded, or even flights that departed
#'    and failed to arrive dur to crashes or other extenuating circumstances.  
#'    Alternately, for analysis we might want to exlude the arrival na's in cases where they become contagious. 

summary(flights)

# alternate way to count na's by column.
# https://sebastiansauer.github.io/sum-isna/
flights %>%
  select(everything()) %>%
  summarize_all(funs(sum(is.na(.))))

# 4. Look at the number of cancelled flights per day. Is there a pattern?
#    Is the proportion of cancelled flights related to the average delay?
#    
#    Answer: Yes, there is a pattern. On a typical day in 2013, the number of flights
#    cancelled was less than .5% and the average dpearture delay was less than
#    15 minutes. 
#    
#    However, on both typical days and atypical days, as the percentage of 
#    cancellations increases, so does the average delay. This trend holds up to
#    25% cancellations, whereafter the number of observations
#    becomes exceedingly smaller. 
#    
#    After 25% cancellations on a given day, one might assume only flights
#    which are not affected extraordinary circumstances are permitted to fly, and therefore
#    are not impacted by excessive delay. 

flights %>%
  group_by(year, month, day) %>%
  summarize(num_flights = n(),
            num_cancelled = sum(is.na(dep_delay)),
            pct_cancelled = mean(is.na(dep_delay)),
            avg_delay     = mean(dep_delay, na.rm = TRUE)
            ) %>%
  ggplot(mapping = aes(x = pct_cancelled * 100, y = avg_delay)) +
  geom_point(aes(alpha = 1/20))+
  geom_smooth(se = FALSE)

# So, which days had an inordinate number of cancellations, more than 50%?
flights %>%
  group_by(year, month, day) %>%
  summarize(num_flights = n(),
            num_cancelled = sum(is.na(dep_delay)),
            pct_cancelled = mean(is.na(dep_delay)),
            avg_delay     = mean(dep_delay, na.rm = TRUE)
            ) %>%
  filter(pct_cancelled > .5)
# February 8th and 9th, 2013
# What was in the news?
# Blizzard in the northeast US
# https://www.theguardian.com/world/2013/feb/08/4000-flights-cancelled-snow-us


# 5. Which carrier has the worst delays?
#    Challenge: can you disentangle the effects of bad airports vs. bad carriers? 
#    Why/why not? (Hint: think about flights %>% group_by(carrier, dest) %>% summarise(n()))

not_cancelled %>%
  group_by(carrier) %>%
  summarize(
    avg_dep_delay = mean(dep_delay),
    avg_arr_delay = mean(arr_delay)
  ) %>%
  arrange(desc(avg_arr_delay))
# Carrier F9 has the worst average arrival delay, being 21.92 minutes
# plot
plot.data <- not_cancelled %>%
  group_by(carrier) %>%
  summarize(
    avg_dep_delay = mean(dep_delay),
    avg_arr_delay = mean(arr_delay)
    )
ggplot(plot.data) +
  geom_col(mapping = aes(x = carrier, y = avg_arr_delay))

# effects of bad airports vs. bad carriers
# we already know carrier F9 has the worst average arrival delay

# which combination of carrier and destination has the worst average arrival delay?
not_cancelled %>%
  group_by(carrier, dest) %>%
  summarize(
    num_flights = n(),
    avg_arr_delay_per_dest = mean(arr_delay)
  ) %>%
  arrange(desc(avg_arr_delay_per_dest))
# UA into STL, but only 2 flights. let's look at sample of 20 or more flights
not_cancelled %>%
  group_by(carrier, dest) %>%
  summarize(
    num_flights = n(),
    avg_arr_delay_per_dest = mean(arr_delay)
  ) %>%
  arrange(desc(avg_arr_delay_per_dest)) %>%
  filter(num_flights >= 20)
# EV into CAE tops the list. In fact carrier EV holds the 6 of the top 7 spots.
# F9 shows up at number 9 into DEN.

# which airport has the worst average arrival delay?
not_cancelled %>%
  group_by(dest) %>%
  summarize(
    num_flights = n(),
    avg_arr_delay_at_dest = mean(arr_delay)
  ) %>%
  arrange(desc(avg_arr_delay_at_dest))
# Indeed CAE has the worst average arrival delay of any destination

# So what might be causing F9 to top the list of carriers with the worst average arrival delay?
not_cancelled %>%
  group_by(carrier, dest) %>%
  summarize(
    num_flights = n(),
    avg_arr_delay_per_dest = mean(arr_delay)
  ) %>%
  arrange(desc(avg_arr_delay_per_dest)) %>%
  filter(carrier == 'F9')
# F9 only flies into DEN
# What about carrier EV?
not_cancelled %>%
  group_by(carrier, dest) %>%
  summarize(
    num_flights = n(),
    avg_arr_delay_per_dest = mean(arr_delay)
  ) %>%
  arrange(desc(avg_arr_delay_per_dest)) %>%
  filter(carrier == 'EV')
# EV flies into many destinations where their avg arrival delay is relative very high, however
# it also flies into 51 more destinations. As yet, we have not compared the delays weighted against
# number of flights, but let's plot EV's delays per destination.

not_cancelled %>% 
  group_by(carrier, dest) %>%
  summarize(
    num_flights = n(),
    avg_arr_delay_per_dest = mean(arr_delay)
  ) %>%
  filter(carrier == 'EV') %>%
  ggplot(mapping = aes(x = dest, y = avg_arr_delay_per_dest)) +
  geom_col() +
  coord_flip()
# Plot shows most of carrier EV's average arrival delays into its 61 destinations are 20 minutes or less.
# While it has a relatively high average arrival delay as a carrier, and it also holds many top spots 
# for carrier-destination combo's, EV's overall average arrival delay is tempered by the fact it has 61 diverse
# destinations.

# 6. What does the sort argument to count() do. When might you use it?
# sort - if TRUE will sort output in descending order of n

not_cancelled %>%
  count(dest, sort = TRUE)

# easier than

not_cancelled %>%
  group_by(dest) %>%
  summarize(n =n()) %>%
  arrange(desc(n))

#just for grins
not_cancelled %>%
  group_by(dest)%>%
  summarize(
    n = n(),
    max_arr_delay = max(arr_delay)
    )%>%
  arrange(desc(max_arr_delay))
  
# Grouped Mutates and Filters ----

# Grouping is most useful in conjunction with summarise(), but you can also do convenient 
# operations with mutate() and filter():

# Find the worst members of each group:

flights_sml %>% 
  group_by(year, month, day) %>% 
  filter(rank(desc(arr_delay)) < 10)

# Find all groups bigger than a threshold:

popular_dests <- flights %>% 
  group_by(dest) %>% 
  filter(n() > 365)
popular_dests

# Standardize to compute per group metrics:

popular_dests %>% 
  filter(arr_delay > 0) %>% 
  mutate(prop_delay = arr_delay / sum(arr_delay)) %>% 
  select(year:day, dest, arr_delay, prop_delay)


