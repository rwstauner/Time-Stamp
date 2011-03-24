# vim: set sw=2 sts=2 ts=2 expandtab smarttab:
use strict;
use warnings;
use Test::More 0.96;
use Time::Local () ; # core

# this script is just to ensure that some actual values can be tested
# without requiring time mocking mods to be installed

our $_time = Time::Local::timegm(5,10,18,16,2,111);
BEGIN {
  *CORE::GLOBAL::time = sub () { $_time };
}

is(time(), $_time, 'global time() overridden');

BEGIN {
  require Time::Stamp;
  Time::Stamp->import(
    'parsegm',
    'gmstamp' => { -as => 'gmdefault' },
    map { (gmstamp => { -as => "gm$_", format => $_ }) } qw(easy numeric compact rfc3339)
  );
}

foreach my $test (
  [default => '2011-03-16T18:10:05Z'],
  [easy    => '2011-03-16 18:10:05 Z'],
  [numeric => '20110316181005'],
  [compact => '20110316_181005Z'],
  [rfc3339 => '2011-03-16T18:10:05Z'],
){
  my ($name, $stamp) = @$test;
  no strict 'refs';
  is(&{"gm$name"}(),  $stamp, "gmstamp $name from time()");
  is(parsegm($stamp), $_time, "parsegm reverts the stamp");
}

my $seconds = Time::Local::timegm(13, 18, 22, 8, 10, 93);

foreach my $test (
  [default => '1993-11-08T22:18:13Z'],
  [easy    => '1993-11-08 22:18:13 Z'],
  [numeric => '19931108221813'],
  [compact => '19931108_221813Z'],
  [rfc3339 => '1993-11-08T22:18:13Z'],
){
  my ($name, $stamp) = @$test;
  no strict 'refs';
  is(&{"gm$name"}($seconds),  $stamp, "gmstamp $name from \$seconds");
  is(parsegm($stamp),       $seconds, "parsegm reverts the stamp");
}

my @gmtime = (1, 2, 3, 4, 5, 67);

foreach my $test (
  [default => '1967-06-04T03:02:01Z'],
  [easy    => '1967-06-04 03:02:01 Z'],
  [numeric => '19670604030201'],
  [compact => '19670604_030201Z'],
  [rfc3339 => '1967-06-04T03:02:01Z'],
){
  my ($name, $stamp) = @$test;
  no strict 'refs';
  is(&{"gm$name"}(@gmtime),      $stamp, "gmstamp $name from \$seconds");
  is_deeply([parsegm($stamp)], \@gmtime, "parsegm reverts the stamp");
}

done_testing;
