package MyQA;
use strict;
use warnings;
use parent qw/Amon2/;
our $VERSION='0.01';

use Amon2::Config::Simple;
sub load_config { Amon2::Config::Simple->load(shift) }

__PACKAGE__->load_plugin('LogDispatch');

use DBI;
use MyQA::DB;
sub db {
    my ($c, ) = @_;

    if($c->{db}){
        return $c->{db};
    }else{
        my $conf = $c->config->{'DB'} or die;
        return MyQA::DB->new($conf);
    }
}

1;
