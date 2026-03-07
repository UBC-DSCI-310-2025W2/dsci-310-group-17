FROM rocker/verse:4.5.2

WORKDIR /home/rstudio/project

COPY renv.lock renv/activate.R .Rprofile ./

RUN Rscript -e "install.packages('renv', repos = 'https://packagemanager.posit.co/cran/latest')" && \
    Rscript -e "renv::restore()"

COPY . .