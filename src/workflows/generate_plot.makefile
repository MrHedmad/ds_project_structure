
data/out/plot.pdf: data/in/repos.tar.gz
	mkdir -p data/repos
	tar -xf $< -C data
	python3 src/worm_cutters.py > data/results.csv
	mkdir -p data/out
	# This ALSO picks up automatically the results.csv file - so sorry
	Rscript --vanilla src/plot_results.R
