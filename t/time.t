# vim: set sw=2 sts=2 ts=2 expandtab smarttab:
use strict;
use warnings;
use Test::More 0.96;
use Time::Local () ; # core

# this script is just to ensure that some actual values can be tested
# without requiring time mocking mods to be installed

our $_timegm    = Time::Local::timegm(   5,10,18,16,2,111);
our $_timelocal = Time::Local::timelocal(5,10,18,16,2,111);
our $_time      = $_timegm;

BEGIN {
  *CORE::GLOBAL::time = sub () { $_time };
}

is(time(), $_time, 'global time() overridden');

BEGIN {
  require Time::Stamp;
  Time::Stamp->import(
    map {
      my $which = $_;
      "parse$which",
      "${which}stamp" => { -as => "${which}default" },
      map { ("${which}stamp" => { -as => "${which}$_", format => $_ }) } qw(easy numeric compact rfc3339)
    } qw( local gm )
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

  $_time = $_timegm;
  is(&{"gm$name"}(),  $stamp, "gmstamp $name from time()");
  is(parsegm($stamp), $_time, "parsegm reverts the stamp");

  $stamp =~ s/\D*Z$//;
  $_time = $_timelocal;
  is &{"local$name"}(), $stamp, 'localstamp from time()';
  is parselocal($stamp), $_timelocal, 'parselocal reverts stamp';
}

my $timegm    = Time::Local::timegm(   13, 18, 22, 8, 10, 93);
my $timelocal = Time::Local::timelocal(13, 18, 22, 8, 10, 93);

foreach my $test (
  [default => '1993-11-08T22:18:13Z'],
  [easy    => '1993-11-08 22:18:13 Z'],
  [numeric => '19931108221813'],
  [compact => '19931108_221813Z'],
  [rfc3339 => '1993-11-08T22:18:13Z'],
){
  my ($name, $stamp) = @$test;
  my $seconds;
  no strict 'refs';

  $seconds = $timegm;
  is(&{"gm$name"}($seconds),  $stamp, "gmstamp $name from \$seconds");
  is(parsegm($stamp),       $seconds, "parsegm reverts the stamp");

  $stamp =~ s/\D*Z$//;
  $seconds = $timelocal;
  is(&{"local$name"}($seconds),  $stamp, "localstamp $name from \$seconds");
  is(parselocal($stamp),       $seconds, "parselocal reverts the stamp");
}

my @gmtime    = (1, 2, 3, 4, 5, 67);
my @localtime = (1, 2, 3, 4, 5, 67);

foreach my $test (
  [default => '1967-06-04T03:02:01Z'],
  [easy    => '1967-06-04 03:02:01 Z'],
  [numeric => '19670604030201'],
  [compact => '19670604_030201Z'],
  [rfc3339 => '1967-06-04T03:02:01Z'],
){
  my ($name, $stamp) = @$test;
  my $timea;
  no strict 'refs';

  $timea = [@gmtime];
  is(&{"gm$name"}(@$timea),      $stamp, "gmstamp $name from \@gmtime");
  is_deeply([parsegm($stamp)],   $timea, "parsegm reverts the stamp");

  $stamp =~ s/\D*Z$//;
  $timea = [@localtime];
  is(&{"local$name"}(@$timea),      $stamp, "localstamp $name from \@localtime");
  is_deeply([parselocal($stamp)],   $timea, "parselocal reverts the stamp");
}

done_testing;
