package MyQueryShow::Web::Dispatcher;
use strict;
use warnings;

use Amon2::Web::Dispatcher::RouterSimple;

connect '/' => 'Root#list';
connect '/list' => 'Root#list';
submapper('/detail/{checksum}')
    ->connect('', { controller => 'Root', action => 'detail'})
    ->connect('/', { controller => 'Root', action => 'detail'});

1;
