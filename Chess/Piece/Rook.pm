package Chess::Piece::Rook;

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
    $self = $self->SUPER::new(%options, -type => 'Rook');
    # we need to know if this rook has moved to check castling
    $self->{moved} = 0;
    return $self;
}

sub canmove {
    my $self = shift;
    my $loc = shift;

    my $location = $self->{location};
    my ($currank, $curfile) = validate_location($location);
    if (!defined $currank || !defined $curfile) {
	carp "Chess::Piece::Rook::canmove(): error: Invalid starting location '$location'";
	return INVALID;
    }
    my ($rank, $file) = validate_location($loc);
    if (!defined $rank || !defined $file) {
	carp "Chess::Piece::Rook::canmove(): error: Invalid location '$loc'";
	return INVALID;
    }
    if (lc $loc eq lc $location) {
	carp "Chess::Piece::Rook::canmove(): warning: piece is already at location '$location'!" if DEBUG;
	return OK;
    }
    if ($currank != $rank && $curfile != $file) {
	carp "Chess::Piece::Rook::canmove(): error: illegal move '$loc'" if DEBUG;
	return ILLEGAL;
    }
    my $board = $self->{board};
    my $start_rank = $rank > $currank ? $currank : $rank;
    my $end_rank = $rank > $currank ? $rank : $currank;
    my $start_file = $file > $curfile ? $curfile : $file;
    my $end_file = $file > $curfile ? $file : $curfile;
    if (!line_isopen($board, $location, $loc)) {
	carp "Chess::Piece::Rook::canmove(): error: that line is blocked" if DEBUG;
	return ILLEGAL;
    }
    return $self->SUPER::canmove($loc);
}

sub move {
    my $self = shift;
    my $location = shift;
    my $validate = shift;

    my $rc;
    if ($rc = $self->SUPER::move($location, $validate)) {
	$self->{moved} = 1;
    }
    return $rc;
}

1;
