#!/usr/bin/env python3
"""Audit shipped resource coordinates, cutout transparency and entrance provenance."""
import hashlib
import json
import re
from pathlib import Path
from PIL import Image
ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "native/Ascended/Assets.xcassets"
RESOURCES = ROOT / "native/Ascended/Resources"
REPORTS = ROOT / "docs/codex-reports"
def image_path(asset):
    folder = ASSETS / (asset + ".imageset")
    entries = json.loads((folder / "Contents.json").read_text())["images"]
    return folder / next(row["filename"] for row in entries if "filename" in row)
def walk(value):
    if isinstance(value, dict):
        yield value
        for child in value.values(): yield from walk(child)
    elif isinstance(value, list):
        for child in value: yield from walk(child)
cutouts = json.loads((REPORTS / "2026-10-04-creature-cutout-sources.json").read_text())
for row in cutouts:
    im = Image.open(image_path(row["asset"]))
    assert im.mode == "RGBA", row["asset"]
    lo, hi = im.getchannel("A").getextrema()
    assert lo == 0 and hi > 0, row["asset"]
references = set()
for path in RESOURCES.glob("*.json"):
    if "creatures" in path.name: continue  # Library avatars are intentionally separate.
    for row in walk(json.loads(path.read_text())):
        asset = row.get("imageAsset", "")
        if asset.startswith(("Dino-", "Boss-")) and "nunatak" not in asset:
            references.add("Cutout-" + asset)
context = " ".join(p.read_text().casefold() for p in RESOURCES.glob("*.json") if any(p.name.endswith("-" + kind + ".json") for kind in ["campaign", "exploration", "bosses", "bases", "information"]))
for fact in json.loads((RESOURCES / "visual-facts.json").read_text()):
    asset = fact.get("asset") or ""
    if asset.startswith(("Dino-", "Boss-")) and any(re.search(r"(?<!\w)" + re.escape(alias.casefold()) + r"(?!\w)", context) for alias in fact["aliases"]):
        references.add("Cutout-" + asset)
assert references <= {r["asset"] for r in cutouts}, references - {r["asset"] for r in cutouts}
entrances = json.loads((REPORTS / "2026-10-04-cave-entrance-photo-sources.json").read_text())
missing = []
for map_id in ["ragnarok", "the-island", "the-center"]:
    routes = json.loads((RESOURCES / (map_id + "-exploration.json")).read_text())["routes"]
    for route in routes:
        for entry in route["entrances"]:
            asset = "Entrance-" + map_id + "-" + entry["id"]
            if not (ASSETS / (asset + ".imageset")).exists(): missing.append(asset)
for row in entrances:
    assert row["reviewed"] and row["sourceURL"], row
    assert hashlib.sha256(image_path(row["asset"]).read_bytes()).hexdigest() == row["sha256"], row["asset"]
counts = {}
for row in json.loads((REPORTS / "2026-10-04-map-resource-sources.json").read_text()):
    p = RESOURCES / (row["map"] + "-resources.json")
    assert hashlib.sha256(p.read_bytes()).hexdigest() == row["nativeSha256"]
    nodes = json.loads(p.read_text())
    assert len(nodes) == row["count"]
    assert all(0 <= n["lat"] <= 100 and 0 <= n["lon"] <= 100 for n in nodes)
    for kind in {n["resource_type"] for n in nodes}:
        special = {"Beaver Dam":"beaver-dam", "Cactus with few berries":"cactus-sap", "Gem Bio":"blue-gem", "Sandpile":"sand"}
        image_path("Item-" + special.get(kind, kind.lower().replace(" ", "-")))
    counts[row["map"]] = len(nodes)
print(json.dumps({"transparentCutouts":len(cutouts), "contextReferencesCovered":len(references), "verifiedEntrancePhotos":len(entrances), "entrancePhotoGaps":missing, "resources":counts}, ensure_ascii=False))
