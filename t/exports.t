# vim: set sw=2 sts=2 ts=2 expandtab smarttab:
use strict;
use warnings;
use Test::More 0.96;
use Time::Local (); # core

# this script is testing exports/options (which means gmtime *and* localtime)
# so to avoid trouble with unknown time zones don't bother to mock time() just use regexps

# defaults
{ package # shh...
  Moe; use Time::Stamp qw(gmstamp localstamp);
}

like(Moe::gmstamp,    qr/^ \d{4} - \d{2} - \d{2} T \d{2} : \d{2} : \d{2} Z$/x, 'default gmstamp');
like(Moe::localstamp, qr/^ \d{4} - \d{2} - \d{2} T \d{2} : \d{2} : \d{2}  $/x,  'default localstamp');

# separators
{ package # shh...
  Larry; use Time::Stamp
    gmstamp    => {date_sep => '/', dt_sep => '_', tz_sep => '@'},
    localstamp => {time_sep => '.', tz_sep => '@'};
}

like(Larry::gmstamp,    qr#^ \d{4} / \d{2} / \d{2} _ \d{2}  : \d{2}  : \d{2} @ Z$ #x, 'gmstamp');
like(Larry::localstamp, qr#^ \d{4} - \d{2} - \d{2} T \d{2} \. \d{2} \. \d{2}    $ #x, 'localstamp');

# names
{ package # shh...
  Curly;
  BEGIN {
    my @imports;
    foreach my $name ( qw(easy numeric compact iso8601) ){
      push(@imports, $_.'stamp' => {format => $name, -as => $_.$name })
        for qw(gm local);
    }
    require Time::Stamp;
    Time::Stamp->import(@imports);
  }
}

like(Curly::gmeasy,    qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} Z$/, 'gmstamp easy');
like(Curly::localeasy, qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/,   'localstamp easy');

like(Curly::gmnumeric,    qr/^\d{4} \d{2} \d{2} \d{2} \d{2} \d{2}$/x, 'gmstamp numeric');
like(Curly::localnumeric, qr/^\d{4} \d{2} \d{2} \d{2} \d{2} \d{2}$/x, 'localstamp numeric');

like(Curly::gmcompact,    qr/^\d{4} \d{2} \d{2} _ \d{2} \d{2} \d{2} Z$/x, 'gmstamp compact');
like(Curly::localcompact, qr/^\d{4} \d{2} \d{2} _ \d{2} \d{2} \d{2}$/x, 'localstamp compact');

like(Curly::gmiso8601,    qr/^\d{4} - \d{2} - \d{2} T \d{2} : \d{2} : \d{2} Z$/x, 'gmstamp iso8601');
like(Curly::localiso8601, qr/^\d{4} - \d{2} - \d{2} T \d{2} : \d{2} : \d{2}$/x, 'localstamp iso8601');

# overwrite named format
{ package # shh...
  Shemp; use Time::Stamp
    gmstamp    => {format => 'compact', dt_sep => '||', tz_sep => '-'},
    localstamp => {tz => '0000', tz_sep => '.', format => 'numeric'};
}

like(Shemp::gmstamp,    qr/^\d{4} \d{2} \d{2} \|\| \d{2} \d{2} \d{2} -Z$/x, 'gmstamp compact override');
like(Shemp::localstamp, qr/^\d{4} \d{2} \d{2}      \d{2} \d{2} \d{2} \. 0000$/x, 'localstamp numeric override');

# group
{ package # shh...
  Joe; use Time::Stamp -stamps => {format => 'compact'};
}

like(Joe::gmstamp,    qr/^\d{4} \d{2} \d{2} _ \d{2} \d{2} \d{2} Z$/x, 'gmstamp compact');
like(Joe::localstamp, qr/^\d{4} \d{2} \d{2} _ \d{2} \d{2} \d{2}$/x, 'localstamp compact');

# parsers
{ package # shh...
  CurlyJoe; use Time::Stamp
    'parsegm',
    # how's this for 'contrived':
    parsegm    => { -as => 'parsegs', regexp =>  q/^3(\d{4})99(\d{2})99(\d{2})\D+(\d{2})\D*(\d{2})\D*(\d{2})$/},
    parselocal => { -as => 'parselr',  regexp => qr/(\d+).(\d+).(\d+)=(\d+):(\d+):(\d+)/};
}

is(CurlyJoe::parsegm('20101230  171819'),     Time::Local::timegm(   19, 18, 17, 30, 11, 110), 'parsestamp to timegm');
is(CurlyJoe::parsegs('3201099129930_171819'), Time::Local::timegm(   19, 18, 17, 30, 11, 110), 'parsestamp to timegm');
is(CurlyJoe::parselr('1998/11/29=04:05:06' ), Time::Local::timelocal( 6,  5,  4, 29, 10,  98), 'parsestamp to timelocal');

# shortcuts
{ package # shh...
  RanOutOfStooges; use Time::Stamp qw( local-compact gm-easy );
}

like(RanOutOfStooges::gmstamp,    qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} Z$/,  'gm-easy shortcut');
like(RanOutOfStooges::localstamp, qr/^\d{4} \d{2} \d{2} _ \d{2} \d{2} \d{2}$/x, 'local-compact shortcut');

# collector
# TODO

done_testing;
