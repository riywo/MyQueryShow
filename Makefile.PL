use inc::Module::Install;
all_from "lib/MyQueryShow.pm";

use lib 'extlib/lib/perl5/';

tests 't/*.t t/*/*.t t/*/*/*.t';
requires 'Amon2';
requires 'Text::Xslate';
requires 'Text::Xslate::Bridge::TT2Like';
requires 'Plack::Middleware::ReverseProxy';
requires 'HTML::FillInForm::Lite';
requires 'Time::Piece';
requires 'DateTime';
requires 'DateTime::Format::HTTP';
requires 'DateTime::Format::MySQL';

recursive_author_tests('xt');

WriteAll;
