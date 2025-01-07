
data/out/plot.pdf: data/in/repos.tar.gz
	mkdir -p data/repos
	tar -xf $< -C data
	python3 src/worm_cutters.py > data/results.csv
	mkdir -p data/out
	# This ALSO picks up automatically the results.csv file - so sorry
	Rscript --vanilla src/plot_results.R

data/data_cookies.json:
	gh search repos cookiecutter data --sort stars --json stargazersCount,url --visibility public -L 50 > ./data/data_cookies.json

data/data_generic.json:
	gh search repos research project template --sort stars --json stargazersCount,url --visibility public -L 50 > ./data/data_generic.json

data/data.json: data/data_generic.json data/data_cookies.json
	jq -s '.[0] + .[1]' data/data_cookies.json data/data_generic.json > data/data.json

data/in/repos.tar.gz: data/data.json
	mkdir -p data/repos
	# This automatically picks up the data.json data - I was lazy
	python3 src/fetch_cookiecutter.py
	tar -czvf $@ -C data repos
	rm -rf data/repos

