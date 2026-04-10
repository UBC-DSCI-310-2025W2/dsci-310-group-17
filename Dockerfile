FROM rocker/rstudio:4.5.2

ENV RENV_PATHS_LIBRARY=/home/rstudio/renv-library \
    RENV_CONFIG_CACHE_ENABLED=FALSE

RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libpng-dev \
    libtiff-dev \
    libjpeg-dev \
    libwebp-dev \
    zlib1g-dev \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-plain-generic \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/rstudio/project

COPY renv.lock .Rprofile ./
COPY renv/activate.R renv/activate.R

RUN Rscript -e "install.packages('renv', repos = 'https://packagemanager.posit.co/cran/2026-03-28')" && \
    Rscript -e "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/jammy/2026-03-28')); renv::restore()"

COPY . .

RUN chown -R rstudio:rstudio /home/rstudio/project && \
    chown -R rstudio:rstudio /home/rstudio/renv-library