# XefuAuto — o xefu certo, sozinho, pra cada jogo

Troca automaticamente o emulador (xefu) do Xbox 360 RGH conforme o jogo de
Xbox clássico que você seleciona no Aurora. Sem menu, sem escolher nada.

## O que é isso

O Xbox 360 roda jogos de Xbox clássico com um emulador chamado **xefu**.
Existem 12 versões dele, e **cada jogo funciona melhor com uma versão
diferente**. Normalmente você teria que trocar na mão, jogo a jogo.

O XefuAuto faz isso sozinho: quando você seleciona um jogo na lista do
Aurora, ele já deixa o xefu certo no lugar. Aí é só apertar A e jogar.

**961 jogos mapeados**, usando a lista de compatibilidade da
comunidade (ConsoleMods) + a tabela oficial extraída do próprio emulador.

Só entram jogos classificados como **officially supported**, **playable**
ou **in-game** — os que dá para sentar e jogar de verdade. Os que só
chegam ao menu, à intro, ou não rodam, ficam de fora de propósito: trocar
o xefu não os torna jogáveis, e só arriscaria substituir uma versão que
por acaso funciona por uma pior.

## Instalação

1. Ligue o console e deixe ele **no Aurora** (não dentro de um jogo).
2. Descubra o IP do console: Aurora → **Settings → Network**.
3. No PC, clique em **`Install.bat`** e digite o IP.
4. **Reinicie o Aurora.**
5. Na lista de jogos, abra **Select Subtitle** e escolha a linha
   **`xefu: ...`** (aperte **A**). É a mesma tela onde hoje está
   "Last Played".

Pronto. Daí em diante é automático.

## Como saber que está funcionando

Embaixo do nome de cada jogo vai aparecer qual xefu está sendo usado:

```
Halo II
xefu: xefu7
```

Quando você passa por outro jogo, o xefu troca junto.

## Ligar e desligar

**Back → Scripts → Xefu Auto**

- **Ligar / Desligar** — liga ou desliga o automático. Desligado, o
  subtítulo ainda mostra qual seria o xefu certo, mas não troca nada.
- **Restaurar originais** — devolve todos os slots para os arquivos
  originais do `XefuBackup`.

## O que o instalador faz

| Onde | O quê |
|---|---|
| `HddX:\Compatibility\XefuBackup\` | os 18 arquivos originais de xefu (o pacote já vem com eles) |
| `Game:\User\Scripts\Content\Subtitles\XefuAuto.lua` | o script que troca o xefu sozinho |
| `Game:\User\Scripts\Utility\XefuAuto\` | o painel de ligar/desligar |
| `HddX:\Compatibility\xefu_auto_ligado.txt` | marca que o automático está ligado |

Ele **não apaga** nada que já existe — só escreve por cima do que é dele.
Seus xefus originais continuam no `XefuBackup`.

## Requisitos

- Xbox 360 com RGH/JTAG
- Aurora 0.7b ou mais novo
- FTP ligado no console (padrão: usuário `xboxftp`, senha `xboxftp`)
- Jogos de Xbox clássico já instalados e escaneados no Aurora

## Perguntas

**Preciso reinstalar quando adicionar um jogo novo?**
Não. O mapa cobre 961 jogos por TitleID, mais uma tabela por nome com
940. Jogo novo que esteja na lista já funciona.

**E se um jogo não estiver no mapa?**
O subtítulo fica vazio e o xefu não é trocado — o jogo roda com o que
estiver no lugar. Nada quebra.

**Isso mexe nos meus jogos?**
Não. Só nos arquivos do emulador em `HddX:\Compatibility\`, e sempre
copiando a partir do `XefuBackup` (que fica intacto).

**Dá pra voltar atrás?**
Dá: **Back → Scripts → Xefu Auto → Restaurar originais**.

## Créditos

- Lista de compatibilidade: comunidade **ConsoleMods**
- Tabela oficial `TitleId → xefu`: extraída por **Matheiulh** do update 5832
- Aurora / AuroraScripts: **XboxUnity**
