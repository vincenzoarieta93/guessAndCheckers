#maxint=500.
row(0..7).
col(0..7).
color(white).
color(black).

choose(R,C,Col,S,V) | notChoose(R,C,Col,S,V) :- pawn(R,C,Col,S,V).

:- choose(R,C,_,_,V), choose(R1,C1,_,_,V1), V<>V1.
:- choose(R,C,_,_,V), notChoose(R1,C1,_,_,V), R<>R1.
:- choose(R,C,_,_,V), notChoose(R1,C1,_,_,V), C<>C1.
:- #count{R,C,V : choose(R,C,_,_,V)}<1.

chosen(R,C,COL,S,V) :- choose(R,C,COL,S,V).

enemyColor(C) :- color(C), userColor(UC), C<>UC.
busyTile(R,C,V) :- chosen(R,C,_,_,V).
emptyTile(R,C,V) :- not busyTile(R,C,V), row(R), col(C), pawn(_,_,_,_,V).

myPawn(R,C,S,V) :- chosen(R,C,Color,S,V), userColor(Color).
enemyPawn(R,C,S,V) :- chosen(R,C,Color,S,V), enemyColor(Color).

numPawns(Color,V,N) :- chosen(_,_,Color,_,V), N=#count{R,C : chosen(R,C,Color,_,V)}, #int(N).
numMyPawns(V,N) :-  numPawns(Color,V,N),userColor(Color).
numEnemyPawns(V,N) :- numPawns(Color,V,N), enemyColor(Color).

myKings(N,V) :- pawn(_,_,_,_,V),N=#count{R,C : myPawn(R,C,king,V)}, #int(N).
enemyKings(N,V) :- pawn(_,_,_,_,V),N=#count{R,C : enemyPawn(R,C,king,V)}, #int(N).


%1 - Maggior numero di pedine rispetto avversario
versionWithMyPawns(V) :- numMyPawns(V,_).
versionWithoutMyPawns(V) :- not versionWithMyPawns(V), chosen(_,_,_,_,V).
numMyPawns(V,0) :- versionWithoutMyPawns(V).

weight(W,V) :- numMyPawns(V,MP), numEnemyPawns(V,EP), MP>=EP, #int(D), D=MP-EP, W=12-D.
weight(W,V) :- numMyPawns(V,MP), numEnemyPawns(V,EP), MP<EP, #int(D), D=EP-MP, W=12+D.
:~ weight(W,V).[W:8]

%2 - Massimizzare il numero di pedine avversarie chiuse
enemyLegalMove(R,C,R1,C1,V) :- enemyPawn(R,C,_,V), enemyColor(black), emptyTile(R1,C1,V), R1=R+1, C1=C+1.
enemyLegalMove(R,C,R1,C1,V) :- enemyPawn(R,C,_,V), enemyColor(blck), emptyTile(R1,C1,V), R1=R+1, C1=C-1.
enemyLegalMove(R,C,R1,C1,V) :- enemyPawn(R,C,_,V), enemyColor(white), emptyTile(R1,C1,V), R1=R-1, C1=C+1.
enemyLegalMove(R,C,R1,C1,V) :- enemyPawn(R,C,_,V), enemyColor(white), emptyTile(R1,C1,V), R1=R-1, C1=C-1.
enemyLegalMove(R,C,R1,C1,V) :- enemyPawn(R,C,king,V), enemyColor(black), emptyTile(R1,C1,V), R1=R-1, C1=C+1.
enemyLegalMove(R,C,R1,C1,V) :- enemyPawn(R,C,king,V), enemyColor(black), emptyTile(R1,C1,V), R1=R-1, C1=C-1.
enemyLegalMove(R,C,R1,C1,V) :- enemyPawn(R,C,king,V), enemyColor(white), emptyTile(R1,C1,V), R1=R+1, C1=C+1.
enemyLegalMove(R,C,R1,C1,V) :- enemyPawn(R,C,king,V), enemyColor(white), emptyTile(R1,C1,V), R1=R+1, C1=C-1.

jumpsCell(R,C,R1,C1,V) :- chosen(R,C,black,_,V), chosen(R1,C1,white,_,V), R1=R+1, C1=C+1, emptyTile(R2,C2,V), R2=R1+1, C2=C1+1.
jumpsCell(R,C,R1,C1,V) :- chosen(R,C,black,_,V), chosen(R1,C1,white,_,V), R1=R+1, C1=C-1, emptyTile(R2,C2,V), R2=R1+1, C2=C1-1.
jumpsCell(R,C,R1,C1,V) :- chosen(R,C,black,king,V), chosen(R1,C1,white,_,V), R1=R-1, C1=C+1, emptyTile(R2,C2,V), R2=R1-1, C2=C1+1.
jumpsCell(R,C,R1,C1,V) :- chosen(R,C,black,king,V), chosen(R1,C1,white,_,V), R1=R-1, C1=C-1, emptyTile(R2,C2,V), R2=R1-1, C2=C1-1.

jumpsCell(R,C,R1,C1,V) :- chosen(R,C,white,_,V), chosen(R1,C1,black,_,V), R1=R-1, C1=C+1, emptyTile(R2,C2,V), R2=R1-1, C2=C1+1.
jumpsCell(R,C,R1,C1,V) :- chosen(R,C,white,_,V), chosen(R1,C1,black,_,V), R1=R-1, C1=C-1, emptyTile(R2,C2,V), R2=R1-1, C2=C1-1.
jumpsCell(R,C,R1,C1,V) :- chosen(R,C,white,king,V), chosen(R1,C1,black,_,V), R1=R+1, C1=C+1, emptyTile(R2,C2,V), R2=R1+1, C2=C1+1.
jumpsCell(R,C,R1,C1,V) :- chosen(R,C,white,king,V), chosen(R1,C1,black,_,V), R1=R+1, C1=C-1, emptyTile(R2,C2,V), R2=R1+1, C2=C1-1.

safeEnemy(R,C,V) :- enemyLegalMove(R,C,R1,C1,V), not jumpsCell(R2,C2,R1,C1,V), myPawn(R2,C2,S,V).
safeEnemy(R,C,V) :- enemyJumper(R,C,V).
:~safeEnemy(R,C,V).[1:7]

%2Bis - Minimizzare il numero di mangiatori avversari
enemyJumper(R,C,V) :- jumpsCell(R,C,R1,C1,V), enemyPawn(R,C,_,V).
:~enemyJumper(R,C,V).[1:7]

%3 - Maggior numero di dame rispetto avversario
weightForKings(W,V) :- myKings(MK,V), enemyKings(EK,V), MK>=EK, #int(D), D = MK-EK, W = 12-D.
weightForKings(W,V) :- myKings(MK,V), enemyKings(EK,V), MK<EK, #int(D), D = EK-MK, W = 12+D.
:~weightForKings(W,V).[W:6]


%4 - Maggior numero di pedine sulla king-row
myPawnBeyondNRow(V) :- userColor(white), myPawn(R,C,man,V), R<7.
myPawnBeyondNRow(V) :- userColor(black), myPawn(R,C,man,V), R>0.
:~myPawnBeyondNRow(V). [1:5]


%5 - Maggior numero di pedine "man" aventi i due lati coperti da altre pedine
mySafeMan(R,C,V) :- userColor(white), myPawn(R,C,man,V), myPawn(R1,C1,_,V), myPawn(R1,C2,_,V), R1 = R+1, R1<=7, C1 = C-1, C1>=0, C2 = C+1, C1 <=7.
mySafeMan(R,C,V) :- userColor(black), myPawn(R,C,man,V), myPawn(R1,C1,_,V), myPawn(R1,C2,_,V), R1 = R-1, R1>=0, C1 = C-1, C1>=0, C2 = C+1, C1 <=7.
myUnsafeMan(R,C,V) :- not mySafeMan(R,C,V), myPawn(R,C,man,V).
:~myUnsafeMan(R,C,V).[1:4]

%6 - Se si rimane con una sola pedina => minimizzare la distanza dalla kingrow avversaria
distanceToGoalRow(V,D) :- userColor(white), numEnemyPawns(V,1), numMyPawns(V,1), myPawn(R,_,man,V), #int(D), D=R.
distanceToGoalRow(V,D) :- userColor(black), numEnemyPawns(V,1), numMyPawns(V,1), myPawn(R,_,man,V), #int(D), D=7-R.
:~distanceToGoalRow(V,D).[D:4]

%7 - Maggior numero di pedine occupanti il centro della scacchiera
pawnAtCenter(R,C,V):- myPawn(R,C,_,V), R<=5, R>=2, C<=5, C>=2.
:~not pawnAtCenter(R,C,V), myPawn(R,C,_,V).[1:3]


%8 - Minor numero di dame sui bordi
myKingAwayFromBorders(R,C,V):- myPawn(R,C,king,V), R<7, R>0, C<7, C>0.
:~ not myKingAwayFromBorders(R,C,V), myPawn(R,C,_,V).[1:2]


%9 - Maggior numero di pedine a protezione del cantone
cantoneProtector(R,C,V) :- userColor(white), myPawn(7,1,_,V), myPawn(7,3,_,V), myPawn(R,C,_,V), R=6, C=0.
cantoneProtector(R,C,V) :- userColor(white), myPawn(7,1,_,V), myPawn(7,3,_,V), myPawn(R,C,_,V), R=6, C=2.
cantoneProtector(R,C,V) :- userColor(black), myPawn(0,6,_,V), myPawn(0,4,_,V), myPawn(R,C,_,V), R=1, C=7.
cantoneProtector(R,C,V) :- userColor(black), myPawn(0,6,_,V), myPawn(0,4,_,V), myPawn(R,C,_,V), R=1, C=5.
:~not cantoneProtector(R,C,V), myPawn(R,C,_,V).[1:1]
