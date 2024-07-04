#? Create the output plot
set -e
gh search repos cookiecutter data --sort stars --json stargazersCount,url --visibility public -L 50 > ./data/data.json

mkdir -p data/repos
python src/fetch_cookiecutter.py
python src/worm_cutters.py > data/results.csv
mkdir -p data/out
Rscript --vanilla src/plot_results.R
