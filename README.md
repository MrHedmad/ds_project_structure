# Data Science Project Structure exploration
An exploration of the different data science project structures around GitHub.

## Prerequisites
- Install Kerblam! (https://kerblam.dev)
- Install Docker (https://docker.com)

## Launching the analysis
This analysis is managed by Kerblam! (see https://kerblam.dev).
Clone the repository, and move inside its root.
Then, choose wether to reproduce our earlier work or start from scratch.

### From pregenerated data
You can fetch the pregenerated and deposited data, and then run the analysis to reproduce our earlier work:
```bash
kerblam data fetch
kerblam run make_plot
```
You should obtain the same data as it was deposited, especially the `data/out/plot.pdf` plot.

### From scratch
You will need to manually repopulate the `data_cookies.json` and `data_generic.json` files.
This can only be done locally as you need to be logged in with the GitHub CLI.
You will need to install the GitHub CLI itself first: install GitHub CLI (https://cli.github.com/) and login with `gh auth login`.

Then, simply run:
```bash
kerblam run find_repos
```
This fetches a new set of repositories. Then, the analysis will be run on the new data.
You can run the rest of the analysis with:
```bash
kerblam run make_plot
```

This downloads the new repos, enumerates them, and produces the output plot.
