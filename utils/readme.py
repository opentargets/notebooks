from pathlib import Path

GITHUB_USER = "opentargets"
GITHUB_REPO = "notebooks"
GITHUB_BRANCH = "main"

notebooks_dir = Path("notebooks")
notebooks = sorted(notebooks_dir.glob("*.ipynb"))

with open("README.md", "w") as f:
    f.write("<!-- Automatically generated README. Use utils/readme.py to modify it. -->\n\n")
    f.write("# Open Targets Notebooks\n\n")

    f.write("## How to start\n\n")
    f.write("To run the notebooks, you can use one of the following options:\n\n")
    f.write("- [![Open in Dev Containers](https://img.shields.io/static/v1?label=Dev%20Containers&message=Open&color=blue)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/opentargets/notebooks) (recommended)\n")
    f.write("- Open in Google Colab\n")
    f.write("- Open in Binder\n")
    f.write("You can also run the notebooks locally by cloning the repository and installing the required dependencies.\n")
    f.write("\n\n")
    f.write("| Notebook | Google Colab | Binder |\n")
    f.write("|---|---|---|\n")
    for nb in notebooks:
        nb_name = nb.name
        nb_path = f"notebooks/{nb_name}"
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
    
    f.write("## Dependencies (local):\n")
    f.write("- Java 11\n")
    f.write("- Python 3.12 or later\n")
    f.write("- uv")