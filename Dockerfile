FROM --platform=linux/amd64 rocker/verse:4.5.2

WORKDIR /home/rstudio/project

COPY renv.lock .Rprofile ./
COPY renv/activate.R renv/activate.R

RUN chown -R rstudio:rstudio /home/rstudio/project && \
    mkdir -p /home/rstudio/renv-library && \
    chown -R rstudio:rstudio /home/rstudio/renv-library

ENV RENV_PATHS_LIBRARY=/home/rstudio/renv-library

USER rstudio

RUN Rscript -e "install.packages('renv', repos = 'https://packagemanager.posit.co/cran/2026-03-07')" && \
    Rscript -e "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/jammy/2026-03-07')); renv::restore()"

USER root

COPY . .