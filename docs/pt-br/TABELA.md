# Editando a tabela de compatibilidade

A tabela que diz **qual xefu cada jogo usa** é um arquivo de texto
simples: **[`TABLE.csv`](../../TABLE.csv)**. Qualquer pessoa pode corrigir.

Isso importa porque a compatibilidade muda: aparecem xefus novos, alguém
descobre que um jogo roda melhor em outra versão, jogos faltando são
adicionados. Você não precisa esperar por ninguém para arrumar.

---

## O formato

Três colunas separadas por ponto e vírgula (`;`):

```
TitleID;Jogo;Xefu
45410026;007: NightFire;xefu
45530018;25 To Life;xefu7
54540001;4x4 EVO 2;xefu3
```

| Coluna | O que é | Importa? |
|---|---|---|
| `TitleID` | ID do jogo, 8 dígitos hex | **Sim** — é por ele que o jogo é reconhecido |
| `Jogo` | Nome, só para você se achar | Não — pode deixar em branco |
| `Xefu` | Qual xefu usar | **Sim** |

Abre no Excel, LibreOffice, Bloco de Notas, VS Code — o que preferir.

> Se usar Excel: ao salvar, escolha **CSV UTF-8**, e confirme que o
> separador é `;`.

### Valores aceitos na coluna Xefu

```
xefu      xefu1_1   xefu2     xefu3
xefu5     xefu6     xefu7     xefu7b
xefu2019  xefu2021a xefu2021b xefu2021c
```

Escreva exatamente assim, minúsculo e sem `.xex`. Qualquer outra coisa é
recusada com aviso, e nada é gerado — não tem como quebrar o script por
engano.

---

## Como descobrir o TitleID de um jogo

No próprio Aurora: selecione o jogo, **Y** (Details) → **A** (Subtitle) →
escolha **`Title ID`**. Ele aparece embaixo do nome do jogo.

Na tela `Select Subtitle` também dá para ver:

![Select Subtitle mostrando o Title ID](../../pic/3.jpeg)

Nessa foto, o Title ID do "25 To Life" é **`45530018`**.

---

## Como aplicar sua edição

Depois de editar e salvar o `TABLE.csv`:

```
python gerar_tabela.py aplicar
```

Isso regera o `XefuAuto.lua` com o conteúdo da sua tabela. Depois é só
instalar normalmente (`Install.bat`) e reiniciar o Aurora.

Se algo estiver errado, ele avisa e **não gera nada**:

```
ERROS na tabela — nada foi gerado:
    linha 2: xefu desconhecido: 'xefu99' (use: xefu, xefu1_1, ...)
    linha 3: TitleID invalido: 'ZZZZ'
```

Precisa de Python 3 no PC (só para regerar; para usar o XefuAuto, não).

---

## Casos comuns

### Um jogo trava — quero trocar o xefu dele

Ache a linha pelo nome e mude a última coluna:

```
49470024;Unreal Championship;xefu       ← travava
49470024;Unreal Championship;xefu7      ← corrigido
```

Se não souber qual tentar, `xefu7` é o mais compatível no geral (é o
escolhido para 658 dos 1024 jogos da lista).

### Quero adicionar um jogo que não está na lista

Acrescente uma linha no fim. A ordem não importa:

```
4B4F0009;Meu Jogo;xefu7
```

### Quero que um jogo não seja trocado

Apague a linha dele. Sem entrada na tabela, o XefuAuto não mexe em nada e
o jogo roda com o xefu que estiver no console.

---

## Quais jogos entram, e por quê

A lista da ConsoleMods classifica cada jogo em seis níveis. **Só os três
primeiros entram aqui:**

| Status | Entra? | Por quê |
|---|---|---|
| `{{supported}}` | ✅ sim | Oficialmente suportado pelo emulador |
| `{{playable}}` | ✅ sim | Problemas mínimos ou nenhum |
| `{{in-game}}` | ✅ sim | Dá para jogar, com problemas |
| `{{menus}}` | ❌ não | Só chega ao menu |
| `{{intro}}` | ❌ não | Só chega à intro |
| `{{unplayable}}` | ❌ não | Não roda |

Os três últimos ficam de fora **de propósito**. Se um jogo não passa do
menu em *nenhuma* das 12 versões, trocar o emulador não o torna jogável —
só mexeria em arquivos à toa, e ainda arriscaria substituir uma versão que
por acaso funciona melhor do que a que a lista chuta. Esses jogos ficam
intocados: o XefuAuto não mexe neles, e eles rodam com o xefu que já
estiver no console.

É essa a diferença entre os 1024 da wiki e os 961 desta tabela.

## De onde vêm esses dados

A tabela nasce do cruzamento de três fontes:

1. **Lista da comunidade ConsoleMods** — 1024 jogos testados em todas as
   12 versões de xefu. É a fonte principal de *qual xefu* cada jogo pede.
2. **Tabela oficial do emulador** — 539 jogos, extraída por *Matheiulh* do
   update 5832.
3. **Bases públicas de Title ID** — [lista do
   MobCat](https://github.com/MobCat/MobCats-original-xbox-game-list) e
   [Xbox Original GameList do
   jeltaqq](https://github.com/jeltaqq/Xbox-Original-GameList).

A fonte 3 importa mais do que parece. A wiki da ConsoleMods identifica os
jogos **só por nome** — não tem coluna de Title ID — e o Aurora identifica
**por Title ID**. Sem essas bases, só dariam para casar os ~479 jogos que
por acaso estão na tabela oficial, e o resto da lista seria inútil. O
cruzamento recuperou o Title ID de 961 deles.

Como rede de segurança, o script também carrega uma tabela por nome (940
entradas), usada quando o Title ID não é reconhecido.

Quando um jogo empata (roda igualmente bem em várias versões), a escolha
é sempre a **versão mais nova**, que costuma ser a mais compatível.

---

## Contribuindo de volta

Se você corrigir algo que vale para todo mundo, abra um **Pull Request**
com o `TABLE.csv` alterado, ou uma **Issue** dizendo:

- Nome do jogo e Title ID
- Qual xefu estava e qual funcionou
- O que acontecia antes (travava, tela preta, só o menu...)

Isso ajuda quem vier depois a não passar pelo mesmo problema.
