gh search repos cookiecutter data --sort stars --json stargazersCount,url --visibility public -L 50 > data/data_cookies.json
gh search repos research project template --sort stars --json stargazersCount,url --visibility public -L 50 > data/data_generic.json
