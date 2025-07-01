from pathlib import Path

GITHUB_USER = "opentargets"
GITHUB_REPO = "notebooks"
GITHUB_BRANCH = "main"

notebooks_dir = Path("notebooks")
notebooks = sorted(notebooks_dir.glob("*.ipynb"))
# read README.template.md file
readme_template = Path("assets/README.template.md").read_text()

def get_table(notebooks: list[Path]) -> str:
    """Generate a markdown table for notebooks with links to Google Colab and Binder.
    Args:
        notebooks (list[Path]): List of notebook paths.
    Returns:
        str: Markdown table as a string.
    """
    output = []
    output.append("| Notebook | Google Colab |")
    output.append("|---|---|")
    for nb in notebooks:
        nb_name = nb.name
        nb_path = f"notebooks/{nb_name}"
        colab_url = (
            f"https://colab.research.google.com/github/"
            f"{GITHUB_USER}/{GITHUB_REPO}/blob/{GITHUB_BRANCH}/{nb_path}"
        )
        output.append(
            f"| [{nb_name}]({nb_path}) "
            f"| [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)]({colab_url}) |"
        )
    return "\n".join(output)

with open("README.md", "w") as f:
    # print template
    f.write("<!-- Automatically generated README. Use utils/readme.py to modify it. -->\n\n")
    f.write(readme_template)
    f.write("\n\n")
    f.write(get_table(notebooks))