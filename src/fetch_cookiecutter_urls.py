import json
from sys import stderr, stdout

import requests as rq
from bs4 import BeautifulSoup


def pprint(*args, **kwargs):
    print(*args, **kwargs, file=stderr)

base_url = "https://github.com/search?q=cookiecutter+data&type=repositories&s=stars&o=desc&p={page}"
res = []

i = 1
while True:
    url = base_url.format(page = i)

    pprint(f"Checking url {url}...")

    response = rq.get(url)
    soup = BeautifulSoup(response.content, "html.parser")

    stuff = json.loads(str(soup))

    for item in stuff["payload"]["results"]:
        repo = item["repo"]["repository"]
        res.append(
            {
                "url": f"https://github.com/{repo['owner_login']}/{repo['name']}",
                "stars": item['followers'],
                "topics": ", ".join(item["topics"])
            }
        )

    if res[-1]["stars"] < 5:
        break

    i += 1

res = [x for x in res if x["stars"] >= 5]

json.dump({"results": res}, stdout)

