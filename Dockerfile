FROM rocker/r-ver:4.5.2

ENV RENV_PATHS_LIBRARY=/project/renv-library \
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
    libzmq3-dev \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-plain-generic \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir jupyter --break-system-packages

# Install IRkernel before renv::restore() so renv does not intercept it
RUN R -e "install.packages(c('IRkernel'), repos = 'https://cloud.r-project.org')" && \
    R -e "IRkernel::installspec(user = FALSE)"

WORKDIR /project

COPY renv.lock .Rprofile ./
COPY renv/activate.R renv/activate.R

RUN Rscript -e "install.packages('renv', repos = 'https://packagemanager.posit.co/cran/2026-03-28')" && \
    Rscript -e "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/jammy/2026-03-28')); renv::restore()"

COPY . .

EXPOSE 8888

CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", \
     "--NotebookApp.token=", "--NotebookApp.password="]
