#!/usr/bin/env python
# -*- coding: utf-8 -*-

import pandas as pd
import numpy as np

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
        fim = '\'' + fim + '\''
        ruasDict.update({idRuas : (inicio, fim, localizacao)})
    else:
        rua = listaSeps[1]
        rua = '\'' + rua + '\''
        ruasDict.update({idRuas : (rua,'',localizacao)})


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
    result = np.sqrt(  (lat1-lat2)**2 + (long1-long2)**2 )
    return result


# Formar o arco entre dois percursos de recolha relativos a uma rua
def formarArco(idInicio,rua):
    (inicio,destino,locInicio) = rua
    listaDests = procurarDestino(idInicio,inicio,destino)
    if len(listaDests) == 0:
            triplo = (idInicio,-1,(-1,-1))
            arcosDict[idInicio] = [triplo]
    else:
        for (idDest,(latDest,longDest)) in listaDests:
            dist = calcularDistancia((latDest,longDest),locInicio)
            
            if dist > 0:
                if idInicio in arcosDict:    
                    arcosDict[idInicio].append((idInicio, idDest, dist))
                else:
                    arcosDict[idInicio] = [(idInicio,idDest,dist)]


# Procurar os percursos seguintes a que podemos recorrer, a partir de uma rua
def procurarDestino(idInicio,inicio,destino):
    res = []
    for key, value in ruasDict.items():
        (ini,_,locInicio) = value
        if((inicio == ini and key > idInicio) or (destino == ini)):
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
# Definição de um nodo representante da garagem, que se situa perto da R Ferragial
nodos.add('nodo(0,\'Garagem\',(-9.10206034846112, 35.7082819634324),[]).\n') 

for key, value in ruasDict.items():
    (inicio,_,(latitude,longitude)) = value 
    listaResiduos = residuosDict[key]
    nodos.add('nodo({},{},{},{}).\n'.format(key,inicio,(latitude,longitude),listaResiduos))

# Definição de um nodo representante do local de depósito, que se situa perto da Av 24 de Julho
nodos.add('nodo(9999,\'Depósito\',(-9.12404532851606, 36.4528294413797),[]).\n') 

for nodo in nodos:
    nodosGrafo.write(nodo)
nodosGrafo.close()

arcos = open('../Prolog/arcos.pl','w+')
arcos.write('%%arco(idInicio,idFim,distancia).\n')
arcosSet = set()
(_,_,(lat,long)) = ruasDict[15805]
dist = calcularDistancia((lat,long),(-9.10206034846112, 35.7082819634324))
arcosSet.add('arco({},{},{}).\n'.format(0,15805,dist))

for key, value in arcosDict.items():
    for elem in value:
        (idInicio,idFim,dist) = elem
        arcosSet.add('arco({},{},{}).\n'.format(idInicio,idFim,dist))

(_,_,(lat,long)) = ruasDict[15876]
dist = calcularDistancia((-9.12404532851606, 36.4528294413797),(lat,long))
arcosSet.add('arco({},{},{}).\n'.format(15876,9999,dist))

distDepositoGaragem = calcularDistancia((-9.10206034846112, 35.7082819634324),(-9.12404532851606, 36.4528294413797))
arcosSet.add('arco({},{},{}).\n'.format(9999,0,distDepositoGaragem))

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






