# slumbR: Sleep Diaries Helper Package for R

A companion package for the [Sleep Diaries
app](https://sleepdiaries.circadia-lab.uk). Provides tools to import
participant JSON exports, compute standard sleep variables, re-score
validated sleep questionnaires, and assemble tidy study-level data
frames ready for downstream analysis.

## Details

### Core workflow

    library(slumbR)

    # 1. Read one participant's export
    p <- read_export("path/to/participant.json")

    # 2. Read a whole study folder
    study <- read_study("path/to/exports/")

    # 3. Access tidy diary data
    study$diary     # long-format data frame, one row per entry
    study$wide      # one row per participant per night (morning + evening merged)
    study$scores    # questionnaire scores, one row per participant per instrument

    # 4. Re-score a questionnaire manually
    score_questionnaire("ess", answers = list(ess1 = 2, ess2 = 1, ...))

## See also

Useful links:

- <https://github.com/circadia-bio/slumbR>

- Report bugs at <https://github.com/circadia-bio/slumbR/issues>

## Author

**Maintainer**: Lucas França <lucas.franca@northumbria.ac.uk>
([ORCID](https://orcid.org/0000-0003-0853-1319))

Authors:

- Mario Leocadio-Miguel ([ORCID](https://orcid.org/0000-0002-7248-3529))
