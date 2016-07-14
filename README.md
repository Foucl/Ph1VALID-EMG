# Ph1VALID-EMG

Analysis pipeline and results/reports for experiment ph1valid





## Additional necessary resources

### raw data

EMG and Facet raw and preprocessed data is not stored in this repository, but in an [Amazon S3 bucket](https://console.aws.amazon.com/s3/home?bucket=ph1valid&prefix=data&region=eu-central-1) (login as described in the [main README](../README.md)). Choose 'abdd' as account/Konto, DDmitarbeiter as user name and the usual password.

You can also get the raw data from the ABDD-Server (Mitarbeiter/Christopher/O:\Mitarbeiter/Christopher/Data_ValidExp/EMG\_raw).

### Fieldtrip toolbox

The EMG pipeline works fine with any current [fieldtrip](http://www.fieldtriptoolbox.org/) version. Reading the FACET data (in order to read that data as an additional 'channel') requires [this fork](https://github.com/foucl/fieldtrip) of fieldtrip. Using this fork also makes sure that the results here can be reproduced exactly.

## Project Organization

    ├── LICENSE
    ├── Makefile           <- Makefile with commands like `make data` or `make train`
    ├── README.md          <- The top-level README for developers using this project.
    ├── data
    │   ├── external       <- Data from third party sources.
    │   ├── interim        <- Intermediate data that has been transformed.
    │   ├── processed      <- The final, canonical data sets for modeling.
    │   └── raw            <- The original, immutable data dump.
    │
    ├── docs               <- A default Sphinx project; see sphinx-doc.org for details
    │
    ├── models             <- Trained and serialized models, model predictions, or model summaries
    │
    ├── notebooks          <- Jupyter notebooks. Naming convention is a number (for ordering),
    │                         the creator's initials, and a short `-` delimited description, e.g.
    │                         `1.0-jqp-initial-data-exploration`.
    │
    ├── references         <- Data dictionaries, manuals, and all other explanatory materials.
    │
    ├── reports            <- Generated analysis as HTML, PDF, LaTeX, etc.
    │   └── figures        <- Generated graphics and figures to be used in reporting
    │
    ├── requirements.txt   <- The requirements file for reproducing the analysis environment, e.g.
    │                         generated with `pip freeze > requirements.txt`
    │
    ├── src                <- Source code for use in this project.
    │   ├── __init__.py    <- Makes src a Python module
    │   │
    │   ├── data           <- Scripts to download or generate data
    │   │   └── make_dataset.py
    │   │
    │   ├── features       <- Scripts to turn raw data into features for modeling
    │   │   └── build_features.py
    │   │
    │   ├── models         <- Scripts to train models and then use trained models to make
    │   │   │                 predictions
    │   │   ├── predict_model.py
    │   │   └── train_model.py
    │   │
    │   └── visualization  <- Scripts to create exploratory and results oriented visualizations
    │       └── visualize.py
    │
    └── tox.ini            <- tox file with settings for running tox; see tox.testrun.org
