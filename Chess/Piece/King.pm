package Chess::Piece::King;

use lib '/home/brian/src/perl/Chess';
use strict;
use Carp;
use Chess::Piece;
use Chess::Validator qw( validate_location line_isopen is_check );

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
    $self = $self->SUPER::new(%options, -type => 'King');
    $self->{moved} = 0;
    return $self;
}

sub canmove {
    my $self = shift;
    my $loc = shift;

    my $location = $self->{location};
    my ($currank, $curfile) = validate_location($location);
    if (!defined $currank || !defined $curfile) {
	carp "Chess::Piece::King::canmove(): error: Invalid starting location '$location'";
	return INVALID;
    }
    my ($rank, $file) = validate_location($loc);
    if (!defined $rank || !defined $file) {
	carp "Chess::Piece::King::canmove(): error: Invalid location '$loc'";
	return INVALID;
    }
    if (lc $loc eq lc $location) {
	carp "Chess::Piece::King::canmove(): warning: piece is already at location '$location'!" if DEBUG;
	return OK;
    }
    my $board = $self->{board};
    # castling is special case
    if ((lc $location eq 'e1' && lc $loc eq 'c1') || (lc $location eq 'e8' && lc $loc eq 'c8')) {
	# queen side castle
	my $rook = $self->{colour} eq 'White' ? $board->square(validate_location('a1')) : 
	                                        $board->square(validate_location('a8'));
	if ($rook->{type} ne 'Rook') {
	    carp "Chess::Piece::King::canmove(): error: illegal move" if DEBUG;
	    return ILLEGAL;
	}
	if ($rook->{colour} ne $self->{colour}) {
	    carp "Chess::Piece::King::canmove(): error: illegal move" if DEBUG;
	    return ILLEGAL;
	}
	if ($rook->{moved}) {
	    carp "Chess::Piece::King::canmove(): error: that rook has already moved" if DEBUG;
	    return ILLEGAL;
	}
	if ($self->{moved}) {
	    carp "Chess::Piece::King::canmove(): error: your king has already moved" if DEBUG;
	    return ILLEGAL;
	}
	if (!line_isopen($board, $loc, $location)) {
	    carp "Chess::Piece::King::canmove(): error: illegal move" if DEBUG;
	    return ILLEGAL;
	}
	if (is_check($self->{board}) eq $self) {
	    carp "Chess::Piece::King::canmove(): error: can't castle out of check" if DEBUG;
	    return ILLEGAL;
	}
	# now see if the other squares are under attack
	# this is accomplished by moving to each of the two squares and
	# seeing if in check, then rolling both moves back
	$self->move($self->{colour} eq 'White' ? 'd1' : 'd8', undef); 
	if (is_check($self->{board}) eq $self) {
	    carp "Chess::Piece::King::canmove(): error: can't castle thru check";
	    $self->{board}->rollback;
	    return ILLEGAL;
	}
        $self->move($self->{colour} eq 'White' ? 'c1' : 'c8', undef);
	if (is_check($self->{board}) eq $self) {
	    carp "Chess::Piece::King::canmove(): error: can't castle thru check";
	    $self->{board}->rollback;
	    $self->{board}{lastmoved} = $self->{colour};
	    $self->{board}->rollback;
	    return ILLEGAL;
	}
	return OK;
    }
    elsif ((lc $location eq 'e1' && lc $loc eq 'g1') || ($location eq 'e8' && $loc eq 'g8')) {
	# king side castle
	my $rook = $self->{colour} eq 'White' ? $board->square(validate_location('h1')) : 
	                                        $board->square(validate_location('h8'));
	if ($rook->{type} ne 'Rook') {
	    carp "Chess::Piece::King::canmove(): error: illegal move" if DEBUG;
	    return ILLEGAL;
	}
	if ($rook->{colour} ne $self->{colour}) {
	    carp "Chess::Piece::King::canmove(): error: illegal move" if DEBUG;
	    return ILLEGAL;
	}
	if ($rook->{moved}) {
	    carp "Chess::Piece::King::canmove(): error: that rook has already moved" if DEBUG;
	    return ILLEGAL;
	}
	if ($self->{moved}) {
	    carp "Chess::Piece::King::canmove(): error: your king has already moved" if DEBUG;
	    return ILLEGAL;
	}
	if (!line_isopen($board, $loc, $location)) {
	    carp "Chess::Piece::King::canmove(): error: illegal move '$loc'" if DEBUG;
	    return ILLEGAL;
	}
	if (is_check($self->{board}) eq $self) {
	    carp "Chess::Piece::King::canmove(): error: can't castle out of check" if DEBUG;
	    return ILLEGAL;
	}
	$self->move($self->{colour} eq 'White' ? 'f1' : 'f8', undef); 
	if (is_check($self->{board}) eq $self) {
	    carp "Chess::Piece::King::canmove(): error: can't castle thru check";
	    $self->{board}->rollback;
	    return ILLEGAL;
	}
        $self->move($self->{colour} eq 'White' ? 'f1' : 'f8', undef);
	if (is_check($self->{board}) eq $self) {
	    carp "Chess::Piece::King::canmove(): error: can't castle thru check";
	    $self->{board}->rollback;
	    $self->{board}{lastmoved} = $self->{colour};
	    $self->{board}->rollback;
	    return ILLEGAL;
	}
	$self->{board}->rollback;
	$self->{board}{lastmoved} = $self->{colour};
	$self->{board}->rollback;
	return OK;
    }
    if ($currank != $rank && $curfile != $file && (abs($currank - $rank) > 1 || abs($curfile - $file) > 1)) {
	carp "Chess::Piece::King::canmove(): error: illegal move '$loc'" if DEBUG;
	return ILLEGAL;
    }
    my $board = $self->{board};
    my $start_rank = $rank > $currank ? $currank : $rank;
    my $end_rank = $rank > $currank ? $rank : $currank;
    my $start_file = $file > $curfile ? $curfile : $file;
    my $end_file = $file > $curfile ? $file : $curfile;
    return $self->SUPER::canmove($loc);
}

sub move {
    my $self = shift;
    my $loc = shift;
    my $validate = shift;

    my $location = $self->{location};
    my $board = $self->{board};
    # check for a valid castle first
    if (lc $location eq 'e8' && lc $loc eq 'c8' || lc $location eq 'e1' && $loc eq 'c1' ||
        lc $location eq 'e1' && lc $loc eq 'g1' || lc $location eq 'e8' && $loc eq 'g8') {
	if (!$self->canmove($loc)) {
	    carp "Chess::Piece::King::move(): error: unable to move to '$loc'";
	    return ILLEGAL;
	}
	if (lc $loc eq 'c1' || lc $loc eq 'c8') {
	    my $rook = $self->{colour} eq 'White' ? $board->square(validate_location('a1')) : 
	                                            $board->square(validate_location('a8'));
	    # move everything around
	    if ($self->{colour} eq 'White') {
	        $board->{board}[2][0] = $board->{board}[4][0];
		$board->{board}[4][0] = undef;
	        $board->{board}[3][0] = $board->{board}[0][0];
		$board->{board}[0][0] = undef;
		$board->{board}[3][0]{moved} = 1;
		$board->{board}[3][0]{location} = 'd1';
	    }
	    else {
	        $board->{board}[2][7] = $board->{board}[4][7];
		$board->{board}[4][7] = undef;
	        $board->{board}[3][7] = $board->{board}[0][7];
		$board->{board}[0][7] = undef;
		$board->{board}[3][7]{moved} = 1;
		$board->{board}[3][7]{location} = 'd8';
	    }
	    push @{ $board->{movelist}{$self->{colour}} }, { 
		piece => $self, 
		from => $location, 
		to => 'O-O-O',
		result => &Chess::Board::MOVE_CASTLE
	    };
	}
	else {
	    my $rook = $self->{colour} eq 'White' ? $board->square(validate_location('h1')) : 
	                                            $board->square(validate_location('h8'));
	    if ($self->{colour} eq 'White') {
		$board->{board}[6][0] = $board->{board}[4][0];
		$board->{board}[4][0] = undef;
		$board->{board}[5][0] = $board->{board}[7][0];
		$board->{board}[7][0] = undef;
		$board->{board}[5][0]{moved} = 1;
		$board->{board}[5][0]{location} = 'f1';
	    }
	    else {
		$board->{board}[6][7] = $board->{board}[4][7];
		$board->{board}[4][7] = undef;
		$board->{board}[5][7] = $board->{board}[7][7];
		$board->{board}[7][7] = undef;
		$board->{board}[5][7]{moved} = 1;
		$board->{board}[5][7]{location} = 'f8';
	    }
	    push @{ $board->{movelist}{$self->{colour}} }, { 
		piece => $self, 
		from => $location, 
		to => 'O-O', 
		result => &Chess::Board::MOVE_CASTLE 
	    };
	}
	$self->{moved} = 1;
	$self->{location} = $loc;
	$board->{lastmoved} = $self->{colour};
	return OK;
    }
    return $self->SUPER::move($loc, $validate);
}

sub reachable {
    my $self = shift;

    my @reachable;
    my ($rank, $file) = validate_location($self->{location});
    # 3 squares reachable to my left
    if ($file > 0) {
	push @reachable, (chr(ord('a') + $file) . $rank + 2) if $rank < 7;
	push @reachable, (chr(ord('a') + $file) . $rank + 1);
	push @reachable, (chr(ord('a') + $file) . $rank) if $rank > 0;
    }
    # 1 above me
    push @reachable, (chr(ord('a') + $file + 1) . $rank + 2) if $rank < 7;
    # 1 below me
    push @reachable, (chr(ord('a') + $file + 1) . $rank) if $rank > 0;
    # 3 squares to my right
    if ($file < 7) {
	push @reachable, (chr(ord('a') + $file + 2) . $rank + 2) if $rank < 7;
	push @reachable, (chr(ord('a') + $file + 2) . $rank + 1);
	push @reachable, (chr(ord('a') + $file + 2) . $rank) if $rank > 0;
    }
    return @reachable;
}

1;
