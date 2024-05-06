import pandas as pd
import sys
import shutil

from Bio import pairwise2
from Bio.pairwise2 import format_alignment
from Bio import SeqIO
from typing import Any, Dict, Mapping, Optional, Sequence, Tuple


pdb_path=sys.argv[1]
ref_seq=sys.argv[2]
align_out=sys.argv[3]
alphafold_path=sys.argv[4]

sys.path.insert(1,alphafold_path)
from alphafold.data.tools import kalign
from alphafold.data import parsers

aligner = kalign.Kalign(binary_path=shutil.which('kalign'))

def extract_pdb_seq(pdb_path):
    """
    Extract sequence from pdb

    Args:
        pdb_path (str): path to pdb file

    Returns:
        PDB sequence
    """
    for record in SeqIO.parse(pdb_path, "pdb-atom"):
        return(str(record.seq))


def generate_alignment(
        aligned_ref,
        aligned_md,
        ref_res_cnt=0):
    """
    Generates alignment string to indicate reference 
    sequence to pdb sequence correspondence.

    Args:
        aligned_ref (str): Sequence alignment of ref.
        aligned_md (str): Sequence alignment of model.
        ref_res_cnt (int): The start of the reference 
        sequence, defaulted to 0. 

    Returns:
        bool: True if successful, False otherwise.
    """
    resolved_res_cnt=0
    alignment=""
    for index, ref_ab_res in enumerate(aligned_ref):
        if ref_ab_res=="-": #not resolved residues in PDB
            resolved_res_cnt+=1
            continue
        md_res=aligned_md[index]
        if md_res=="-": # reference residue not aligned to anything 
            ref_res_cnt+=1
            continue
        else:
            alignment+="%d:%d;" % (ref_res_cnt, resolved_res_cnt)
            resolved_res_cnt+=1
            ref_res_cnt+=1
    return alignment[:-1]

# extract pdb sequence
md_seq=extract_pdb_seq(pdb_path)

# generate reference to pdb sequence alignment
parsed_a3m=parsers.parse_a3m(
        aligner.align([ref_seq, md_seq]))

aligned_ref, aligned_md = parsed_a3m.sequences

print(aligned_ref)
print(aligned_md)

alignment_dict=generate_alignment(
    aligned_ref,
    aligned_md)


# This is the alignment header line
out="template_pdbfile\ttarget_to_template_alignstring\ttarget_len\ttemplate_len\tidentities\n"

# if you want to generate alignment strings for multiple 
# pdb files as template for this chain, just add to the 
# "out" string.
out+=f"{pdb_path}\t{alignment_dict}\t{len(ref_seq)}\t{len(md_seq)}\t0\n"

# write the alignment to file
with open(align_out,"w+") as fh:
    fh.write(out)