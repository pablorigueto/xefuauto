"""Gera o GameDetails.lua a partir de dados_extra.json.

Uso:  python gerar.py
Saida: GameDetails.lua (ao lado deste arquivo)
"""
import json
import os

AQUI = os.path.dirname(os.path.abspath(__file__))
DADOS = os.path.join(AQUI, '..', 'dados_extra.json')
SAIDA = os.path.join(AQUI, 'GameDetails.lua')

# generos com nome curto para caber na linha do subtitulo
ABREV = {
    'Role-playing (RPG)': 'RPG',
    'Turn-based strategy (TBS)': 'TBS',
    'Real Time Strategy (RTS)': 'RTS',
    'Card & Board Game': 'Card & Board',
    'Point-and-click': 'Point-and-click',
    'Hack and slash': 'Hack n Slash',
    'Visual Novel': 'Visual Novel',
}

def players_texto(n):
    if not n or n <= 0:
        return ''
    n = int(n)
    if n >= 4:
        return '1-4 Players'
    if n == 1:
        return '1 Player'
    return '1-%d Players' % n

def main():
    dados = json.load(open(DADOS, encoding='utf-8'))
    linhas = []
    for tid, v in sorted(dados.items()):
        try:
            num = int(tid, 16)
        except ValueError:
            continue
        gens = [ABREV.get(g, g) for g in v.get('genres', []) if g]
        partes = []
        if gens:
            partes.append(', '.join(gens))
        pt = players_texto(v.get('players'))
        if pt:
            partes.append(pt)
        if not partes:
            continue
        linhas.append('\t[0x%08X] = %s,' % (num, json.dumps(' | '.join(partes))))

    corpo = '\n'.join(linhas)

    lua = '''-- GameDetails - genero e jogadores APENAS na linha "xefu: ...".
-- Nao polui o menu "Select Subtitle": so a linha do Xefu Auto
-- (que ja e a exibida na tela de detalhes) ganha a info na frente.
-- Gerado automaticamente por gerar.py. Nao edite a mao.
-- Jogos mapeados: %d

local MAPA = {
%s
}

local function infoDe(Content)
	return MAPA[Content.TitleId]
end

local function envolver(fn)
	return function(Content)
		local ok, texto = pcall(fn, Content)
		if not ok then
			texto = ""
		end
		local info = infoDe(Content)
		if not info or info == "" then
			return texto
		end
		if texto == nil or texto == "" then
			return info
		end
		return texto .. "  |  " .. info
	end
end

-- Envolve QUALQUER funcao que seja registrada na chave "Xefu Auto",
-- agora ou depois (independe da ordem de carregamento dos scripts).
do
	local mt = getmetatable(GameListSubtitles)
	local novoindex_antigo = mt and mt.__newindex
	mt = mt or {}
	mt.__newindex = function(t, k, v)
		if k == "Xefu Auto" and type(v) == "function" then
			v = envolver(v)
		end
		if novoindex_antigo then
			novoindex_antigo(t, k, v)
		else
			rawset(t, k, v)
		end
	end
	setmetatable(GameListSubtitles, mt)

	-- se o Xefu Auto ja estiver registrado (carregou antes de nos),
	-- envolve agora
	local atual = rawget(GameListSubtitles, "Xefu Auto")
	if type(atual) == "function" then
		rawset(GameListSubtitles, "Xefu Auto", envolver(atual))
	end
end
''' % (len(linhas), corpo)

    with open(SAIDA, 'w', encoding='utf-8') as fh:
        fh.write(lua)
    print('gerado: %s  (%d jogos, %d bytes)'
          % (SAIDA, len(linhas), os.path.getsize(SAIDA)))

    # validacao de sintaxe, se a lib estiver disponivel
    try:
        import luaparser.ast as a
        a.parse(lua)
        print('Lua: sintaxe OK')
    except ImportError:
        print('Lua: lib luaparser nao disponivel, validacao pulada')
    except Exception as e:
        print('Lua: ERRO DE SINTAXE: %s' % e)

if __name__ == '__main__':
    main()
