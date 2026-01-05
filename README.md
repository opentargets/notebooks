<p align="center">
    <img src="assets/platform_logo.png" alt="Open Targets Platform Logo" width="300"/>
</p>

## How to start

To run the notebooks, you can use one of the following options:

1. Self-contained environment (recommended)

[![Open in Dev Containers](https://img.shields.io/static/v1?label=Dev%20Containers&message=Open&color=blue)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/opentargets/notebooks)

2. Open in Google Colab (see table)
3. You can also run the notebooks locally by cloning the repository and installing the required dependencies.

## Local

For local development, the next dependencies are required:

- Java 11
- Python 3.12 or later
- [uv](https://docs.astral.sh/uv/)

## Notebooks

| Notebook                                                                       | Language | Framework        | Description                                                                                                                                    | Google Colab                                                                                                                                                                                      |
| ------------------------------------------------------------------------------ | -------- | ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [autoimmune_colocalisations.ipynb](notebooks/autoimmune_colocalisations.ipynb) | Python   | pyspark          | Extract colocalisations for GWAS credible sets associated with autoimmune diseases, including additional metadata about the studies.          | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/opentargets/notebooks/blob/main/notebooks/autoimmune_colocalisations.ipynb) |
| [autoimmune_credible_set.ipynb](notebooks/autoimmune_credible_set.ipynb)       | Python   | pyspark          | Extract GWAS credible sets associated with autoimmune diseases, including additional metadata about the studies and Locus-2-gene assignments. | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/opentargets/notebooks/blob/main/notebooks/autoimmune_credible_set.ipynb)    |
| [chembl_evidence_download.ipynb](notebooks/chembl_evidence_download.ipynb)   | Python   | pyspark          | Download ChEMBL evidence data from the Open Targets Platform using rsync. Includes drug-target associations and related evidence.            | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/opentargets/notebooks/blob/main/notebooks/chembl_evidence_download.ipynb)    |
| [exploring_ot_datasets.ipynb](notebooks/exploring_ot_datasets.ipynb)           | Python   | pyspark, polars  | Explore the Open Targets datasets available at Open Targets Data Downloads. Includes information on diseases, targets, evidence, and associations. | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/opentargets/notebooks/blob/main/notebooks/exploring_ot_datasets.ipynb)      |
| [reading_data_from_aws.ipynb](notebooks/reading_data_from_aws.ipynb)           | Python   | pandas, polars, pyspark | Access Open Targets Platform datasets hosted on AWS S3 using pandas, polars, and pyspark without downloading local copies.                  | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/opentargets/notebooks/blob/main/notebooks/reading_data_from_aws.ipynb)      |
