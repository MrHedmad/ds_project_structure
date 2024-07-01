from pathlib import Path

discovery_dir = "/tmp/test"
input_file = Path("test.json")

with input_file.open("r+") as stream:
    data = json.load(stream)

