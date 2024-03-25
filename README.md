## INSTALL NCBI Entrez Direct E-Utilities conda environment.

# Create the entrez direct conda environment.
conda create --name entrez_direct_env

# Activate the entrez direct conda environment.
conda activate entrez_direct_env

# Install the the entrez direct conda package.
conda install -c bioconda entrez-direct


## Usage

# Execute the script.
sh download_ncbi_genomes.sh  

