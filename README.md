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

## Testing

This project includes automated smoke tests for all notebooks.

### Run Tests Locally

```bash
# Install dependencies including test extras
uv sync --all-extras

# Run all notebook tests
./scripts/run_notebook_test.sh

# Run specific notebook test
./scripts/run_notebook_test.sh autoimmune_colocalisations
```

### Run Tests with Docker

```bash
# Build the test image
docker build --target test -t notebooks-test .

# Run all notebook tests
docker run --rm notebooks-test

# Run specific notebook test
docker run --rm notebooks-test uv run pytest tests/test_notebooks.py -v -k autoimmune_colocalisations

# Run with custom pytest options
docker run --rm notebooks-test uv run pytest tests/ -v --tb=short
```


## Notebooks

| Notebook | Google Colab |
|---|---|
| [autoimmune_colocalisations.ipynb](notebooks/autoimmune_colocalisations.ipynb) | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/opentargets/notebooks/blob/main/notebooks/autoimmune_colocalisations.ipynb) |
| [autoimmune_credible_set.ipynb](notebooks/autoimmune_credible_set.ipynb) | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/opentargets/notebooks/blob/main/notebooks/autoimmune_credible_set.ipynb) |
| [exploring_ot_datasets.ipynb](notebooks/exploring_ot_datasets.ipynb) | [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/opentargets/notebooks/blob/main/notebooks/exploring_ot_datasets.ipynb) |