FROM --platform=linux/amd64 rocker/verse:4.5.2

WORKDIR /home/rstudio/project

RUN Rscript -e "install.packages('renv', repos = 'https://packagemanager.posit.co/cran/2026-03-07')" && \
    Rscript -e "install.packages(c('tidytuesdayR', 'caret', 'tidymodels'), repos = 'https://packagemanager.posit.co/cran/__linux__/jammy/2026-03-07')" && \
    Rscript -e "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/jammy/2026-03-07'));

COPY . .
