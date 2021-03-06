#!/usr/bin/env python
# -*- coding: utf-8 -*-

import pandas as pd
from math import sin, cos, atan2, sqrt, radians
import re 

# Ler o conteudo do dataset
df = pd.read_excel(r'../Dados/dataset.xlsx',encoding='utf-8')

# Guardar as linhas necessárias para transformar em ascii
i = 0
for line in df:
    if i == 3:
        pontoRecolhaFreguesia = line
    elif i == 4:
        pontoRecolhaLocal = line
    elif i == 5:
        pontoResiduo = line
    i = i + 1

# Converter para carateres ascii compativeis
df[pontoRecolhaFreguesia] = df[pontoRecolhaFreguesia].str.normalize('NFKD').str.encode('ascii', errors='ignore').str.decode('utf-8')
df[pontoRecolhaLocal] = df[pontoRecolhaLocal].str.normalize('NFKD').str.encode('ascii', errors='ignore').str.decode('utf-8')
df[pontoResiduo] = df[pontoResiduo].str.normalize('NFKD').str.encode('ascii', errors='ignore').str.decode('utf-8')

# --------------------------------------------------------------------------------------------------

# Povoar os dicionários
def updateDicts(ruas, tipoLixo, totalLitros, localizacao):
    separacoes = ruas.split(": ")
    updateRuas(separacoes, localizacao)
    updateResiduos(separacoes, tipoLixo, totalLitros)


# Povoar o dicionário que representa o percurso de uma rua
#  : chave -> id do percurso e valor -> (inicio, fim, (lat,long))
def updateRuas(listaSeps, localizacao):
    idRuas = int(listaSeps[0])
    if(ruasDict.has_key(idRuas)):
        pass
    elif(len(listaSeps) == 3):
        ruas = listaSeps[2]
        inicio = ruas.split(' - ')[0]
        inicio = '\'' + inicio + '\''
        fim = ruas.split(' - ')[1]
        fim = fim.split(')')[0]
        if fim == 'R Cintura (Santos':
            fim = 'R Cintura (Santos)'
        fim = '\'' + fim + '\''
        ruasDict.update({idRuas : (inicio, fim, localizacao)})
    else:
        pass


# Povoar o dicionário dos resíduos: Chave -> idPercursoRua e Valor -> [(Residuo, TotalLitros)]
def updateResiduos(seps, lixo, litros):
    par = (lixo,litros)
    idRuas = int(seps[0])
    if idRuas in residuosDict:
        residuosDict[idRuas].append(par)
    else:
        residuosDict[idRuas] = [par]


# Calcular a distância entre dois pontos (cada ponto representa o percurso de recolha de uma rua)
def calcularDistancia(fim,inicio): 	
    (lat1,long1) = fim
    (lat2,long2) = inicio

    lat1 = radians(lat1)
    lat2 = radians(lat2)
    long1 = radians(long1)
    long2 = radians(long2)

    R = 6373.0
    
    dlon = long2 - long1
    dlat = lat2 - lat1
    a = (sin(dlat/2))**2 + cos(lat1) * cos(lat2) * (sin(dlon/2))**2
    c = 2 * atan2(sqrt(a), sqrt(1-a))
    return R * c * 1000


# Formar o arco entre dois percursos de recolha relativos a uma rua
def formarArco(idInicio,rua):
    (_,destino,locInicio) = rua
    listaDests = procurarDestino(destino)
    if len(listaDests) == 0:
            pass
    else:
        for (idDest,(latDest,longDest)) in listaDests:
            dist = calcularDistancia((latDest,longDest),locInicio)
            
            if dist > 0:
                if idInicio in arcosDict:    
                    arcosDict[idInicio].append((idInicio, idDest, dist))
                else:
                    arcosDict[idInicio] = [(idInicio,idDest,dist)]


# Procurar os percursos seguintes a que podemos recorrer, a partir de uma rua
def procurarDestino(destino):
    res = []
    for key, value in ruasDict.items():
        (ini,_,locInicio) = value
        if destino == ini:
            res.append((key,locInicio))
    return res


# Dicionario que guarda os nodos do grafo e a lista dos seus adjacentes
ruasDict = {}
residuosDict = {}
arcosDict = {}

# Preencher o dicionário, chave -> id da rua, valor -> adjacência entre uma rua e outra
for value in df.values:
    ruas = value[4]
    tipoLixo = str(value[5])
    totalLitros = int(value[9])
    lat = float(value[0])
    long = float(value[1])
    localizacao = (lat,long)
    updateDicts(ruas, tipoLixo, totalLitros, localizacao)


# Formar os arcos
for key, value in ruasDict.items():
    formarArco(key, value)


# Converter tudo em predicados para utilizar no Prolog
nodosGrafo = open('../Prolog/nodos.pl','w+')
nodosGrafo.write('%%nodo(Id, Nome, (Latitude, Longitude), [(Residuo, TotalLitros)]).\n')
nodos = set()

for key, value in ruasDict.items():
    (inicio,_,(latitude,longitude)) = value 
    listaResiduos = residuosDict[key]
    nodos.add('nodo({},{},{},{}).\n'.format(key,inicio,(latitude,longitude),listaResiduos))

for nodo in nodos:
    nodosGrafo.write(nodo)
nodosGrafo.close()

arcos = open('../Prolog/arcos.pl','w+')
arcos.write('%%arco(idInicio,idFim,distancia).\n')
arcosSet = set()
(_,_,(lat,long)) = ruasDict[15805]

for key, value in arcosDict.items():
    for elem in value:
        (idInicio,idFim,dist) = elem
        arcosSet.add('arco({},{},{}).\n'.format(idInicio,idFim,dist))

(_,_,(lat1,long1)) = ruasDict[15899]
dist = calcularDistancia((lat1,long1),(lat,long))
arcosSet.add('arco({},{},{}).\n'.format(15899,15805,dist))

for arco in arcosSet:
    arcos.write(arco)
arcos.close()

    

# ruasSorted = sorted(ruasDict.items()) # Ordenar o dicionário pelo ID das ruas
# for elem in ruasSorted:
#     print(elem)

# residSorted = sorted(residuosDict.items()) # Ordenar o dicionário pelo ID das ruas
# for elem in residSorted:
#     print(elem)

# arcosSorted = sorted(arcosDict.items()) # Ordenar o dicionário pelo ID das ruas
# for elem in arcosSorted:
#     print(elem)






