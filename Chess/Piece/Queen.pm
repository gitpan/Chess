package Chess::Piece::Queen;

use lib '/home/brian/src/perl/Chess';
use strict;
use Carp;
use Chess::Piece;
use Chess::Validator qw( validate_location line_isopen );

use constant INVALID => undef;
use constant ILLEGAL => 0;
use constant OK => 1;

use constant DEBUG => 1;

BEGIN {
    our @ISA = qw( Chess::Piece );
}

sub new {
    my $this = shift;
    my %options = @_;

    my $class = ref $this || $this;
    my $self = bless { }, $class;
    $self = $self->SUPER::new(%options, -type => 'Queen');
    return $self;
}

sub canmove {
    my $self = shift;
    my $loc = shift;

    my $location = $self->{location};
    my ($currank, $curfile) = validate_location($location);
    if (!defined $currank || !defined $curfile) {
	carp "Chess::Piece::Queen::canmove(): error: Invalid starting location '$location'";
	return INVALID;
    }
    my ($rank, $file) = validate_location($loc);
    if (!defined $rank || !defined $file) {
	carp "Chess::Piece::Queen::canmove(): error: Invalid location '$loc'";
	return INVALID;
    }
    if (lc $loc eq lc $location) {
	carp "Chess::Piece::Queen::canmove(): warning: piece is already at location '$location'!" if DEBUG;
	return OK;
    }
    if (($curfile != $file && $currank != $rank) && abs($currank - $rank) != abs($curfile - $file)) {
	carp "Chess::Piece::Queen::canmove(): error: illegal move '$loc'" if DEBUG;
	return ILLEGAL;
    }
    my $board = $self->{board};
    my $start_rank = $rank > $currank ? $currank : $rank;
    my $end_rank = $rank > $currank ? $rank : $currank;
    my $start_file = $file > $curfile ? $curfile : $file;
    my $end_file = $file > $curfile ? $file : $curfile;
    if (!line_isopen($board, $location, $loc)) {
	carp "Chess::Piece::Queen::canmove(): error: that line is blocked" if DEBUG;
	return ILLEGAL;
    }
    return $self->SUPER::canmove($loc);
}

1;
