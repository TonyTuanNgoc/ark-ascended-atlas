"""Validate exact map artwork, genuine photos, and simplified route UI contracts."""
from pathlib import Path
import json
from PIL import Image
r=Path(__file__).resolve().parents[1];n=r/'native/Ascended';a=n/'Assets.xcassets'
for source in (n/'Resources').glob('*-exploration.json'):
 for artifact in json.loads(source.read_text())['artifacts']:
  assert (a/(artifact['imageAsset']+'.imageset')/'Contents.json').exists(),artifact['id']
for key in ['canyon','falls','herbivore','viking','highlands']:
 folder=a/('Base-'+key+'.imageset');row=json.loads((folder/'Contents.json').read_text())['images'][0]
 with Image.open(folder/row['filename']) as im:im.load();assert im.width>=320
sources=json.loads((r/'docs/codex-reports/2026-10-04-game-portrait-sources.json').read_text())
ready=[x for x in sources if x['status']=='ready']
for x in ready:
 folder=a/(x['gameAsset']+'.imageset');rows=json.loads((folder/'Contents.json').read_text())['images']
 for row in rows:
  with Image.open(folder/row['filename']) as im:im.load();assert im.width>0
 assert not any(t in x.get('imageURL','').lower() for t in ['concept','dossier','paintregion','skeletal','costume'])
assert all('ellipsis' not in p.read_text() for p in (n/'Sources').glob('*.swift'))
kit=(n/'Sources/VisualFacts.swift').read_text().split('struct VisualKitGroup: View')[1].split('struct VisualTeam: View')[0]
assert 'Button' not in kit and 'Stepper' not in kit and 'quantity: nil' in kit
cave=(n/'Sources/ExplorationLibrary.swift').read_text().split('struct CaveRouteDetail: View')[1].split('struct ArtifactDetail: View')[0]
assert 'GuideDestination.artifact' not in cave
assert cave.index('RoutePreparation')<cave.index('CaveGIFWalkthrough')
gifs=(n/'Sources/CaveGIFs.swift').read_text().split('struct CaveGIFWalkthrough: View')[1].split('struct AutoCaveGIF: View')[0]
assert 'Text(step.title)' not in gifs and 'Text(item.title)' not in gifs and 'gif-position-' not in gifs
assert '.tabViewStyle(.page(indexDisplayMode: .never))' in gifs
assert 'CaveGIFWalkthrough' in (n/'Sources/PlaySession.swift').read_text()
print(json.dumps({'artifactArtwork':True,'basePhotos':5,'verifiedGamePortraits':len(ready),'missingGamePortraits':[x['name'] for x in sources if x['status']!='ready'],'noEllipsis':True,'plainPreparation':True,'onePageCave':True,'captionOnlyCarousel':True},ensure_ascii=False))
