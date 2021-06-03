#!/usr/bin/env python
# -*- coding: utf-8 -*-

import pandas as pd
import numpy as np

# Ler o conteudo do dataset
df = pd.read_excel(r'dataset.xlsx',encoding='utf-8')

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


# Povoar o dicionário das ruas : chave -> id e valor -> (inicio, fim, (lat,long))
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
        fim = '\'' + fim + '\''
        ruasDict.update({idRuas : (inicio, fim, localizacao)})
    else:
        rua = listaSeps[1]
        rua = '\'' + rua + '\''
        ruasDict.update({idRuas : (rua,'',localizacao)})


# Povoar o dicionário dos resíduos: Chave -> idRua e Valor -> [(Residuo, TotalLitros)]
def updateResiduos(seps, lixo, litros):
    par = (lixo,litros)
    idRuas = int(seps[0])
    if idRuas in residuosDict:
        residuosDict[idRuas].append(par)
    else:
        residuosDict[idRuas] = [par]


# Calcular a distância entre dois pontos 
def calcularDistancia(fim,inicio):
    (lat1,long1) = fim
    (lat2,long2) = inicio
    result = np.sqrt(  (lat1-lat2)**2 + (long1-long2)**2 )
    return result


# Formar o arco a partir do ponto de início de uma rua
def formarArco(idInicio,rua):
    (_,destino,locInicio) = rua
    if(destino != ''):
        # print('Destino: ' + destino)
        (idDest,(latDest,longDest)) = procurarDestino(destino)
        if(latDest != -1 and longDest != -1):
            dist = calcularDistancia((latDest,longDest),locInicio)
        else:
            dist = -1
        arcosDict[idInicio] = (idInicio, idDest, dist)


# Procurar o final de uma rua
def procurarDestino(destino):
    for key, value in ruasDict.items():
        (inicio,_,locInicio) = value
        if(inicio == destino):
            return (key, locInicio)
    return (-1,(-1.0,-1.0))


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
nodosGrafo = open('nodos.pl','w+')
nodosGrafo.write('%%nodo(Id, Nome, (Latitude, Longitude), [(Residuo, TotalLitros)]).\n')
nodos = set()

for key, value in ruasDict.items():
    (inicio,_,(latitude,longitude)) = value 
    listaResiduos = residuosDict[key]
    nodos.add('nodo({},{},{},{}).\n'.format(key,inicio,(latitude,longitude),listaResiduos))

for nodo in nodos:
    nodosGrafo.write(nodo)
nodosGrafo.close()

arcos = open('arcos.pl','w+')
arcos.write('%%arco(idInicio,idFim,distancia).\n')
arcosSet = set()

for key, value in arcosDict.items():
    (idIn,idDest,dist) = value
    arcosSet.add('arco({},{},{}).\n'.format(idIn,idDest,dist))

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






