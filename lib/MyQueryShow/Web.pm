package MyQueryShow::Web;
use strict;
use warnings;
use parent qw/MyQueryShow Amon2::Web/;

# load all controller classes
use Module::Find ();
Module::Find::useall("MyQueryShow::Web::C");

# custom classes
use MyQueryShow::Web::Request;
use MyQueryShow::Web::Response;
sub create_request  { MyQueryShow::Web::Request->new($_[1]) }
sub create_response { shift; MyQueryShow::Web::Response->new(@_) }

# dispatcher
use MyQueryShow::Web::Dispatcher;
sub dispatch {
    return MyQueryShow::Web::Dispatcher->dispatch($_[0]) or die "response is not generated";
}

# optional configuration
__PACKAGE__->add_config(
    'Text::Xslate' => {
        'syntax'   => 'TTerse',
        'module'   => [ 'Text::Xslate::Bridge::TT2Like' ],
        'function' => {
            c => sub { Amon2->context() },
            uri_with => sub { Amon2->context()->req->uri_with(@_) },
            uri_for  => sub { Amon2->context()->uri_for(@_) },
        },
    }
);

# setup view class
use Tiffany::Text::Xslate;
{
    my $view_conf = __PACKAGE__->config->{'Text::Xslate'};
    my $view = Tiffany::Text::Xslate->new($view_conf);
    sub create_view { $view }
}

# load plugins
# __PACKAGE__->load_plugins('Web::FillInFormLite');
# __PACKAGE__->load_plugins('Web::NoCache');

1;
