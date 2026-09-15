# -*- coding: utf-8 -*-
"""Matcher melhorado: oficial x comunidade (token-level, anos, sequências, romanos)."""
import json
import re
import unicodedata

def norm(s):
    s = s.lower()
    s = unicodedata.normalize('NFKD', s).encode('ascii', 'ignore').decode()
    return re.sub(r'[^a-z0-9]+', '', s)

NUMWORD = {'one': '1', 'two': '2', 'three': '3', 'four': '4', 'five': '5',
           'six': '6', 'seven': '7', 'eight': '8', 'nine': '9', 'ten': '10'}
ROMAN = {'ii': '2', 'iii': '3', 'iv': '4', 'v': '5', 'vi': '6', 'vii': '7',
         'viii': '8', 'ix': '9', 'x': '10'}
IGNORE = {'the', 'and', 'of', 'in', 'for', 'a', 'to', 'se', 'usa', 'pal',
          'ntsc', 'jpn', 'eu', 'uk', 'us', 'edition', 'video', 'game',
          'with', 'on', 'deluxe', 's', 'version', 'online',
          'special'}
ABBREV = {
    'nfs': ['need', 'for', 'speed'],
    'jsrf': ['jet', 'set', 'radio', 'future'],
    'tmnt': ['teenage', 'mutant', 'ninja', 'turtles'],
    'sw': ['star', 'wars'],
    'doa': ['dead', 'or', 'alive'],
    'bps': ['bass', 'pro', 'shops'],
    'wwe': [],
    'ufc': [],
    'nhl': ['nhl'],
    'nba': ['nba'],
    'mlb': ['mlb'],
    'nfl': ['nfl'],
}

def to_year(tok):
    n = int(tok)
    if n < 100:
        n += 2000 if n < 70 else 1900
    return n

def is_year(tok):
    if not tok.isdigit():
        return False
    if len(tok) == 4:
        return True
    if len(tok) == 2 and tok.startswith('0'):
        return True
    return False

def tokens(s):
    s = s.lower().replace('’', "'").replace('&', ' and ').replace(';', ' ')
    words = re.findall(r"[a-z0-9']+", s)
    out = []
    for w in words:
        w = w.strip("'")
        if not w:
            continue
        if w in NUMWORD:
            w = NUMWORD[w]
        if w in ROMAN:
            w = ROMAN[w]
        if w in ABBREV:
            out.extend(ABBREV[w])
        else:
            # separa sufixo de número colado: mechassault2 -> mechassault 2
            m = re.match(r'^([a-z]+)(\d+)$', w)
            if m and len(m.group(1)) >= 3:
                out.append(m.group(1))
                out.append(m.group(2))
            else:
                out.append(w)
    return out

def sig_and_years(s):
    ts = tokens(s)
    years = {to_year(t) for t in ts if is_year(t)}
    sig = [t for t in ts if t not in IGNORE and not t.isdigit()]
    versions = {int(t) for t in ts if t.isdigit() and not is_year(t)}
    return sig, years, versions

def eq(a, b):
    if a == b:
        return True
    la, lb = len(a), len(b)
    if la >= 3 and lb >= 3:
        return a.startswith(b) or b.startswith(a)
    return False

def covers(A, B):
    return all(any(eq(a, b) for b in B) for a in A)

# TitleIDs que NÃO devem ser casados automaticamente (risco de jogo errado)
DENY = {
    '4D530040',  # Whacked! Trial Version
    '4D53003D',  # Xbox Demos (compilação)
    '5451001C',  # Tetris Worlds Online
}

def match(official_name, community_names):
    osig, oy, over = sig_and_years(official_name)
    if not osig:
        return None
    ok = norm(official_name)
    cands = []
    for cname in community_names:
        csig, cy, cver = sig_and_years(cname)
        if not csig:
            continue
        if oy and cy and oy.isdisjoint(cy):
            continue
        # versão: se oficial tem versão, comunidade precisa ter a mesma
        if over and cver and over.isdisjoint(cver):
            continue
        if over and not cver:
            continue  # oficial pede sequência específica
        if cver and not over:
            continue  # comunidade tem sequência que oficial não tem
        if covers(osig, csig) or covers(csig, osig):
            extra = max(0, len(csig) - len(osig))
            bonus = 1 if (oy and cy and not oy.isdisjoint(cy)) else 0
            exact = len({a for a in osig if any(b == a for b in csig)})
            cands.append((cname, min(len(osig), len(csig)), -extra, bonus, exact))
    if cands:
        cands.sort(key=lambda x: (x[4], x[1] + x[3], x[2]), reverse=True)
        best = cands[0][4], cands[0][1] + cands[0][3], cands[0][2]
        tops = [c for c in cands if (c[4], c[1] + c[3], c[2]) == best]
        if len(tops) == 1:
            return tops[0][0]
    # fallback: substring (nomes concatenados ou abreviados de forma atípica)
    subs = []
    for cname in community_names:
        ck = norm(cname)
        if len(ok) >= 6 and len(ck) >= 6 and (ok in ck or ck in ok):
            subs.append(cname)
    if len(subs) == 1:
        return subs[0]
    return None

if __name__ == '__main__':
    official = json.load(open(r'd:\projects\xbox-compat\official_xefu_map.json', encoding='utf-8'))
    community = json.load(open(r'd:\projects\xbox-compat\xefu_best.json', encoding='utf-8'))
    cnames = [g['name'] for g in community]
    ckeys = {g['key']: g['name'] for g in community}

    unmatched = [e for e in official
                 if norm(e['name']) not in ckeys and e['title_id'] not in DENY]
    print('alvos:', len(unmatched))
    matched, still = [], []
    for e in unmatched:
        m = match(e['name'], cnames)
        (matched if m else still).append((e, m))
    print('casados:', len(matched))
    for e, m in sorted(matched, key=lambda x: x[0]['title_id']):
        print(f"  {e['title_id']} | {e['name']!r} -> {m!r} | {e['emu']}")
    print('\nsem casar:', len(still))
    for e, _ in still:
        print('  ', e['title_id'], '|', e['name'], '|', e['emu'])
