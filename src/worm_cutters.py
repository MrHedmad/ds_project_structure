from pathlib import Path
import os
from sys import stderr

discovery_dir = Path("/tmp/test")

def pprint(*args, **kwargs):
    print(*args, **kwargs, file=stderr)

all_paths = []

tot = 0
for dir in os.listdir(discovery_dir):
    pprint(f"Looking into {dir}...")
    if not (target := discovery_dir / dir / "project").exists():
        pprint(f"Rejected {dir} for not containing the 'project' folder")
    tot += 1
    for root, dirs, files in os.walk(target):
        root = Path(root[len(str(target)):])
        for dir in dirs:
            all_paths.append((root / dir, "directory"))
        for file in files:
            all_paths.append((root / file, "file"))

pprint(f"Processed a total of {tot} project templates")
counts = {}
for path, _type in all_paths:
    if path not in counts:
        counts[path] = {"count": 1, "types": {_type}}
        continue
    counts[path]["count"] += 1
    counts[path]["types"].add(_type)

print("path,count,types")
for key, value in counts.items():
    print(f'"{key}","{value['count']}","{','.join(value["types"])}"')

