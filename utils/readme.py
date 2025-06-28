from pathlib import Path

GITHUB_USER = "opentargets"
GITHUB_REPO = "notebooks"
GITHUB_BRANCH = "main"

notebooks_dir = Path("examples")
notebooks = sorted(notebooks_dir.glob("*.ipynb"))

with open("README.md", "w") as f:
    f.write("<!-- Automatically generated README. Use utils/readme.py to modify it. -->\n\n")
    f.write("# Open Targets Notebooks\n\n")
    f.write(
        "This repository contains Notebooks demonstrating how to use the Open Targets Data and pipelines.\n\n"
    )
    f.write("| Notebook | Google Colab | Binder |\n")
    f.write("|---|---|---|\n")
    for nb in notebooks:
        nb_name = nb.name
        nb_path = f"examples/{nb_name}"
        colab_url = (
            f"https://colab.research.google.com/github/"
            f"{GITHUB_USER}/{GITHUB_REPO}/blob/{GITHUB_BRANCH}/{nb_path}"
        )
        binder_url = (
            f"https://mybinder.org/v2/gh/"
            f"{GITHUB_USER}/{GITHUB_REPO}/{GITHUB_BRANCH}"
            f"?filepath={nb_path}"
        )
        f.write(
            f"| [{nb_name}]({nb_path}) "
            f"| [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)]({colab_url}) "
            f"| [![Open In Binder](https://mybinder.org/badge_logo.svg)]({binder_url}) |\n"
        )