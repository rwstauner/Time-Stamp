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
  # should we offer { prefix => '', suffix => '' } ? is that really useful?
  # the stamps are easy enough to parse as is (the whole point of this module)
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
    easy     => {%default, dt_sep => ' ', tz_sep => ' '}, # easier to read
    numeric  => {%blank},
    compact  => {
      %blank,
      dt_sep   => '_', # visual separation
    },
  };
  # aliases
  $n->{$_} = $n->{default} for qw(iso8601 rfc3339 w3cdtf);
  $n;
};

# we could offer a separate format_time_array() but currently
# I think the gain would be less than the cost of the extra function call:
# sub _build { return sub { format_time_array($arg, @_ or localtime) }; }
# sub format_time_array { sprintf(_format(shift), _ymdhms(@_)) }

sub _build_localstamp {
  my ($class, $name, $arg, $col) = @_;
  my $format = _format($arg);
  return sub {
    sprintf($format, _ymdhms(@_ > 1 ? @_ : CORE::localtime(@_ ? $_[0] : time)));
  };
}

sub _build_gmstamp {
  my ($class, $name, $arg, $col) = @_;
  # add the Z for UTC (Zulu) time zone unless the numeric format is requested
  $arg = {tz => 'Z', %$arg}
    unless $arg->{format} && $arg->{format} eq 'numeric';
  my $format = _format($arg);
  return sub {
    sprintf($format, _ymdhms(@_ > 1 ? @_ : CORE::gmtime(   @_ ? $_[0] : time)));
  };
}

sub _format {
  my ($arg) = @_;

  my $name = $arg->{format} || ''; # avoid undef
  # we could return $arg->{format} unless exists $formats->{$name}; warn if no % found?
  # or just return $arg->{sprintf} if exists $arg->{sprintf};
  $name = 'default'
    unless exists $formats->{$name};

  my %opt = (%{ $formats->{$name} }, %$arg);

  # TODO: $opt{tz} = tz_offset() if $opt{guess_tz};

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

Currently there is no attempt to guess the time zone.
By default C<gmstamp> sets C<tz> to C<'Z'> (which you can override if desired).
If you are using C<gmstamp> (recommended for transmitting to another computer)
you don't need anything else.  If you are using C<localstamp> you are probably
keeping the timestamp on that computer (like the stamp in a log file)
and you probably aren't concerned with time zone since it isn't likely to change.

If you want to include a time zone (other than C<'Z'> for UTC)
the standards suggest using the offset value (like C<-0700> or C<+12:00>).
If you would like to determine the time zone offset you can do something like:

  use Time::Zone (); # or Time::Timezone
  use Time::Stamp localtime => { tz => Time::Zone::tz_offset() };

If, despite the recommendations, you want to use the local time zone code:

  use POSIX (); # included in perl core
  use Time::Stamp localtime => { tz => POSIX::strftime('%Z', localtime) };

These options are not included in this module since they are not recommended
and introduce unnecessary overhead (loading the afore mentioned modules).

=head1 EXPORTS

This module uses L<Sub::Exporter>
to enable you to customize your timestamp function
but still create it as easily as possible.

The customizations to the format are done at import
and stored in the custom function returned
to make the resulting function as fast as possible.

Each export accepts any of the keys listed in L</FORMAT>
as well as C<format> which can be the name of a predefined format.

  use Time::Stamp gmstamp => { dt_sep => ' ', tz => ' UTC' };

  use Time::Stamp gmstamp => { -as => shorttime, format => 'compact' };

Each timestamp function will return a string according to the time as follows:

=begin :list

* If called with no arguments C<time()> (I<now>) will be used.

=item *

A single argument should be an integer
(like that returned from C<time()> or C<stat()>).

=item *

More than one argument is assumed to be the list returned from
C<gmtime()> or C<localtime()> which can be useful if you previously called
the function and don't want to do it again.

=end :list

Most commonly the 0 or 1 argument form would be used,
but the shortcut of using a time array is provided
in case you already have the array so that you don't have to use
C<Time::Local> just to get the integer back.

The following functions are available for export
(nothing is exported by default):

=head2 gmstamp

  $stamp = gmstamp(); # equivalent to gmstamp(time())
  $stamp = gmstamp($seconds);
  $stamp = gmstamp(@gmtime);

Returns a string according to the format specified in the import call.

By default this function sets C<tz> to C<'Z'>
since C<gmtime()> returns values in C<UTC> (no time zone offset).

This is the recommended stamp as it is by default unambiguous
and useful for transmitting to another computer.

=head2 localstamp

  $stamp = localstamp(); # equivalent to localstamp(time())
  $stamp = localstamp($seconds);
  $stamp = localstamp(@localtime);

Returns a string according to the format specified in the import call.

By default this function does not include a time zone indicator.

This function can be useful for log files or other values that stay
on the machine where time zone is not important and/or is constant.

=head2 -stamps

This is a convenience group for importing both L</gmstamp> and L</localstamp>.

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

=item *

Allow an option for overwriting the globals
so that calling C<localtime> in scalar context will return
a stamp in the desired format.
The normal values will be returned in list context.

* Include the fractional portion of the seconds if present?

=end :list

=cut
