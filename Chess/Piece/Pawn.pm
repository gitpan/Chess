package Chess::Piece::Pawn;

use lib '/home/brian/src/perl/Chess';
use strict;
use Carp;
use Chess::Piece;
use Chess::Validator qw( validate_location );
use Chess::Board;

use constant INVALID => undef;
use constant ILLEGAL => 0;
use constant OK => 1;
use constant ENPASSANT => 2;

# change to 0 if not debugging
use constant DEBUG => 1;

BEGIN {
    our @ISA = qw( Chess::Piece );
}

sub new {
    my $this = shift;
    my %options = @_;

    my $class = ref $this || $this;
    my $self = bless { }, $class;
    $self = $self->SUPER::new(%options, -type => 'Pawn');
    return $self;
}

sub canmove {
    my $self = shift;
    my $location = shift;

    my ($rank, $file) = validate_location($location);
    my $colour = $self->{colour};
    my $is_ep = 0;
    if (!defined $rank || !defined $file) {
	carp "Chess::Piece::Pawn::canmove(): error: invalid location '$location'";
	return INVALID;
    }
    if (!$colour) {
	carp "Chess::Piece::Pawn::canmove(): error: invalid piece colour '$colour'";
	return INVALID;
    }
    my $loc = $self->{location};
    my ($currank, $currfile) = validate_location($loc);
    if (!defined $currank || !defined $currfile) {
        carp "Chess::Piece::Pawn::canmove(): error: invalid current location '$loc'";
        return INVALID;
    }
    # captures diagonally
    if (abs ($currfile - $file) == 1) {
	if ($colour eq 'White') {
	    if ($rank - $currank != 1) {
		carp "Chess::Piece::Pawn::canmove(): error: illegal move '$location'";
		return ILLEGAL;
	    }
	}
	else {
	    if (($currank - $rank) != 1) {
		carp "Chess::Piece::Pawn::canmove(): error: illegal move '$location'";
		return ILLEGAL;
	    }
	}
	# make sure there's a piece in that square;
	my $piece;
	my $board = $self->{board};
	if (!defined ($piece = $self->{board}->square($rank, $file))) {
	    # check for en passant capture
	    my $moveno = $board->moveno($self->{colour});
	    my $lastmove;
	    if ($colour eq 'White') {
		$lastmove = $board->movelist('Black', $moveno);
	    }
	    else {
		$lastmove = $board->movelist('White', $moveno + 1);
	    }
	    if ($lastmove->{piece}{type} ne 'Pawn') {
		carp "Chess::Piece::Pawn::canmove(): error: can only capture pawns en passant" if DEBUG;
		return ILLEGAL;
	    }
	    my ($lastrank, $lastfile) = validate_location($lastmove->{from});
	    my ($torank, $tofile) = validate_location($lastmove->{to});
	    if (!defined $lastrank || !defined $lastfile || !defined $torank || !defined $tofile) {
		carp "Chess::Piece::Pawn::canmove(): error: invalid move list data!";
		return undef;
	    }
	    if ($file != $tofile) {
		carp "Chess::Piece::Pawn::canmove(): error: can only capture en passant on subsequent turn";
		return ILLEGAL;
	    }
	    if ($colour eq 'White') {
		if ($lastrank != 6 || $torank != 4) {
		    carp "Chess::Piece::Pawn::canmove(): error: that's not a valid en passant capture" if DEBUG;
		    return ILLEGAL;
		}
	    }
	    else {
		if ($lastrank != 1 || $torank != 3) {
		    carp "Chess::Piece::Pawn::canmove(): error: that's not a valid en passant capture" if DEBUG;
		    return ILLEGAL;
		}
	    }
	    $is_ep = 1;
	}
	# make sure it's the right colour
	if ($piece->{colour} eq $colour) {
	    carp "Chess::Piece::Pawn::canmove(): error: can't capture my own piece! '$location'" if DEBUG;
	    return ILLEGAL;
	}
	return $is_ep ? ENPASSANT : OK;
    }
    # else
    my $board = $self->{board};
    if ($board->square(validate_location($location))) {
	carp "Chess::Piece::Pawn::canmove(): error: pawns can only capture diagonally" if DEBUG;
	return ILLEGAL;
    }
    if ($currfile != $file) {
	carp "Chess::Piece::Pawn::canmove(): error: illegal move '$location'" if DEBUG;
	return ILLEGAL;
    }
    if ($colour eq 'White') {
	# can move forward 2 squares at the beginning
	if (!($currank == 1 && ($rank - $currank == 2))) {
	    if ($rank - $currank != 1) {
		carp "Chess::Piece::Pawn::canmove(): error: illegal move '$location'" if DEBUG;
		return ILLEGAL;
	    }
	    else {
		return OK;
	    }
	}
	else {
	    return OK;
	}
    }
    else {
	# can move forward 2 squares at the beginning
	if (!($currank == 6 && ($currank - $rank == 2))) {
	    if ($currank - $rank != 1) {
		carp "Chess::Piece::Pawn::canmove(): error: illegal move '$location'" if DEBUG;
		return ILLEGAL;
	    }
	    else {
		return OK;
	    }
	}
	else {
	    return OK;
	}
    }
}

# have to override move to make en passant captures
sub move ($$$) {
    my $self = shift;
    my $location = shift;
    my $validate = shift;

    my ($rank, $file) = validate_location($location);
    if (!defined $rank || !defined $file) {
	carp "Chess::Piece::Pawn::move(): error: invalid location '$location'";
	return INVALID;
    }
    my $board = $self->{board};
    my $colour = $self->{colour};
    my $moveno = $board->moveno($colour);
    my $is_ep = ($self->canmove($location) == ENPASSANT);
    if ($is_ep) {
	# this is kinda of a hack -- move the e.p. captured pawn back a space without going
	# through usual channels. this way we still capture it. then we update the result to
	# say that it was an en passant capture
        # grab the piece that needs to be moved back:
	my $lastmove = $board->movelist($colour eq 'White' ? 'Black' : 'White', $colour eq 'White' ? $moveno : $moveno + 1);
	my $to = $lastmove->{to};
	my ($oldrank, $oldfile) = validate_location($to);
	if (!defined $oldrank or !defined $oldfile) {
	    carp "Chess::Piece::Pawn::move(): error: invalid move list data";
	    return INVALID;
	}
	my $newrank;
	if ($colour eq 'White') {
	    $newrank = $oldrank + 1;
	}
	else {
	    $newrank = $oldrank - 1;
	}
	$board->{board}[$oldfile][$newrank] = $board->{board}[$oldfile][$oldrank];
	undef $board->{board}[$oldfile][$oldrank];
    }
    my $rc = $self->SUPER::move($location, $validate);
    if ($is_ep) { $board->{movelist}{$colour}[$moveno]{result} = &Chess::Board::MOVE_ENPASSANT }
    if ($colour eq 'White' && $rank == 7) {
	$board->{movelist}{$colour}[$moveno]{result} = &Chess::Board::MOVE_PROMOTE;
	return &Chess::Board::MOVE_PROMOTE;
    }
    elsif ($colour eq 'Black' && $rank == 0) {
	$board->{movelist}{$colour}[$moveno]{result} = &Chess::Board::MOVE_PROMOTE;
	return &Chess::Board::MOVE_PROMOTE;
    }
    return $is_ep ? &Chess::Board::MOVE_ENPASSANT : $rc;
}

1;
