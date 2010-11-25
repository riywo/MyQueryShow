package MyQA::Web::Dispatcher;
use strict;
use warnings;

use Amon2::Web::Dispatcher::RouterSimple;

connect '/' => 'Root#index';
connect '/test' => 'Root#test';

1;
