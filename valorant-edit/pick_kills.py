"""Turn the kills you picked in the gallery into kills.json for edit.py.

  python pick_kills.py /Volumes/lexa4/valorant/kills --pick 3,7,12,15,21 --drop 7 --final 12 \
      [--showcase 15,21] [--out kills.json]

--drop / --final   the two hero kills (first drop, and the final kill after the freeze)
--showcase         cuts to use as the slow intro / breather shots (defaults to the drop and final cuts)
The order of --pick is the order the kills play in the beat-chain.
"""
import argparse, json, os, sys


def ids(s):
    return [int(x) for x in s.replace(" ", "").split(",") if x]


ap = argparse.ArgumentParser()
ap.add_argument("kills_dir")
ap.add_argument("--pick", required=True)
ap.add_argument("--drop", type=int, required=True)
ap.add_argument("--final", type=int, required=True)
ap.add_argument("--showcase", default="")
ap.add_argument("--out", default="kills.json")
a = ap.parse_args()

cands = {c["id"]: c for c in json.load(open(os.path.join(a.kills_dir, "candidates.json")))}
pick = ids(a.pick)
for i in pick + [a.drop, a.final] + ids(a.showcase):
    if i not in cands:
        sys.exit(f"kill #{i} not in candidates.json")

order = [a.drop, a.final] + [i for i in pick if i not in (a.drop, a.final)]
n = len(order)
kills = [dict(clip=cands[i]["file"], t=cands[i]["t_in_cut"], score=n - rank, id=i) for rank, i in enumerate(order)]
show = ids(a.showcase) or [a.drop, a.final]
showcase = [dict(clip=cands[i]["file"], start=0.0) for i in show]
json.dump(dict(kills=kills, showcase=showcase), open(a.out, "w"), indent=1)
print(f"wrote {a.out}: {n} kills (drop #{a.drop}, final #{a.final}), showcase {show}")
