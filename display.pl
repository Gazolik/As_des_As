% Stop condition for displaying the board
display([]).
% Displays each row, and then displays the rest of the board by recursion.
display([Row|B]) :- displayRow(Row), display(B).

% Ends a row display (if row is empty)
displayRow([]) :- nl.
% Displays one element of the row and calls recursively for the rest of the row.
displayRow([Element|Row]) :- write(Element), write('|'), displayRow(Row).

% Test call : display([[a,b,c],[c,d,e],[f,g,i]]).

% Gameover displays
playerOneWinsDisplay :- write('Player 1 wins!'), nl.
playerTwoWinsDisplay :- write('Player 2 wins!'), nl.
drawDisplay :- write('Draw!'), nl.

roundDisplay :- write('Round : '), round(NB), write(NB), nl.
playerDisplay(Idx) :- 	plane(Idx, _, _, Life, _),
						write('Player '), write(Idx), nl,
						write('Remaining life : '), write(Life), nl.
