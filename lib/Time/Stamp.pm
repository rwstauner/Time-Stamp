package Time::Stamp;
# ABSTRACT: Easy, readable, efficient timestamp functions

use strict;
use warnings;

use Sub::Exporter 0.982 -setup => {
	exports => [
		localstamp => \'_build_localstamp',
		gmstamp    => \'_build_gmstamp',
	],
	groups => [
		stamps => [qw(localstamp gmstamp)],
	]
};

our %Formats = (
	common     => '%04d-%02d-%02dT%02d:%02d:%02d',
	easy       => '%04d-%02d-%02d %02d:%02d:%02d',
	condensed  => '%04d%02d%02d_%02d%02d%02d',
	numeric    => '%04d%02d%02d%02d%02d%02d',
);

sub _build_localstamp {
	my $format = _format($_[2]->{format});
	return sub {
		sprintf($format, _ymdhms(CORE::localtime()));
	};
}

sub _build_gmstamp {
	my $format = _format($_[2]->{format});
	return sub {
		sprintf($format, _ymdhms(CORE::gmtime()));
	};
}

sub _format {
	return $Formats{ $_[0] || 'common' };
}

sub _ymdhms {
	return ($_[5] + 1900, $_[4] + 1, @_[3, 2, 1, 0]);
}

# define default localstamp and gmstamp in this package
# so that exporting is not strictly required
__PACKAGE__->import($_) for qw(localstamp gmstamp);

1;

=for stopwords TODO timestamp

=head1 SYNOPSIS

	use Time::Stamp 'gmstamp';
	use Time::Stamp localstamp => { -as => 'ltime', format => 'easy' };

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
but that doesn't sort well or parse easily
and contains characters that aren't friendly for things like file names.
(See L<perlport/Time and Date> for more discussion on useful timestamps).

For simple timestamps you can get the data you need from
L<perlfunc/localtime> and L<perlfunc/gmtime>
without incurring the resource cost of L<DateTime>
(or any other object for that matter).

So the aim of this module is to provide simple timestamp functions
so that you can have easy-to-use, easy-to-read timestamps efficiently.

=head1 EXPORTS

This module uses L<Sub::Exporter>
to enable you to customize your timestamp function
but still create it as easily as possible.

=head1 SEE ALSO

=for :list
* L<perlport/Time and Date>
* L<perlfunc/localtime>
* L<Timestamp::Simple>
* L<Time::Piece>
* L<DateTime::Tiny>
* L<DateTime>
* L<Time::localtime>
* L<Time::gmtime>
* L<POSIX>

=head1 TODO

=begin :list

* Figure out a solution for including the timezone.
For C<gmtime()> there is none (which is easy),
but I don't know a good, efficient way to determine the timezone code or offset
for use with C<localtime()>.  How does C<localtime()> determine the offset?

* Allow an option for overwriting the globals
so that calling C<localtime> in scalar context will return
a stamp in the desired format.
The normal values will be returned in list context.

=cut
