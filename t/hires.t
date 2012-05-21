# vim: set sw=2 sts=2 ts=2 expandtab smarttab:
use strict;
use warnings;
use Test::More 0.96;

BEGIN {
  require Time::Stamp;
  my %args = (us => 1, format => 'easy');

  $INC{"Time/HiRes.pm"} = 1;
  *Time::HiRes::gettimeofday = sub () { CORE::time(), 23456789 };
  Time::Stamp->import(localstamp => { -as => 'localfrac', %args });

  no warnings 'redefine';
  local *Time::Stamp::_have_hires = sub { 0 };
  Time::Stamp->import(localstamp => { -as => 'localzero', %args });
}

like localfrac(), qr/^\d+-\d+-\d+ \d+:\d+:\d+\.(234568)$/, 'local time with us';

# if fraction is specified it should be returned, even if we can't do better than zero
like localzero(), qr/^\d+-\d+-\d+ \d+:\d+:\d+\.(000000)$/,  'local time with whole number precision';

done_testing;
