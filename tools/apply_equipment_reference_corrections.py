"""Keep reviewed primary identity/batch corrections after secondary acquisition."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
IDS = {'water-reservoir', 'bee-hive', 'absorbent-substrate', 'mutagen', 'mutagel', 'tek-thalassian-hoversail'}

def apply():
    folder = ROOT / 'native/Ascended/Resources'
    refs = {r['id']: r for r in json.loads((folder / 'equipment-details.json').read_text())['items']}
    path = folder / 'build-crafting.json'
    data = json.loads(path.read_text())
    for row in data['items']:
        if row['id'] not in IDS:
            continue
        source = refs[row['id']]
        row.update(ingredients=source['ingredients'], stations=source['stations'],
                   recipeVerified=bool(source['ingredients']), sourceURL=source['sourceURL'],
                   editionNote='Primary Wiki identity/batch correction 2026-10-07; confirm current ASA edition and server settings.')
        if source.get('outputStatus') == 'primary-batch-reference':
            row['output'] = source['output']
    data['processes'] = [p for p in data['processes'] if p['name'] != 'Absorbent Substrate']
    data['processes'].append(dict(name='Absorbent Substrate', output=6,
        ingredients={'Black Pearl': 8, 'Sap': 8, 'Oil': 8}, station='Chemistry Bench',
        sourceURL='https://ark.wiki.gg/wiki/Absorbent_Substrate',
        variant='Primary batch reference; excludes fuel. Confirm edition/server settings.'))
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')

if __name__ == '__main__':
    apply()
