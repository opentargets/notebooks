<!-- Automatically generated README. Use utils/readme.py to modify it. -->

<!-- Automatically generated README. Use utils/readme.py to modify it. -->

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

| Notebook | Google Colab |
|---|---|
| [autoimmune_colocalisations.ipynb](notebooks/autoimmune_colocalisations.ipynb) | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/opentargets/notebooks/blob/main/notebooks/autoimmune_colocalisations.ipynb) |
| [autoimmune_credible_set.ipynb](notebooks/autoimmune_credible_set.ipynb) | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/opentargets/notebooks/blob/main/notebooks/autoimmune_credible_set.ipynb) |
| [exploring_ot_datasets.ipynb](notebooks/exploring_ot_datasets.ipynb) | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/opentargets/notebooks/blob/main/notebooks/exploring_ot_datasets.ipynb) |


## Testing

This project includes automated tests for all notebooks.

### Local tests

```bash
# Install dependencies including test extras
uv sync --all-extras

# Run all notebook tests
./scripts/run_notebook_test.sh

# Run specific notebook test
./scripts/run_notebook_test.sh autoimmune_colocalisations
```

Remote regular testing is also implemented within GCP. More information in `./scripts/setup_gcp.sh`.
