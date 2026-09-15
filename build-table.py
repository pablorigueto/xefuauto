# -*- coding: utf-8 -*-
"""Gera a tabela editavel (CSV) e reconstroi o Lua a partir dela.

Dois usos:

  python build-table.py exportar
      Cria TABLE.csv a partir das listas da comunidade/oficial.

  python build-table.py aplicar
      Le TABLE.csv e regera o XefuAuto.lua com o conteudo dela.
      E isso que a comunidade usa depois de editar a tabela.
"""
import csv
import os
import sys

RAIZ = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, RAIZ)

from build_lua import (  # noqa: E402
    DISPONIVEIS, carregar_mapa, completar_por_nome, gerar_lua,
    jogos_instalados,
)

# Funciona tanto no repo (onde existe a pasta release/) quanto de dentro
# do proprio pacote distribuido (onde o CSV fica ao lado do script).
if (os.path.exists(os.path.join(RAIZ, 'TABLE.csv'))
        or os.path.exists(os.path.join(RAIZ, 'TABELA.csv'))
        or os.path.exists(os.path.join(RAIZ, 'Aurora'))):
    BASE = RAIZ
else:
    BASE = os.path.join(RAIZ, 'release')


def _achar_csv():
    """Aceita TABLE.csv (ingles, padrao) ou TABELA.csv (legado)."""
    for nome in ('TABLE.csv', 'TABELA.csv'):
        caminho = os.path.join(BASE, nome)
        if os.path.exists(caminho):
            return caminho
    return os.path.join(BASE, 'TABLE.csv')


CSV_PATH = _achar_csv()
LUA_PATH = os.path.join(BASE, 'Aurora', 'User', 'Scripts',
                        'Content', 'Subtitles', 'XefuAuto.lua')

CABECALHO = ['TitleID', 'Game', 'Xefu']


def nomes_conhecidos():
    """TitleID -> nome do jogo, juntando todas as fontes."""
    import json
    nomes = {}
    for arq, campo in (('xefu_full.json', 'title_id'),
                       ('official_xefu_map.json', 'title_id')):
        caminho = os.path.join(RAIZ, arq)
        if not os.path.exists(caminho):
            continue
        for j in json.load(open(caminho, encoding='utf-8')):
            tid = j.get(campo)
            if tid and j.get('name'):
                nomes.setdefault(tid.upper().zfill(8), j['name'])
    # nomes dos jogos instalados tem prioridade (sao os reais do console)
    for tid, nome in jogos_instalados(os.path.join(RAIZ, 'dev', 'content.db')).items():
        if nome:
            nomes[tid] = nome
    return nomes


def exportar():
    mapa, _ = carregar_mapa()
    inst = jogos_instalados(os.path.join(RAIZ, 'dev', 'content.db'))
    completar_por_nome(mapa, {}, inst)
    nomes = nomes_conhecidos()

    os.makedirs(os.path.dirname(CSV_PATH), exist_ok=True)
    destino = os.path.join(BASE, 'TABLE.csv')
    with open(destino, 'w', encoding='utf-8-sig', newline='') as fh:
        w = csv.writer(fh, delimiter=';')
        w.writerow(CABECALHO)
        for tid in sorted(mapa, key=lambda t: (nomes.get(t, 'zzz').lower(), t)):
            w.writerow([tid, nomes.get(tid, ''), mapa[tid]])
    print('exportado: %s (%d jogos)' % (destino, len(mapa)))


def aplicar():
    if not os.path.exists(CSV_PATH):
        print('nao achei %s — rode "exportar" primeiro' % CSV_PATH)
        return 1

    mapa, erros = {}, []
    with open(CSV_PATH, encoding='utf-8-sig', newline='') as fh:
        for n, linha in enumerate(csv.DictReader(fh, delimiter=';'), start=2):
            tid = (linha.get('TitleID') or '').strip().upper()
            xefu = (linha.get('Xefu') or '').strip().lower()
            if not tid or not xefu:
                continue
            if len(tid) != 8 or any(c not in '0123456789ABCDEF' for c in tid):
                erros.append('linha %d: TitleID invalido: %r' % (n, tid))
                continue
            if xefu not in DISPONIVEIS:
                erros.append('linha %d: xefu desconhecido: %r (use: %s)'
                             % (n, xefu, ', '.join(sorted(DISPONIVEIS))))
                continue
            mapa[tid] = xefu

    if erros:
        print('ERROS na tabela — nada foi gerado:')
        for e in erros[:20]:
            print('   ', e)
        return 1

    n, nomes_xefu = gerar_lua(mapa, LUA_PATH)
    print('gerado: %s' % LUA_PATH)
    print('   %d jogos, %d xefus: %s' % (n, len(nomes_xefu), ', '.join(nomes_xefu)))
    return 0


if __name__ == '__main__':
    acao = sys.argv[1] if len(sys.argv) > 1 else 'exportar'
    if acao == 'exportar':
        exportar()
    elif acao == 'aplicar':
        sys.exit(aplicar())
    else:
        print(__doc__)
