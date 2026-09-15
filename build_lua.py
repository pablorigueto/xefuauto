# -*- coding: utf-8 -*-
"""Gera o Xefu Auto AUTOMATICO para o Aurora.

Saida: aurora-autoxefu/saida_auto/Aurora/User/Scripts/
  Content/Subtitles/XefuAuto.lua   <- o gancho automatico (roda sozinho)
  Utility/XefuAuto/...             <- painel de controle (ligar/desligar)
"""
import json
import os
import sqlite3
import sys

RAIZ = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, RAIZ)

# xefus que realmente existem em Hddx:\Compatibility\XefuBackup
DISPONIVEIS = {
    'xefu': 'xefu.xex', 'xefu1_1': 'xefu1_1.xex', 'xefu2': 'xefu2.xex',
    'xefu3': 'xefu3.xex', 'xefu5': 'xefu5.xex', 'xefu6': 'xefu6.xex',
    'xefu7': 'xefu7.xex', 'xefu7b': 'xefu7b.xex', 'xefu2019': 'xefu2019.xex',
    'xefu2021a': 'xefu2021a.xex', 'xefu2021b': 'xefu2021b.xex',
    'xefu2021c': 'xefu2021c.xex',
}

# xefu -> xefutitle correspondente (os que nao aparecem usam xefutitle.xex)
XEFUTITLE = {
    'xefu5': 'xefutitle5.xex', 'xefu6': 'xefutitle6.xex',
    'xefu7': 'xefutitle7.xex', 'xefu7b': 'xefutitle7b.xex',
    'xefu2019': 'xefutitle2019.xex', 'xefu2021a': 'xefutitle2021.xex',
    'xefu2021b': 'xefutitle2021.xex', 'xefu2021c': 'xefutitle2021.xex',
}

# nomes abreviados no console -> nome na lista da comunidade
ALIASES = {
    'MGS2 SUBSTANCE': 'Metal Gear Solid 2: Substance',
    'M:I - OP SURMA': 'Mission: Impossible: Operation Surma',
    'The Matrix: PON': 'The Matrix: Path of Neo',
    'Prince of Persia WW': 'Prince of Persia: Warrior Within',
    'Prince of Persia: T2T': 'Prince of Persia: The Two Thrones',
    'TMNT(TM)2': 'Teenage Mutant Ninja Turtles 2: Battle Nexus',
    'TMNT(R)3': 'Teenage Mutant Ninja Turtles 3: Mutant Nightmare',
    'The Two Towers(tm)': 'The Lord of the Rings: The Two Towers',
    'TimeSplitters FP': 'TimeSplitters: Future Perfect',
    'MK Deadly Alliance': 'Mortal Kombat: Deadly Alliance',
    'MK Shaolin Monks': 'Mortal Kombat: Shaolin Monks',
    'PSO': 'Phantasy Star Online Episode I & II',
}

CURTO = {'1': 'xefu', '2': 'xefu2', '3': 'xefu3', '5': 'xefu5',
         '1_1': 'xefu1_1', '6': 'xefu6', '7': 'xefu7', '7b': 'xefu7b',
         '19': 'xefu2019', '2019': 'xefu2019', '21a': 'xefu2021a',
         '21b': 'xefu2021b', '21c': 'xefu2021c'}


# So entram jogos que dao para jogar de fato. Menus/Intro/Unplayable e
# Untested ficam de fora: trocar o xefu neles nao torna o jogo jogavel, e
# so aumentaria a chance de aplicar uma versao pior do que a que ja esta.
STATUS_ACEITOS = ('Officially supported', 'Playable', 'In-game')


def curto_para_xefu(c):
    if c is None:
        return None
    v = CURTO.get(str(c).strip().lower().replace('.xex', ''))
    return v if v in DISPONIVEIS else None


def norm_emu(emu):
    if not emu:
        return None
    e = str(emu).strip().lower().replace('config_loader_', '').replace('.xex', '')
    if e in ('xefu2021', 'xefu2021d'):
        e = 'xefu2021c'
    if e == 'xefu1.1':
        e = 'xefu1_1'
    return e if e in DISPONIVEIS else None


def carregar_mapa():
    """TitleId(hex, 8) -> nome do xefu, juntando as duas listas com TitleId."""
    mapa, origem = {}, {}

    # 1) consolidado (ja tem title_id + melhor xefu testado pela comunidade)
    for j in json.load(open(os.path.join(RAIZ, 'xefu_full.json'), encoding='utf-8')):
        if j.get('status') not in STATUS_ACEITOS:
            continue
        tid, emu = j.get('title_id'), norm_emu(j.get('xefu'))
        if tid and emu:
            k = tid.upper().zfill(8)
            mapa[k] = emu
            origem[k] = 'comunidade:' + (j.get('name') or '')

    # 2) lista oficial preenche o que faltar
    for j in json.load(open(os.path.join(RAIZ, 'official_xefu_map.json'), encoding='utf-8')):
        tid, emu = j.get('title_id'), norm_emu(j.get('emu'))
        if tid and emu:
            k = tid.upper().zfill(8)
            if k not in mapa:
                mapa[k] = emu
                origem[k] = 'oficial:' + (j.get('name') or '')

    # 3) TitleIDs recuperados de bases publicas (MobCat / jeltaqq).
    #    A wiki da ConsoleMods lista os jogos so por nome, entao sem isto
    #    a maior parte da lista ficaria de fora em consoles de terceiros.
    extra = os.path.join(RAIZ, 'titleids_resolvidos.json')
    if os.path.exists(extra):
        jogaveis = set(por_nome_comunidade())   # ja vem filtrado por status
        for tid, info in json.load(open(extra, encoding='utf-8')).items():
            if info.get('name') not in jogaveis:
                continue
            emu = norm_emu(info.get('xefu'))
            k = tid.upper().zfill(8)
            if emu and k not in mapa:
                mapa[k] = emu
                origem[k] = 'resolvido:' + (info.get('name') or '')
    return mapa, origem


def por_nome_comunidade(todos=False):
    """nome -> melhor xefu, da lista da comunidade.

    Por padrao devolve so os jogos com status jogavel (ver STATUS_ACEITOS).
    `todos=True` ignora o filtro (util para auditoria).
    """
    out = {}
    for g in json.load(open(os.path.join(RAIZ, 'xefu_best.json'), encoding='utf-8')):
        if not todos and g.get('status') not in STATUS_ACEITOS:
            continue
        e = curto_para_xefu(g.get('best_xefu'))
        if e:
            out.setdefault(g['name'], e)
    return out


def jogos_instalados(db):
    """TitleId -> nome, dos jogos OG Xbox no content.db."""
    if not os.path.exists(db):
        return {}
    c = sqlite3.connect(db)
    cur = c.cursor()
    cur.execute("select TitleId, TitleName from ContentItems where Executable='default.xbe'")
    out = {}
    for tid, nome in cur.fetchall():
        if tid is not None:
            out['%08X' % (tid & 0xFFFFFFFF)] = nome
    c.close()
    return out


def completar_por_nome(mapa, origem, inst):
    """Casa por nome os instalados que nao tem TitleId nas listas."""
    from match_names import match, norm
    com = por_nome_comunidade()
    cnames = list(com)
    pk = {norm(n): n for n in cnames}
    novos, faltam = 0, []
    for tid in list(inst):
        if tid in mapa:
            continue
        nome = inst[tid]
        if not nome:
            continue
        nome = ALIASES.get(nome.strip(), nome)
        alvo = pk.get(norm(nome)) or match(nome, cnames)
        if alvo:
            mapa[tid] = com[alvo]
            origem[tid] = 'nome:' + alvo
            novos += 1
        else:
            faltam.append((tid, inst[tid]))
    return novos, faltam


def mapa_por_nome():
    """chave normalizada do nome -> xefu, para os 1024 da comunidade.

    A wiki da ConsoleMods lista os jogos por NOME, sem TitleID: so 479 dos
    1024 tem ID conhecido. Casar tambem por nome e o que faz o pacote
    funcionar para qualquer pessoa, e nao so para quem tem os jogos que
    por acaso estao na tabela oficial.
    """
    from match_names import norm
    out = {}
    for nome, xefu in por_nome_comunidade().items():
        chave = norm(nome)
        if chave:
            out.setdefault(chave, xefu)
    return out


def gerar_lua(mapa, caminho_saida, so=None, por_nome=None):
    """Escreve o subtitle script com as duas tabelas embutidas.

    `mapa`     TitleID -> xefu   (casamento exato, tem prioridade)
    `por_nome` nome normalizado -> xefu  (cobre quem nao tem TitleID)
    """
    if por_nome is None:
        por_nome = mapa_por_nome()

    nomes = sorted(set(list(mapa.values()) + list(por_nome.values())))
    idx = {n: i + 1 for i, n in enumerate(nomes)}

    pares = []
    for tid in sorted(mapa):
        if so and tid not in so:
            continue
        pares.append('[0x%s]=%d' % (tid, idx[mapa[tid]]))
    linhas = ['\t' + ','.join(pares[i:i + 10]) + ','
              for i in range(0, len(pares), 10)]
    tabela = '\n'.join(linhas).rstrip(',')

    pares_n = ['["%s"]=%d' % (k, idx[v]) for k, v in sorted(por_nome.items())]
    linhas_n = ['\t' + ','.join(pares_n[i:i + 6]) + ','
                for i in range(0, len(pares_n), 6)]
    tabela_nome = '\n'.join(linhas_n).rstrip(',')

    lista_xefu = ','.join('"%s.xex"' % n for n in nomes)
    lista_title = ','.join('"%s"' % XEFUTITLE.get(n, 'xefutitle.xex') for n in nomes)

    lua = LUA_TEMPLATE % {
        'n_jogos': len(pares),
        'n_nomes': len(pares_n),
        'tabela': tabela,
        'tabela_nome': tabela_nome,
        'lista_xefu': lista_xefu,
        'lista_title': lista_title,
    }
    os.makedirs(os.path.dirname(caminho_saida), exist_ok=True)
    with open(caminho_saida, 'w', encoding='utf-8', newline='\r\n') as fh:
        fh.write(lua)
    return len(pares), nomes


LUA_TEMPLATE = '''-- XefuAuto - troca o xefu automaticamente conforme o jogo selecionado.
-- Gerado automaticamente por gerar_auto.py. Nao edite a mao.
-- Jogos mapeados: %(n_jogos)d

local COMPAT = "Hddx:\\\\Compatibility\\\\"
local BACKUP = "Hddx:\\\\Compatibility\\\\XefuBackup\\\\"
local ESTADO = COMPAT .. "xefu_auto.txt"
local DESLIGADO = COMPAT .. "xefu_auto_off.txt"

-- TODOS os slots que o emulador pode carregar. Precisa cobrir os 12:
-- se um slot ficar de fora e o emulador escolher justo ele, o jogo roda
-- com a versao errada (foi o caso dos xefu2021*).
local SLOTS = {"xefu.xex", "xefu2.xex", "xefu3.xex", "xefu5.xex",
               "xefu1_1.xex", "xefu6.xex", "xefu7.xex", "xefu7b.xex",
               "xefu2019.xex", "xefu2021a.xex", "xefu2021b.xex",
               "xefu2021c.xex"}
local SLOTS_TITLE = {"xefutitle.xex", "xefutitle5.xex", "xefutitle6.xex",
                     "xefutitle7.xex", "xefutitle7b.xex",
                     "xefutitle2019.xex", "xefutitle2021.xex"}

local XEFUS = {%(lista_xefu)s}
local TITLES = {%(lista_title)s}

-- TitleId -> indice em XEFUS (casamento exato, tem prioridade)
local MAPA = {
%(tabela)s
}

-- nome normalizado -> indice em XEFUS (%(n_nomes)d jogos)
-- A lista da comunidade so tem NOME para a maioria dos jogos, entao esta
-- tabela e o que faz o pacote cobrir a lista inteira em qualquer console.
local POR_NOME = {
%(tabela_nome)s
}

-- Mesma normalizacao usada ao gerar a tabela: minusculas, sem acentos,
-- so letras e numeros.
local ACENTOS = {
\t["\\195\\161"]="a",["\\195\\160"]="a",["\\195\\162"]="a",["\\195\\163"]="a",["\\195\\164"]="a",
\t["\\195\\169"]="e",["\\195\\168"]="e",["\\195\\170"]="e",["\\195\\171"]="e",
\t["\\195\\173"]="i",["\\195\\172"]="i",["\\195\\174"]="i",["\\195\\175"]="i",
\t["\\195\\179"]="o",["\\195\\178"]="o",["\\195\\180"]="o",["\\195\\181"]="o",["\\195\\182"]="o",
\t["\\195\\186"]="u",["\\195\\185"]="u",["\\195\\187"]="u",["\\195\\188"]="u",
\t["\\195\\167"]="c",["\\195\\177"]="n",
}

local function normalizar(s)
\tif type(s) ~= "string" then return "" end
\ts = s:lower()
\tfor k, v in pairs(ACENTOS) do s = s:gsub(k, v) end
\treturn (s:gsub("[^a-z0-9]", ""))
end

-- cache em memoria: evita reescrever quando ja esta aplicado
local atual = nil

-- Ligado por padrao: so fica desligado se o arquivo de "off" existir.
local function ligado()
\treturn not FileSystem.FileExists(DESLIGADO)
end

local function aplicar(arquivo, titulo)
\tif not FileSystem.FileExists(BACKUP .. arquivo) then return false end
\tfor i = 1, #SLOTS do
\t\tFileSystem.CopyFile(BACKUP .. arquivo, COMPAT .. SLOTS[i], true)
\tend
\tif titulo and FileSystem.FileExists(BACKUP .. titulo) then
\t\tfor i = 1, #SLOTS_TITLE do
\t\t\tFileSystem.CopyFile(BACKUP .. titulo, COMPAT .. SLOTS_TITLE[i], true)
\t\tend
\tend
\tFileSystem.WriteFile(ESTADO, arquivo)
\treturn true
end

-- Aplica o xefu do jogo. Devolve o nome curto do xefu (ou nil).
-- Acha o xefu do jogo: primeiro pelo TitleId (exato), depois pelo nome.
-- O nome vem do proprio Aurora, entao funciona em qualquer console.
local function achar(Content)
\tlocal i = MAPA[Content.TitleId]
\tif i then return i end

\tfor _, campo in ipairs({Content.Name, Content.TitleName, Content.Directory}) do
\t\tif type(campo) == "string" and #campo > 0 then
\t\t\t-- Directory vem como "\\Xbox Original\\Nome do Jogo"
\t\t\tlocal so_nome = campo:match("([^\\\\]+)$") or campo
\t\t\ti = POR_NOME[normalizar(so_nome)]
\t\t\tif i then return i end
\t\tend
\tend
\treturn nil
end

local function trocar(Content)
\tlocal i = achar(Content)
\tif not i then return nil end
\tlocal arquivo = XEFUS[i]
\tif not ligado() then
\t\treturn arquivo:gsub("%%.xex$", "") .. " (off)"
\tend
\t-- Compara pelo TAMANHO do arquivo que esta no slot com o do original
\t-- no XefuBackup. E a fonte da verdade: nao depende de cache nem de
\t-- arquivo de registro, entao nunca "acha" que ja aplicou sem ter
\t-- aplicado.
\tlocal ok1, atualTam = pcall(FileSystem.GetFileSize, COMPAT .. "xefu.xex")
\tlocal ok2, alvoTam = pcall(FileSystem.GetFileSize, BACKUP .. arquivo)
\tif not (ok1 and ok2 and atualTam == alvoTam and atualTam > 0) then
\t\taplicar(arquivo, TITLES[i])
\tend
\treturn arquivo:gsub("%%.xex$", "")
end

-- 1) subtitulo proprio, para quem quiser ver so o xefu
GameListSubtitles["Xefu Auto"] = function(Content)
\tlocal nome = trocar(Content)
\tif not nome then return "" end
\treturn "xefu: " .. nome
end

-- 2) engancha nos subtitulos que ja existem, para funcionar
--    sem precisar trocar nada nas opcoes do Aurora.
--    Monta a lista primeiro e so depois substitui, para nao alterar
--    a tabela enquanto o pairs() percorre ela.
local function engancharTodos()
\tlocal alvos = {}
\tfor chave, original in pairs(GameListSubtitles) do
\t\tif chave ~= "Xefu Auto" and type(original) == "function" then
\t\t\talvos[#alvos + 1] = { chave = chave, original = original }
\t\tend
\tend
\tfor _, a in ipairs(alvos) do
\t\tlocal original = a.original
\t\tGameListSubtitles[a.chave] = function(Content)
\t\t\tpcall(trocar, Content)
\t\t\tlocal ok, texto = pcall(original, Content)
\t\t\tif ok then return texto end
\t\t\treturn ""
\t\tend
\tend
\t-- deixa rastro no debug.log para sabermos que o engate rodou
\tprint("XefuAuto: enganchei " .. #alvos .. " subtitulos")
end

pcall(engancharTodos)
'''


if __name__ == '__main__':
    mapa, origem = carregar_mapa()
    inst = jogos_instalados(os.path.join(RAIZ, 'dev', 'content.db'))
    novos, faltam = completar_por_nome(mapa, origem, inst)
    cob = sum(1 for t in inst if t in mapa)
    print('mapa total: %d titleids (+%d casados por nome)' % (len(mapa), novos))
    if inst:
        print('cobertura instalados: %d/%d (%.0f%%)'
              % (cob, len(inst), 100.0 * cob / len(inst)))
    for t, n in sorted(faltam, key=lambda x: x[1] or ''):
        print('   sem xefu conhecido:', t, n)

    saida = os.path.join(RAIZ, 'aurora-autoxefu', 'saida_auto', 'Aurora', 'User',
                         'Scripts', 'Content', 'Subtitles', 'XefuAuto.lua')
    n, nomes = gerar_lua(mapa, saida)
    print('\ngerado: %s' % saida)
    print('   %d jogos, %d xefus: %s' % (n, len(nomes), ', '.join(nomes)))
    print('   tamanho: %d bytes' % os.path.getsize(saida))
