# Chapter 21 - R Markdown ----
# 
# *** Introduction *** ----
# 
# R Markdown provides an unified authoring framework for data science, combining your code, 
# its results, and your prose commentary. R Markdown documents are fully reproducible and 
# support dozens of output formats, like PDFs, Word files, slideshows, and more.
# 
# R Markdown files are designed to be used in three ways:

# - For communicating to decision makers, who want to focus on the conclusions, 
#   not the code behind the analysis.
# 
# - For collaborating with other data scientists (including future you!), who are interested in 
#   both your conclusions, and how you reached them (i.e. the code).
# 
# - As an environment in which to do data science, as a modern day lab notebook where you can capture 
#   not only what you did, but also what you were thinking.
#   
# R Markdown integrates a number of R packages and external tools. This means that help is, by-and-large, 
# not available through ?. Instead, as you work through this chapter, and use R Markdown in the future, 
# keep these resources close to hand:

# - R Markdown Cheat Sheet: Help > Cheatsheets > R Markdown Cheat Sheet,
# 
# - R Markdown Reference Guide: Help > Cheatsheets > R Markdown Reference Guide.
# 
# Both cheatsheets are also available at http://rstudio.com/cheatsheets.
# 
# _Prerequisites ----
# 
# You need the rmarkdown package, but you don’t need to explicitly install it or load it, 
# as RStudio automatically does both when needed.
# 
# *** R Markdown basics *** ----
# 
# This is an R Markdown file, a plain text file that has the extension .Rmd:

---
title: "Diamond sizes"
date: 2016-08-25
output: html_document
---

```{r setup, include = FALSE}
library(ggplot2)
library(dplyr)

smaller <- diamonds %>% 
  filter(carat <= 2.5)
```

We have data about `r nrow(diamonds)` diamonds. Only 
`r nrow(diamonds) - nrow(smaller)` are larger than
2.5 carats. The distribution of the remainder is shown
below:

```{r, echo = FALSE}
smaller %>% 
  ggplot(aes(carat)) + 
  geom_freqpoly(binwidth = 0.01)
```
# 