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

# Install Cell Ranger 7.2.0
RUN wget -qO- https://cf.10xgenomics.com/releases/cell-exp/cellranger-7.2.0.tar.gz | tar -xz -C /opt \
 && ln -s /opt/cellranger-7.2.0/cellranger /usr/local/bin/cellranger

# Install Space Ranger 2.1.1
RUN wget -qO- https://cf.10xgenomics.com/releases/spatial-exp/spaceranger-2.1.1.tar.gz | tar -xz -C /opt \
 && ln -s /opt/spaceranger-2.1.1/spaceranger /usr/local/bin/spaceranger

# Create conda environment
RUN conda env create -f environment.yml

# Set conda environment for all remaining RUN steps
SHELL ["conda", "run", "-n", "bioinf_proj", "/bin/bash", "-c"]

# Install R packages from CRAN
RUN R -e "install.packages(c('ggrepel', 'future', 'VennDiagram', 'grDevices', 'venn', 'SeuratObject', 'SeuratDisk'), repos='https://cloud.r-project.org')"

# Install from GitHub
RUN R -e "remotes::install_github('chris-mcginnis-ucsf/DoubletFinder')"
RUN R -e "remotes::install_github('immunogenomics/harmony')"

# Install Bioconductor packages
RUN R -e "if (!requireNamespace('BiocManager', quietly = TRUE)) install.packages('BiocManager')"
RUN R -e "BiocManager::install(c('CellChat', 'multinichenetr'), ask = FALSE, update = FALSE)"

# Install Jupyter and R kernel
RUN pip install jupyterlab
RUN R -e "IRkernel::installspec(user = FALSE)"

# Install RStudio Server
RUN wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2023.06.2-561-amd64.deb \
 && gdebi -n rstudio-server-2023.06.2-561-amd64.deb \
 && rm rstudio-server-2023.06.2-561-amd64.deb

# Default to bash shell
CMD ["/bin/bash"]

