% Declaracoes iniciais
% :- set_prolog_flag(discontiguous_warnings,off).
% :- set_prolog_flag(single_var_warnings,off).

:- op(900,xfy,'::').

% Includes necessários, dos nodos e dos arcos
:- include('nodos.pl').
:- include('arcos.pl').
:- include('auxiliares.pl').

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
% Para garagem e depósito fixos

% 1.1) Indiferenciada

printDfs(I) :-
    inicial(I),
    dfs(I,[I],S,0,TotalRecolhido,0,DistanciaTotal),
    escreverTriplo(S,0),
    write('Total recolhido no circuito: '),
    write(TotalRecolhido), write(' | Distancia percorrida: '),
    write(DistanciaTotal), write(' metros').

dfs(Estado,_,[Estado/'Deposito'/0,EstadoInicial/'Garagem'/0],_,0,_,0) :-
    final(Estado),
    arco(Estado,EstadoInicial,_).

dfs(Estado,Historico,[Estado/Rua/TotalRecolhido|Sol],RecolhidoAtual,TotalRecolhidoFinal,Dist,DistFinal) :-
    nodo(Estado,Rua,_,Recolhidos),
    recolher(Recolhidos,TotalRecolhido),
    RecolhidoAtual1 is RecolhidoAtual + TotalRecolhido,
    arco(Estado,Estado1,Distancia),
    Dist1 is Dist + Distancia,
    nao(membro(Estado1,Historico)),
    dfs(Estado1,[Estado1|Historico],Sol,RecolhidoAtual1,TotalRecolhido1,Dist1,DistFinal1),
    TotalRecolhidoFinal is TotalRecolhido1 + TotalRecolhido,
    DistFinal is DistFinal1 + Distancia.

% 1.2) Escolher o tipo de resíduo

printDfsSeletiva(I,Tipo) :-
    inicial(I),
    dfsSeletiva(I,[I],S,0,TotalRecolhido,0,DistanciaTotal,Tipo),
    escreverTriplo(S,0),
    write('Total recolhido no circuito: '),
    write(TotalRecolhido), write(' | Distancia percorrida: '),
    write(DistanciaTotal), write(' metros').

dfsSeletiva(Estado,_,[Estado/'Deposito'/0,EstadoInicial/'Garagem'/0],_,0,_,0,_) :-
    final(Estado),
    arco(Estado,EstadoInicial,_).

dfsSeletiva(Estado,Historico,[Estado/Rua/TotalRecolhido|Sol],RecolhidoAtual,
TotalRecolhidoFinal,Dist,DistFinal,Tipo) :-
    nodo(Estado,Rua,_,Recolhidos),
    selecionaTipo(Recolhidos,Tipo,Recolhidos1),
    recolher(Recolhidos1,TotalRecolhido),
    RecolhidoAtual1 is RecolhidoAtual + TotalRecolhido,
    arco(Estado,Estado1,Distancia),
    Dist1 is Dist + Distancia,
    nao(membro(Estado1,Historico)),
    dfsSeletiva(Estado1,[Estado1|Historico],Sol,RecolhidoAtual1,TotalRecolhido1,
    Dist1,DistFinal1,Tipo),
    TotalRecolhidoFinal is TotalRecolhido1 + TotalRecolhido,
    DistFinal is DistFinal1 + Distancia.


% -> Primeiro em largura
% resolvebf(Solucao) :-
% 	inicial(InicialEstado),
% 	resolvebf([(InicialEstado,[])|Xs]-Xs,[],Solucao).

% resolvebf([(Estado,Vs)|_]-_,_,Rs) :-
% 	final(Estado),!,inverso(Vs,Rs).

% resolvebf([(Estado, _)|Xs]-Ys, Historico, Solucao):-
% 	membro(Estado, Historico),!,
% 	resolvebf(Xs-Ys,Historico,Solucao).

% resolvebf([(Estado,Vs)|Xs]-Ys,Historico,Solucao) :-
% 	setof((Move,Estado1), transicao(Estado,Move,Estado1),Ls),
% 	atualizar(Ls,Vs,[Estado|Historico], Ys-Zs),
% 	resolvebf(Xs-Zs,[Estado|Historico],Solucao).

% atualizar([],_,_,X-X).

% atualizar([(_,Estado)|Ls], Vs, Historico, Xs-Ys) :-
% 	membro(Estado,Historico), !,
% 	atualizar(Ls,Vs,Historico,Xs-Ys).

% atualizar([(Move,Estado)|Ls], Vs, Historico, [(Estado, [Move|Vs])|Xs]-Ys) :-
% 	atualizar(Ls,Vs,Historico,Xs-Ys).

