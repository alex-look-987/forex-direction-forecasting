import subprocess
from pathlib import Path


def pair_and_sync_notebooks():
    for notebook in Path("notebooks").rglob("*.ipynb"):
        subprocess.run(
            [
                "uv",
                "run",
                "jupytext",
                "--set-formats",
                "ipynb,py:percent",
                str(notebook),
            ],
            check=True,
        )

        subprocess.run(
            [
                "uv",
                "run",
                "jupytext",
                "--sync",
                str(notebook),
            ],
            check=True,
        )


if __name__ == "__main__":
    pair_and_sync_notebooks()
