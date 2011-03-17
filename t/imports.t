# vim: set sw=2 sts=2 ts=2 expandtab smarttab:
use strict;
use warnings;
use Test::More 0.96;

my $mod = 'Time::Stamp';
eval "require $mod" or die $@;

# Test that subs have been defined in the package (__PACKAGE__->import)

my @subs = qw(
  localstamp
  gmstamp
);

plan tests => scalar @subs;

foreach my $sub ( @subs ){
  no strict 'refs';
  ok(eval { &{"${mod}::${sub}"}() }, "have ${mod}::${sub}()");
}
