package Chess::Board;

use strict;
use lib '/home/brian/src/perl/Chess';
use Carp;
use Chess::Piece;
use Chess::Validator qw( validate_location is_check );
use Exporter;

use constant FAIL => undef;
use constant MOVE_OK => 1;
use constant MOVE_CAPTURE => 2;
use constant MOVE_ENPASSANT => 3;
use constant MOVE_PROMOTE => 4;
use constant MOVE_CASTLE => 5;

BEGIN {
    our @ISA = qw( Exporter );
    our @EXPORT = qw( MOVE_OK MOVE_CAPTURE MOVE_ENPASSANT MOVE_PROMOTE MOVE_CASTLE );
}

sub new {
    my $this = shift;

    my $class = ref $this || $this;
    my $self = {
	board => [ [ undef, undef, undef, undef, undef, undef, undef, undef ],
	           [ undef, undef, undef, undef, undef, undef, undef, undef ],
	           [ undef, undef, undef, undef, undef, undef, undef, undef ],
	           [ undef, undef, undef, undef, undef, undef, undef, undef ],
	           [ undef, undef, undef, undef, undef, undef, undef, undef ],
	           [ undef, undef, undef, undef, undef, undef, undef, undef ],
	           [ undef, undef, undef, undef, undef, undef, undef, undef ],
	           [ undef, undef, undef, undef, undef, undef, undef, undef ] ],
	pieces => { White => [ ], Black => [ ] },
	movelist => { White => [ ], Black => [ ] },
	moveno => { White => 0, Black => 0 },
	lastmoved => undef,
	capture => undef,
	kings => { White => undef, Black => undef }
    };
    bless $self, $class;
    # set up all the pawns
    my $c = 0;
    foreach my $file (qw( a b c d e f g h )) {
	my $wpawn = new Chess::Piece::Pawn(-colour => 'White', -location => "${file}2", -board => $self);
	my $bpawn = new Chess::Piece::Pawn(-colour => 'Black', -location => "${file}7", -board => $self);
        $self->{board}[$c][1] = $wpawn;
	$self->{board}[$c][6] = $bpawn;
	push @{ $self->{pieces}{White} }, $wpawn;
	push @{ $self->{pieces}{Black} }, $bpawn;
	$c++;
    }
    # Rooks
    foreach my $file qw( a h ) {
        my $wrook = new Chess::Piece::Rook(-colour => 'White', -location => "${file}1", -board => $self);
	my $brook = new Chess::Piece::Rook(-colour => 'Black', -location => "${file}8", -board => $self);
	$c = ($file eq 'a' ? 0 : 7);
	$self->{board}[$c][0] = $wrook;
	$self->{board}[$c][7] = $brook;
	push @{ $self->{pieces}{White} }, $wrook;
	push @{ $self->{pieces}{Black} }, $brook;
    }
    # Knights
    foreach my $file qw( b g ) {
	my $wknight = new Chess::Piece::Knight(-colour => 'White', -location => "${file}1", -board => $self);
	my $bknight = new Chess::Piece::Knight(-colour => 'Black', -location => "${file}8", -board => $self);
	$c = ($file eq 'b' ? 1 : 6);
	$self->{board}[$c][0] = $wknight;
	$self->{board}[$c][7] = $bknight;
	push @{ $self->{pieces}{White} }, $wknight;
	push @{ $self->{pieces}{Black} }, $bknight;
    }
    # Bishops
    foreach my $file qw( c f ) {
	my $wbishop = new Chess::Piece::Bishop(-colour => 'White', -location => "${file}1", -board => $self);
	my $bbishop = new Chess::Piece::Bishop(-colour => 'Black', -location => "${file}8", -board => $self);
	$c = ($file eq 'c' ? 2 : 5);
	$self->{board}[$c][0] = $wbishop;
	$self->{board}[$c][7] = $bbishop;
	push @{ $self->{pieces}{White} }, $wbishop;
	push @{ $self->{pieces}{Black} }, $bbishop;
    }
    # Queen
    my $wqueen = new Chess::Piece::Queen(-colour => 'White', -location => 'd1', -board => $self);
    my $bqueen = new Chess::Piece::Queen(-colour => 'Black', -location => 'd8', -board => $self);
    $self->{board}[3][0] = $wqueen;
    $self->{board}[3][7] = $bqueen;
    push @{ $self->{pieces}{White} }, $wqueen;
    push @{ $self->{pieces}{Black} }, $bqueen;
    # King
    my $wking = new Chess::Piece::King(-colour => 'White', -location => 'e1', -board => $self);
    my $bking = new Chess::Piece::King(-colour => 'Black', -location => 'e8', -board => $self);
    $self->{board}[4][0] = $wking;
    $self->{board}[4][7] = $bking;
    push @{ $self->{pieces}{White} }, $wking;
    push @{ $self->{pieces}{Black} }, $bking;
    $self->{kings}{White} = $wking;
    $self->{kings}{Black} = $bking;
    return $self;
}

sub square ($$) {
    my $self = shift;
    my $rank = shift;
    my $file = shift;

    return $self->{board}[$file][$rank];
}

sub move ($$$) {
    my $self = shift;
    my $piece = shift;
    my $location = shift;
    my $validate = shift;

    my $colour = $piece->{colour};
    if ($validate && $colour eq $self->{lastmoved}) {
	carp "Chess::Board::move(): error: $colour just moved!";
	return FAIL;
    }
    $self->{moveno}{$colour}++;
    # note: there is no verification done here: the piece that requested the move is responsible for that
    my ($rank, $file) = validate_location($piece->{location});
    my ($new_rank, $new_file) = validate_location($location);
    if (!defined $rank || !defined $file || !defined $new_rank || !defined $new_file) {
	carp "Chess::Board::move(): invalid location '", $piece->{location}, "'";
	return FAIL;
    }
    $self->{lastmoved} = $piece->{colour};
    # Log the move first so we can rollback, etc.
    if ($self->{capture} = $self->{board}[$new_file][$new_rank]) {
        $self->{board}[$new_file][$new_rank] = $piece;
        undef $self->{board}[$file][$rank];
        push @{ $self->{movelist}{$colour} }, { piece => $piece, 
	                                        from => $piece->{location}, 
						to => $location,
					        result => MOVE_CAPTURE };
	if ($validate && is_check($self)) {
	    carp "Chess::Board::move(): error: $colour is in check!";
	    $self->rollback;
	    return FAIL;
	}
	return MOVE_CAPTURE;
    }
    else {
	$self->{board}[$new_file][$new_rank] = $piece;
	undef $self->{board}[$file][$rank];
        push @{ $self->{movelist}{$colour} }, { piece => $piece, 
	                                        from => $piece->{location}, 
						to => $location,
					        result => MOVE_OK };
	if ($validate && is_check($self)) {
	    carp "Chess::Board::move(): error: $colour is in check!";
	    $self->rollback;
	    return FAIL;
	}
        return MOVE_OK;
    }
}

sub capture {
    my $self = shift;

    my $capture = $self->{capture};
    return undef unless $capture;
    my $colour = $capture->{colour};
    my $i = 0;
    foreach my $piece (@{ $self->{pieces}{$colour} }) {
	delete $self->{pieces}{$colour}[$i] if $capture eq $piece;
	$i++;
    }
    $capture->{location} = 'captured';
    undef $self->{capture};
    return $capture;
}

sub movelist {
    my $self = shift;
    my $colour = shift;
    my $moveno = shift;

    if (!$moveno) {
	if (!$colour) {
	    return \(@{ $self->{movelist}{White} }, @{ $self->{movelist}{Black} });
	}
	else {
	    return \@{ $self->{movelist}{$colour} };
	}
    }
    else {
	if (!$colour) {
	    return ($self->{movelist}{White}[$moveno-1], $self->{movelist}{Black}[$moveno-1]);
	}
	else {
	    return $self->{movelist}{$colour}[$moveno-1];
	}
    }
}

sub moveno {
    my $self = shift;
    my $colour = shift;

    return $colour ? $self->{moveno}{$colour} : ($self->{moveno}{White}, $self->{moveno}{Black});
}

sub rollback {
    my $self = shift;

    my $colour = $self->{lastmoved};
    my $move = $self->{movelist}{$colour}[$self->moveno($colour) - 1];
    my ($rank, $file) = validate_location($move->{from});
    my $piece = $self->square(validate_location($move->{to}));
    $self->{board}[$file][$rank] = $piece;
    if ($self->{capture}) {
	my ($crank, $cfile) = validate_location($self->{capture}{location});
	$self->{board}[$cfile][$crank] = $self->{capture};
	undef $self->{capture};
    }
    else {
	($rank, $file) = validate_location($move->{to});
	delete $self->{board}[$file][$rank];
    }
    undef $self->{movelist}{$colour}[$self->moveno($colour) - 1];
    $self->{lastmoved} = ($colour eq 'White' ? 'Black' : 'White'); 
    $self->{moveno}{$colour}--;
}

1;
