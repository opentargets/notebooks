"""Pytest configuration for notebook tests."""
import os
from pathlib import Path

import pytest


@pytest.fixture(scope="session")
def notebooks_dir():
    """Return the path to the notebooks directory."""
    return Path(__file__).parent.parent / "notebooks"


@pytest.fixture(scope="session")
def output_dir(tmp_path_factory):
    """Create a temporary directory for test outputs."""
    return tmp_path_factory.mktemp("notebook_outputs")


def pytest_configure(config):
    """Configure pytest with custom markers."""
    config.addinivalue_line(
        "markers", "notebook: mark test as a notebook execution test"
    )

