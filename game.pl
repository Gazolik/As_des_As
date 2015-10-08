:- [plane].
:- [board].

reset:-retract(avion1(_,_,0)).
reset:-retract(avion2(_,_,0)).

%TODO : change avec plane(1,...) etc
gameover:-avion1(X, _, _), X <0, print('Joueur 2 a gagn�').
gameover:-avion1(X, _, _), X >16, print('Joueur 2 a gagn�').
gameover:-avion1(-, Y, _), Y <0, print('Joueur 2 a gagn�').
gameover:-avion1(-, Y, _), Y >16, print('Joueur 2 a gagn�').

gameover:-avion2(X, _, _), X <0, print('Joueur 1 a gagn�').
gameover:-avion2(X, _, _), X >16, print('Joueur 1 a gagn�').
gameover:-avion2(-, Y, _), Y <0, print('Joueur 1 a gagn�').
gameover:-avion2(-, Y, _), Y >16, print('Joueur 1 a gagn�').


gameover:-avion1(X, Y, _), avion2(X, Y, _), print('�galit� par colision').
gameover:- avion1(_,_,0), avion2(_,_,0), print('�galit� par mort des deux avions').
gameover:- avion1(_,_,0), print('Joueur 2 a gagn�').
gameover:- avion2(_,_,0), print('Joueur 1 a gagn�').

etape:-
	updatePlanes(['FF', 'LT', 'UT'], ['LT', 'RT', 'F']), % test values, a supprimer
	displayBoard.
	%,game(). % a d�commenter pour boucle de jeu

game:- gameover, !.
game:- etape.

lancer:-reset; game.
%['C:/Users/Djowood/Documents/INSA/Prolog/Projet/As_des_As/game'].
