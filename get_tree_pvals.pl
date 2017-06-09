use 5.12.0;
use warnings;

use Bio::EnsEMBL::Registry;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous'
    );

my $c = 0;

##Adaptors
my $gene_adaptor        = $registry->get_adaptor("human", "core", "Gene");
my $tree_adaptor        = $registry->get_adaptor("Multi", "compara", "GeneTree");
my $gene_member_adaptor = $registry->get_adaptor("Multi", "compara", "GeneMember");
my $genome_db_adaptor   = Bio::EnsEMBL::Registry->get_adaptor( "Multi", "compara", "GenomeDB");

##Genome DB for human
my $genome_db = $genome_db_adaptor->fetch_by_registry_name('human');

##Get trees for all gene members
my $gene_members_aref = $gene_member_adaptor->fetch_all_by_GenomeDB($genome_db);
for my $gene_member ( @{$gene_members_aref} ){
    my $sid = $gene_member->stable_id;
    
    ##Get the gene tree if exists
    my $gene_tree    = $tree_adaptor->fetch_default_for_Member($gene_member);
    if (!$gene_tree){
        next;
    }
    
    ##CAFE creates the coffee object
    my $coffee = $gene_tree->adaptor->db->get_CAFEGeneFamilyAdaptor->fetch_by_GeneTree($gene_tree);
    if ($coffee){
        my $pval_avg = $coffee->pvalue_avg();
        say "$sid\t$pval_avg";
    }
    
    if ($c++ % 1000 == 0){
        warn $c;
    }
}

