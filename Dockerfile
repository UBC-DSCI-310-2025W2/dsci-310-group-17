ARG TARGETPLATFORM=linux/amd64
FROM --platform=$TARGETPLATFORM rocker/r-ver:4.4.2
WORKDIR /project

# System dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    libglpk-dev \
    libzmq3-dev \
    build-essential \
    wget \
    git \
    python3-pip \
    pandoc \
    cmake \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Jupyter
RUN pip3 install jupyterlab==4.3.4 --break-system-packages

# Install Quarto
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.9.36/quarto-1.9.36-linux-amd64.deb \
    && dpkg -i quarto-1.9.36-linux-amd64.deb \
    && rm quarto-1.9.36-linux-amd64.deb

# Install TinyTeX for PDF rendering
RUN quarto install tinytex --no-prompt

# Install R packages and register IRkernel
# knitr and rmarkdown are required by Quarto to render .qmd files
RUN R -e "install.packages(c('renv', 'IRkernel', 'knitr', 'rmarkdown'), repos='https://cloud.r-project.org'); IRkernel::installspec(user=FALSE)"

# Copy renv lockfile and restore packages
COPY renv.lock .
COPY renv/ renv/
COPY .Rprofile* .
RUN R -e "renv::restore(prompt=FALSE)"

COPY notebooks/billboard_number_one_prediction.ipynb /project/notebooks/
COPY data/ /project/data/

EXPOSE 8888
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--no-browser", "--allow-root", "--NotebookApp.token=", "--NotebookApp.password="]