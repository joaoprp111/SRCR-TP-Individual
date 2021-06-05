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
% capacidadeMax(15000).

% ------------------------------------------ Pesquisa nao informada --------------------------------------

% 1) Gerar os circuitos de recolha tanto indiferenciada como seletiva, caso existam, que
% cubram um determinado território

% -> Primeiro em profundidade

% Gerar todos os circuitos que partem da garagem, atingem o depósito e regressam à garagem

printDfs(I) :-
    inicial(I),
    dfs(I,[I],S,0,TotalRecolhido),
    escreverTriplo(S,0),
    write('Total recolhido no circuito: '),
    write(TotalRecolhido).

dfs(Estado,_,[Estado/'Deposito'/0,EstadoInicial/'Garagem'/0],_,0) :-
    final(Estado),
    arco(Estado,EstadoInicial,_).

dfs(Estado,Historico,[Estado/Rua/TotalRecolhido|Sol],RecolhidoAtual,TotalRecolhidoFinal) :-
    nodo(Estado,Rua,_,Recolhidos),
    recolher(Recolhidos,TotalRecolhido),
    RecolhidoAtual1 is RecolhidoAtual + TotalRecolhido,
    arco(Estado,Estado1,_),
    nao(membro(Estado1,Historico)),
    dfs(Estado1,[Estado1|Historico],Sol,RecolhidoAtual1,TotalRecolhido1),
    TotalRecolhidoFinal is TotalRecolhido1 + TotalRecolhido.


% Predicado para recolher os resíduos no percurso de uma rua 
% recolher(ListaFonte,TotalRecolhido (litros))
recolher(Lista,Total) :-
    recolher(Lista,0,Total).

recolher([],_,0).

recolher([(_,TotalLitros)|T],Atual,Final) :-
    Soma is Atual + TotalLitros,
    recolher(T,Soma,Final1),
    Final is Final1 + TotalLitros.


% printBfsIndiferenciada(I) :-
%     bfsIndiferenciada(I,S,0,TotalRecolhido),
%     escrever(S),
%     write('Total Recolhido: '),
%     escrever([TotalRecolhido]).

% bfsIndiferenciada(I,S,CapacidadeAtual,TotalRecolhido) :-
%     inicial(I),
%     bfsIndiferenciada(I,[I],S,CapacidadeAtual,TotalRecolhido).

% bfsIndiferenciada(Estado,_,[Estado/[],EstadoInicial/[]],_,0) :-
%     final(Estado),
%     arco(Estado,EstadoInicial,_).

% bfsIndiferenciada(Estado,Historico,[Estado/ListaRecolhidos|Sol],CapacidadeAtual,TotalRecolhido) :-
%     nodo(Estado,_,_,ListaResiduos),
%     recolher(ListaResiduos,ListaRecolhidos,CapacidadeAtual,Recolhido),
%     ProximaCapacidade is CapacidadeAtual + Recolhido,
%     arco(Estado,Estado1,_),
%     nao(membro(Estado1,Historico)),
%     bfsIndiferenciada(Estado1,[Estado1|Historico],Sol,ProximaCapacidade,TotalRecolhido1),
%     TotalRecolhido is TotalRecolhido1 + Recolhido.


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

