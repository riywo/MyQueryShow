package MyQueryShow::Web::Dispatcher;
use strict;
use warnings;

use Amon2::Web::Dispatcher::RouterSimple;

connect '/' => 'Root#index';
connect '/q_list' => 'Root#queryList';
connect '/test' => 'Root#test';

1;
