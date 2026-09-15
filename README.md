# XefuAuto

**The right xefu, automatically, for every Xbox Classic game.**

Automatically switches the Xbox Original emulator (xefu) on an RGH/JTAG
Xbox 360 based on which game you select in Aurora. No menus, no manual
swapping — just pick a game and play.

> 🇧🇷 **Português:** [LEIA-ME.md](docs/pt-br/LEIA-ME.md) ·
> [Guia de configuração](docs/pt-br/COMO-CONFIGURAR.md) ·
> [Tabela editável](docs/pt-br/TABELA.md)

---

## The problem

The Xbox 360 runs Xbox Classic games through an emulator called **xefu**.
There are 12 versions of it, and **each game works best with a different
one**. Normally you'd swap them by hand, game by game.

Some games freeze on the wrong xefu. Others show only menus, or a black
screen. Getting it right means knowing which of the 12 versions each of
your games needs — and swapping files every time you switch games.

XefuAuto does that for you. Select a game in Aurora, and the correct xefu
is already in place.

**961 games mapped**, using the ConsoleMods community compatibility list
plus the official table extracted from the emulator itself.

Only games rated **officially supported**, **playable** or **in-game** are
included — the ones you can actually sit down and play. Titles that only
reach menus, an intro, or nothing at all are deliberately left out:
swapping the xefu doesn't make them playable, and it would only risk
replacing a working emulator version with a worse one.

---

## What it looks like

Once set up, each game shows which xefu it uses, right under its name:

![Game details showing xefu](pic/2.jpeg)

Browse your list and the xefu follows along automatically.

---

## Install

1. Turn on the console and leave it **on the Aurora dashboard** (not in a
   game).
2. Find the console IP: **Settings → Network** in Aurora.
3. On your PC, run **`Install.bat`** and enter the IP.
4. **Restart Aurora.**
5. Select any Xbox Classic game, press **Y** → **A**, and choose the
   **`xefu: ...`** line.

That last step is a one-time, one-click setup.

**→ Full step-by-step guide with screenshots: [SETUP.md](SETUP.md)**
(also covers installing via USB drive if you'd rather not use FTP)

---

## Turning it on and off

**Back → Scripts → Xefu Auto**

![Xefu Auto panel](pic/5.jpeg)

Shows the current state and which xefu is loaded right now (read from the
actual files, not from a saved record). Press **A** on the toggle line to
switch, **B** to go back.

The panel speaks **English, Portuguese and Spanish**, following your
Aurora language automatically.

---

## Editing the compatibility table

Compatibility changes: new xefus appear, someone finds a game runs better
on another version, missing games get added. You shouldn't have to wait
for anyone to fix that.

The table is a plain text file — **[`TABLE.csv`](TABLE.csv)**:

```
TitleID;Game;Xefu
45410026;007: NightFire;xefu
45530018;25 To Life;xefu7
54540001;4x4 EVO 2;xefu3
```

Edit it in Excel, LibreOffice or Notepad, then run:

```
python gerar_tabela.py aplicar
```

Bad entries are rejected with a clear message and **nothing is generated**,
so you can't break the script by mistake.

**→ Details: [TABLE.md](TABLE.md)**

---

## What it touches

| Path | What |
|---|---|
| `Hdd1:\Compatibility\XefuBackup\` | the 18 original xefu files (included in this package) |
| `Game:\User\Scripts\Content\Subtitles\XefuAuto.lua` | the script that does the switching |
| `Game:\User\Scripts\Utility\XefuAuto\` | the on/off panel |

It **never** modifies your games, and it always copies **from**
`XefuBackup`, which stays untouched. To undo everything, turn it off and
copy `XefuBackup` back over `Hdd1:\Compatibility\`.

---

## Requirements

- Xbox 360 with RGH/JTAG
- Aurora 0.7b or newer
- Xbox Classic games installed and scanned in Aurora
- For FTP install: FTP enabled in Aurora (default `xboxftp` / `xboxftp`)

---

## FAQ

**Do I need to reinstall when I add a new game?**
No. The table covers 961 games by Title ID, plus a name-based fallback
for 940 more. Any new game already in the list just works.

**What if a game isn't in the table?**
The subtitle stays empty and nothing is swapped — the game runs with
whatever xefu is currently on the console. Nothing breaks.

**Why does it copy the xefu to all 12 slots?**
The emulator decides on its own which slot to load. Filling all of them
means that whichever it picks, the game gets the right version. Same
technique the Xefu Spoofer uses.

**A game froze. Now what?**
The table may list the wrong xefu for it. See [TABLE.md](TABLE.md) — you
can fix it yourself, it's a text file. Please open an issue too, so
everyone benefits.

---

## Credits

- Compatibility data: **ConsoleMods** community
- Official `TitleId → xefu` table: extracted by **Matheiulh** from update 5832
- Aurora / AuroraScripts: **XboxUnity**
