# Chapter 1 - Data Visualization with ggplot2 ----


# *** Introduction ----

# load tidyverse packages
# library(tidyverse)

# load ggplot2
library(ggplot2)

# *** First Steps ----

# The mpg Data Frame 
# (ggplot2::mpg)
# 234 observations x 11 variables, tibble data frame
# http://r4ds.had.co.nz/tibbles.html
mpg

#Creating a ggplot ----

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))

# *** Aesthetic Mappings -----

# Color ----
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = class))

# Color mapped to something other than a variable name
# TRUE / FALSE
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = displ < 5))

# Size ----
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, size = class))
# Warning message: Using size for a discrete variable is not advised. 

# Alpha ----
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, alpha = class))

# Shape ----
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, shape = class))

# Can set the aesthetic of the geom manually. 
# Does not convey information about variables.
# You’ll need to pick a value that makes sense for that aesthetic:
# - The name of a color as a character string.
# - The size of a point in mm.
# - The shape of a point as a number
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), color = "blue")

# *** Common Problems -----

#  - see book 

# *** Facets ----

# Single variable, use facet_wrap()

# The first argument of facet_wrap() should be a formula, 
# which you create with ~ followed by a variable name.
# The variable that you pass to facet_wrap() should be discrete.
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ class, nrow = 2)

# Two variables, use facet_grid()

# The first argument of facet_grid() is also a formula. 
# This time the formula should contain two variable names separated by a ~
# row ~ column
# If you prefer to not facet in the rows or columns dimension, 
# use a . instead of a variable name, e.g. + facet_grid(. ~ cyl)
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_grid(drv ~ cyl)

# *** Geometric objects ----

# A geom is the geometrical object that a plot uses to represent data

# point (scatter)
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))

# smooth
ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy))

# Every geom function in ggplot2 takes a mapping argument. 
# However, not every aesthetic works with every geom. 
# You could set the shape of a point, but you couldn’t set the “shape” of a line. 
# On the other hand, you could set the linetype of a line. 

# geom_smooth() will draw a different line, with a different linetype, for 
# each unique value of the variable that you map to linetype.

# linetype
ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv))

# ggplot2 provides over 30 geoms, and extension packages provide even more 
# (see http://www.ggplot2-exts.org for a sampling). 

# Many geoms, like geom_smooth(), 
# use a single geometric object to display multiple rows of data. 
ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy))

# For these geoms, you can set the group aesthetic to a categorical variable 
# to draw multiple objects. ggplot2 will draw a separate object for each unique 
# value of the grouping variable.
ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, group = drv))

# In practice, ggplot2 will automatically group the data for these 
# geoms whenever you map an aesthetic to a discrete variable (as in the linetype example). 
# It is convenient to rely on this feature because the group aesthetic by itself does not 
# add a legend or distinguishing features to the geoms.
ggplot(data = mpg) +
  geom_smooth(
    mapping = aes(x = displ, y = hwy, color = drv),
    show.legend = TRUE
  )

# To display multiple geoms in the same plot, add multiple geom functions to ggplot()
# Best to pass the mapping to ggplot() globally rather than to the geom objects, which 
# avoids duplicating the x-axis and y-axis arguments.
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth()

# If you place mappings in a geom function, 
# ggplot2 will treat them as local mappings for the layer.
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = class)) + 
  geom_smooth()

# You can use the same idea to specify different data for each layer.
# se - display confidence interval around smooth
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = class)) + 
  geom_smooth(data = filter(mpg, class == "subcompact"), se = FALSE)

# Exercises ----

# #2
ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) + 
  geom_point() + 
  geom_smooth(se = FALSE)

# #6
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point() +
  geom_smooth(se = FALSE)

# draws the same plot as below
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point() +
  geom_smooth(mapping = aes(group = drv), se = FALSE)

# draws the same plot as above
ggplot(data = mpg, mapping = aes(x = displ, y = hwy, group = drv)) +
  geom_point() +
  geom_smooth(se = FALSE)

ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  geom_smooth(se = FALSE)

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point(mapping = aes(color = drv)) +
  geom_smooth(se = FALSE)

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point(mapping = aes(color = drv)) +
  geom_smooth(mapping = aes(linetype = drv), se = FALSE)

# The key here is overlaying, in particular order,
# two separate geom's to draw the plot - 
# one with white borders (local), and the other with color fill (global)
ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) +
  geom_point(shape = 21, color = 'white', size = 4, stroke = 2) +
  geom_point(shape = 16, size = 4)
  

# *** Statistical Transformations ----

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut))

# Statistical transformations caculate new values and bin data:
# Bar charts, histograms, and frequency polygons bin your data and then plot bin counts, 
# the number of points that fall in each bin.

# You can learn which stat a geom uses by inspecting the default value for the stat argument.
?geom_bar

# Same effect as above
ggplot(data = diamonds) + 
  stat_count(mapping = aes(x = cut))

# Exercises ----

# #1
# geom_pointrange. the key here is to tell it to use stat "summary", 
# rather than the defaut stat "identity"
ggplot(data = diamonds, mapping = aes(x = cut, y = depth)) +
  geom_pointrange(
    stat = "summary",
    fun.ymin = min, 
    fun.ymax = max,
    fun.y = median
    )

ggplot(data = diamonds, mapping = aes(x = cut, y = depth)) +
  stat_summary(fun.ymin = min, 
               fun.ymax = max,
               fun.y = median)

#2
g <- ggplot(data = diamonds, mapping = aes(x = cut))              
g + geom_bar()
g + geom_col(aes(y = z))

# #5
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, y = ..prop.., group = 1))
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = color, y = ..prop..))

# *** Position Adjustments ----
# mostly useful for bar charts

# color aesthetic

# basically just puts a respective colored border around each bar
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, colour = cut))

# fill aesthetic

# fills each entire bar with respective colors
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = cut))

# if you map the fill aesthetic to another variable, like clarity, 
# the bars are automatically stacked such that  
# each colored rectangle represents a combination of cut and clarity.
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity))

# The stacking is performed automatically by the position adjustment specified 
# by the position argument. If you don’t want a stacked bar chart, you can use 
# one of three other options: 
# - "identity", 
# - "dodge" or 
# - "fill".

# position = "identity"

ggplot(data = diamonds, mapping = aes(x = cut, fill = clarity)) + 
  geom_bar(alpha = 1/5, position = "identity")

ggplot(data = diamonds, mapping = aes(x = cut, colour = clarity)) + 
  geom_bar(fill = NA, position = "identity")

# position = "fill" 

# works like stacking, but makes each set of stacked bars the same height. 
# This makes it easier to compare proportions across groups.
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "fill")

# position = "dodge" 

# places overlapping objects directly beside one another. 
# This makes it easier to compare individual values.
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "dodge")

# position = "jitter"

# Avoids overplotting
# Useful for scatter plots
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = class), position = "jitter")

# Because this is such a useful operation, ggplot2 comes with a shorthand 
# for geom_point(position = "jitter"): geom_jitter().

# Exercises ----

# 1. What is the problem with this plot? How could you improve it?
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_point()

# it is overplotted. induce jitter to reveal more observations.
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_jitter()

# 2. What parameters to geom_jitter() control the amount of jittering?
?geom_jitter
# width and height. defaults are 40% (.4)
ggplot(data = mpg, mapping = aes(x = cty, y = hwy, color = class)) + 
  geom_jitter(height = 1, width = 1)

# 3. Compare and contrast geom_jitter() with geom_count().

?geom_count

# Count overlapping points - This is a variant geom_point that counts 
# the number of observations at each location, then maps the count to point area. 
# It useful when you have discrete data and overplotting.

ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_count()

?geom_jitter

# Jittered points - The jitter geom is a convenient shortcut for geom_point(position = "jitter"). 
# It adds a small amount of random variation to the location of each point, 
# and is a useful way of handling overplotting caused by discreteness in smaller datasets.

# 4. What’s the default position adjustment for geom_boxplot()? 
# Create a visualisation of the mpg dataset that demonstrates it.

?geom_boxplot
# default position = "dodge"

ggplot(mpg, aes(class, hwy)) +
  geom_boxplot()

# *** Coordinate Systems ---------------

# coord_flip()

ggplot(data = mpg, mapping = aes(x = class, y = hwy)) + 
  geom_boxplot()

ggplot(data = mpg, mapping = aes(x = class, y = hwy)) + 
  geom_boxplot() +
  coord_flip()

# coord_quickmap() sets the aspect ratio correctly for maps.

# This is very important if you’re plotting spatial data with ggplot2

library(maps)

nz <- map_data("nz")

ggplot(nz, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", colour = "black")

ggplot(nz, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", colour = "black") +
  coord_quickmap()

# coord_polar() uses polar coordinates.

# Polar coordinates reveal an interesting connection between a bar chart and a Coxcomb chart.

bar <- ggplot(data = diamonds) + 
  geom_bar(
    mapping = aes(x = cut, fill = cut), 
    show.legend = FALSE,
    width = 1
  ) + 
  theme(aspect.ratio = 1) +
  labs(x = NULL, y = NULL)

bar + coord_flip()

bar + coord_polar()

# Exercises ----

# 1. Turn a stacked bar chart into a pie chart using coord_polar().

ggplot(data = mpg) +
  geom_bar(mapping = aes(manufacturer, fill = drv)) +
  coord_flip()

ggplot(data = mpg) +
  geom_bar(mapping = aes(manufacturer, fill = drv)) +
  coord_polar()

# 2. What does labs() do? Read the documentation.

?labs

# Modify axis, legend, and plot labels - xlab, ylab, ggtitle and subtitle, caption

# 3. What’s the difference between coord_quickmap() and coord_map()?

?coord_quickmap

?coord_map

# coord_map projects a portion of the earth...  is a quick approximation that does preserve 
# straight lines. It works best for smaller areas closer to the equator.

# 4. What does the plot below tell you about the relationship between city and highway mpg? 
# Why is coord_fixed() important? What does geom_abline() do?

ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
  geom_point() + 
  geom_abline() +
  coord_fixed()

?coord_fixed

# A fixed scale coordinate system forces a specified ratio between the physical representation 
# of data units on the axes. The ratio represents the number of units on the y-axis equivalent 
# to one unit on the x-axis. The default, ratio = 1, ensures that one unit on the x-axis is the 
# same length as one unit on the y-axis

?geom_abline

# Reference lines: horizontal, vertical, and diagonal
# These geoms add reference lines (sometimes called rules) to a plot, either horizontal, 
# vertical, or diagonal (specified by slope and intercept). These are useful for annotating plots.

# *** The layered grammar of graphics ----

# ggplot(data = <DATA>) + 
#   <GEOM_FUNCTION>(
#     mapping = aes(<MAPPINGS>),
#     stat = <STAT>, 
#     position = <POSITION>
#   ) +
#   <COORDINATE_FUNCTION> +
#   <FACET_FUNCTION>

ggplot(data = diamonds) + 
  geom_bar(
    mapping = aes(cut, fill = clarity),
    stat = "count", 
    position = "stack"
  ) +
  coord_polar() +
  facet_null()
