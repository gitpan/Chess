package Chess::Piece::Knight;

use lib '/home/brian/src/perl/Chess';
use strict;
use Carp;
use Chess::Piece;
use Chess::Validator qw( validate_location );

use constant INVALID => undef;
use constant ILLEGAL => 0;
use constant OK => 1;

# Set this to 0 for production
use constant DEBUG => 1;

BEGIN {
    our @ISA = qw( Chess::Piece );
}

sub new {
    my $this = shift;
    my %options = @_;

    my $class = ref $this || $this;
    my $self = bless { }, $class;
    $self = $self->SUPER::new(%options, -type => 'Knight');
    return $self;
}

sub canmove {
    my $self = shift;
    my $location = shift;

    my ($rank, $file) = validate_location($location);
    if (!defined $rank || !defined $file) {
	carp "Chess::Piece::Knight::canmove(): error: invalid location '$location'";
	return INVALID;
    }
    my ($currank, $curfile) = validate_location($self->{location});
    if (!defined $currank || !defined $curfile) {
	carp "Chess::Piece::Knight::canmove(): error: invalid start location '$location'";
	return INVALID;
    }
    # there's only really 2 possibilities for a Knight move
    if (abs($currank - $rank) == 2) {
	if (abs($curfile - $file) != 1) {
	    carp "Chess::Piece::Knight::canmove(): error: illegal move '$location'" if DEBUG;
	    return ILLEGAL;
	}
    }
    elsif (abs($currank - $rank) == 1) {
	if (abs($curfile - $file) != 2) {
	    carp "Chess::Piece::Knight::canmove(): error: illegal move '$location'" if DEBUG;
	    return ILLEGAL;
	}
    }
    else {
	carp "Chess::Piece::Knight::canmove(): error: illegal move '$location'" if DEBUG;
	return ILLEGAL;
    }
    # The Chess::Piece::canmove() function will check for pinned pieces and capturing own pieces
    my $rc = $self->SUPER::canmove($location);
    return $rc;
}

1;
