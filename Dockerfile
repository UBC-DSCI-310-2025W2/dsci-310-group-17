FROM --platform=linux/amd64 rocker/verse:4.5.2

WORKDIR /home/rstudio/project

RUN Rscript -e "install.packages(c('docopt', 'tidytuesdayR', 'caret', 'tidymodels'), repos = 'https://packagemanager.posit.co/cran/__linux__/jammy/2026-03-07')"

COPY . .
