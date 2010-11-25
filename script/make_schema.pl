use strict;
use warnings;
use MyQA;
use DBIx::Skinny::Schema::Loader qw/make_schema_at/;
use FindBin;

my $c = MyQA->bootstrap;
my $conf = $c->config->{'DB'};

my $schema = make_schema_at('MyQA::DB::Schema', {}, $conf);
my $dest = File::Spec->catfile($FindBin::Bin, '..', 'lib', 'MyQA', 'DB', 'Schema.pm');
open my $fh, '>', $dest or die "cannot open file '$dest'; $!";
print {$fh} $schema;
close $fh;
