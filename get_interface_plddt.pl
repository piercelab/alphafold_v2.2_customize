#!/usr/bin/perl

use strict;

my $pdb_file = $ARGV[0];
my $chn1 = $ARGV[1];
my $chn2 = $ARGV[2];
my $dis_cut = $ARGV[3];
my $lowest = -1; # default value for no contacts
if (defined $ARGV[4]) {
    $lowest = $ARGV[4];
}

if (($pdb_file eq "") || ($chn1 eq "") || ($chn2 eq "") || ($dis_cut eq "")) { 
    die("Usage: get_interface_plddt.pl <pdb_file> <chns_a> <chns_b> <distance_cutoff> [lowest_iplddt_score]\nNote: By default, complexes without interface atomic contacts within the specified distance cutoff will be scored as '-1.00'. This default score can be modified by providing the 'lowest_iplddt_score' argument.\n"); 
    } 

open(PDB, $pdb_file) || die("unable to open file: $pdb_file\n");
my @pdb_lines = <PDB>;
close(PDB);

my %chn1int = ();
for (my $i = 0; $i < length($chn1); $i++) { $chn1int{substr($chn1, $i, 1)} = 1; }
my %chn2int = ();
for (my $i = 0; $i < length($chn2); $i++) { $chn2int{substr($chn2, $i, 1)} = 1; }

# set the distance cutoff
my $dis_cutoff = $dis_cut * $dis_cut;

my %chn1_int_plddt; 
my %chn2_int_plddt;
# go through residues
foreach my $line (@pdb_lines)
{
    if (substr($line, 0, 4) ne "ATOM") { next; }
    if ((substr($line, 13, 1) eq "H") || (substr($line, 12, 1) eq "H")) {next;}
    my $res_num = substr($line, 22, 5);
    my $chn_id = substr($line, 21, 1);
    my $res_id = substr($line, 17, 3);
    my $atm_id = substr($line, 12, 4);
    my $plddt1 = substr($line, 60, 6);

    # if (($atm_id eq " C  ") || ($atm_id eq " CA ") || ($atm_id eq " N  ") || ($atm_id eq " O  ")) { next; }

    if ($chn1int{$chn_id} == 1)  # check to see if it's in the interface
    {
        my $x1 = substr($line, 30, 8);
        my $y1 = substr($line, 38, 8);
        my $z1 = substr($line, 46, 8);

        foreach my $line2 (@pdb_lines)
        {
            if (substr($line2, 0, 4) ne "ATOM") { next; }
            if ((substr($line2, 13, 1) eq "H") || (substr($line2, 12, 1) eq "H")) {next;}

            my $chn2 = substr($line2, 21, 1);
            my $res_num2 = substr($line2, 22, 5);
            my $res_id2 = substr($line2, 17, 3);
            my $atm_id2 = substr($line2, 12, 4);

            # if (($atm_id2 eq " C  ") || ($atm_id2 eq " CA ") || ($atm_id2 eq " N  ") || ($atm_id2 eq " O  ")) { next; }

            my $plddt2 = substr($line2, 60, 6);

            if ($chn2int{$chn2} == 1)
            {
                my $x2 = substr($line2, 30, 8);
                my $y2 = substr($line2, 38, 8);
                my $z2 = substr($line2, 46, 8);
                my $dist = ($x1 - $x2)**2 + ($y1 - $y2)**2 + ($z1 - $z2)**2;
                if ($dist < $dis_cutoff) # is within cutoff distance 
                { 
                    $chn1_int_plddt{join("\t", $res_num,$chn_id,$res_id)} = $plddt1;
                    $chn2_int_plddt{join("\t", $res_num2,$chn2,$res_id2)} = $plddt2;
                }
            }
        }
    }
}

my $weighted_sum = 0;
my $counts = 0;

my @chn1_int_res = keys %chn1_int_plddt;
my @chn2_int_res = keys %chn2_int_plddt;

foreach my $res (@chn1_int_res) {
    $weighted_sum += $chn1_int_plddt{$res} ;
    $counts += 1;
}

foreach my $res (@chn2_int_res) {
    $weighted_sum += $chn2_int_plddt{$res} ;
    $counts += 1;
}

# If counts=0, then output the lowest score
my $final_score;
if ($counts == 0) {
    $final_score = $lowest;
} else {
    $final_score = $weighted_sum / $counts;
}

$final_score = sprintf("%.2f", $final_score);
print "$final_score\n";
