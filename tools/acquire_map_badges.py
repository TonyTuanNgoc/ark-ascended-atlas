"""Acquire unmodified DLC/map icons mapped by the official ARK Wiki configuration."""
import concurrent.futures, hashlib, html, json, re, subprocess, urllib.parse, time
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
CONFIG = 'https://ark.wiki.gg/wiki/Module:DissectDlcItemName/config?useskin=vector'
def fetch(url):
    return subprocess.check_output(['curl', '-fLs', '--retry', '3', '--retry-delay', '50', url])
def acquire(record):
    slug, name = record['id'], record['name']
    filename = {'legacy-of-santiago': 'Santiago Logo.png', 'dragontopia':'Dragontopia.png'}.get(slug, name.replace('Genesis Part', 'Genesis Part') + ' Icon.png')
    page = 'https://ark.wiki.gg/wiki/File:' + urllib.parse.quote(filename.replace(' ', '_')) + '?useskin=vector'
    url = 'https://ark.wiki.gg/images/' + urllib.parse.quote(filename.replace(' ', '_')) + '?x=1'
    asset_file = ROOT/'native/Ascended/Assets.xcassets'/('MapBadge-'+slug+'.imageset')/'image.png'
    if asset_file.exists():
        raw = asset_file.read_bytes()
    else:
        time.sleep(8)
        raw = fetch(url)
    assert raw[:8] == b'\x89PNG\r\n\x1a\n', (slug, 'not PNG')
    import struct
    width, height = struct.unpack('>II', raw[16:24])
    assert width > 15 and height > 15
    out = ROOT / 'native/Ascended/Assets.xcassets' / ('MapBadge-' + slug + '.imageset')
    out.mkdir(exist_ok=True)
    (out/'image.png').write_bytes(raw)
    (out/'Contents.json').write_text(json.dumps({'images':[{'filename':'image.png','idiom':'universal'}],'info':{'author':'xcode','version':1}},indent=2)+'\n')
    edition = 'Shared DLC/map icon used by the official wiki for ASA and ASE where applicable; not presented as a newly created ASA logo.'
    return {'mapID':slug,'name':name,'asset':'MapBadge-'+slug,'fileTitle':filename,'configurationURL':CONFIG,'filePage':page,'imageURL':url,'sha256':hashlib.sha256(raw).hexdigest(),'bytes':len(raw),'width':width,'height':height,'editionNote':edition,'transformation':'None; original PNG bytes retained.','attribution':'ARK Official Community Wiki; ARK game artwork belongs to Studio Wildcard and respective creators. See linked file page for licensing.'}
if __name__ == '__main__':
    maps = json.loads((ROOT/'native/Ascended/Resources/expansion-catalog.json').read_text())['maps']
    config = Path('/tmp/map-config.html').read_bytes() if Path('/tmp/map-config.html').exists() else fetch(CONFIG)
    with concurrent.futures.ThreadPoolExecutor(max_workers=1) as pool:
        records = []
        missing = []
        for record in maps:
            try: records.append(acquire(record))
            except Exception as error: missing.append({'mapID':record['id'],'name':record['name'],'reason':str(error),'policy':'No invented icon or terrain crop substituted.'})
    genesis = next(x for x in records if x['mapID']=='genesis-part-1')
    src = ROOT/'native/Ascended/Assets.xcassets/MapBadge-genesis-part-1.imageset'
    dst = ROOT/'native/Ascended/Assets.xcassets/MapBadge-genesis-ocean.imageset'
    dst.mkdir(exist_ok=True)
    for f in src.iterdir(): (dst/f.name).write_bytes(f.read_bytes())
    records.append(dict(genesis,mapID='genesis-ocean',name='Genesis Ocean',asset='MapBadge-genesis-ocean',editionNote='Genesis Ocean biome intentionally reuses genuine Genesis Part 1 map icon.'))
    report = {'checkedAt':'2026-10-04','configurationSHA256':hashlib.sha256(config).hexdigest(),'configurationURL':CONFIG,'count':len(records),'records':records,'missing':missing}
    (ROOT/'docs/codex-reports/2026-10-04-map-badge-sources.json').write_text(json.dumps(report,indent=2)+'\n')
    for r in records: print(r['mapID'],r['width'],r['height'],r['bytes'])
