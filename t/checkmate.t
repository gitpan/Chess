use Test::Simple tests => 5;

use Chess::Game;

$game = Chess::Game->new();
$game->make_move("e2", "e3", 1);
$game->make_move("f7", "f6", 1);
$game->make_move("d2", "d3", 1);
$game->make_move("g7", "g5", 1);
$game->make_move("d1", "h5", 1);
ok( $game->player_checkmated("black") );
ok( $game->result() == 1 );
$game->take_back_move();
ok( !$game->player_checkmated("black") );
ok( !defined($game->result()) );
$game->make_move("d1", "h5", 1);
ok( $game->player_checkmated("black") );
