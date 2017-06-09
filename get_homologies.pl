##Get homology for 2 organisms
use 5.14.0;
use strict;
#use warnings;
use Bio::SeqIO;
use Bio::AlignIO;
use Bio::EnsEMBL::Registry;

my ($org1, $org2) = @ARGV;

## Load the registry automatically
my $reg = "Bio::EnsEMBL::Registry";
$reg->load_registry_from_url('mysql://anonymous@ensembldb.ensembl.org');

my @genes = get_genes($reg, $org1);

## Get the compara member adaptor
my $gene_member_adaptor = $reg->get_adaptor("Multi", "compara", "GeneMember");

## Get the compara homology adaptor
my $homology_adaptor = $reg->get_adaptor("Multi", "compara", "Homology");

say "gene1\tgene2\tdn\tds\ttaxonomy_level\tdescription";
for my $gene_id (@genes) {

    ## Get the compara member
    my $gene_member = $gene_member_adaptor->fetch_by_stable_id($gene_id);

    ## Get all the homologs in the other species
    my $all_homologies = $homology_adaptor->fetch_all_by_Member($gene_member, -TARGET_SPECIES => $org2);

    ## For each homology get relavant info
    foreach my $this_homology (@{$all_homologies}) {

        my $gene_members = $this_homology->get_all_GeneMembers();
        foreach my $this_member (@{$gene_members}) {
            print $this_member->stable_id(),"\t";
        }

        print $this_homology->dn,"\t";
        print $this_homology->ds,"\t";
        print $this_homology->taxonomy_level,"\t";
        print $this_homology->description,"\n";
    }
}

#======================================== 
sub get_genes {
    my ($registry, $org) = @_;

    my $gene_adaptor = $registry->get_adaptor("$org", "core", "Gene");

    my $genes_aref = $gene_adaptor->fetch_all_by_biotype('protein_coding');
    my @genes = ();
    for my $gene ( @{$genes_aref} ){
        my $sid = $gene->stable_id;
        push @genes, $sid;
    }
    return @genes;
}

