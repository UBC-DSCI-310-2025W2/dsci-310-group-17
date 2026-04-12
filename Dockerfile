FROM rocker/r-ver:4.5.2

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
    python3-pip \
    wget \
    gdebi-core \
    && rm -rf /var/lib/apt/lists/*

RUN ARCH=$(dpkg --print-architecture) && \
    wget -qO /tmp/quarto.deb "https://github.com/quarto-dev/quarto-cli/releases/download/v1.6.43/quarto-1.6.43-linux-${ARCH}.deb" && \
    gdebi --non-interactive /tmp/quarto.deb && \
    rm /tmp/quarto.deb

RUN quarto install tinytex --no-prompt

RUN pip3 install --no-cache-dir jupyter --break-system-packages

RUN R -e "install.packages('IRkernel', repos = 'https://cloud.r-project.org')" && \
    R -e "IRkernel::installspec(user = FALSE)"

ENV RENV_PATHS_LIBRARY=/renv-library
ENV RENV_CONFIG_CACHE_ENABLED=FALSE

WORKDIR /project

COPY renv.lock .Rprofile ./
COPY renv/activate.R renv/activate.R

RUN Rscript -e "install.packages('renv', repos = 'https://packagemanager.posit.co/cran/2026-03-28')" && \
    Rscript -e "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/jammy/2026-03-28')); renv::restore()"

COPY . .

EXPOSE 8888

CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", \
     "--NotebookApp.token=", "--NotebookApp.password="]
      