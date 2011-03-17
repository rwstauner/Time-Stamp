# vim: set sw=2 sts=2 ts=2 expandtab smarttab:
use strict;
use warnings;
use Test::More 0.96;

use Time::Stamp ();

sub f { goto &Time::Stamp::_format; }

my %z = qw(tz Z);

# names
is(f({format => 'default'}),    '%04d-%02d-%02dT%02d:%02d:%02d',   'default format spec');
is(f({format => 'default',%z}), '%04d-%02d-%02dT%02d:%02d:%02dZ',  'default format spec');

is(f({format => 'easy'   }),    '%04d-%02d-%02d %02d:%02d:%02d',   'easy to read');
is(f({format => 'easy',   %z}), '%04d-%02d-%02d %02d:%02d:%02d Z', 'easy to read');

is(f({format => 'numeric'}),    '%04d%02d%02d%02d%02d%02d',        'numeric');
is(f({format => 'numeric',%z}), '%04d%02d%02d%02d%02d%02dZ',       'numeric');

is(f({format => 'compact'}),    '%04d%02d%02d_%02d%02d%02d',       'compact');
is(f({format => 'compact',%z}), '%04d%02d%02d_%02d%02d%02dZ',      'compact');

is(f({format => 'iso8601'}),    '%04d-%02d-%02dT%02d:%02d:%02d',   'the famous iso8601');
is(f({format => 'iso8601',%z}), '%04d-%02d-%02dT%02d:%02d:%02dZ',  'the famous iso8601 with tz');
is(f({format => 'rfc3339'}),    '%04d-%02d-%02dT%02d:%02d:%02d',   'rfc3339 profile of iso8601');
is(f({format => 'rfc3339',%z}), '%04d-%02d-%02dT%02d:%02d:%02dZ',  'rfc3339 with tz');
is(f({format => 'w3cdtf' }),    '%04d-%02d-%02dT%02d:%02d:%02d',   'w3cdtf  profile of iso8601');
is(f({format => 'w3cdtf', %z}), '%04d-%02d-%02dT%02d:%02d:%02dZ',  'w3cdtf  with tz');

is(f({format => 'goober' }),    '%04d-%02d-%02dT%02d:%02d:%02d',   'unknown becomes default');
is(f({format => 'goober', %z}), '%04d-%02d-%02dT%02d:%02d:%02dZ',  'unknown with tz');

# pieces
is(f({date_sep => '+'}),        '%04d+%02d+%02dT%02d:%02d:%02d',   'date_sep');
is(f({dt_sep   => '+'}),        '%04d-%02d-%02d+%02d:%02d:%02d',   'dt_sep');
is(f({time_sep => '+'}),        '%04d-%02d-%02dT%02d+%02d+%02d',   'time_sep');
is(f({tz_sep   => '+'}),        '%04d-%02d-%02dT%02d:%02d:%02d',   'tz_sep (no tz)');
is(f({tz_sep   => '+',%z}),     '%04d-%02d-%02dT%02d:%02d:%02d+Z', 'tz_sep (with tz)');
is(f({tz       => 'Z'}),        '%04d-%02d-%02dT%02d:%02d:%02dZ',  'tz');

done_testing;
