package Chess::Piece;

use Carp;
use lib '/home/brian/src/perl/Chess';
use strict;
use Chess::Validator qw( validate_location is_check );
use Chess::Board;
use Chess::Piece::Pawn;
use Chess::Piece::Knight;
use Chess::Piece::Bishop;
use Chess::Piece::Rook;
use Chess::Piece::Queen;
use Chess::Piece::King;

use constant FAIL => undef;
use constant INVALID => undef;
use constant ILLEGAL => 0;
use constant OK => 1;

my @VALID_PIECES = ( 'Pawn', 'Knight', 'Bishop', 'Rook', 'Queen', 'King' );
my @VALID_COLOURS = ( 'Black', 'White' );

# Please don't call this directly: Use the appropriate child class
sub new {
    my $this = shift;
    my %options = @_;

    my $class = ref $this || $this;
    if ($class eq 'Chess::Piece') {
	carp "Chess::Piece::new(): error: Do not call me directly, use one of my subclasses";
	return FAIL;
    }
    my $type = exists $options{-type} ? $options{-type} : $options{type};
    my $colour = (exists $options{-colour} ? $options{-colour} : $options{colour}) ||
                 (exists $options{-color} ? $options{-color} : $options{colour});
    my $location = exists $options{-location} ? $options{-location} : $options{location};
    my $board = exists $options{-board} ? $options{-board} : $options{board};

    if (!grep @VALID_PIECES, $type) {
	carp "Chess::Piece::new(): error: Unknown piece type '$type'";
	return FAIL;
    }
    if (!grep @VALID_COLOURS, $colour) {
	carp "Chess::Piece::new(): error: Unknown colour '$colour'";
	return FAIL;
    }
    if (!validate_location($location)) {
	carp "Chess::Piece::new(): error: Invalid location '$location'";
	return FAIL;
    }
    if (!(ref $board eq 'Chess::Board')) {
	carp "Chess::Piece::new(): error: No valid Chess::Board object specified";
	return FAIL;
    }
    my $self = {
	type => $type,
	colour => $colour,
	location => $location,
	board => $board
    };
    return bless $self, $class;
}

sub canmove ($) {
    my $self = shift;
    my $location = shift;

    my ($rank, $file) = validate_location($location);
    my $board = $self->{board};
    if (!defined $rank || !defined $file) {
	carp "Chess::Piece::canmove(): error: Invalid location '$location'";
	return FAIL;
    }
    # Check for checks, etc. here
    my $piece;
    if (defined ($piece = $self->{board}->square($rank, $file))) {
	if ($piece->{colour} eq $self->{colour}) {
	    carp "Chess::Piece::canmove(): error: can't capture your own piece";
	    return ILLEGAL;
	}
    }
    return OK;
}


sub move ($$) {
    my $self = shift;
    my $location = shift;
    my $validate = shift;

    if (!validate_location($location)) {
	carp "Chess::Piece::move(): error: Invalid location '$location'";
	return FAIL;
    }
    if ($validate) {
	if (!$self->canmove($location)) {
	    carp "Chess::Piece::move(): error: Illegal move to '$location'";
	    return FAIL;
	}
    }
    my $board = $self->{board};
    my $rc = $board->move($self, $location, $validate);
    if (!$rc) {
	carp "Chess::Piece::move(): error: Chess::Board couldn't move to '$location'";
	return FAIL;
    }
    $self->{location} = $location;
    return $rc;
}

sub hasmoves {
    my $self = shift;

    my @reachable = $self->reachable;
    foreach my $loc (@reachable) { return 1 if $self->canmove($loc) }
    return 0;
}

1;

