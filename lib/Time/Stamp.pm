# vim: set sw=2 sts=2 ts=2 expandtab smarttab:
package Time::Stamp;
# ABSTRACT: Easy, readable, efficient timestamp functions

use strict;
use warnings;

# TODO: use collector?

use Sub::Exporter 0.982 -setup => {
  exports => [
    localstamp => \'_build_localstamp',
    gmstamp    => \'_build_gmstamp',
  ],
  groups => [
    stamps => [qw(localstamp gmstamp)],
  ]
};

# set up named formats with default values
my $formats = do {
  my %default = (
    date_sep => '-',
    dt_sep   => 'T', # ISO 8601
    time_sep => ':',
    tz_sep   => '',
    tz       => '',
  );
  my %blank = map { $_ => '' } keys %default;
  my $n = {
    default  => {%default},
    utc      => {%default, tz => 'Z'}, # using gmtime() we know we can add 'Z'
    easy     => {%default, dt_sep => ' ', tz_sep => ' '}, # easier to read
    numeric  => {%blank},
    compact  => {
      %blank,
      dt_sep   => '_', # visual separation
    },
  };
  # aliases
  $n->{gm} = $n->{utc};
  $n->{$_} = $n->{default} for qw(iso8601 rfc3339 w3cdtf);
  $n;
};

# we could offer a separate format_time_array() but currently
# I think the gain would be less than the cost of the extra function call:
# sub _build { return sub { format_time_array($arg, @_ or localtime) }; }
# sub format_time_array { sprintf(_format(shift), _ymdhms(@_)) }

sub _build_localstamp {
  my $format = _format($_[2]);
  return sub {
    sprintf($format, _ymdhms(@_ > 1 ? @_ : CORE::localtime(@_ ? $_[0] : time)));
  };
}

sub _build_gmstamp {
  my $format = _format({format => 'utc', %{$_[2]}});
  return sub {
    sprintf($format, _ymdhms(@_ > 1 ? @_ : CORE::gmtime(   @_ ? $_[0] : time)));
  };
}

sub _format {
  my ($arg) = @_;

  my $name = $arg->{format} || ''; # avoid undef
  $name = 'default'
    unless exists $formats->{$name};

  my %opt = (%{ $formats->{$name} }, %$arg);

  return
    join($opt{date_sep}, qw(%04d %02d %02d)) .
    $opt{dt_sep} .
    join($opt{time_sep}, qw(%02d %02d %02d)) .
    ($opt{tz} ? $opt{tz_sep} . $opt{tz} : '')
  ;
}

sub _ymdhms {
  return ($_[5] + 1900, $_[4] + 1, @_[3, 2, 1, 0]);
}

# define default localstamp and gmstamp in this package
# so that exporting is not strictly required
__PACKAGE__->import(qw(localstamp gmstamp));

1;

=for stopwords TODO timestamp

=head1 SYNOPSIS

  use Time::Stamp 'gmstamp';

  use Time::Stamp localstamp => { -as => 'ltime', format => 'compact' };

  use Time::Stamp -stamps => { dt_sep => ' ', date_sep => '/' };

  # the default configurations of localstamp and gmstamp
  # are available without importing into your namespace
  # but this is probably less useful
  $stamp = Time::Stamp::gmstamp($time);

=head1 DESCRIPTION

This module makes it easy to include timestamp functions
that are simple, easily readable, and fast.

Sometimes you desire a simple timestamp to add to a file name
or use as part of a generated data identifier.
The fastest and easiest thing to do is call L<time()|perlfunc/time>
to get a seconds-since-epoch integer.

Sometimes you get a seconds-since-epoch integer from another function
(like L<stat()|perlfunc/stat> for instance)
and maybe you want to store that in a database or send it across the network.

This integer timestamp works for these purposes,
but it's not easy to read.

If you're looking at a list of timestamps you have to fire up a perl
interpreter and copy and paste the timestamp into L<localtime()|perlfunc/time>
to figure out when that actually was.

You can pass the timestamp to C<scalar localtime($sec)>
(or C<scalar gmtime($sec)>)
but that doesn't sort well or parse easily,
isn't internationally friendly,
and contains characters that aren't friendly for file names or URIs
(or other places you may want to use it).

See L<perlport/Time and Date> for more discussion on useful timestamps.

For simple timestamps you can get the data you need from
L<perlfunc/localtime> and L<perlfunc/gmtime>
without incurring the resource cost of L<DateTime>
(or any other object for that matter).

So the aim of this module is to provide simple timestamp functions
so that you can have easy-to-use, easy-to-read timestamps efficiently.

=head1 FORMAT

For reasons listed elsewhere
the timestamps are always in order from largest unit to smallest:
year, month, day, hours, minutes, seconds.

The other characters of the stamp are configurable:

=for :list
* C<date_sep> - Character separating date components; Default: C<'-'>
* C<dt_sep>   - Character separating date and time;   Default: C<'T'>
* C<time_sep> - Character separating time components; Default: C<':'>
* C<tz_sep>   - Character separating time and timezone; Default: C<''>
* C<tz> - Time zone designator;  Default: C<''>

The following formats are predefined:

  default => see above descriptions
  iso8601 => \%default
  rfc3339 => \%default
  w3cdtf  => \%default
    "2010-01-02T13:14:15"

  easy    => like default but with a space as dt_sep and tz_sep (easier to read)
    "2010-01-02 13:14:15"
    "2010-01-02 13:14:15 Z"

  compact => condense date and time components and set dt_sep to '_'
    "20100102_131415"

  numeric => all options are '' so that only numbers remain
    "20100102131415"

  utc     => same as default but sets tz to 'Z'; this is the default for gmstamp
    "2010-01-02T12:14:15Z"

=head1 EXPORTS

This module uses L<Sub::Exporter>
to enable you to customize your timestamp function
but still create it as easily as possible.

=head1 SEE ALSO

=for :list
* L<perlport/Time and Date> - discussion on using portable, readable timestamps
* L<perlfunc/localtime> - built-in function
* L<perlfunc/gmtime> - built-in function
* L<Timestamp::Simple> - small, less efficient, non-customizable stamp
* L<Time::Piece> - object-oriented module for working with times
* L<DateTime::Tiny> - object-oriented module "with as little code as possible"
* L<DateTime> - large, powerful object-oriented system
* L<Time::localtime> - small object-oriented/named interface to C<localtime()>
* L<Time::gmtime> - small object-oriented/named interface to C<gmtime()>
* L<POSIX> - large module contained standard methods including C<strftime()>
* L<http://www.cl.cam.ac.uk/~mgk25/iso-time.html> - summary of C<ISO 8601>
* L<http://www.w3.org/TR/NOTE-datetime> - C<W3CDTF> profile of C<ISO 8601>
* L<http://www.ietf.org/rfc/rfc3339.txt> - C<RFC3339> profile of C<ISO 8601>

=head1 TODO

=begin :list

* Figure out a solution for including the timezone.
For C<gmtime()> there is none (which is easy).
C<< POSIX::strftime("%z", localtime) >> is not the most efficient way
to determine the offset, but it is in the core
(compared to L<Time::Zone> and L<Time::Timezone>).

* Allow an option for overwriting the globals
so that calling C<localtime> in scalar context will return
a stamp in the desired format.
The normal values will be returned in list context.

=cut
