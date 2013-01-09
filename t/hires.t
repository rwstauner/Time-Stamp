# vim: set sw=2 sts=2 ts=2 expandtab smarttab:
use strict;
use warnings;
use Test::More 0.96;
use lib 't/lib';
use ControlTime;

BEGIN {
  require Time::Stamp;
  my %args = (us => 1, format => 'easy');

  # tell TS that HiRes *is* available
  ControlTime->fake_have_hires(1);
  Time::Stamp->import(localstamp => { -as => 'localfrac', %args });

  # tell TS that HiRes is *not* available
  ControlTime->fake_have_hires(0);
  Time::Stamp->import(localstamp => { -as => 'localzero', %args });

  ControlTime->fraction(23456789);
}

like localfrac(), qr/^\d+-\d+-\d+ \d+:\d+:\d+\.(234568)$/, 'local time with us';

# if fraction is specified it should be returned, even if we can't do better than zero
like localzero(), qr/^\d+-\d+-\d+ \d+:\d+:\d+\.(000000)$/,  'local time with whole number precision';

done_testing;
