# docker/Dockerfile

FROM continuumio/miniconda3

# Set working directory inside container
WORKDIR /project

# Copy environment file
COPY environment.yml .

# Create Conda environment from yml
RUN conda env create -f environment.yml

# Set environment activation for following commands
SHELL ["conda", "run", "-n", "bioinf_proj", "/bin/bash", "-c"]

# Install additional R packages (CRAN + GitHub + Bioconductor)
RUN R -e "install.packages(c('ggrepel', 'future', 'VennDiagram', 'grDevices', 'venn', 'SeuratObject', 'SeuratDisk'), repos='https://cloud.r-project.org')"
RUN R -e "remotes::install_github('chris-mcginnis-ucsf/DoubletFinder')"
RUN R -e "remotes::install_github('immunogenomics/harmony')"
RUN R -e "if (!requireNamespace('BiocManager', quietly = TRUE)) install.packages('BiocManager')"
RUN R -e "BiocManager::install(c('CellChat', 'multinichenetr'), ask = FALSE, update = FALSE)"

# Install JupyterLab + R kernel
RUN pip install jupyterlab
RUN R -e "IRkernel::installspec(user = FALSE)"

# Install RStudio Server
RUN apt-get update && apt-get install -y \
    gdebi-core \
    libssl-dev \
    libcurl4-gnutls-dev \
    libxml2-dev \
    wget \
    fonts-dejavu \
    && wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2023.06.2-561-amd64.deb \
    && gdebi -n rstudio-server-2023.06.2-561-amd64.deb \
    && rm rstudio-server-2023.06.2-561-amd64.deb

# Default command
CMD ["/bin/bash"]

