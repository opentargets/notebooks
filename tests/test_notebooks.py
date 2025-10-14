"""Smoke tests for Open Targets notebooks.

This module uses papermill to execute notebooks and validate that they run
without errors. These are smoke tests designed to catch basic execution issues.
"""
import logging
from pathlib import Path

import papermill as pm
import pytest

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def get_notebooks():
    """
    Dynamically discover all Jupyter notebooks in the notebooks directory.
    
    Returns:
        list: List of notebook filenames (not full paths, just names)
    """
    notebooks_dir = Path(__file__).parent.parent / "notebooks"
    
    # Find all .ipynb files, excluding checkpoint directories
    notebooks = [
        nb.name for nb in sorted(notebooks_dir.glob("*.ipynb"))
        if ".ipynb_checkpoints" not in str(nb)
    ]
    
    if not notebooks:
        logger.warning(f"No notebooks found in {notebooks_dir}")
    else:
        logger.info(f"Discovered {len(notebooks)} notebooks: {notebooks}")
    
    return notebooks


# Dynamically get list of notebooks to test
NOTEBOOKS = get_notebooks()


@pytest.mark.notebook
@pytest.mark.parametrize("notebook_name", NOTEBOOKS)
def test_notebook_execution(notebook_name, notebooks_dir, output_dir):
    """
    Execute a notebook and verify it completes without errors.
    
    This is a smoke test that runs the full notebook with all computations.
    The test will fail if any cell raises an exception.
    
    Args:
        notebook_name: Name of the notebook file to test
        notebooks_dir: Path to the notebooks directory (from fixture)
        output_dir: Path to store output notebooks (from fixture)
    """
    notebook_path = notebooks_dir / notebook_name
    output_path = output_dir / f"output_{notebook_name}"
    
    logger.info(f"Testing notebook: {notebook_name}")
    logger.info(f"Input path: {notebook_path}")
    logger.info(f"Output path: {output_path}")
    
    # Verify notebook exists
    assert notebook_path.exists(), f"Notebook not found: {notebook_path}"
    
    try:
        # Execute the notebook using papermill
        pm.execute_notebook(
            input_path=str(notebook_path),
            output_path=str(output_path),
            parameters={},  # No parameters for now (full execution)
            kernel_name="python3",
            progress_bar=False,
            log_output=True,
            cwd=str(notebooks_dir),  # Set working directory to notebooks dir
        )
        logger.info(f"✓ Notebook {notebook_name} executed successfully")
        
    except pm.PapermillExecutionError as e:
        logger.error(f"✗ Notebook {notebook_name} failed to execute")
        logger.error(f"Error: {e}")
        pytest.fail(f"Notebook execution failed: {e}")
    
    except Exception as e:
        logger.error(f"✗ Unexpected error in {notebook_name}")
        logger.error(f"Error: {e}")
        pytest.fail(f"Unexpected error during notebook execution: {e}")


def test_notebooks_discovered(notebooks_dir):
    """Verify that notebooks were discovered in the notebooks directory."""
    discovered_notebooks = list(notebooks_dir.glob("*.ipynb"))
    
    # Filter out checkpoint files
    discovered_notebooks = [
        nb for nb in discovered_notebooks
        if ".ipynb_checkpoints" not in str(nb)
    ]
    
    assert len(discovered_notebooks) > 0, (
        f"No notebooks found in {notebooks_dir}. "
        "Please ensure the notebooks directory contains .ipynb files."
    )
    
    logger.info(f"✓ Discovered {len(discovered_notebooks)} notebooks in {notebooks_dir}")

