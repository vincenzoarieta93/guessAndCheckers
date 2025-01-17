row(0..7).
col(0..7).
maxPawns(0..12).
color(white).
color(black).

chosen(R,C,COL,S) :- pawn(R,C,COL,S,V), choose(V).

enemyColor(C) :- color(C), userColor(UC), C<>UC.
busyTile(R,C) :- chosen(R,C,_,_).
emptyTile(R,C) :- not busyTile(R,C), row(R), col(C).

myPawn(R,C,S) :- chosen(R,C,Color,S), userColor(Color).
enemyPawn(R,C,S) :- chosen(R,C,Color,S), enemyColor(Color).

numPawns(Color,N) :- color(Color), N=#count{R,C : chosen(R,C,Color,_)}, maxPawns(N).
numMyPawns(N) :-  numPawns(Color,N),userColor(Color).
numEnemyPawns(N) :- numPawns(Color,N), enemyColor(Color).

myKings(N) :- N=#count{R,C : chosen(R,C,Color,king),userColor(Color)}, maxPawns(N).
enemyKings(N) :- N=#count{R,C : chosen(R,C,Color,king), enemyColor(Color)}, maxPawns(N).

myMen(N) :- N=#count{R,C : myPawn(R,C,man)}, maxPawns(N).
enemyMen(N) :- N=#count{R,C : enemyPawn(R,C,man)}, maxPawns(N).

numDefenders(N) :- userColor(white), N=#count{R,C: myPawn(R,C,man), R>=5}, maxPawns(N).
numDefenders(N) :- userColor(black), N=#count{R,C: myPawn(R,C,man), R<=2}, maxPawns(N).

weightMen(W) :- myMen(MM), enemyMen(EM), MM>=EM, maxPawns(D), D=MM-EM, W=12-D.
weightMen(W) :- myMen(MM), enemyMen(EM), MM<EM, maxPawns(D), D=EM-MM, W=12+D.

%1
weightForKings(W2) :- myKings(MK), enemyKings(EK), MK>=EK, maxPawns(D), D = MK-EK, W = 24-D, W2=W*2.
weightForKings(W2) :- myKings(MK), enemyKings(EK), MK<EK, maxPawns(D), D = EK-MK, W = 24+D, W2=W*2.
weightPawns(W) :- weightMen(WM), weightForKings(WK), W=WM+WK.
:~weightPawns(W).[W:9]

%2 - Maggior numero di pedine sulla king-row
myPawnBeyondNRow(R,C) :- userColor(white), myPawn(R,C,man), R<7.
myPawnBeyondNRow(R,C) :- userColor(black), myPawn(R,C,man), R>0.
myPawnsBeyondKingRow(N) :- N= #count{R,C:myPawnBeyondNRow(R,C)}, maxPawns(N).
:~ enemyKings(0), myPawnsBeyondKingRow(N). [N:7]

%9 - Maggior numero di pedine a protezione del biscacco
:~ userColor(white), myPawn(7,1,man), myPawn(7,3,man), not myPawn(6,0,man).[1:6]
:~ userColor(black), myPawn(0,6,man), myPawn(0,4,man), not myPawn(1,7,man).[1:6]

%pedine compatte
safePawn(R,C):- userColor(white), myPawn(R,C,_), myPawn(R1,C2,_), C2=C+1, myPawn(R1,C1,S), R1=R+1, C1=C-1.
safePawn(R,C):- userColor(black), myPawn(R,C,_), myPawn(R1,C2,_), C2=C+1, myPawn(R1,C1,S), R1=R-1, C1=C-1.
unsafePawn(R,C) :- myPawn(R,C,_), not safePawn(R,C).
:~numMyPawns(MP), numEnemyPawns(EP), MP<=EP, unsafePawn(R,C). [1:5]

%attaccare il biscacco avversario
:~userColor(black), myPawn(R,C,man),C>3.[1:4]
:~userColor(white), myPawn(R,C,man),C<4.[1:4]

%4 - Minimizzare le mosse safe dell'avversario 
legalMove(R,C,R1,C1) :- chosen(R,C,white,_), emptyTile(R1,C1), R1=R-1, C1=C+1.
legalMove(R,C,R1,C1) :- chosen(R,C,white,_), emptyTile(R1,C1), R1=R-1, C1=C-1.
legalMove(R,C,R1,C1) :- chosen(R,C,black,king), emptyTile(R1,C1), R1=R-1, C1=C+1.
legalMove(R,C,R1,C1) :- chosen(R,C,black,king), emptyTile(R1,C1), R1=R-1, C1=C-1.

legalMove(R,C,R1,C1) :- chosen(R,C,white,king), emptyTile(R1,C1), R1=R+1, C1=C+1.
legalMove(R,C,R1,C1) :- chosen(R,C,white,king), emptyTile(R1,C1), R1=R+1, C1=C-1.
legalMove(R,C,R1,C1) :- chosen(R,C,black,_), emptyTile(R1,C1), R1=R+1, C1=C-1.
legalMove(R,C,R1,C1) :- chosen(R,C,black,_), emptyTile(R1,C1), R1=R+1, C1=C+1.
goodMoveForEnemy(R1,C1) :- enemyPawn(R,C,_), legalMove(R,C,R1,C1), not legalMove(R2,C2,R1,C1), myPawn(R2,C2,_).
:~numMyPawns(MP), numEnemyPawns(EP), MP>=EP, myKings(MK), enemyKings(EK), MK>EK, goodMoveForEnemy(R1,C1).[1:4]

% mandare le dame in soccorso delle pedine
:~ userColor(white), numDefenders(N), N>=2, myPawn(R,_,king), R<5.[1:4]
:~ userColor(black), numDefenders(N), N>=2, myPawn(R,_,king), R>2.[1:4]

%6 - Minimizzare la distanza dalla kingrow avversaria
distanceToGoalRow(R) :- userColor(white), myPawn(R,_,man).
distanceToGoalRow(D) :- userColor(black), myPawn(R,_,man), row(D), D=7-R.
:~ distanceToGoalRow(D).[D:3]

%privilegiare le pedine che sono vicine alla king row avversaria quasi sguarnita
opponentPawnsOnKingR(N):- enemyColor(white), N=#count{C : enemyPawn(7,C,_)}, row(N).
opponentPawnsOnKingR(N):- enemyColor(black), N=#count{C : enemyPawn(0,C,_)}, row(N).
:~ opponentPawnsOnKingR(N), N<2, distanceToGoalRow(D).[D:8]

%8 - evitare dame sui bordi
myCenterKing(R,C) :- myPawn(R,C,king), R>=1, R<=6, C<=6, C>=1.
myLateralKing(R,C) :- not myCenterKing(R,C), myPawn(R,C,king).
:~ myLateralKing(R,C).[1:2]
