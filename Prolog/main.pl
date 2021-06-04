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


