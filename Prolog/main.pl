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
inicial(15805).

% Estado final (Depósito)
final(15899).

% LIMITE PARA A PESQUISA EM PROFUNDIDADE 
limite(6).

% Numero de pontos de recolha do grafo
numNodos(6). 

% Tipo de resíduo a recolher
tipo('Lixos').

% ---------------------------------------------------------------------------------------------------------

% -> Primeiro em profundidade

% 1) Gerar todos os circuitos de recolha num dado território
% O território é limitado pelo número de pontos de recolha que queremos visitar.

% 1.1) Indiferenciada
% -> Tendo em conta que se deve percorrer X nodos obrigatoriamente.

dfs(I,S,Dist) :-
    dfs(I,[I],S,0,Dist).

dfs(Estado,_,[Estado/Rua,Estado1/Rua1],DistAtual,DistFinal) :-
    final(Estado),
    nodo(Estado,Rua,_,_),
    nodo(Estado1,Rua1,_,_),
    arco(Estado,Estado1,Dist),
    DistFinal is DistAtual + Dist.

dfs(Estado,Historico,[Estado/Rua|Sol],Dist,DistFinal) :-
    nodo(Estado,Rua,_,_),
    arco(Estado,Estado1,Distancia),
    Dist1 is Dist + Distancia,
    nao(membro(Estado1,Historico)),
    dfs(Estado1,[Estado1|Historico],Sol,Dist1,DistFinal1),
    DistFinal is DistFinal1 + Distancia.


printDfsCircuitoRecolha(I) :-
    inicial(I),
    dfsCircuitoRecolha(I,[I],S,0,TotalRecolhido,0,DistanciaTotal,SDeposito,DistDeposito),
    escreverTriplo(S,0),
    escreverDupla(SDeposito,0),
    write('Total recolhido no circuito: '),
    write(TotalRecolhido),
    DistanciaTotal1 is DistanciaTotal + DistDeposito,
    write(' | Distancia total percorrida: '),
    write(DistanciaTotal1), write(' metros').

dfsCircuitoRecolha(S) :-
    inicial(I),
    dfsCircuitoRecolha(I,[I],S,0,_,0,_,_,_).

dfsCircuitoRecolha(Estado,Historico,[],_,0,_,0,SDeposito,DistDeposito) :-
    nodo(Estado,_,_,Recolhidos),
    recolher(Recolhidos,_),
    numNodos(X),
    length(Historico,N),
    N == X,
    dfs(Estado,SDeposito,DistDeposito).

dfsCircuitoRecolha(Estado,Historico,[Estado/Rua/TotalRecolhido|Sol],RecolhidoAtual,TotalRecolhidoFinal,
Dist,DistFinal,SDeposito,DistDeposito) :-
    nodo(Estado,Rua,_,Recolhidos),
    recolher(Recolhidos,TotalRecolhido),
    RecolhidoAtual1 is RecolhidoAtual + TotalRecolhido,
    arco(Estado,Estado1,Distancia),
    Dist1 is Dist + Distancia,
    nao(membro(Estado1,Historico)),
    dfsCircuitoRecolha(Estado1,[Estado1|Historico],Sol,RecolhidoAtual1,TotalRecolhido1,
    Dist1,DistFinal1,SDeposito,DistDeposito),
    TotalRecolhidoFinal is TotalRecolhido1 + TotalRecolhido,
    DistFinal is DistFinal1 + Distancia.

todosIndiferenciada(Solucao,NumCaminhos) :-
	findall((S,C),(dfsCircuitoRecolha(S),length(S,C)),Solucao),
    length(Solucao,NumCaminhos).

% -> Gerar qualquer caminho de recolha desde que se atinja o depósito.

dfs(I,S) :-
    inicial(I),
    dfs(I,[I],S,0,_,0,_).

printDfs(I) :-
    inicial(I),
    dfs(I,[I],S,0,TotalRecolhido,0,DistanciaTotal),
    escreverTriplo(S,0),
    write('Total recolhido no circuito: '),
    write(TotalRecolhido), write(' | Distancia percorrida: '),
    write(DistanciaTotal), write(' metros').

dfs(Estado,_,[Estado/Rua1/0,EstadoInicial/Rua/0],_,0,_,0) :-
    final(Estado),
    nodo(Estado,Rua,_,_),
    nodo(EstadoInicial,Rua1,_,_),
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

qualquerCaminhoIndiferenciado(Solucao,NumCaminhos) :-
    inicial(I),
	findall((S,C),(dfs(I,S),length(S,C)),Solucao),
    length(Solucao,NumCaminhos).

% 1.2) Escolher o tipo de resíduo

dfsSeletiva(I,S) :-
    tipo(Tipo),
    dfsSeletiva(I,[I],S,0,_,0,_,Tipo).

printDfsSeletiva(I) :-
    inicial(I),
    tipo(Tipo),
    dfsSeletiva(I,[I],S,0,TotalRecolhido,0,DistanciaTotal,Tipo),
    escreverTriplo(S,0),
    write('Total recolhido no circuito: '),
    write(TotalRecolhido), write(' | Distancia percorrida: '),
    write(DistanciaTotal), write(' metros').

dfsSeletiva(Estado,_,[Estado/Rua/0,Estado1/Rua1/0],_,0,_,0,_) :-
    final(Estado),
    nodo(Estado,Rua,_,_),
    nodo(Estado1,Rua1,_,_),
    arco(Estado,Estado1,_).

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

todosSeletiva(Solucao,NumCaminhos) :-
    inicial(I),
    tipo(Tipo),
	findall((S,C),(dfsSeletiva(I,S,Tipo),length(S,C)),Solucao),
    length(Solucao,NumCaminhos).

% -> Iterativa limitada
% 1.1) Indiferenciada

dfsLimitada(I,S) :-
    limite(Lim),
    dfsLimitada(I,[I],S,0,_,0,_,Lim).

printDfsLimitada(I) :-
    inicial(I),
    limite(Lim),
    dfsLimitada(I,[I],S,0,TotalRecolhido,0,DistanciaTotal,Lim),
    escreverTriplo(S,0),
    write('Total recolhido no circuito: '),
    write(TotalRecolhido), write(' | Distancia percorrida: '),
    write(DistanciaTotal), write(' metros').

dfsLimitada(Estado,_,[Estado/Rua/0,EstadoInicial/Rua1/0],_,0,_,0,_) :-
    final(Estado),
    nodo(Estado,Rua,_,_),
    nodo(EstadoInicial,Rua1,_,_),
    arco(Estado,EstadoInicial,_).

dfsLimitada(_,_,[],_,0,_,0,0).

dfsLimitada(Estado,Historico,[Estado/Rua/TotalRecolhido|Sol],RecolhidoAtual,TotalRecolhidoFinal,
Dist,DistFinal,Contador) :-
    Contador > 0,
    Contador1 is Contador - 1,
    nodo(Estado,Rua,_,Recolhidos),
    recolher(Recolhidos,TotalRecolhido),
    RecolhidoAtual1 is RecolhidoAtual + TotalRecolhido,
    arco(Estado,Estado1,Distancia),
    Dist1 is Dist + Distancia,
    nao(membro(Estado1,Historico)),
    dfsLimitada(Estado1,[Estado1|Historico],Sol,RecolhidoAtual1,TotalRecolhido1,
    Dist1,DistFinal1,Contador1),
    TotalRecolhidoFinal is TotalRecolhido1 + TotalRecolhido,
    DistFinal is DistFinal1 + Distancia.

todosIndiferenciadaLim(Solucao,NumCaminhos) :-
    inicial(I),
	findall((S,C),(dfsLimitada(I,S),length(S,C)),Solucao),
    length(Solucao,NumCaminhos).

% 1.2) Seletiva

dfsSeletivaLim(I,S) :-
    tipo(Tipo),
    limite(Lim),
    dfsSeletivaLim(I,[I],S,0,_,0,_,Tipo,Lim).

printDfsSeletivaLim(I) :-
    inicial(I),
    tipo(Tipo),
    limite(Lim),
    dfsSeletivaLim(I,[I],S,0,TotalRecolhido,0,DistanciaTotal,Tipo,Lim),
    escreverTriplo(S,0),
    write('Total recolhido no circuito: '),
    write(TotalRecolhido), write(' | Distancia percorrida: '),
    write(DistanciaTotal), write(' metros').

dfsSeletivaLim(Estado,_,[Estado/Rua/0,EstadoInicial/Rua1/0],_,0,_,0,_,_) :-
    final(Estado),
    nodo(Estado,Rua,_,_),
    nodo(EstadoInicial,Rua1,_,_),
    arco(Estado,EstadoInicial,_).

dfsSeletivaLim(_,_,[],_,0,_,0,_,0).

dfsSeletivaLim(Estado,Historico,[Estado/Rua/TotalRecolhido|Sol],RecolhidoAtual,
TotalRecolhidoFinal,Dist,DistFinal,Tipo,Contador) :-
    Contador > 0,
    Contador1 is Contador - 1,
    nodo(Estado,Rua,_,Recolhidos),
    selecionaTipo(Recolhidos,Tipo,Recolhidos1),
    recolher(Recolhidos1,TotalRecolhido),
    RecolhidoAtual1 is RecolhidoAtual + TotalRecolhido,
    arco(Estado,Estado1,Distancia),
    Dist1 is Dist + Distancia,
    nao(membro(Estado1,Historico)),
    dfsSeletivaLim(Estado1,[Estado1|Historico],Sol,RecolhidoAtual1,TotalRecolhido1,
    Dist1,DistFinal1,Tipo,Contador1),
    TotalRecolhidoFinal is TotalRecolhido1 + TotalRecolhido,
    DistFinal is DistFinal1 + Distancia.

todosSeletivaLim(Solucao,NumCaminhos) :-
    inicial(I),
	findall((S,C),(dfsSeletivaLim(I,S),length(S,C)),Solucao),
    length(Solucao,NumCaminhos).


% ---------------------------------------------------------------------------------------------------------
% 2) Circuitos com mais pontos de recolha, por tipo de resíduo


% -> Pesquisa Gulosa
resolve_gulosaSemEscrever(Caminho,NumPontos) :-
    inicial(I),
    tipo(T),
    nodo(I,_,_,Residuos),
    quantosPontosTem(Residuos,T,0,Quantos),
    agulosa([[I]/Quantos], InvCaminho/NumPontos),
    inverso(InvCaminho,Caminho).

resolve_gulosa(I) :-
    tipo(T),
    nodo(I,_,_,Residuos),
    quantosPontosTem(Residuos,T,0,Quantos),
    agulosa([[I]/Quantos], InvCaminho/NumPontos),
    inverso(InvCaminho,Caminho),
    escrever(Caminho),
    write('Número de pontos de recolha: '), write(NumPontos), write('\n').

agulosa(Caminhos, Caminho) :-
    obtem_melhor_g(Caminhos, Caminho),
    Caminho = [Nodo|_]/_,
    final(Nodo).

agulosa(Caminhos,SolucaoCaminho) :-
    obtem_melhor_g(Caminhos, MelhorCaminho),
    seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
    expande_gulosa(MelhorCaminho, ExpCaminhos),
    append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    agulosa(NovoCaminhos, SolucaoCaminho).

obtem_melhor_g([Caminho],Caminho) :- !.

obtem_melhor_g([Caminho1/Quantos1,_/Quantos2|Caminhos], MelhorCaminho) :-
    Quantos1 > Quantos2, !,
    obtem_melhor_g([Caminho1/Quantos1|Caminhos], MelhorCaminho).

obtem_melhor_g([_|Caminhos], MelhorCaminho) :-
    obtem_melhor_g(Caminhos, MelhorCaminho).

expande_gulosa(Caminho, ExpCaminhos) :-
    findall(NovoCaminho, adjacente3(Caminho, NovoCaminho), ExpCaminhos).


adjacente3([Nodo|Caminho]/Quantos, [ProxNodo,Nodo|Caminho]/NovoQuantos) :-
    arco(Nodo, ProxNodo, _),\+ member(ProxNodo, Caminho),
    nodo(Nodo,_,_,Residuos),
    tipo(T),
    quantosPontosTem(Residuos,T,0,Quantos1),
    NovoQuantos is Quantos + Quantos1,
    arco(Nodo,ProxNodo, _).


% Pesquisa em profundidade
dfsMaisPontosRecolha(I,S/NumPontos) :-
    inicial(I),
    dfsMaisPontosRecolha(I,[I],S,0,NumPontos).

% Os estados final e inicial nao contam para a contagem
dfsMaisPontosRecolha(Estado,_,[Inicio/Rua1/0,Estado/Rua/0],_,0) :-
    final(Estado),
    nodo(Estado,Rua,_,_),
    arco(Estado,Inicio,_),
    nodo(Inicio,Rua1,_,_).

dfsMaisPontosRecolha(Estado,Historico,[Estado/Rua/Quantos|Sol],Atual,Total) :-
    nodo(Estado,Rua,_,Recolhidos),
    tipo(T),
    quantosPontosTem(Recolhidos,T,0,Quantos),
    Atual1 is Atual + Quantos,
    arco(Estado,Estado1,_),
    nao(membro(Estado1,Historico)),
    dfsMaisPontosRecolha(Estado1,[Estado1|Historico],Sol,Atual1,Total1),
    Total is Total1 + Quantos.

todosMaisPontosRecolha(Solucao,NumSolucoes) :-
    inicial(I),
	findall((S,NumPontos),(dfsMaisPontosRecolha(I,S/NumPontos)),Solucao),
    length(Solucao,NumSolucoes).

maisPontosRecolha :-
    todosMaisPontosRecolha(Sol,_),
    retirarElems(Sol,Sol1,50),
    maximo(Sol1,(S,N)),
    escreverTriplo2(S,0),
    write('Total de pontos do tipo '),
    tipo(T), write(T), write(' '), write(N).



% -> Primeiro em largura

% bfsIndiferenciada(Solucao) :-
%     inicial(InicialEstado),
% 	bfsIndiferenciada([(InicialEstado,[])|Xs]-Xs,[],Solucao).

% bfsIndiferenciada([(Estado,Vs)|_]-_,_,Rs) :-
% 	final(Estado),!,inverso(Vs,Rs).

% bfsIndiferenciada([(Estado, _)|Xs]-Ys, Historico, Solucao):-
% 	membro(Estado, Historico),!,
% 	bfsIndiferenciada(Xs-Ys,Historico,Solucao).

% bfsIndiferenciada([(Estado,Vs)|Xs]-Ys,Historico,Solucao) :-
% 	setof((Dist,Estado1), arco(Estado,Estado1,Dist),Ls),
% 	atualizar(Ls,Vs,[Estado|Historico], Ys-Zs),
% 	bfsIndiferenciada(Xs-Zs,[Estado|Historico],Solucao).

% atualizar([],_,_,X-X).

% atualizar([(_,Estado)|Ls], Vs, Historico, Xs-Ys) :-
% 	membro(Estado,Historico), !,
% 	atualizar(Ls,Vs,Historico,Xs-Ys).

% atualizar([(Dist,Estado)|Ls], Vs, Historico, [(Estado, [(Estado,Rua,Dist)|Vs])|Xs]-Ys) :-
%     nodo(Estado,Rua,_,_),
% 	atualizar(Ls,Vs,Historico,Xs-Ys).

