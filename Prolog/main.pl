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

% Estado final (Depósito)
final(9999).

% Capacidade de carga do veículo coletor de resíduos (em dm3 -> 15 m3 == 15000 dm3)
capacidadeMax(15000).

% ------------------------------------------ Pesquisa nao informada --------------------------------------
% 1) Primeiro em profundidade (BFS)
% 1.1) Gerar os circuitos de recolha tanto indiferenciada como seletiva, caso existam, que
% cubram um determinado território
% 1.1.1) Indiferenciada

printBfs(I) :-
    bfs(I,[I],S),
    escrever([I|S]).

bfs(Estado,_,[EstadoInicial]) :-
    final(Estado),
    arco(Estado,EstadoInicial,_).

bfs(Estado,Historico,[Estado1|Sol]) :-
    arco(Estado,Estado1,_),
    nao(membro(Estado1,Historico)),
    bfs(Estado1,[Estado1|Historico],Sol).



printBfsIndiferenciada(I) :-
    bfsIndiferenciada(I,S,0,TotalRecolhido),
    escrever(S),
    write('Total Recolhido: '),
    escrever([TotalRecolhido]).

bfsIndiferenciada(I,S,CapacidadeAtual,TotalRecolhido) :-
    inicial(I),
    bfsIndiferenciada(I,[I],S,CapacidadeAtual,TotalRecolhido).

bfsIndiferenciada(Estado,_,[Estado/[],EstadoInicial/[]],_,0) :-
    final(Estado),
    arco(Estado,EstadoInicial,_).

bfsIndiferenciada(Estado,Historico,[Estado/ListaRecolhidos|Sol],CapacidadeAtual,TotalRecolhido) :-
    nodo(Estado,_,_,ListaResiduos),
    recolher(ListaResiduos,ListaRecolhidos,CapacidadeAtual,Recolhido),
    ProximaCapacidade is CapacidadeAtual + Recolhido,
    arco(Estado,Estado1,_),
    nao(membro(Estado1,Historico)),
    bfsIndiferenciada(Estado1,[Estado1|Historico],Sol,ProximaCapacidade,TotalRecolhido1),
    TotalRecolhido is TotalRecolhido1 + Recolhido.



recolher([],[],_,0).

recolher([(_,TotalLitros)|T],S,LitrosAtual,LitrosFinal) :-
    Soma is LitrosAtual + TotalLitros,
    capacidadeMax(Max),
    Max < Soma,
    recolher(T,S,LitrosAtual,LitrosFinal).

recolher([(Lixo,TotalLitros)|T],[(Lixo,TotalLitros)|S],LitrosAtual,LitrosFinal) :-
    Soma is LitrosAtual + TotalLitros,
    capacidadeMax(Max),
    Max >= Soma,
    recolher(T,S,Soma,LitrosFinal1),
    LitrosFinal is TotalLitros + LitrosFinal1.




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

