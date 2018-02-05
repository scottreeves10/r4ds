Chapter 8 - Data Import with readr2
================
2018-02-03

Introduction
------------

Working with data provided by R packages is a great way to learn the tools of data science, but at some point you want to stop learning and start working with your own data. In this chapter, you'll learn how to read plain-text rectangular files into R. Here, we'll only scratch the surface of data import, but many of the principles will translate to other forms of data. We'll finish with a few pointers to packages that are useful for other types of data.

### Prerequisites

In this chapter, you'll learn how to load flat files in R with the **readr** package, which is part of the core tidyverse.

``` r
library(tidyverse)
```

Getting started
---------------

Most of readr's functions are concerned with turning flat files into data frames:

#### read\_csv(), read\_csv2(), read\_tsv(), read\_delim()

-   `read_csv()` reads comma delimited files, `read_csv2()` reads semicolon separated files (common in countries where `,` is used as the decimal place), `read_tsv()` reads tab delimited files, and `read_delim()` reads in files with any delimiter.

#### read\_fwf(), fwf\_widths(), fwf\_positions(), read\_table()

-   `read_fwf()` reads fixed width files. You can specify fields either by their widths with `fwf_widths()` or their position with `fwf_positions()`. `read_table()` reads a common variation of fixed width files where columns are separated by white space.

#### read\_log()

-   `read_log()` reads Apache style log files. (But also check out [webreadr](https://github.com/Ironholds/webreadr) which is built on top of `read_log()` and provides many more helpful tools.)

These functions all have similar syntax: once you've mastered one, you can use the others with ease. For the rest of this chapter we'll focus on `read_csv()`. Not only are csv files one of the most common forms of data storage, but once you understand `read_csv()`, you can easily apply your knowledge to all the other functions in readr.

The first argument to `read_csv()` is the most important: it's the path to the file to read.

``` r
heights <- read_csv("data/heights.csv")
```

When you run `read_csv()` it prints out a column specification that gives the name and type of each column. That's an important part of readr, which we'll come back to in \[parsing a file\].

You can also supply an inline csv file. This is useful for experimenting with readr and for creating reproducible examples to share with others:

#### inline csv file

``` r
read_csv("a,b,c
1,2,3
4,5,6")
```

    #> # A tibble: 2 x 3
    #>       a     b     c
    #>   <int> <int> <int>
    #> 1     1     2     3
    #> 2     4     5     6

In both cases `read_csv()` uses the first line of the data for the column names, which is a very common convention. There are two cases where you might want to tweak this behaviour:

#### skip = n, comment = "\#"

1.  Sometimes there are a few lines of metadata at the top of the file. You can use `skip = n` to skip the first `n` lines; or use `comment = "#"` to drop all lines that start with (e.g.) `#`.

    ``` r
    read_csv("The first line of metadata
      The second line of metadata
      x,y,z
      1,2,3", skip = 2)
    ```

        #> # A tibble: 1 x 3
        #>       x     y     z
        #>   <int> <int> <int>
        #> 1     1     2     3

    ``` r
    read_csv("# A comment I want to skip
      x,y,z
      1,2,3", comment = "#")
    ```

        #> # A tibble: 1 x 3
        #>       x     y     z
        #>   <int> <int> <int>
        #> 1     1     2     3

2.  The data might not have column names. You can use `col_names = FALSE` to tell `read_csv()` not to treat the first row as headings, and instead label them sequentially from `X1` to `Xn`:

#### col\_names = FALSE

    ```r
    read_csv("1,2,3\n4,5,6", col_names = FALSE)
    ```

    ```
    #> # A tibble: 2 x 3
    #>      X1    X2    X3
    #>   <int> <int> <int>
    #> 1     1     2     3
    #> 2     4     5     6
    ```

(`"\n"` is a convenient shortcut for adding a new line. You'll learn more about it and other types of string escape in \[string basics\].)

Alternatively you can pass `col_names` a character vector which will be used as the column names:

    ```r
    read_csv("1,2,3\n4,5,6", col_names = c("x", "y", "z"))
    ```

    ```
    #> # A tibble: 2 x 3
    #>       x     y     z
    #>   <int> <int> <int>
    #> 1     1     2     3
    #> 2     4     5     6
    ```

Another option that commonly needs tweaking is `na`: this specifies the value (or values) that are used to represent missing values in your file:

``` r
read_csv("a,b,c\n1,2,.", na = ".")
```

    #> # A tibble: 1 x 3
    #>       a     b     c
    #>   <int> <int> <chr>
    #> 1     1     2  <NA>

This is all you need to know to read ~75% of CSV files that you'll encounter in practice. You can also easily adapt what you've learned to read tab separated files with `read_tsv()` and fixed width files with `read_fwf()`. To read in more challenging files, you'll need to learn more about how readr parses each column, turning them into R vectors.

### Compared to base R

If you've used R before, you might wonder why we're not using `read.csv()`. There are a few good reasons to favour readr functions over the base equivalents:

-   They are typically much faster (~10x) than their base equivalents. Long running jobs have a progress bar, so you can see what's happening. If you're looking for raw speed, try `data.table::fread()`. It doesn't fit quite so well into the tidyverse, but it can be quite a bit faster.

-   They produce tibbles, they don't convert character vectors to factors, use row names, or munge the column names. These are common sources of frustration with the base R functions.

-   They are more reproducible. Base R functions inherit some behaviour from your operating system and environment variables, so import code that works on your computer might not work on someone else's.

### Exercises

1.  What function would you use to read a file where fields were separated with
    "|"?

    ``` r
    read_delim()
    ```

2.  Apart from `file`, `skip`, and `comment`, what other arguments do `read_csv()` and `read_tsv()` have in common?

    They both have the same arguments, the others being: col\_types, locale, na, quoted\_na, quote, trim\_ws, n\_max, guess\_max, progress

    ``` r
    union(names(formals(read_csv)), names(formals(read_tsv)))
    ```

        #>  [1] "file"      "col_names" "col_types" "locale"    "na"       
        #>  [6] "quoted_na" "quote"     "comment"   "trim_ws"   "skip"     
        #> [11] "n_max"     "guess_max" "progress"

3.  What are the most important arguments to `read_fwf()`? Read a fixed width file into a tibble.

    The most important arguments are Column positions, as created by `fwf_empty()`, `fwf_widths()` or `fwf_positions()`.

4.  Sometimes strings in a CSV file contain commas. To prevent them from causing problems they need to be surrounded by a quoting character, like `"` or `'`. By convention, `read_csv()` assumes that the quoting character will be `"`, and if you want to change it you'll need to use `read_delim()` instead. What arguments do you need to specify to read the following text into a data frame?

    ``` r
    "x,y\n1,'a,b'"
    ```

    You need to specify `quote = "'"` in:

    ``` r
    read_delim("x,y\n1,'a,b'", delim = ",", quote = "'")
    ```

        #> # A tibble: 1 x 2
        #>       x     y
        #>   <int> <chr>
        #> 1     1   a,b

    or

    ``` r
    read_csv("x,y\n1,'a,b'", quote = "'")
    ```

        #> # A tibble: 1 x 2
        #>       x     y
        #>   <int> <chr>
        #> 1     1   a,b

5.  Identify what is wrong with each of the following inline CSV files. What happens when you run the code?

    ``` r
    read_csv("a,b\n1,2,3\n4,5,6")
    read_csv("a,b,c\n1,2\n1,2,3,4")
    read_csv("a,b\n\"1")
    read_csv("a,b\n1,2\na,b")
    read_csv("a;b\n1;3")
    ```

    ``` r
    read_csv("a,b\n1,2,3\n4,5,6")      # only two columns
    ```

        #> Warning: 2 parsing failures.
        #> row # A tibble: 2 x 5 col     row   col  expected    actual         file expected   <int> <chr>     <chr>     <chr>        <chr> actual 1     1  <NA> 2 columns 3 columns literal data file 2     2  <NA> 2 columns 3 columns literal data

        #> # A tibble: 2 x 2
        #>       a     b
        #>   <int> <int>
        #> 1     1     2
        #> 2     4     5

    ``` r
    read_csv("a,b,c\n1,2\n1,2,3,4") #(1, 3) is missing and (1, 4) is truncated
    ```

        #> Warning: 2 parsing failures.
        #> row # A tibble: 2 x 5 col     row   col  expected    actual         file expected   <int> <chr>     <chr>     <chr>        <chr> actual 1     1  <NA> 3 columns 2 columns literal data file 2     2  <NA> 3 columns 4 columns literal data

        #> # A tibble: 2 x 3
        #>       a     b     c
        #>   <int> <int> <int>
        #> 1     1     2    NA
        #> 2     1     2     3

    ``` r
    read_csv("a,b\n\"1") # inline csv file input contains misplaced quote
    ```

        #> Warning: 2 parsing failures.
        #> row # A tibble: 2 x 5 col     row   col                     expected    actual         file expected   <int> <chr>                        <chr>     <chr>        <chr> actual 1     1     a closing quote at end of file           literal data file 2     1  <NA>                    2 columns 1 columns literal data

        #> # A tibble: 1 x 2
        #>       a     b
        #>   <int> <chr>
        #> 1     1  <NA>

    ``` r
    read_csv("a,b\n1,2\na,b") # mismatched types
    ```

        #> # A tibble: 2 x 2
        #>       a     b
        #>   <chr> <chr>
        #> 1     1     2
        #> 2     a     b

    ``` r
    read_csv("a;b\n1;3") # should use read_csv2() for semi-colon delims
    ```

        #> # A tibble: 1 x 1
        #>   `a;b`
        #>   <chr>
        #> 1   1;3

Parsing a vector
----------------

Before we get into the details of how readr reads files from disk, we need to take a little detour to talk about the `parse_*()` functions. These functions take a **character vector** and return a more specialised vector like a logical, integer, or date:

#### parse\_logical(), parse\_integer(), parse\_date()

``` r
str(parse_logical(c("TRUE", "FALSE", "NA")))
```

    #>  logi [1:3] TRUE FALSE NA

``` r
str(parse_integer(c("1", "2", "3")))
```

    #>  int [1:3] 1 2 3

``` r
str(parse_date(c("2010-01-01", "1979-10-14")))
```

    #>  Date[1:2], format: "2010-01-01" "1979-10-14"

These functions are useful in their own right, but are also an important building block for readr. Once you've learned how the individual parsers work in this section, we'll circle back and see how they fit together to parse a complete file in the next section.

Like all functions in the tidyverse, the `parse_*()` functions are uniform: the first argument is a character vector to parse, and the `na` argument specifies which strings should be treated as missing:

``` r
parse_integer(c("1", "231", ".", "456"), na = ".")
```

    #> [1]   1 231  NA 456

If parsing fails, you'll get a warning:

``` r
x <- parse_integer(c("123", "345", "abc", "123.45"))
```

    #> Warning in rbind(names(probs), probs_f): number of columns of result is not
    #> a multiple of vector length (arg 1)

    #> Warning: 2 parsing failures.
    #> row # A tibble: 2 x 4 col     row   col               expected actual expected   <int> <int>                  <chr>  <chr> actual 1     3    NA             an integer    abc row 2     4    NA no trailing characters    .45

And the failures will be missing in the output:

``` r
x
```

    #> [1] 123 345  NA  NA
    #> attr(,"problems")
    #> # A tibble: 2 x 4
    #>     row   col               expected actual
    #>   <int> <int>                  <chr>  <chr>
    #> 1     3    NA             an integer    abc
    #> 2     4    NA no trailing characters    .45

If there are many parsing failures, you'll need to use `problems()` to get the complete set. This returns a tibble, which you can then manipulate with dplyr.

#### problems()

``` r
problems(x)
```

    #> # A tibble: 2 x 4
    #>     row   col               expected actual
    #>   <int> <int>                  <chr>  <chr>
    #> 1     3    NA             an integer    abc
    #> 2     4    NA no trailing characters    .45
