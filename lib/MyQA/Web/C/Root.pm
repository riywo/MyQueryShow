package MyQA::Web::C::Root;
use strict;
use warnings;

sub index {
    my ($class, $c) = @_;
    $c->render("index.tt");
}

1;
