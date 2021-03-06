:- module(ai_hybride, [aiHybrid/1, aiHybridNonDeterministic/1]).

:- use_module('../game').
:- use_module('ai_general').
:- use_module('../Game/plane').
:- use_module('../Game/plane_actions').

:- dynamic meilleurGain/1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%				FAITS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
meilleurGain(0).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%				PREDICATS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Implémentation d'une intelligence articificielle hybride dans le sens où elle essaie de tirer sans se faire tirer dessus aussi.
% Son but est de maximiser ses tirs tout en minimisant les possibilités de tirs de l'adversaire.
% Elle suppose que l'adversaire joue les coups qui sont le plus en sa faveur.
% Principe : A partir d'un état du jeu, on construit l'arbre de jeu c'est à dire tous les coups (triplets d'actions) possibles 
% pour l'IA. On évalue ensuite les coups grâce à une heuristique pour faire remonter les min puis les max des ces mins.
% L'arbre de recherche n'a pas une grande profondeur mais un nombre très important de noeuds dû aux coups possibles à chaque "step".

% Choisi une solution au hasard parmi l'ensemble des solutions dont le gain est maximal.
% Idx : indice du joueur en entrée
aiHybridNonDeterministic(Idx) :- mapCoupGain(Idx, Map), % Construction de la map <Coup,Gain>
								 maxMap(_,GainMax,Map), % Calcul du gain max de la map qu
								 coupVautGain(ListeCoup,GainMax,Map), !,
								 random_member(FinalSol, ListeCoup),
								 % Crée le prochain coup à jouer
								retract(actions(Idx, _)),
								assert(actions(Idx, FinalSol)).


% AI hybride qui prend le premier meilleur coup
% Idx : indice du joueur en entrée
aiHybrid(Idx) :-
				mapCoupGain(Idx, Map),
				maxMap(Coup,_,Map),
				retract(actions(Idx, _)),
				assert(actions(Idx, Coup)),
				resetMeilleurGain.
								

% Donne les coups de la map dont le gain vaut Gain dans une liste
% accCoupVautGain est le prédicat qui parcours la map de façon récursive.
% coupVautGain est le prédicat qui donne l'ensemble des coups
% Liste : Liste des coups en sortie
% Gain : gain à comparer en entrée
% Map : map<Coup,Gain> en entrée
accCoupVautGain(L,_,[],L).
accCoupVautGain(Liste,Gain, [First|Map],AccL) :-   First = [_|G], G = [NewGain|_],
										  First = [CMax|_],
										  NewGain == Gain,
										  accCoupVautGain(Liste,Gain,Map,[CMax|AccL]).
accCoupVautGain(Liste,Gain, [First|Map],AccL) :-   First = [_|G], G = [NewGain|_],
										  %First = [CMax|_],
										  NewGain \= Gain,
										  accCoupVautGain(Liste,Gain,Map,AccL).
coupVautGain(Liste,Gain,Map) :- accCoupVautGain(Liste, Gain, Map,[]).				  



% Donne le coup associé au gain Max dans la map. C'est à dire le coup qui permet de maximiser le gain.
% accMaxMap est le prédicat qui parcours la map de façon récursive.
% maxMap est le prédicat qui donne ce coup max. Il utilise accMaxMap.
accMaxMap([],Ag,Ag,CoupMax,CoupMax).
accMaxMap([E|Map],Ac,Ag,_,CoupMax) :- E = [_|G], G = [Gain|_],
								   E = [CMax|_],
								   Gain > Ac,
								   accMaxMap(Map,Gain,Ag,CMax,CoupMax).
accMaxMap([E|Map],Ac,Ag,GMax,CoupMax) :- E = [_|G], G = [Gain|_],
								   Gain =< Ac,
								   accMaxMap(Map,Ac,Ag,GMax,CoupMax).
maxMap(CoupMax,GainMax,Map) :- 
					   Map = [E|_], % On chope le premier élément de la map
					   E = [_|G], % On chope le gain associé à ce premier coup sous la forme [Gain]
					   G = [Gain|_], % On recupère le gain 
					   E = [CoupDefault|_], % On récupère le premier coup de la map
					   % On suppose que ce couple constitue notre max
					   accMaxMap(Map, Gain,GainMax, CoupDefault,CoupMax).


% Construis une sorte de map qui contient un coup et le gain minimum associé à ce coup sous la forme
% [ [[Action,Action,Action],Gain], [[Action,Action,Action],Gain] ].
% Exemple : [ [['FF','UT',RT'],2], [['FF','UT','F'],-1]] => Si l'ia joue ['FF','UT',RT'] au pire il gagne 2 donc il aura 
% intérêt à choisir ce coup dans notre exemple. 
mapCoupGain(Idx,Map) :- findall([Coup,Min],setOfMin(Idx,Min,Coup),Map).

% Donne le gain minimal et le coup de notre IA associé à ce gain minimal pour l'ensemble des coups de l'adversaire.
% On supposera que l'adversaire jouera toujours le coup qui nous avantage le moins d'où le gain minimal choisi.
% Idx : id de notre IA en entrée
% Min : le minimum des coups en sortie
% CoupIA : le coup de notre IA associé à ce gain min
setOfMin(Idx,Min,CoupIA) :- otherPlayer(Idx, OtherIdx),
				 generate(Idx, CoupIA),
				 setof(CoupOther,generate(OtherIdx,CoupOther),ListeCoup), % On récupère l'ensemble des coups de l'adversaire
				 minGain(Idx, OtherIdx, CoupIA, ListeCoup, Min).

% Donne le gain min d'une série liste de coups pour un coup donné.
% Idx : Indice de l'ia en entrée
% CoupIa : coup de l'ia en entrée
% OtherIdx : indice de l'autre joueur en entrée
% ListeCoup : liste de coups de l'autre ia en entrée
% Min : gain minimal en sortie
accMinGain(_,_,_,[],A,A).
accMinGain(Idx,OtherIdx,T,[H2|T2],A,Min) :-  h(Idx,OtherIdx,T,H2,ValeurCoup),
												ValeurCoup < A,
										   		accMinGain(Idx,OtherIdx, T, T2, ValeurCoup, Min).
										   
accMinGain(Idx,OtherIdx,T,[H2|T2],A,Min) :-	h(Idx,OtherIdx,T,H2,ValeurCoup),
												ValeurCoup >= A,
										   		accMinGain(Idx,OtherIdx, T, T2, A, Min).

minGain(Idx,OtherIdx,CoupIa,ListeCoup,Min) :- accMinGain(Idx,OtherIdx,CoupIa, ListeCoup, 3 ,Min).

					    					      

% Fonction d'évaluation qui calcule le gain associé à un coup.
% Idx : indice de l'avion de l'ia en entrée
% OtherPlayer : indice de l'autre joueur en entrée
% CoupIA : Coup de l'IA en entrée
% CoupOther : Coup de l'autre joueur
% Les deux listes doivent avoir le meme nombre d'élements.
% Gain : gain associé en sortie.
% Le gain correspond à une valeur entre -3 et 3 : 
%  - une valeur négative correspond à un nombre de tirs encaissés > au nombre de tirs donnés
%  - 0 implique pas de tirs donnés ou nombre tirs donnés = nombre tirs reçus.
%  - Une valeur positive correspond à un nombre de tirs donnés > nombre de tirs encaissés.
% Au départ on met le gain à zero et on choisit l'avion 3 et 4 comme avions temporaires
h(Idx,OtherPlayer,CoupIA,CoupOther,Gain) :- hr(Idx,OtherPlayer,3,4,CoupIA,CoupOther,0,Gain).						   			

% Effectue l'appel récursif pour le calcul de la fonction d'évaluation
% TmpPlane1 et TmpPlane2 : avions temporaires en entrée
% ActionIA : action courante de l'IA en entrée
% ActionOther : action courante de l'autre joueur en entrée
% Acc : sert d'accumulateur pour le calcul du gain
% Note : le nombre d'appel récursifs est lié au nombre d'actions dans la liste. Pour le moment on en a que 3.
% Avec cette méthode, on pourra étendre ce prédicat si on ne connait pas le nombre de coups à l'avance.
hr(_,_,_,_,[],[],Gain,Gain).
hr(Idx,OtherPlayer,TmpPlane1,TmpPlane2,[ActionIA|CoupIA],[ActionOther|CoupOther],AccGain,Gain):- 
										update(Idx, TmpPlane1), % Remplissage du premier avion temporaire
							   			update(OtherPlayer, TmpPlane2), % Remplissage du premier avion temporaire
							   			callPlaneAction(TmpPlane1, ActionIA), %  Déplacement du premier avion
							   			callPlaneAction(TmpPlane2, ActionOther), %  Déplacement du second avion
							   			(canFire(TmpPlane1, TmpPlane2) -> NewGain is AccGain + 1;NewGain is AccGain), % +1 si l'ia peut tirer
							   			(canFire(TmpPlane2, TmpPlane1) -> NewPerte is NewGain - 1;NewPerte is NewGain), % -1 si l'autre joueur peut tirer
							   			NewTmpPlane1 is TmpPlane1 + 2, % Passage au prochain avion temporaire
							   			NewTmpPlane2 is TmpPlane2 + 2, % Passage au prochain avion temporaire
							   			hr(TmpPlane1,TmpPlane2,NewTmpPlane1,NewTmpPlane2,CoupIA,CoupOther,NewPerte,Gain). % Appel récursif			   	
 
% Met tous les triplets dans une liste
generateAll(Idx,Liste) :- setof([Action1,Action2,Action3],generate(Idx,[Action1,Action2,Action3]),Liste).

% Genere tous les triplets d'actions possibles pour un avion à partir de sa position 
% - sans sortir du tableau à la fin des 3 actions.
% - sans s'éloigner de l'autre joueur
% - sans ne pas être orienté dans le sens du jeu.
generate(Idx,[Action1,Action2,Action3]) :- otherPlayer(Idx, OtherIdx),
					   action(Action1),action(Action2),action(Action3), % Génération des triplets d'actions
					   update(Idx,3),
					   callPlaneAction(3,Action1),
					   callPlaneAction(3,Action2),
					   callPlaneAction(3,Action3),
					   testPosition(3),
					   betterPosition(Idx, OtherIdx, 3, OtherIdx),
					   testOrientation(3).


% Une position est meilleure si on se rapproche de l'autre joueur
betterPosition(I1, I2, J1, J2) :- 	dist(I1, I2, D1),
									dist(J1, J2, D2),
									D1 >= D2.


% Réinitialise le meilleur gain
resetMeilleurGain :- retract(meilleurGain(_)),
				assert(meilleurGain(0)).
% Reinitialise le meilleur gain avec le NouveauMeilleurGain
resetMeilleurGain(NouveauMeilleurGain) :- retract(meilleurGain(_)),
										  assert(meilleurGain(NouveauMeilleurGain)).
										  