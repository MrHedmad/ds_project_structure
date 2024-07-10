#? Create the output plot
set -e
gh search repos cookiecutter data --sort stars --json stargazersCount,url --visibility public -L 50 > ./data/data_cookies.json
gh search repos research project template --sort stars --json stargazersCount,url --visibility public -L 50 > ./data/data_generic.json

jq -s '.[0] + .[1]' data/data_cookies.json data/data_generic.json > data/data.json

mkdir -p data/repos
python src/fetch_cookiecutter.py
python src/worm_cutters.py > data/results.csv
mkdir -p data/out
Rscript --vanilla src/plot_results.R
