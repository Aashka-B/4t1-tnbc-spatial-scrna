# docker/Dockerfile

FROM continuumio/miniconda3

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
    libsm6 \
    libxrender1

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

# Install RStudio Server
RUN apt-get update && apt-get install -y gdebi-core \
    && wget https://download2.rstudio.org/server/focal/amd64/rstudio-server-2025.05.0-496-amd64.deb \
    && gdebi -n rstudio-server-2025.05.0-496-amd64.deb \
    && rm rstudio-server-2025.05.0-496-amd64.deb

# Set conda environment for all remaining RUN steps
SHELL ["conda", "run", "-n", "bioinf_proj", "/bin/bash", "-c"]

# Install R packages from CRAN
RUN R -e "install.packages(c('ggrepel', 'future', 'VennDiagram', 'grDevices', 'venn', 'SeuratObject', 'SeuratDisk'), repos='https://cloud.r-project.org')"

# Install from GitHub
RUN R -e "remotes::install_github('chris-mcginnis-ucsf/DoubletFinder')"
RUN R -e "remotes::install_github('immunogenomics/harmony')"

# Install Bioconductor packages
RUN R -e "if (!requireNamespace('BiocManager', quietly = TRUE)) install.packages('BiocManager', repos='https://cloud.r-project.org')"
RUN R -e "BiocManager::install(c('CellChat', 'multinichenetr'), ask = FALSE, update = FALSE)"

# Install Jupyter and R kernel
RUN pip install jupyterlab
RUN R -e "install.packages('IRkernel', repos='https://cloud.r-project.org')"
RUN R -e "IRkernel::installspec(user = FALSE)"

# Default to bash shell
CMD ["/bin/bash"]

