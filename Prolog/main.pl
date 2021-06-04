% Declaracoes iniciais
% :- set_prolog_flag(discontiguous_warnings,off).
% :- set_prolog_flag(single_var_warnings,off).

:- op(900,xfy,'::').

% Includes necessários, dos nodos e dos arcos
:- include('nodos.pl').
:- include('arcos.pl').

% ------------------------------------------ Dados do problema --------------------------------------------
% Estado inicial (Garagem)
inicial(0).

% Estado final (Garagem)
final(0).

% ------------------------------------------ Pesquisa nao informada --------------------------------------
% 1) Primeiro em profundidade (BFS)

bfs(I,[I|S]) :-
    bfs(I,[I],S).

bfs(Estado, _, []) :-
    final(Estado).
bfs(Estado,Historico,[Estado1|Sol]) :-
    move(Estado,Estado1,_),
    nao(membro(Estado1,Historico)),
    bfs(Estado1,[Estado1|Historico],Sol).


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

