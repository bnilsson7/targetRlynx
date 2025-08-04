
# targetRlynx

`targetRlynx` is an R package for parsing summary `.txt` files exported
from TargetLynx, commonly used in LCMS workflows. It reads files and
finds headers, extracts analyte blocks, and produces a clean data frame
suitable for further analysis.

GitHub Repository:
[bnilsson7/targetRlynx](https://github.com/bnilsson7/targetRlynx)

------------------------------------------------------------------------

## Installation

``` r
# Install from GitHub
remotes::install_github("bnilsson7/targetRlynx")
```

------------------------------------------------------------------------

## Example Usage

``` r
library(targetRlynx)

# Path to sample data
example_path <- system.file("extdata", "example_data_lynx_summary.txt", package = "targetRlynx")

# Parse single file
parsed <- processRlynx(example_path)
```

------------------------------------------------------------------------

## Before & After Parsing

### Raw File Preview (First 10 lines)

``` r
raw_lines <- readLines(example_path, warn = FALSE)
clean_lines <- iconv(raw_lines[1:10], from = "", to = "UTF-8", sub = "byte?")
cat(paste(clean_lines, collapse = "\n"))
```

    ## Quantify Compound Summary Report 
    ## 
    ## Printed Thu Jun 26 09:08:13 2025
    ## 
    ## Amphetamine
    ## 
    ##  #   Name    ID  Sample Text Type    RT  Area    IS Area Response    Primary Flags   Std. Conc   Conc.   %Dev    RRT R.T. Tolerance Flag Vial    S/N 1byte? Ratio Flag   1byte? Ratio (Pred) 1byte? Ratio (Actual)   Quantify Reference
    ## 1    1   20250619_101    SST     Recovery    2.22    2850834 3462660 0.823   bb  0.000   68.5        1.00    NO  V:2 1593.802    NO  0.695   0.679   
    ## 2    2   20250619_102    SST     Recovery    2.22    2992703 3545423 0.844   bb  0.000   70.2        1.00    NO  V:2 2022.577    NO  0.695   0.702   
    ## 3    3   20250619_103    CAL1        Standard    2.22    1315076 1038413 1.266   bb  100 106 5.6 1.00    NO  6:1,A   1060.196    NO  0.695   0.697   

### Parsed Output (First 10 rows)

``` r
print(parsed[1:10, c(3,7:10)])
```

    ##            Name   RT     Area IS.Area Response
    ## 1  20250619_101 2.22  2850834 3462660    0.823
    ## 2  20250619_102 2.22  2992703 3545423    0.844
    ## 3  20250619_103 2.22  1315076 1038413    1.266
    ## 4  20250619_104 2.22  2625691 1062010    2.472
    ## 5  20250619_105 2.22  9353513  853856   10.954
    ## 6  20250619_106 2.21 16782084  595485   28.182
    ## 7  20250619_107 2.22    22401 1113866    0.020
    ## 8  20250619_108   NA       NA 1044998       NA
    ## 9  20250619_109   NA       NA 1082198       NA
    ## 10 20250619_110   NA       NA 1057882       NA

------------------------------------------------------------------------

## Batch Parsing

``` r
# Parse all .txt files in a folder
results <- processRlynx("path/to/folder/")
```

------------------------------------------------------------------------

## Functions

- `parse_one_file(path)`: Parses a single `.txt` file  
- `processRlynx(path)`: Parses one or many `.txt` files from a file or
  folder

Each row includes: - Cleaned numeric columns - Analyte label - Source
file name

------------------------------------------------------------------------

## Citation

If you use this package in publications:

    Nilsson, B. (2025). targetRlynx: Summary File Parser for TargetLynx. R package. https://github.com/bnilsson7/targetRlynx

------------------------------------------------------------------------

## License

MIT © B. Nilsson
