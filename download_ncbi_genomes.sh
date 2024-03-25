#!/bin/bash

source ~/.bash_profile
#source ~/.bashrc

conda activate entrez_direct_env

# Exporting NCBI_API_KEY for use with edirect utilites.
export NCBI_API_KEY=9f29b62a5d8212263424327b94284d57a407

# The output directory to write metadata files and download genomes.
output_dir="/Users/kevin.muirhead/Desktop/AAFC_Bioinformatics/download_ncbi_genomes"

# The date of the refseq database was downloaded.
date=$(date +"%Y-%m-%d")

# Create the output directory if it does not exist.
mkdir -p $output_dir

# The genome metadata output file that is downloaded from NCBI edirect using a query.
genome_metadata_outfile="${output_dir}/ncbi_refseq_genome_metadata.tsv"

# The genome assembly output directory.
#genome_assembly_dir="${output_dir}/genome_assemblies"
#mkdir -p $genome_assembly_dir

# The genome database directory.
genome_database_dir="${output_dir}/refseq_genome_database"
mkdir -p $genome_database_dir

# Latest Genbank and RefSeq 43023.
##echo "esearch -db assembly -query '("Bacteria"[Organism] OR "Archaea"[Organism]) AND (latest[filter] AND "complete genome"[filter] AND all[filter] NOT anomalous[filter] AND "taxonomy check ok"[filter])' | esummary | xtract -pattern DocumentSummary -element  AssemblyAccession,Organism,Taxid,BioSampleAccn,AssemblyStatus,FtpPath_GenBank,FtpPath_RefSeq -group GB_BioProjects -block Bioproj -element BioprojectAccn -group RS_BioProjects -block Bioproj -element BioprojectAccn > $genome_metadata_outfile"

##esearch -db assembly -query '("Bacteria"[Organism] OR "Archaea"[Organism]) AND (latest[filter] AND "complete genome"[filter] AND all[filter] NOT anomalous[filter] AND "taxonomy check ok"[filter])' | esummary | xtract -pattern DocumentSummary -element  AssemblyAccession,Organism,Taxid,BioSampleAccn,AssemblyStatus,FtpPath_GenBank,FtpPath_RefSeq -group GB_BioProjects -block Bioproj -element BioprojectAccn -group RS_BioProjects -block Bioproj -element BioprojectAccn > $genome_metadata_outfile

# Latest RefSeq 35,210.
#echo "esearch -db assembly -query '("Bacteria"[Organism]) OR ("Archaea"[Organism]) AND ("latest refseq"[filter]) AND "complete genome"[filter] NOT anomalous[filter] AND "taxonomy check ok"[filter])' | esummary | xtract -pattern DocumentSummary -def "NA" -element AssemblyAccession,Organism,Taxid,BioSampleAccn,AssemblyStatus,FtpPath_GenBank,FtpPath_RefSeq -group GB_BioProjects -block Bioproj -def "NA" -element BioprojectAccn -group RS_BioProjects -block Bioproj -def "NA" -element BioprojectAccn > $genome_metadata_outfile"

#esearch -db assembly -query '("Bacteria"[Organism]) OR ("Archaea"[Organism]) AND ("latest refseq"[filter]) AND "complete genome"[filter] NOT anomalous[filter] AND "taxonomy check ok"[filter])' | esummary | xtract -pattern DocumentSummary -def "NA" -element AssemblyAccession,AssemblyName,Organism,Taxid,BioSampleAccn,AssemblyStatus,FtpPath_GenBank,FtpPath_RefSeq -group GB_BioProjects -block Bioproj -def "NA" -element BioprojectAccn -group RS_BioProjects -block Bioproj -def "NA" -element BioprojectAccn > $genome_metadata_outfile

filename=$(basename $genome_metadata_outfile | sed 's/\.tsv//g')

genome_metadata_final_file="${output_dir}/${filename}_${date}.tsv"

echo "assembly_id\torganism_name\torganism_rank\tscientific_name\ttaxid\ttax_lineage\tbioproject_id\tbiosample_id\tassembly_status\trefseq_ftp_path\tgenome_assembly_filepath\tgenome_database_filepath" > $genome_metadata_final_file

IFS=$'\n'
for row in $(cat $genome_metadata_outfile);
do
	echo $row;
    
    assembly_id=$(echo $row | cut -f1);
    assembly_name=$(echo $row | cut -f2);
    organism_name=$(echo $row | cut -f3);
    taxid=$(echo $row | cut -f4);
    biosample_id=$(echo $row | cut -f5);
    assembly_status=$(echo $row | cut -f6);
#    genbank_ftp_path=$(echo $row | cut -f7);
    refseq_ftp_path=$(echo $row | cut -f8);
#    genbank_bioproject_id=$(echo $row | cut -f9);
    refseq_bioproject_id=$(echo $row | cut -f10);

    
    taxonomy_result=$(efetch -db taxonomy -id ${taxid} -format xml | xtract -pattern TaxaSet  -group Taxon -sep "," -element ScientificName,Rank -element Lineage -group LineageEx -block Taxon -sep "," -element TaxId,ScientificName,Rank)
    scientific_name=$(echo $taxonomy_result | cut -f1 | cut -d ',' -f1)
    organism_rank=$(echo $taxonomy_result | cut -f1 | cut -d ',' -f2)
    tax_lineage=$(echo $taxonomy_result | cut -f2)
    
    echo $assembly_id;
    echo $taxid;
    echo $refseq_ftp_path;
    
    echo $taxonomy_result;
    echo $scientific_name;
    echo $organism_rank;
    echo $tax_lineage;
    
    # The scientific name of the organism for file path usage.
    scientific_name_path=$(echo "${scientific_name}" | tr '[:upper:]' '[:lower:]' | sed 's/ /_/g' | sed 's/\.//g' | sed 's/(/_/g' | sed 's/)//g');
    
    # Write the following data summary to the genome metadata file.
    echo "${assembly_id}\t${organism_name}\t${organism_rank}\t${scientific_name}\t${taxid}\t${tax_lineage}\t${refseq_bioproject_id}\t${biosample_id}\t${assembly_status}\t${refseq_ftp_path}\t${genome_assembly_filepath}\t${genome_database_filepath}" >> $genome_metadata_final_file

#    # The genome name directory.
#    genome_name_dir="${genome_assembly_dir}/${scientific_name_path}"
#    mkdir -p ${genome_name_dir}
#    
#    # The genome entry directory.
#    genome_entry_dir="${genome_name_dir}/${assembly_id}_${scientific_name_path}"
#    mkdir -p ${genome_entry_dir}
    
    refseq_genome_ftp_path="${refseq_ftp_path}/${assembly_id}_${assembly_name}_genomic.fna.gz"
    
    # Download the genome assembly and all files.
    ##echo "wget --recursive --no-host-directories --cut-dirs=6 \"${refseq_ftp_path}\" -P ${genome_entry_dir}"

    ##wget --recursive --no-host-directories --cut-dirs=6 "${refseq_ftp_path}" -P ${genome_entry_dir}
    
 
    # Grab the genome fna.gz file and filter the cds and rna files because they have the same "*_genomic.fna.gz" extension.
    ##genome_assembly_filepath=$(find ${genome_entry_dir} -name "*_genomic.fna.gz" -type f | grep -v "rna\|cds")
    
    # The path to the genome file in the database directory.
    genome_database_filepath="${genome_database_dir}/${assembly_id}_${scientific_name_path}.fna.gz"
    
    echo "wget \"${refseq_genome_ftp_path}\" -O ${genome_database_filepath}"

    wget "${refseq_genome_ftp_path}" -O ${genome_database_filepath}
        
       
    # Make a softlink from the genome assembly file and rename file to the database directory.
    ##ln -s ${genome_assembly_filepath} ${genome_database_filepath}
    
	#exit 0;
done

# Move the metadata file to the genome assemblies directory.
#mv $genome_metadata_outfile $genome_assembly_dir



