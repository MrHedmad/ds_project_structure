FROM rocker/tidyverse:4.4

# Install required Python and R packages
RUN Rscript --vanilla -e "install.packages(c('igraph', 'ggraph', 'ggnewscale', 'extrafont', 'showtext', 'sysfonts'), repos='https://cloud.r-project.org')"
RUN apt update && apt install python3 python3-cookiecutter python3-git -y;

# Install the other tools that we need
RUN apt install jq -y

COPY . .
