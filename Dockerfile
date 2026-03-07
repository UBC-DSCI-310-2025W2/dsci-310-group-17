FROM rocker/verse:4.5.2

WORKDIR /home/rstudio/project

COPY renv.lock renv/activate.R .Rprofile ./

RUN Rscript -e "install.packages('renv', repos = 'https://packagemanager.posit.co/cran/2026-03-07')" && \
    Rscript -e "renv::restore()"

COPY . .