# docker/Dockerfile

FROM continuumio/miniconda3

ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /project

# Copy the environment file
COPY environment.yml .

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    unzip \
    bzip2 \
    libssl-dev \
    libcurl4-gnutls-dev \
    libxml2-dev \
    gdebi-core \
    fonts-dejavu \
    libxt6 \
    libxext6 \
    libxrender1 \
    && rm -rf /var/lib/apt/lists/*

# Copy and Install Cell Ranger 9.0.1
COPY docker/cellranger-9.0.1.tar /tmp/
RUN tar -xf /tmp/cellranger-9.0.1.tar -C /opt \
 && rm /tmp/cellranger-9.0.1.tar \
 && ln -s /opt/cellranger-9.0.1/cellranger /usr/local/bin/cellranger

# Copy and Install Space Ranger 3.1.3
COPY docker/spaceranger-3.1.3.tar /tmp/
RUN tar -xf /tmp/spaceranger-3.1.3.tar -C /opt \
 && rm /tmp/spaceranger-3.1.3.tar \
 && ln -s /opt/spaceranger-3.1.3/spaceranger /usr/local/bin/spaceranger

# Create conda environment
RUN conda env create -f environment.yml

# Install xtra OS dependencies required by RStudio Server .deb
RUN apt-get update && apt-get install -y \
    gdebi-core \
    wget \
    psmisc \
    libclang-dev \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# --- Install libssl1.1 (needed by the RStudio Server build) -------------------
ARG SNAPSHOT_CANDIDATES="20230201T000000Z 20221201T000000Z 20220615T000000Z"
RUN set -eux; \
  for d in $SNAPSHOT_CANDIDATES; do \
    echo "Trying Debian snapshot ${d} for libssl1.1"; \
    echo "deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/${d}/ bullseye main" > /etc/apt/sources.list.d/bullseye-snapshot.list; \
    if apt-get -o Acquire::Check-Valid-Until=false update; then \
      if apt-get install -y --no-install-recommends libssl1.1; then \
        rm -f /etc/apt/sources.list.d/bullseye-snapshot.list; \
        rm -rf /var/lib/apt/lists/*; \
        exit 0; \
      fi; \
    fi; \
  done; \
  echo "ERROR: Could not install libssl1.1 from any snapshot." >&2; \
  exit 1
# -------------------------------------------------------------------------------

# Install RStudio Server for ARM64
RUN wget https://s3.amazonaws.com/rstudio-ide-build/server/focal/arm64/rstudio-server-2025.05.0-496-arm64.deb \
    && gdebi -n rstudio-server-2025.05.0-496-arm64.deb \
    && rm rstudio-server-2025.05.0-496-arm64.deb

# Ensure subsequent RUNs use the conda env's R/Python
SHELL ["conda", "run", "-n", "bioinf_proj", "/bin/bash", "-c"]

# Install R packages from CRAN
RUN R -e "install.packages(c('ggrepel', 'future', 'VennDiagram', 'grDevices', 'venn', 'SeuratObject', 'SeuratDisk'), repos='https://cloud.r-project.org')"

# Install packages from GitHub
RUN R -e "remotes::install_github('chris-mcginnis-ucsf/DoubletFinder')"
RUN R -e "remotes::install_github('immunogenomics/harmony')"

# Install Bioconductor packages
RUN R -e "if (!requireNamespace('BiocManager', quietly = TRUE)) install.packages('BiocManager', repos='https://cloud.r-project.org')"
RUN R -e "BiocManager::install(c('CellChat', 'multinichenetr'), ask = FALSE, update = FALSE)"

# Install Jupyter and R kernel
RUN pip install jupyterlab
RUN R -e "install.packages('IRkernel', repos='https://cloud.r-project.org')"
RUN R -e "IRkernel::installspec(user = FALSE)"

# Set R path for RStudio Server
RUN echo "rsession-which-r=/opt/conda/envs/bioinf_proj/bin/R" > /etc/rstudio/rserver.conf

# Create default RStudio user
RUN useradd -m rstudio && echo "rstudio:bioinf123" | chpasswd

# For convenience inside the container
ENV PATH="/opt/conda/envs/bioinf_proj/bin:${PATH}"

# Expose default ports
EXPOSE 8787 8888

# Start both RStudio Server and JupyterLab when container launches
CMD ["bash", "-lc", "rstudio-server start && jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --NotebookApp.token='' --NotebookApp.password='' --notebook-dir=/project"]
