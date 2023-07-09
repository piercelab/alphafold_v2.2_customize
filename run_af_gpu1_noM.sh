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

CUDA_VISIBLE_DEVICES=1 python run_alphafold_customized.py --fasta_paths=$1 --max_template_date=$2 --model_preset=multimer --output_dir=$3 --use_custom_templates --template_alignfile=$4 --use_gpu_relax=True --run_relax=False --use_precomputed_msas=True --model_preset=monomer_ptm --run_model_names=$6 $5 
