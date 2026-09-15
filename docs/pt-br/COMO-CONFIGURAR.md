# Como configurar o XefuAuto

Guia passo a passo, com fotos do console real.

---

## O problema que isso resolve

O Xbox 360 roda jogos de Xbox clássico com um emulador chamado **xefu**.
Existem 12 versões dele, e **cada jogo funciona melhor com uma versão
diferente**. Normalmente você teria que trocar na mão, jogo a jogo.

O XefuAuto faz isso sozinho: quando você seleciona um jogo na lista do
Aurora, ele já deixa o xefu certo no lugar. Aí é só apertar A e jogar.

---

## Parte 1 — Instalar os arquivos

Você pode instalar **por FTP** (mais fácil) ou **por pendrive/USB**.
Escolha um dos dois.

### Opção A — Por FTP (recomendado)

Precisa do PC e do console na mesma rede.

1. Ligue o console e deixe ele **no Aurora** (não dentro de um jogo).
   O FTP do Aurora só funciona no dash.
2. Descubra o IP do console: **Settings → Network** no Aurora.
3. No PC, clique duas vezes em **`Install.bat`**.
4. Digite o IP quando ele pedir.

O instalador envia tudo sozinho e mostra o progresso. Leva alguns minutos
por causa dos xefus (são ~7 MB).

Para automatizar (sem perguntas):

```
Install-XefuAuto.ps1 -Ip 192.168.0.10 -Quiet
```

Se os xefus originais já estiverem no console, você pode pular essa parte
e mandar só os scripts (bem mais rápido):

```
Install-XefuAuto.ps1 -Ip 192.168.0.10 -SkipXefu
```

| Parâmetro | Para quê |
|---|---|
| `-Ip` | IP do console |
| `-User` / `-Password` | Login do FTP (padrão: `xboxftp` / `xboxftp`) |
| `-Quiet` | Não pergunta nada, não espera Enter no final |
| `-SkipXefu` | Envia só os scripts, sem os arquivos de xefu |

### Opção B — Por pendrive / USB

Serve se você não tem rede, ou se prefere copiar na mão.

1. Copie estas pastas do pacote para um pendrive.
2. Espete o pendrive no console.
3. No Aurora, use o **File Manager** (Settings → Utilities → File Manager)
   para copiar cada item para o destino:

| Do pendrive | Para o console |
|---|---|
| `Xefu\*.xex` (18 arquivos) | `Hdd1:\Compatibility\XefuBackup\` |
| `Aurora\User\Scripts\Content\Subtitles\XefuAuto.lua` | `Game:\User\Scripts\Content\Subtitles\` |
| `Aurora\User\Scripts\Utility\XefuAuto\` (a pasta toda) | `Game:\User\Scripts\Utility\` |

> **Atenção:** se as pastas `Content\Subtitles` ou `Utility` não existirem,
> crie elas primeiro (o File Manager tem opção de criar pasta).

> **Sobre o XefuBackup:** essa pasta guarda os xefus **originais**. O
> XefuAuto sempre copia a partir dela, e nunca a modifica. Se você já tem
> um XefuBackup com os 18 arquivos, pode pular essa cópia.

### Depois de instalar (nos dois casos)

**Reinicie o Aurora.** Ele só carrega scripts novos quando inicia.

---

## Parte 2 — Ativar (só uma vez)

Essa é a única configuração manual, e é um clique.

### Antes: o jogo mostra "Last Played"

Por padrão, embaixo do nome de cada jogo o Aurora mostra
**`Last Played:`** (quando você jogou pela última vez). É a informação
padrão da lista:

![Lista de jogos do Aurora](../../pic/1.jpeg)

### Passo 1 — Abrir os detalhes do jogo

Na lista, escolha qualquer jogo de Xbox clássico e aperte **Y** (Details).

Você vai ver a linha de informação logo abaixo do nome do jogo. Aperte
**A** (Subtitle) para trocar qual informação aparece ali:

![Tela de detalhes do jogo](../../pic/2.jpeg)

### Passo 2 — Escolher "xefu:"

Abre a tela **Select Subtitle**, com todas as informações que o Aurora
pode mostrar (Title ID, Media ID, Release Date, Last Played, Virtual
Path...).

**Desça até o final da lista** e escolha a linha **`xefu: ...`**.
Aperte **A** para selecionar:

![Tela Select Subtitle](../../pic/3.jpeg)

> Repare que a linha já mostra `xefu: xefu7`. Isso é o XefuAuto
> funcionando: ele leu o Title ID do jogo (`45530018`) e calculou qual
> xefu é o melhor para ele. Cada jogo vai mostrar o seu.

**Pronto.** A partir daqui é automático: basta navegar pela lista de jogos
que o xefu troca sozinho.

---

## E a informação do "Last Played"?

Uma dúvida comum, e a resposta é tranquilizadora.

Depois que você escolhe `xefu:`, o **"Last Played" deixa de aparecer**
embaixo do nome do jogo — no lugar dele aparece o xefu. Mas isso é só
**qual informação está sendo exibida**.

**Nada foi apagado.** A data do "Last Played" continua guardada
normalmente, e o Aurora segue registrando quando você joga cada jogo.

Para ver de novo a qualquer momento, é o mesmo caminho: **Y → A →
Select Subtitle**, e escolha `Last Played`. A data vai estar lá, intacta.

Você pode alternar entre uma e outra quando quiser. Só lembre: enquanto o
subtítulo **não** estiver em `xefu:`, o XefuAuto não roda — é essa tela
que faz ele funcionar.

---

## Ligar e desligar

O XefuAuto vem **ligado**. Para desligar (ou religar), vá em
**Back → Scripts → Xefu Auto**:

![Lista de scripts do Aurora](../../pic/4.jpeg)

O painel mostra o estado e qual xefu está carregado agora:

![Painel do Xefu Auto](../../pic/5.jpeg)

- **Automatic xefu switching is ON** — o estado atual
- **Current xefu** — qual xefu está no console neste momento (lido direto
  dos arquivos, não de um registro)
- **Turn Off / Turn On** — escolha essa linha e aperte **A** para alternar
- **B** volta sem mudar nada

O painel fala **inglês, português e espanhol**, seguindo o idioma do seu
Aurora automaticamente.

Quando está desligado, o subtítulo continua mostrando qual seria o xefu
certo, com um `(off)` no final — mas não troca nada.

---

## Como saber que está funcionando

Navegue pela lista de jogos e olhe a linha embaixo do nome. Ela muda
conforme o jogo:

```
25 To Life
xefu: xefu7

Battlefield 2: Modern Combat
xefu: xefu2021c
```

Se quiser conferir de verdade, abra **Back → Scripts → Xefu Auto** e veja
o **Current xefu** — ele lê os arquivos reais em
`Hdd1:\Compatibility\`.

---

## Perguntas frequentes

**Preciso reinstalar quando adicionar um jogo novo?**
Não. A tabela cobre 961 jogos por Title ID. Jogo novo que esteja na lista
já funciona.

**E se um jogo não estiver na tabela?**
O subtítulo fica vazio e nada é trocado — o jogo roda com o xefu que
estiver no console. Nada quebra.

**Isso mexe nos meus jogos?**
Não. Só nos arquivos do emulador em `Hdd1:\Compatibility\`, e sempre
copiando a partir do `XefuBackup` (que fica intacto).

**Um jogo travou. E agora?**
Pode ser que a tabela indique o xefu errado para ele. Veja
[TABELA.md](TABELA.md) — dá para corrigir você mesmo, é um arquivo de
texto.

**Dá pra voltar tudo ao normal?**
Dá. Desligue em **Back → Scripts → Xefu Auto**, e copie os arquivos de
`Hdd1:\Compatibility\XefuBackup\` de volta para `Hdd1:\Compatibility\`
pelo File Manager.

**Por que ele copia o xefu para todos os slots?**
O emulador decide sozinho qual dos 12 slots vai carregar. Preenchendo
todos, qualquer que seja a escolha dele, o jogo pega a versão certa. É a
mesma técnica que o Xefu Spoofer usa.

---

## Requisitos

- Xbox 360 com RGH/JTAG
- Aurora 0.7b ou mais novo
- Jogos de Xbox clássico instalados e escaneados no Aurora
- Para instalar por FTP: FTP ligado no Aurora (padrão `xboxftp`/`xboxftp`)

---

## Créditos

- Lista de compatibilidade: comunidade **ConsoleMods**
- Tabela oficial `TitleId → xefu`: extraída por **Matheiulh** do update 5832
- Aurora / AuroraScripts: **XboxUnity**
