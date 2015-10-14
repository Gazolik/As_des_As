﻿:- dynamic plane/5.
:- [plane_actions].
:- [gameover].

% Faits qui definissent les positions initiales des avions.
% Le premier argument correspond à l'indice de l'avion
plane(1, 0, 0, 3, 'S').
plane(2, 15, 15, 3, 'N').

% Execute les coups de même indice en même temps
updatePlanes([], []).
updatePlanes([Action1|ActionList1], [Action2|ActionList2]) :- 	callPlaneAction(1, Action1),
																callPlaneAction(2, Action2),
																fire(1), fire(2), !,
																not(gameoverStep),
																updatePlanes(ActionList1, ActionList2).
dis(I) :- write(I), nl.

% Big kind of switch, choosing between all implemented actions 
callPlaneAction(Idx, Action) :- Action == 'F', actionForward(Idx), !.
callPlaneAction(Idx, Action) :- Action == 'FF', actionFastForward(Idx), !.
callPlaneAction(Idx, Action) :- Action == 'RT', actionRightTurn(Idx), !.
callPlaneAction(Idx, Action) :- Action == 'LT', actionLeftTurn(Idx), !.
callPlaneAction(Idx, Action) :- Action == 'UT', actionUTurn(Idx), !.

% Error handling if unknown action. TODO : better error than "1 == 2"...
callPlaneAction(Idx, Action) :- print('Unknown action '), print(Action), print(' for index '), print(Idx), 1 == 2.

% Fire methods
fire(Idx) :- 	canFire(Idx),
				otherPlayer(Idx, OutIdx),
				decrementLife(OutIdx),
				shotDisplay(Idx, OutIdx).
fire(_).
				
canFire(Idx) :- plane(Idx, X1, Y1, _, Orientation1),
				plane(Idx2, X2, Y2, _, _),
				Idx2 \== Idx,
				Orientation1 == 'N', !,
				X1 == X2,
				Distance is Y1 - Y2,
				Distance >= 0,
				Distance =< 5.
canFire(Idx) :- plane(Idx, X1, Y1, _, Orientation1),
				plane(Idx2, X2, Y2, _, _),
				Idx2 \== Idx,
				Orientation1 == 'S', !,
				X1 == X2,
				Distance is Y2 - Y1,
				Distance >= 0,
				Distance =< 5.
canFire(Idx) :- plane(Idx, X1, Y1, _, Orientation1),
				plane(Idx2, X2, Y2, _, _),
				Idx2 \== Idx,
				Orientation1 == 'E', !,
				Y1 == Y2,
				Distance is X2 - X1,
				Distance >= 0,
				Distance =< 5.
canFire(Idx) :- plane(Idx, X1, Y1, _, Orientation1),
				plane(Idx2, X2, Y2, _, _),
				Idx2 \== Idx,
				Orientation1 == 'W', !,
				Y1 == Y2,
				Distance is X1 - X2,
				Distance >= 0,
				Distance =< 5.

decrementLife(Idx) :- 	retract(plane(Idx, X, Y, Life, Orientation)),
						NewLife is Life-1,
						assert(plane(Idx, X, Y, NewLife, Orientation)).
