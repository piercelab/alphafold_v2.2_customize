#!/bin/bash
#SBATCH -n 1
#SBATCH -c 40
#SBATCH --gpus=rtx_2080_ti:1
#SBATCH --mem=60G
#SBATCH -A ibbr

#read in features.pkl and make AF-mult structural predictions
#the inputs are:
#1. path to .fasta file
#2. maximum template date
#3. output path (make sure that a subdirectory with name matching the name.fasta file is created; for instance, if the fasta file is Tn4430.fasta, and the output path is: out_dir/, make sure that out_dir/Tn4430 exists)
#4. To run relax or not (True or False)

CUDA_VISIBLE_DEVICES=0 python run_alphafold_customized.py --fasta_paths=$1 --max_template_date=$2 --model_preset=multimer --data_dir=/piercehome/alphafold/genetic_databases/ --output_dir=$3 --uniref90_database_path=/piercehome/alphafold/genetic_databases/uniref90/uniref90.fasta --mgnify_database_path=/piercehome/alphafold/genetic_databases/mgnify/mgy_clusters_2018_12.fa --template_mmcif_dir=/piercehome/alphafold/genetic_databases/pdb_mmcif/mmcif_files/ --obsolete_pdbs_path=/piercehome/alphafold/genetic_databases/pdb_mmcif/obsolete.dat --bfd_database_path=/piercehome/alphafold/genetic_databases/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt --uniclust30_database_path=/piercehome/alphafold/genetic_databases/uniclust30/uniclust30_2018_08/uniclust30_2018_08 --pdb_seqres_database_path=/piercehome/alphafold/genetic_databases/pdb_seqres/pdb_seqres.txt --uniprot_database_path=/piercehome/alphafold/genetic_databases/uniprot/uniprot.fasta --use_gpu_relax=True --run_relax=True --use_precomputed_msas=True --use_precomputed_msas=True --num_multimer_predictions_per_model=1
