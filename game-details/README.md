# Game Details

Aurora subtitle add-on for XefuAuto: shows each game's **genre and
player count** right on the `xefu: ...` line in the game details screen
(press **Y**). No extra selection needed — the info is already there.

Example of what you see when you press Y:

```
xefu: xefu  |  Platform  |  1-2 Players
```

## What it does

Aurora displays a subtitle under the game name in the details screen.
XefuAuto registers its own subtitle (`Xefu Auto`) that shows the active
xefu for the selected game, and that is the line users have active.

`GameDetails.lua` wraps **only** that one subtitle function and appends
the genre/players info to whatever `Xefu Auto` returns:

- The `Select Subtitle` menu stays clean — no other subtitle option is
  touched.
- The hook is installed through a table metatable (`__newindex`), so it
  works regardless of the order in which Aurora loads the scripts
  (alphabetically, `GameDetails.lua` loads before `XefuAuto.lua`).
- Games without mapped data keep the plain `xefu: ...` line.

## Data source

The info comes from `dados_extra.json` at the repository root, keyed by
Title ID:

```json
{
  "41430001": {"genres": ["Racing", "Sport"], "players": 2}
}
```

- `genres` — list of genres using the same names as the compatibility
  site (Racing, Shooter, Fighting, RPG, etc.)
- `players` — maximum local player count (rendered as `1 Player`,
  `1-2 Players`, `1-3 Players`, `1-4 Players`)

924 games are currently mapped. There is no separate co-op flag in the
data yet; when the site provides one, it can be added to the generator.

## Integration with the main plugin

The add-on ships inside the XefuAuto package as a regular script file:

```
Aurora/User/Scripts/Content/Subtitles/
├── XefuAuto.lua       <- main plugin (xefu switching)
└── GameDetails.lua    <- this add-on (genre + players on the xefu line)
```

Because installers (FTP or USB) copy the whole `User/Scripts` tree, the
add-on is installed automatically next to the main plugin — the only
user step is restarting Aurora.

### Building / regenerating the Lua

`GameDetails.lua` is a generated file. To rebuild it after changing
`dados_extra.json`:

```
cd game-details
python gerar.py
```

This produces `game-details/GameDetails.lua` and validates its Lua
syntax (`luaparser`). Commit the regenerated file and copy it to
`Aurora/User/Scripts/Content/Subtitles/GameDetails.lua` (the packaged
copy). The `gerar.py` script reads `../dados_extra.json` relative to
this folder.

## Manual install (without the package)

Copy `GameDetails.lua` to:

```
Hdd1:\Aurora\User\Scripts\Content\Subtitles\GameDetails.lua
```

(or `Game:\User\Scripts\Content\Subtitles\GameDetails.lua`, depending
on where Aurora is installed), then restart Aurora.

## Line format

```
xefu: <xefu>  |  <Genre 1>, <Genre 2>  |  1-N Players
```

- Player count is omitted for games without player data (and vice
  versa for genres).
