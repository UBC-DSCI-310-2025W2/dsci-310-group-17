FROM rocker/rstudio:4.5.2

WORKDIR /home/rstudio/project

COPY renv.lock renv.lock
COPY renv/activate.R renv/activate.R
COPY .Rprofile .Rprofile

RUN Rscript -e "install.packages('renv', repos = 'https://packagemanager.posit.co/cran/latest')"
RUN Rscript -e "renv::restore()"

COPY . .
