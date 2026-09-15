# Editing the compatibility table

The table that says **which xefu each game uses** is a plain text file:
**[`TABLE.csv`](TABLE.csv)**. Anyone can fix it.

This matters because compatibility changes: new xefus show up, someone
finds a game runs better on another version, missing games get added. You
shouldn't have to wait for anyone to fix that for you.

> 🇧🇷 Em português: [TABELA.md](docs/pt-br/TABELA.md)

---

## The format

Three columns separated by semicolons (`;`):

```
TitleID;Game;Xefu
45410026;007: NightFire;xefu
45530018;25 To Life;xefu7
54540001;4x4 EVO 2;xefu3
```

| Column | What it is | Required? |
|---|---|---|
| `TitleID` | Game ID, 8 hex digits | **Yes** — this is how the game is matched |
| `Game` | Name, just so you can find it | No — can be left empty |
| `Xefu` | Which xefu to use | **Yes** |

Opens in Excel, LibreOffice, Notepad, VS Code — whatever you prefer.

> If you use Excel: when saving, pick **CSV UTF-8** and make sure the
> separator is `;`.

### Accepted values in the Xefu column

```
xefu      xefu1_1   xefu2     xefu3
xefu5     xefu6     xefu7     xefu7b
xefu2019  xefu2021a xefu2021b xefu2021c
```

Write them exactly like that: lowercase, no `.xex`. Anything else is
rejected with a message and nothing is generated — you can't break the
script by mistake.

---

## Finding a game's Title ID

In Aurora itself: select the game, press **Y** (Details) → **A**
(Subtitle) → pick **`Title ID`**. It shows under the game name.

You can also read it on the `Select Subtitle` screen:

![Select Subtitle showing the Title ID](pic/3.jpeg)

In that screenshot, "25 To Life" has Title ID **`45530018`**.

---

## Applying your changes

After editing and saving `TABLE.csv`:

```
python gerar_tabela.py aplicar
```

This regenerates `XefuAuto.lua` from your table. Then install as usual
(`Install.bat`) and restart Aurora.

If something is wrong, it tells you and **generates nothing**:

```
ERRORS in table — nothing was generated:
    line 2: unknown xefu: 'xefu99' (use: xefu, xefu1_1, ...)
    line 3: invalid TitleID: 'ZZZZ'
```

You need Python 3 on your PC for this (not for using XefuAuto itself).

---

## Common cases

### A game freezes — I want to change its xefu

Find the line by name and change the last column:

```
49470024;Unreal Championship;xefu       ← was freezing
49470024;Unreal Championship;xefu7      ← fixed
```

If you don't know what to try, `xefu7` is the most compatible overall
(it's the pick for 658 of the 1024 games in the community list).

### I want to add a game that isn't listed

Add a line at the end. Order doesn't matter:

```
4B4F0009;My Game;xefu7
```

### I want a game left alone

Delete its line. With no entry, XefuAuto doesn't touch anything and the
game runs with whatever xefu is on the console.

---

## A note on duplicate Title IDs

Some games share a Title ID, either because the series reuses it or
because of how the disc was ripped. Real examples from a live console:

```
5553001D:  Prince of Persia | PoP 2 | PoP: The Sands of Time
4D53006D:  CDX (demo disc) | Jade Empire
```

They all get the same xefu, since matching is by Title ID. For a series
sharing an engine that's usually fine. For an unrelated pair (like a demo
disc carrying another game's ID) the wrong xefu may be applied — there's
no way to tell them apart by ID alone.

---

## Which games are included, and why

The ConsoleMods list rates every game on a six-level scale. **Only the top
three are included here:**

| Status | In the table? | Why |
|---|---|---|
| `{{supported}}` | ✅ yes | Officially supported by the emulator |
| `{{playable}}` | ✅ yes | Very minor or no issues |
| `{{in-game}}` | ✅ yes | Playable, with issues |
| `{{menus}}` | ❌ no | Only reaches the menus |
| `{{intro}}` | ❌ no | Only reaches the intro |
| `{{unplayable}}` | ❌ no | Doesn't run |

The bottom three are left out **on purpose**. If a game can't get past its
menus on *any* of the 12 xefu versions, swapping the emulator won't make it
playable — it would just churn files for nothing, and risk replacing a
version that happens to work better than what the list guesses. Those games
are left alone: XefuAuto doesn't touch them, and they run with whatever
xefu is already on the console.

That's the difference between the wiki's 1024 entries and this table's 961.

## Where the data comes from

The table is built by cross-referencing three sources:

1. **ConsoleMods community list** — 1024 games tested across all 12 xefu
   versions. This is the primary source for *which xefu* each game needs.
2. **Official emulator table** — 539 games, extracted by *Matheiulh* from
   update 5832.
3. **Public Title ID databases** — [MobCat's OG Xbox game
   list](https://github.com/MobCat/MobCats-original-xbox-game-list) and
   [jeltaqq's Xbox Original
   GameList](https://github.com/jeltaqq/Xbox-Original-GameList).

Source 3 matters more than it looks. The ConsoleMods wiki identifies games
**by name only** — it has no Title ID column — and Aurora identifies games
**by Title ID**. Without those databases, only the ~479 games that happen to
appear in the official table could be matched, and the rest of the list
would be unusable. Cross-referencing recovered Title IDs for 961 of them.

As a safety net the script also carries a name-based table (940 entries),
used when a Title ID isn't recognised.

When a game ties (runs equally well on several versions), the pick is
always the **newest** version, which tends to be the most compatible.

---

## Contributing back

If you fix something that applies to everyone, open a **Pull Request** with
the changed `TABLE.csv`, or an **Issue** telling us:

- Game name and Title ID
- Which xefu was listed and which one worked
- What happened before (froze, black screen, menus only...)

That saves the next person from hitting the same problem.
