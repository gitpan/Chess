package Chess::Validator;

use lib '/home/brian/src/perl/Chess';
use strict;
use Carp;
use Exporter;

use constant INVALID => undef;
use constant ILLEGAL => 0;
use constant OK => 1;

BEGIN {
    our @ISA = qw( Exporter );
    our @EXPORT = qw( );
    our @EXPORT_OK = qw( validate_location line_isopen is_check is_checkmate is_stalemate );
}

sub validate_location {
    my $loc = shift;

    $loc = uc $loc;

    if (length $loc != 2) {
	carp "Chess::Validator::validate_location(): error: invalid board location '$loc'";
	return INVALID;
    }
    my $file = ord(substr($loc, 0, 1)) - ord('A');
    my $rank = substr($loc, 1, 1) - 1;
    if ($file < 0 || $file > 7 || !defined $file) {
	carp "Chess::Validator::validate_move(): error: invalid file '", chr($file + ord('A')), "'";
	return INVALID;
    }
    if ($rank < 0 || $rank > 7 || !defined $rank) {
	carp "Chess::Validator::validate_move(): error: invalid rank @{[$rank + 1]}";
	return INVALID;
    }
    return wantarray ? ($rank, $file) : 1;
}

sub line_isopen {
    my $board = shift;
    my $loc1 = shift;
    my $loc2 = shift;

    my ($rank1, $file1) = validate_location($loc1);
    if (!defined $rank1 || !defined $file1) {
	carp "Chess::Validator::line_isopen(): error: invalid board location '$loc1'";
	return INVALID;
    }
    my ($rank2, $file2) = validate_location($loc2);
    if (!defined $rank2 || !defined $file2) {
	carp "Chess::Validator::line_isopen(): error: invalid board location '$loc2'";
	return INVALID;
    }
    # trivial case: a single square line will be considered open iff it is empty
    return ($board->square(validate_location($loc1)) ? 0 : 1) if lc $loc1 eq lc $loc2;
    unless ((abs($rank1 - $rank2) == abs($file1 - $file2)) ||
            ($rank1 - $rank2 == 0) || ($file1 - $file2 == 0)) {
        carp "Chess::Validator::line_isopen(): error: '$loc1' - '$loc2' is not a line!";
	return INVALID;
    }
    my $deltax;
    my $deltay;
    $deltax = 0 if $file1 == $file2;
    $deltax = 1 if $file1 < $file2;
    $deltax = -1 if $file1 > $file2;
    $deltay = 0 if $rank1 == $rank2;
    $deltay = 1 if $rank1 < $rank2;
    $deltay = -1 if $rank1 > $rank2;
    return 1 if !$deltax && !$deltay;
    # Credit to Cyril Scetbon <cyril.scetbon@wanadoo.fr for
    # debugging the following conditional expression
    while ( ($deltay ? (($rank1 += $deltay) != $rank2) : 1) && 
            ($deltax ? (($file1 += $deltax) != $file2) : 1) ){
	return 0 if defined ($board->{board}[$file1][$rank1]);
    }
    return 1;
}

sub is_check {
    my $board = shift;

    my $wking = $board->{kings}{White};
    my $bking = $board->{kings}{Black};

    foreach my $piece (@{ $board->{pieces}{White} }) {
	next if $piece eq $wking;
	return $bking if $piece->canmove($bking->{location});
    }
    foreach my $piece (@{ $board->{pieces}{Black} }) {
        next if $piece eq $bking;
	next if !$piece; # i.e. it's a captured piece
        return $wking if $piece->canmove($wking->{location});
    }
    return 0;
}

sub is_checkmate {
    my $board = shift;

    carp "Chess::Validator::is_checkmate(): warning: not implemented";
}

sub is_stalemate {
    my $board = shift;

    carp "Chess::Validator::is_stalemate(): warning: not implemented";
    # it is stalemate if !is_check($board), and foreach my $piece, !$piece->hasmoves
}

1;
