# vim: set sw=2 sts=2 ts=2 expandtab smarttab:
use strict;
use warnings;
use Test::More 0.96;
use Time::Local () ; # core

use Time::Stamp -parsers;

my $seconds = Time::Local::timegm(33, 22, 11, 17,  5, 93);

foreach my $test (
  [default => '1993-06-17T11:22:33Z'],
  [easy    => '1993-06-17 11:22:33 Z'],
  [numeric => '19930617112233'],
  [compact => '19930617_112233Z'],
){
  my ($name, $stamp) = @$test;
  is(parsegm($stamp), $seconds, "parsed $name format");
}

$seconds = Time::Local::timelocal(33, 22, 11, 17,  5, 93);

foreach my $test (
  [default => '1993-06-17T11:22:33'],
  [easy    => '1993-06-17 11:22:33'],
  [numeric => '19930617112233'],
  [compact => '19930617_112233'],
){
  my ($name, $stamp) = @$test;
  is(parselocal($stamp), $seconds, "parsed $name format");
}

is(scalar parsegm('oops'), undef, 'parsegm failed to parse');
is_deeply([parsegm('oops')], [],  'parsegm failed to parse');

done_testing;
