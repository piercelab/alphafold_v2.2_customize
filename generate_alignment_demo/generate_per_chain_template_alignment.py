import pandas as pd
import sys
from Bio import pairwise2
from Bio.pairwise2 import format_alignment
from Bio import SeqIO

pdb_path=sys.argv[1]
ref_seq=sys.argv[2]
align_out=sys.argv[3]

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
        biopython_align_out,
        ref_res_cnt=0):
    """
    Generates alignment string to indicate reference 
    sequence to pdb sequence correspondence.

    Args:
        biopython_align_out (int): Sequence alignment.
        ref_res_cnt (str): The start of the reference 
        sequence, defaulted to 0. 

    Returns:
        bool: True if successful, False otherwise.
    """
    resolved_res_cnt=0
    alignment=""
    for index, ref_ab_res in enumerate(biopython_align_out[0]):
        if ref_ab_res=="-": #not resolved residues in PDB
            resolved_res_cnt+=1
            continue
        md_res=biopython_align_out[1][index]
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
alignments=pairwise2.align.globalxx(ref_seq, md_seq, penalize_extend_when_opening=True)

# normally, the first alignemnt output from biopython 
# pairwise2 function is good, but inspect it to make 
# sure the alignment is good.
print(format_alignment(*alignments[0]))

# generate sequence correspondence string
seq_correspond=generate_alignment(alignments[0],0)

# This is the alignment header line
out="template_pdbfile\ttarget_to_template_alignstring\ttarget_len\ttemplate_len\tidentities\n"

# if you want to generate alignment strings for multiple 
# pdb files as template for this chain, just add to the 
# "out" string.
out+=f"{pdb_path}\t{seq_correspond}\t{len(ref_seq)}\t{len(md_seq)}\t0\n"

# write the alignment to file
with open(align_out,"w+") as fh:
    fh.write(out)