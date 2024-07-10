import json
from pathlib import Path
from shutil import copytree, rmtree
import os

from cookiecutter.main import cookiecutter
from cookiecutter.exceptions import RepositoryNotFound
from git import Repo

input_file = Path("data/data.json")

with input_file.open("r+") as stream:
    data = json.load(stream)

base_extra_content = {
    "project_name": "project",
    "project_directory": "project",
    "project_slug": "project",
    "repo_name": "project",
}

for item in data:
    url = item["url"]

    print(f"Cutting {url}...")

    out_dir = f"data/repos/{url.split('/')[-1]}"
    
    try:
        cookiecutter(
            url,
            no_input=True,
            output_dir=out_dir,
            extra_context=base_extra_content,
            accept_hooks=False,
            overwrite_if_exists=True,
            checkout="v1" if item['url'] == "https://github.com/drivendataorg/cookiecutter-data-science" else None
        )
        # This has created a "project" directory (hopefully), which we need
        # to extract in order to be shallow.
        if (target := Path(out_dir) / "project").exists():
            print(f"INFO: Extracting content of {target}...")
            temp = target.parent / "tempstash"
            os.mkdir(temp)
            copytree(target, temp, dirs_exist_ok=True)
            rmtree(target)
            copytree(temp, target.parent, dirs_exist_ok=True)
            rmtree(temp)
    except RepositoryNotFound as e:
        print(f"WARN: Repository {url} is not a valid cookiecutter. Downloading raw template")
        try:
            Repo.clone_from(item['url'], out_dir)
        except Exception as e:
            print(f"ERROR: {type(e)} - {e}")
    except Exception as e:
        print(f"ERROR: {type(e)} - {e}")

