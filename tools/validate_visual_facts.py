#!/usr/bin/env python3
"""Check actual Swift matching/count logic and every referenced image asset."""
import json,subprocess,tempfile
from pathlib import Path
from PIL import Image
root=Path(__file__).resolve().parents[1];native=root/'native/Ascended';facts=json.loads((native/'Resources/visual-facts.json').read_text());assert len({x['id'] for x in facts})==len(facts)
image_count=0
for fact in facts:
 if fact.get('asset'):
  folder=native/'Assets.xcassets'/(fact['asset']+'.imageset');content=json.loads((folder/'Contents.json').read_text())
  for row in content['images']:
   if row.get('filename'):
    with Image.open(folder/row['filename']) as im: im.load();assert im.width>0 and im.height>0
  if fact['category']=='item':image_count+=1
swift=(native/'Sources/VisualFacts.swift').read_text().split('struct FactPicture: View')[0]
swift+='''
enum ArkMap {
    static func load<T: Decodable>(_ type: T.Type, name: String) throws -> T {
        try JSONDecoder().decode(type, from: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1])))
    }
}
func verify(_ text: String, _ expected: [String: String]) {
    let actual = Dictionary(uniqueKeysWithValues: VisualFacts.matches(text).map { ($0.fact.name, $0.quantity ?? "") })
    precondition(actual == expected, "Mismatch: \\(text) -> \\(actual)")
}
verify("19 Rex + 1 Yutyrannus", ["Rex":"19", "Yutyrannus":"1"])
verify("18 Theri + 1 Yuty + 1 pig", ["Therizinosaur":"18", "Yutyrannus":"1", "Daeodon":"1"])
verify("Hai Bary", ["Baryonyx":"2"])
verify("10 Argentavis Talon", ["Argentavis Talon":"10"])
verify("Shotgun, đạn", ["Pump-Action Shotgun":"", "Simple Shotgun Ammo":""])
verify("Iceworm Queen", ["Iceworm Queen":""])
verify("Iceworm", ["Iceworm":""])
precondition(VisualFacts.matches("HP 27.000").first!.metricValue == "27.000")
precondition(VisualFacts.matches("melee nền 500").first!.metricValue == "500")
precondition(VisualFacts.matches("level 10").first!.metricValue == "10")
precondition(VisualFacts.items(["Unknown DLC Item"]).first!.fact.name == "Unknown DLC Item")
print("Matching, explicit counts, aliases, Queen distinction, unknown item preservation passed")
'''
with tempfile.TemporaryDirectory(prefix='ascended-visual-') as folder:
 p=Path(folder)/'main.swift';p.write_text(swift)
 subprocess.run(['swift',str(p),str(native/'Resources/visual-facts.json')],check=True)
report={'definitions':len(facts),'itemImages':image_count,'assetReferencesValid':True,'swiftMatchingFixturesPassed':True}
(root/'docs/codex-reports/2026-10-04-visual-facts-validation.json').write_text(json.dumps(report,indent=2)+'\n');print(report)
