use strict;
use warnings;
use MyQueryShow;
use DBIx::Skinny::Schema::Loader qw/make_schema_at/;
use FindBin;

my $c = MyQueryShow->bootstrap;
my $conf = $c->config->{'DB'};

my $schema = make_schema_at('MyQueryShow::DB::Schema', {}, $conf);
my $dest = File::Spec->catfile($FindBin::Bin, '..', 'lib', 'MyQueryShow', 'DB', 'Schema.pm');
open my $fh, '>', $dest or die "cannot open file '$dest'; $!";
print {$fh} $schema;
close $fh;
