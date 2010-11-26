package MyQueryShow::Web::Dispatcher;
use strict;
use warnings;

use Amon2::Web::Dispatcher::RouterSimple;

connect '/' => 'Root#list';
connect '/list' => 'Root#list';
#connect '/detail' => 'Root#detail';

1;
