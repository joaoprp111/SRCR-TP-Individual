% ------------------------------------------ Predicados auxiliares --------------------------------------
nao( Questao ) :-
    Questao, !, fail.
nao( _ ).

membro(X,[X|_]).
membro(X,[_|T]) :-
	membro(X,T).

inverso(Xs,Ys) :-
    inverso(Xs,[],Ys).

inverso([],Xs,Xs).
inverso([X|Xs],Ys,Zs) :-
    inverso(Xs,[X|Ys],Zs).

escrever([]) :-
	write('').
escrever([X|T]) :-
	write(X),
	write('\n'),
	escrever(T).

escreverDupla([],_) :-
	write('').
escreverDupla([Id/Rua|T],N) :-
    N1 is N + 1,
    write(N1), write(') '),
	write('Id: '), write(Id), write(' | Rua: '), write(Rua),
	write('\n'),
	escreverDupla(T,N1).

escreverSeguido([]) :-
	write('').
escreverSeguido([(X,Y)|T]) :-
	write('('), write(X), write(','), write(Y), write(')'),
	write(' | '),
	escreverSeguido(T).

escreverTriplo([],_) :-
	write('').
escreverTriplo([Id/Rua/TotalRecolhido|T],N) :-
    N1 is N + 1,
    write(N1), write(') '),
	write('Id: '), write(Id), write(' | Rua: '), write(Rua), write(' | Total recolhido: '),
    write(TotalRecolhido), write(' litros'),
	write('\n'),
	escreverTriplo(T,N1).

escreverQuadra([]) :-
	write('').
escreverQuadra([Id/Rua/TotalRecolhido/Rs|T]) :-
	write('Id: '), write(Id), write(' | Rua: '), write(Rua), write(' | Total recolhido: '),
    write(TotalRecolhido), write(' litros'),
    write(' | Residuos: '), escreverSeguido(Rs),
	write('\n'),
	escreverQuadra(T).

selecionaTipo([],_,[]).

selecionaTipo([(Tipo,_)|S],Tipo1,Sol) :-
    Tipo1 \= Tipo,
    selecionaTipo(S,Tipo1,Sol).

selecionaTipo([(Tipo,Total)|S],Tipo1,[(Tipo,Total)|Sol]) :-
    Tipo1 == Tipo,
    selecionaTipo(S,Tipo1,Sol).

% Predicado para recolher os resíduos no percurso de uma rua 
% recolher(ListaFonte,TotalRecolhido (litros))
recolher(Lista,Total) :-
    recolher(Lista,0,Total).

recolher([],_,0).

recolher([(_,TotalLitros)|T],Atual,Final) :-
    Soma is Atual + TotalLitros,
    recolher(T,Soma,Final1),
    Final is Final1 + TotalLitros.

seleciona(E, [E|Xs], Xs).
seleciona(E, [X|Xs], [X|Ys]) :- seleciona(E,Xs,Ys).
