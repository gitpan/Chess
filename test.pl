# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
local $SIG{__WARN__} = sub { 1 };
BEGIN { plan tests => 13 };
use Chess;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.
# test 2 - create board
my $board = new Chess::Board;
ok(1);

# pawns
#
# test 3 - 2 squares forward
my $pawn = $board->square(validate_location('e2'));
ok($pawn->move('e4', TRUE), MOVE_OK);

# test 4 - 1 square forward
$pawn = $board->square(validate_location('d7'));
ok($pawn->move('d6', TRUE), MOVE_OK);

# test 5 - not allowed to move 2 squares anywhere else
$pawn = $board->square(validate_location('e4'));
ok($pawn->move('e6', TRUE), undef);

# test 6 - en passant capture
$pawn->move('e5');
$pawn = $board->square(validate_location('f7'));
$pawn->move('f5');
$pawn = $board->square(validate_location('e5'));
ok($pawn->move('f6', TRUE), MOVE_ENPASSANT);

# test 7 - board returns captured piece
my $capture = $board->capture;
ok($capture);

# test 8 - regular capture
$pawn = $board->square(validate_location('e7'));
$pawn->move('e5');
$pawn = $board->square(validate_location('f6'));
ok($pawn->move('g7', TRUE), MOVE_CAPTURE);
$capture = $board->capture;

# test 9 - promotion
$pawn = $board->square(validate_location('c7'));
$pawn->move('c5');
$pawn = $board->square(validate_location('g7'));
ok($pawn->move('f8', TRUE), MOVE_PROMOTE);
$capture = $board->capture;

# test 10 - knight moves
my $knight = $board->square(validate_location('b8'));
ok($knight->move('c6', TRUE), MOVE_OK);

# test 11 - illegal knight moves
$knight = $board->square(validate_location('b1'));
ok($knight->move('c4', TRUE), undef);

# test 12 - bishop moves
$knight->move('c3');
my $bishop = $board->square(validate_location('c8'));
ok($bishop->move('e6', TRUE), MOVE_OK);

# test 13 - illegal bishop moves
$bishop = $board->square(validate_location('f1'));
ok($bishop->move('h3', TRUE), undef);
$bishop->move('c4');

# test 14 - and so on... there's a lot of tests to write here, and i don't
# know how to do the t/00pawn type tests that DBI does
