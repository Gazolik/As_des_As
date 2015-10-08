:-dynamic avion1/3, avion2/3.

avion1(1,1,10).
avion2(1,17,10).

reset():-retract(avion1(_,_,0)).
reset():-retract(avion2(_,_,0)).

%TODO
gameover():-avion1(X, _, _), X <0, print('Joueur 2 a gagn�').
gameover():-avion1(X, _, _), X >16, print('Joueur 2 a gagn�').
gameover():-avion1(-, Y, _), Y <0, print('Joueur 2 a gagn�').
gameover():-avion1(-, Y, _), Y >16, print('Joueur 2 a gagn�').

gameover():-avion2(X, _, _), X <0, print('Joueur 1 a gagn�').
gameover():-avion2(X, _, _), X >16, print('Joueur 1 a gagn�').
gameover():-avion2(-, Y, _), Y <0, print('Joueur 1 a gagn�').
gameover():-avion2(-, Y, _), Y >16, print('Joueur 1 a gagn�').


gameover():-avion1(X, Y, _), avion2(X, Y, _), print('�galit� par colision').
gameover():- avion1(_,_,0), avion2(_,_,0), print('�galit� par mort des deux avions').
gameover():- avion1(_,_,0), print('Joueur 2 a gagn�').
gameover():- avion2(_,_,0), print('Joueur 1 a gagn�').

update():-updateAvion1(), updateAvion2().

updateAvion1():-
        %r�cup�re X (pt de vie)
	avion1(Y,Z,X),
	%on le retire de la base
	retract(avion1(Y,Z,X)),
	X1 is X-1,
	assert(avion1(Y,Z,X1)).

updateAvion2():-
	%r�cup�re X (pt de vie)
	avion2(Y,Z,X),
	%on le retire de la base
	retract(avion2(Y,Z,X)),
	X1 is X-1,
	assert(avion2(Y,Z,X1)).

etape():-
	updatePlanes(),
	displayBoard()
	game().

game():- gameover(), !.
game():- etape().

lancer():-reset(); game().
%['C:/Users/Djowood/Documents/INSA/Prolog/Projet/As_des_As/game'].
