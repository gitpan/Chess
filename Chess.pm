package Chess;

use 5.006;
use strict;
use warnings;

require Exporter;
use Chess::Piece;
use Chess::Board;
use Chess::Validator qw( is_check line_isopen is_checkmate validate_location );

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Chess ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
    is_check
    line_isopen
    is_checkmate
    validate_location
    MOVE_OK
    MOVE_CAPTURE
    MOVE_PROMOTE
    MOVE_ENPASSANT
    MOVE_CASTLE
);
our $VERSION = '0.5';


# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Chess - Manipulate and validate a chessboard in Perl

=head1 SYNOPSIS

 use Chess;

 my $board = new Chess::Board;
 my $pawn = $board->square(validate_location('e2'));
 $pawn->move('e4', TRUE);

=head1 DESCRIPTION

This module provides object oriented methods to move pieces around on a
chessboard, and optionally validate the resulting positions (eg. is_check()).
Currently, it knows about all the rules of chess, and supports validation of
en passant captures and all castling rules. This module is in early development,
so it doesn't do anything particulary useful yet. Here is a run-down on the
more useful routines:

=over 4

=item Chess::Board::new()

Creates a new chessboard with all of the pieces in their correct location

=item Chess::Board::square($x, $y)

Returns the Chess::Piece at location (0-based) ($x, $y), or undef if the square
is empty.

=item Chess::Piece::move($loc, $validate)

Attempts to move the piece to location $loc on the board, validating the
legality of the move if $validate is TRUE. If the move results in a capture,
the captured piece can be retrieved with Chess::Board::capture.

=item Chess::Board::rollback

Rolls back the last move that was made on the chessboard

=item Chess::Board::movelist($colour)

Returns all moves made by $colour

=item Chess::Board::moveno($colour)

Returns the current move number for $colour

=item Chess::Validator::line_isopen($loc1, $loc2)

Returns true if the line defined between $loc1 and $loc2 is completely clear

=item Chess::Validator::is_check($board)

Returns the king which is currently in check on $board, or undef if no one is
in check

=item Chess::Validator::validate_location($algebraic)

Returns ($rank, $file) of the square in $algebraic notation, or undef if the
square is not a valid board location

=back

=head2 EXPORT

None by default.

Chess::Validator allows the export of line_isopen, is_check and
validate_location.


=head1 AUTHOR

Brian Richardson <brian@cubik.ca>


=head1 SEE ALSO

L<Meta::Chess>, L<Chess::PGN>.

=cut
