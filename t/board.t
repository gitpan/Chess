use Test::Simple tests => 36;

use Chess::Board;
use List::Compare;

sub compare_lists {
    my ($list1, $list2) = @_;
    my $lc = List::Compare->new('-a', $list1, $list2);
    return $lc->is_LequivalentR();
}

ok( Chess::Board->square_is_valid('e4') );
ok( !Chess::Board->square_is_valid('q9') );
ok( Chess::Board->get_color_of('a1') eq 'dark' );
ok( Chess::Board->get_color_of('a8') eq 'light' );
ok( Chess::Board->get_color_of('e4') eq 'light' );
ok( !defined(Chess::Board->square_left_of('a4')) );
ok( !defined(Chess::Board->square_right_of('h7')) );
ok( !defined(Chess::Board->square_up_from('f8')) );
ok( !defined(Chess::Board->square_down_from('c1')) );
ok( Chess::Board->square_left_of('e4') eq 'd4' );
ok( Chess::Board->square_right_of('e4') eq 'f4' );
ok( Chess::Board->square_down_from('e4') eq 'e3' );
ok( Chess::Board->square_up_from('e4') eq 'e5' );
ok( Chess::Board->horz_distance("a3", "f6") == 5 );
ok( Chess::Board->vert_distance("a1", "d5") == 4 );
ok( Chess::Board->add_horz_distance("e4", 3) eq "h4" );
ok( Chess::Board->add_vert_distance("e4", 4) eq "e8" );
@a1_h8_diag = qw/a1 b2 c3 d4 e5 f6 g7 h8/;
@squares_in_line = Chess::Board->squares_in_line("a1", "h8");
ok( compare_lists(\@a1_h8_diag, \@squares_in_line) );
@e_file = qw/e1 e2 e3 e4 e5 e6 e7 e8/;
@squares_in_line = Chess::Board->squares_in_line("e1", "e8");
ok( compare_lists(\@e_file, \@squares_in_line) );
@rank_4 = qw/a4 b4 c4 d4 e4 f4 g4 h4/;
@squares_in_line = Chess::Board->squares_in_line("a4", "h4");
ok( compare_lists(\@rank_4, \@squares_in_line) );
$board = Chess::Board->new();
ok( ref($board) eq 'Chess::Board' );
$clone = $board->clone();
ok( $board ne $clone );
$board->set_piece_at('e4', 42);
$clone->set_piece_at('e3', 42);
$b_piece1 = $board->get_piece_at('e4');
$b_piece2 = $board->get_piece_at('e3');
$c_piece1 = $clone->get_piece_at('e4');
$c_piece2 = $clone->get_piece_at('e3');
ok( $b_piece1 == 42 and !defined($b_piece2) );
ok( !defined($c_piece1) and $c_piece2 == 42 );
ok( $board->line_is_open('c1', 'c8') );
ok( $board->line_is_open('c8', 'c1') );
ok( $board->line_is_open('a1', 'h1') );
ok( $board->line_is_open('h1', 'a1') );
ok( $board->line_is_open('c1', 'a3') );
ok( $board->line_is_open('a3', 'c1') );
ok( $board->line_is_open('e1', 'e8') == 0 );
ok( $board->line_is_open('e8', 'e1') == 0 );
ok( $board->line_is_open('a4', 'h4') == 0 );
ok( $board->line_is_open('h4', 'a4') == 0 );
ok( $board->line_is_open('b1', 'h7') == 0 );
ok( $board->line_is_open('h7', 'b1') == 0 );
