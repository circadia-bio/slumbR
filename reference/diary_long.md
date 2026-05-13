# Extract the long-format diary data frame from a study or export

A convenience accessor that returns the `diary` data frame from a
`slumbr_study` or `slumbr_export` object. For a plain data frame it is
returned unchanged.

## Usage

``` r
diary_long(x)

# S3 method for class 'slumbr_study'
diary_long(x)

# S3 method for class 'slumbr_export'
diary_long(x)

# S3 method for class 'data.frame'
diary_long(x)
```

## Arguments

- x:

  A `slumbr_study`, `slumbr_export`, or plain data frame.

## Value

A data frame with one row per diary entry.

## Details

The long-format frame has **one row per diary entry** (morning or
evening). Morning rows carry sleep timing and quality variables; evening
rows carry daytime behaviour variables. Most analyses will want
[`diary_wide()`](https://slumbr.circadia-lab.uk/reference/diary_wide.md)
to merge them into one row per night.
