# Customized DeepMind AlphaFold v.2.2.0 


## Table of Contents

- [Project description](#project-description)
- [Features](#features)
- [Installation](#installation)
- [Template alignment file](#template-alignment)
- [Interface pLDDT score](#iplddt)
- [Other features](#other-features)
- [License](#license)

# Project Description

This code repository offers a modified version of AlphaFold for users who wish to utilize it in their endeavors. The provided code is the one we utilized to generate AlphaFold predictions with adjusted parameters.

For more detailed information, please refer to the following paper:

Yin R, Pierce BG. Evaluation of AlphaFold antibody-antigen modeling with implications
for improving predictive accuracy. Protein Science. 2024 Jan;33(1):e4865. doi:
10.1002/pro.4865. PMID: 38073135; PMCID: PMC10751731. 

## Features

The modified AlphaFold allows one to do things such as:
- Use custom PDB as template
- Save MSA to a file
- Generate "single_chain" (no MSA) predictions
- Compute interface pLDDT of AlphaFold predictions

The script `run_alphafold_customized.py` is the key to calling all the modified functions. To run the script, one needs to provide command line arguments that defines the path to AlphaFold databases (or modify the default value of the path in the script so that you don't need to set it every time you call the python script) and provide path to fasta file (fasta_paths). Those are mandatory arguments that must be provided to the script. Then, you can read the script, pick the arguments that interest you, and mix-and-match!

## Installation

Install alphaFold requirements in a conda environment. Here's a useful resource if you prefer to install AlphaFold without Docker: https://github.com/kalininalab/alphafold_non_docker


## Template alignment file

### Generate template alignment file

AlphaFold has the capability to use up to four PDBs as templates per chain. The script included in the `generate_alignment_demo` folder demonstrates how to generate an alignment file to use one PDB as a chain template. You can modify the script to build alignment file for up to four templates per chain.

The alignment file instructs the program on how to map chain sequences from AlphaFold models to residues in the template/PDB. The script is adapted from [`predict_utils.py`](https://github.com/phbradley/alphafold_finetune/blob/main/predict_utils.py) of the [alphafold_finetune](https://github.com/phbradley/alphafold_finetune) repository.

#### Usage 

We have provided two python scripts for generating alignment tsv file. 
##### Kalign alignment
```shell
python generate_per_chain_template_alignment_kalign.py <pdb_path> <reference_sequence> <output_tsv_file> <path_to_alphafold>
```

- `pdb_path`: The path to the template PDB. We recommend using an absolute path so that the program can retrieve the file for template featurization at runtime, even when running AlphaFold from different directories.
- `reference_sequence`: The sequence of the chain you input to AlphaFold.
- `output_tsv_file`: The path to the desired output TSV file.
- `path_to_alphafold`: The path to the AlphaFold code.

For example:

```shell
python generate_per_chain_template_alignment_kalign.py demo.pdb QVQLQQSGAELMKPGASVKISCKATGYTFSGHWIEWVKQRPGHGLEWIGEILPGSGNIHYNEKFKGKATFAADTSSNTAYMQLSSLTSEDSAVYYCARLGTTAVERDWYFDVWGAGTTVTVSL demo.align.tsv alphafold_v2.2_customized/
```

##### Biopython alignment
```shell
python generate_per_chain_template_alignment.py <pdb_path> <reference_sequence> <output_tsv_file>
```

- `pdb_path`: The path to the template PDB. We recommend using an absolute path so that the program can retrieve the file for template featurization at runtime, even when running AlphaFold from different directories.
- `reference_sequence`: The sequence of the chain you input to AlphaFold.
- `output_tsv_file`: The path to the desired output TSV file.

For example:

```shell
python generate_per_chain_template_alignment.py demo.pdb QVQLQQSGAELMKPGASVKISCKATGYTFSGHWIEWVKQRPGHGLEWIGEILPGSGNIHYNEKFKGKATFAADTSSNTAYMQLSSLTSEDSAVYYCARLGTTAVERDWYFDVWGAGTTVTVSL demo.align.tsv
```

We have included the resulting `demo.align.tsv` file in `expected.demo.align.tsv` for your reference.

### Using the Template Alignment File in AlphaFold

Once you have generated the alignment TSV file, you can utilize it in AlphaFold by passing it as a command-line argument to `run_alphafold_customized`. To do this, make use of the following two arguments:

```
--use_custom_templates=True
--template_alignfile=<path_to_template_alignment_files>
```

Regarding `<path_to_template_alignment_files>`:

This argument expects the path to the custom template file(s). If the target is a monomer, provide the template path for the monomer chain. If it's a multimer, provide all template alignment files in the order they appear in the target, separated by commas. If a chain does not require a template, or if you don't want to use any template for that chain, leave the path blank. To use the default AlphaFold pipeline for generating the template for a specific chain, write "UseDefaultTemplate". 

Concretely, if you have a three-chain target. First chain has a customized template alignment file demo.align.tsv. For second chain you don't want to use template. For the third chain you want to use default AlphaFold pipeline for generating template. You will input:

```
--use_custom_templates=True
--template_alignfile=demo.align.tsv,,UseDefaultTemplate
```

## Interface pLDDT score

This script, `get_interface_plddt.pl` calculates the average pLDDT score for interface residues of a protein complex prediction generated by AlphaFold. This Perl script requires the following inputs: a PDB (Protein Data Bank) file, identifiers for two sets of chains in the protein complex (chns_a and chns_b), a distance cutoff, and an optional argument for the lowest I-pLDDT score. This last parameter will be used when no interface residues were identified within the distance cutoff across the sets of chains. 

The script works by identifying all residues within each set of chains that fall within the cutoff distance of the other set of chains. Residues will be considered "interface residue" if their non-hydrogen atom is within the specified distance cutoff from non-hydrogen atoms of any residues in the other set of chains. For each identified interface residue, the script records its pLDDT score. 

In cases where no interface residues are detected within the stipulated distance cutoff, the script defaults to a score of -1, unless a different score is input by the user. Ultimately, the script outputs the I-pLDDT score, which is the average pLDDT score of all identified interface residues.

#### Usage

```
perl get_interface_plddt.pl <pdb_file> <chns_a> <chns_b> <distance_cutoff> [lowest_iplddt_score]
```

By default, complexes without interface atomic contacts within the specified distance cutoff will be scored as '-1.00'. This default score can be modified by providing the 'lowest_iplddt_score' argument.


#### Example

For example, if the pdb file is `ranked_0.pdb`, and the interface is formed by the antibody and the antigen chains (assuming this is an antibody-antigen complex prediction), the antibody chains are `A` and `B`, the antigen chain is `C`, and the interface distance is defined as `4 Å`, the command would be:

```
perl get_interface_plddt.pl ranked_0.pdb AB C 4
```

## Other features

### Save MSA to a file

Use the following argument to save MSA to files:

```
--save_msa_fasta=True
```

### Generate "single_chain" (no MSA) predictions

Use the following argument to NOT use MSA:

```
--msa_mode=single_sequence
```


## License
Apache License 2.0

## Acknowledgements

We would like to thank [alphafold](https://github.com/deepmind/alphafold/), [alphafold_finetune](https://github.com/phbradley/alphafold_finetune), [ColabFold](https://github.com/sokrypton/ColabFold) teams for developing and distributing the code. The content inside alphafold/ folder is modified from [alphafold/](https://github.com/deepmind/alphafold/releases/tag/v2.2.0) of [alphafold](https://github.com/deepmind/alphafold/) repository. The featurization of custom template is modified from [predict_utils.py](https://github.com/phbradley/alphafold_finetune/blob/main/predict_utils.py) of [alphafold_finetune](https://github.com/phbradley/alphafold_finetune). Chain break introduction, as well as making mock template feature steps are modified from [batch.py](https://github.com/sokrypton/ColabFold/blob/aa7284b56c7c6ce44e252787011a6fd8d2817f85/colabfold/batch.py) of [ColabFold](https://github.com/sokrypton/ColabFold).

