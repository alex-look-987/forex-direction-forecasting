import json
import subprocess
from pathlib import Path


def pair_notebooks():
    for notebook in Path("notebooks").rglob("*.ipynb"):
        with open(notebook, encoding="utf-8") as f:
            data = json.load(f)

        metadata = data.get("metadata", {})
        jupytext_metadata = metadata.get("jupytext")

        if not jupytext_metadata:
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
