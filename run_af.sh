#!/bin/bash

python run_alphafold_customized.py --fasta_paths=$1 --max_template_date=$2 --model_preset=multimer --output_dir=$3 --use_custom_templates --template_alignfile=$4 --use_gpu_relax=True --run_relax=True --use_precomputed_msas=True --use_precomputed_msas=True --num_multimer_predictions_per_model=1 $5
