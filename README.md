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
kerblam run generate_plot
```
You should obtain the same data as it was deposited, especially the `data/out/plot.pdf` plot.

Otherwise, to use a pre-built container, grab a Kerblam replay package from
[the releases tab](https://github.com/MrHedmad/ds_project_structure/releases)
and run `kerblam run <path to the release tarball>`.

### From scratch
You will need to manually repopulate the `data_cookies.json` and `data_generic.json` files.
This can only be done locally as you need to be logged in with the GitHub CLI.
You will need to install the GitHub CLI itself first (https://cli.github.com/) and login with `gh auth login`.

Then, simply run:
```bash
kerblam run find_repos
```
This fetches a new set of repositories. Then, the analysis can be run on the new data.
You can run the rest of the analysis with:
```bash
kerblam run run_analysis
```

This downloads the new repos, enumerates them, and produces the output plot.
