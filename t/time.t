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
  Time::Stamp->import('gmstamp',
    map { (gmstamp => { -as => "gm$_", format => $_ }) } qw(easy numeric compact rfc3339)
  );
}

is(gmstamp,   '2011-03-16T18:10:05Z',  'gmstamp from time()');
is(gmeasy,    '2011-03-16 18:10:05 Z', 'gmstamp easy from time()');
is(gmnumeric, '20110316181005',        'gmstamp numeric from time()');
is(gmcompact, '20110316_181005Z',      'gmstamp compact from time()');
is(gmrfc3339, '2011-03-16T18:10:05Z',  'gmstamp rfc3339 from time()');

my $seconds = Time::Local::timegm(13, 18, 22, 8, 10, 93);

is(gmstamp($seconds),   '1993-11-08T22:18:13Z',  'gmstamp from $seconds');
is(gmeasy($seconds),    '1993-11-08 22:18:13 Z', 'gmstamp easy from $seconds');
is(gmnumeric($seconds), '19931108221813',        'gmstamp numeric from $seconds');
is(gmcompact($seconds), '19931108_221813Z',      'gmstamp compact from $seconds');
is(gmrfc3339($seconds), '1993-11-08T22:18:13Z',  'gmstamp rfc3339 from $seconds');

my @gmtime = (1, 2, 3, 4, 5, 67);

is(gmstamp(@gmtime),   '1967-06-04T03:02:01Z',  'gmstamp from @gmtime');
is(gmeasy(@gmtime),    '1967-06-04 03:02:01 Z', 'gmstamp easy from @gmtime');
is(gmnumeric(@gmtime), '19670604030201',        'gmstamp numeric from @gmtime');
is(gmcompact(@gmtime), '19670604_030201Z',      'gmstamp compact from @gmtime');
is(gmrfc3339(@gmtime), '1967-06-04T03:02:01Z',  'gmstamp rfc3339 from @gmtime');

done_testing;
