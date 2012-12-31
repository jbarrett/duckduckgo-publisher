package DDG::App::Publisher;
# ABSTRACT: The application class

=head1 SYNOPSIS

=cut

use MooX;
use MooX::Options protect_argv => 0;
use Path::Class;
use DDG::Publisher;

=attr no_compression

If this is deactivated the compression will not used, which speeds up the
things for development.

=cut

option no_compression => (
	is => 'ro',
	predicate => 1,
);

=attr dryrun

If this option is activated the publisher will not generate any files and
will just execute the code so that tokens and generatly sanity of the code
can be checked. This option requires a filename to be given, so this is used
for the dryrun of L<Locale::Simple>.

=cut

option dryrun => (
	format => 's',
	is => 'ro',
	predicate => 1,
);

=attr site_only

Use this option to only execute one specific file. You can use it several
times. Give the classname of the site you want to execute with the
B<DDG::Publisher::Site::> part. This option can be given several times.

=cut

option site_only => (
	format => 's',
	is => 'ro',
	predicate => 1,
);

=method run

This method gets executed for the run of the publisher

=cut

sub run {
	my ( $self ) = @_;

	#
	# Getting the target directory from $ENV{DDG_PUBLISHER_TARGETDIR}
	# or from command line.
	#

	my $target = @ARGV
		? shift @ARGV
		: defined $ENV{DDG_PUBLISHER_TARGETDIR}
			? $ENV{DDG_PUBLISHER_TARGETDIR}
			: die "Require a target path or DDG_PUBLISHER_TARGETDIR set";
	my $dir = dir($target)->absolute;
	my $publisher = DDG::Publisher->new(
		$self->has_no_compression ? ( no_compression => $self->no_compression ) : (),
		$self->has_dryrun ? ( dryrun => $self->dryrun ) : (),
		$self->has_site_only ? ( site_classes => [$self->site_only] ) : (),
	);
	print "Publishing to ".$dir." ... \n";
	my $count;
	eval {
		$count = $publisher->publish_to($dir);
	};
	if ($@) {
		print "\nFAILED: ".$@;
		exit 1;
	} else {
		print "\n".$count." files generated\n";
	}
}

1;