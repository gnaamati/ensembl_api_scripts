#!/usr/bin/env perl
use strict;
use warnings;
use Bio::EnsEMBL::Registry;
use Data::Dumper;
use Bio::SeqIO;
use feature qw /say/;
use Bio::EnsEMBL::Registry;

my ($species) = @ARGV;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
	-host => 'ensembldb.ensembl.org',
	-user => 'anonymous',
);

##fetch a gene by its stable identifier
my $gene_adaptor = $registry->get_adaptor("$species", "core", "Gene");

my $genes_aref = $gene_adaptor->fetch_all_by_biotype('protein_coding');
for my $gene ( @{$genes_aref} ){
    say ">",$gene->stable_id;
    my $transcript = $gene->canonical_transcript;
    say $transcript->seq->seq;
}

