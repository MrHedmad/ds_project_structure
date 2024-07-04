import json
from pathlib import Path

from cookiecutter.main import cookiecutter

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
    
    try:
        cookiecutter(
            url,
            no_input=True,
            output_dir=f"data/repos/{url.split('/')[-1]}",
            extra_context=base_extra_content,
            accept_hooks=False,
            overwrite_if_exists=True,
            checkout="v1" if item['url'] == "https://github.com/drivendataorg/cookiecutter-data-science" else None
        )
    except Exception as e:
        print(f"ERROR: {e}")

