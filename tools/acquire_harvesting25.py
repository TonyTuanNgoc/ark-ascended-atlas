#!/usr/bin/env python3
"""Build the curated harvesting reference. Facts reviewed through public wiki search on 2026-10-07.
This does not scrape, rank arbitrary stars, or simulate yields. See source report for limitations.
"""
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
DATE = '2026-10-07'
WIKI = 'https://ark.wiki.gg/wiki/'
entries = []
def add(resource, summary, tools=(), creatures=(), targets=(), cautions=(), sources=(), aliases=(), weights=()):
    entries.append(dict(resource=resource, aliases=list(aliases), summary=summary,
        tools=[dict(name=n,role=r) for n,r in tools], creatures=[dict(name=n,role=r) for n,r in creatures],
        targets=list(targets), cautions=list(cautions), weightReductions=[dict(name=n,percent=p) for n,p in weights],
        sourceURLs=[WIKI+s for s in sources], verifiedAt=DATE))
add('Raw Meat','For a hand harvest, choose Metal Pick over Metal Hatchet. A meat-harvesting carnivore is the practical bulk option.',
 [('Metal Pick','Favors meat when harvesting a corpse.'),('Stone Pick','Early pick option before metal tools.'),('Metal Hatchet','Harvests meat too, but favors hide.')],
 [('Rex','Bulk corpse harvesting.'),('Carnotaurus','Meat harvesting option.'),('Allosaurus','Meat harvesting option.'),('Giganotosaurus','Bulk option once available and safely tamed.'),('Argentavis','Mobile corpse-harvesting option.')],
 ['Ordinary land-creature corpses','Phiomia: useful early meat and hide; it flees when attacked'],
 ['Yield varies with harvester stats, tool quality and harvest settings.','Fish meat and prime meat require their own source choices.'],
 ['Raw_Meat','Metal_Pick','Metal_Hatchet','Hide'],['Meat','Dino Corpse'])
add('Raw Prime Meat','Harvest prime-dropping larger creatures. ASA also has wild babies that yield prime meat.',
 [('Metal Pick','Hand tool option.'),('Chainsaw','Listed corpse-harvesting option.')],
 [('Rex','Prime corpse harvester.'),('Carnotaurus','Prime corpse harvester.'),('Allosaurus','Prime corpse harvester.'),('Ichthyornis','Hunt eligible small animals to make prime available.')],
 ['Brontosaurus','Diplodocus','Paraceratherium','Stegosaurus','Argentavis','Mammoth','Rex','Spino','Alpha creatures','Non-adult creatures; ASA includes wild babies'],
 ['Targets are source examples, not a yield ranking.','Prime spoils quickly; collect it near the intended tame.','A hungry carnivore can consume prime in its inventory.','Ichthyornis enhancement applies to hunted eligible small prey, not every corpse.'],
 ['Raw_Prime_Meat','Metal_Pick'],['Prime Meat'])
add('Raw Fish Meat','Harvest fish corpses; use a water-capable collector for bulk trips.',
 [('Metal Pick','Listed hand tool for fish corpses.')],
 [('Spino','Fish corpse collector.'),('Pelagornis','Fish-harvesting option.'),('Otter','Can kill fish and collect fish meat.'),('Ichthyornis','Can hunt fish near water.')],
 ['Coelacanth','Piranha','Sabertooth Salmon','Manta','Megalodon','Dunkleosteus'],
 ['Manta groups around Basilosaurus are a wiki-listed bulk source, with combat risk.','Normal fish meat is distinct from prime fish meat.'],['Raw_Fish_Meat'],['Fish Meat'])
add('Raw Prime Fish Meat','Use Metal Sickle on eligible fish. Hand-tool choice can change with the species.',
 [('Metal Sickle','Recommended for prime fish harvests.'),('Metal Hatchet','Resource page favors hatchet for dead Dunkleosteus or Megalodon.'),('Metal Pick','Alternative listed tool.'),('Fishing Rod','Can obtain small amounts by fishing.'),('Chainsaw','Use only on a corpse accessible on land; cannot operate underwater.')],
 [('Spino','Prime fish harvesting option.'),('Ichthyornis','Fish hunting and land-delivery option.'),('Moschops','Invest prime-fish harvesting levels for Leedsichthys.')],
 ['Sabertooth Salmon','Megalodon','Dunkleosteus','Tusoteuthis','Leedsichthys','Alpha Megalodon','Alpha Tusoteuthis'],
 ['Metal Sickle can scrape Leedsichthys without making it aggressive.','Do not apply the general pick-for-meat rule blindly to every fish.','Scorched Earth source page identifies fishing as the route to prime fish.'],['Raw_Prime_Fish_Meat','Metal_Sickle'],['Prime Fish Meat'])
add('Raw Mutton','Harvest an Ovis corpse. Ovis health affects the amount received.',
 [('Chainsaw','Preferred tool listed for mutton.'),('Sword / Metal Sickle / Metal Pick','Held tool enabling the tamed Ovis Slaughter radial action.')],
 [('Direwolf','Listed mutton corpse collector.')],['Ovis'],
 ['Ovis can be rare; this is a specific prey source, not ordinary meat.','Hungry harvesting carnivores can eat the mutton.'],['Raw_Mutton','Ovis'],['Mutton'])
add('Hide','Use Metal Hatchet rather than Metal Pick when hide is the priority; Chainsaw is the wiki-preferred hand tool.',
 [('Metal Hatchet','Favors hide over meat.'),('Chainsaw','Preferred hand tool for hide.')],
 [('Direwolf','Hide collection option.'),('Sabertooth','Hide collection option.'),('Therizinosaur','Bite attack favors hide; attack choice matters.'),('Thylacoleo','Hide collection option.')],
 ['Most non-fish, non-invertebrate corpses','Phiomia','Early game: Dodo, Lystrosaurus, Parasaur','Ovis: hide amount increases with its health'],
 ['Tool choice and prey choice are separate decisions.','Phiomia and Parasaur flee when attacked.'],['Hide','Metal_Hatchet','Therizinosaur','Ovis'])
add('Chitin','Harvest arthropod corpses. Megatherium and Metal Hatchet are useful dedicated choices.',
 [('Metal Hatchet','Useful hand tool.'),('Pike','Precision option for small insect corpses.')],
 [('Megatherium','Chitin gathering specialist.'),('Sabertooth','Chitin corpse collector.'),('Direwolf','Chitin corpse collector.'),('Therizinosaur','Bite/head harvest favors chitin; delicate harvesting investment affects it.'),('Diplocaulus','Specialist for Trilobites.')],
 ['Trilobite','Meganeura','Titanomyrma','Pulmonoscorpius','Araneo','Karkinos'],
 ['Karkinos farming needs a strong enough tame.','Cave insect density is useful, but route danger still matters.'],['Chitin','Therizinosaur','Trilobite'],weights=[('Equus',50),('Unicorn',50)])
add('Keratin','Harvest horned, plated or shelled animals with Metal Hatchet or an appropriate corpse collector.',
 [('Metal Hatchet','Useful hand tool.'),('Stone Hatchet','Early alternative.')],
 [('Sabertooth','Keratin corpse collector.'),('Direwolf','Keratin corpse collector.'),('Therizinosaur','Listed harvesting option.')],
 ['Carbonemys','Triceratops','Stegosaurus','Ankylosaurus','Doedicurus','Mammoth'],
 ['Not every creature drops keratin.','Chitin substitutes for keratin in recipes that explicitly accept either.'],['Keratin'],weights=[('Equus',50),('Unicorn',50)])
add('Pelt','Harvest furry animals. Metal Hatchet or Direwolf are useful options.',
 [('Metal Hatchet','Effective hand harvest.')], [('Direwolf','Pelt collector.'),('Sabertooth','Alternative pelt collector.'),('Thylacoleo','Alternative pelt collector.')],
 ['Mammoth','Megaloceros','Castoroides','Dire Bear','Equus','Ovis','Megatherium','Procoptodon'],
 ['Pelt can be collected outside snow from eligible mammals.'],['Pelt'])
add('Wool','Shear Ovis without killing it; food stat affects wool regrowth.', [('Scissors','Shear wild or tamed Ovis.')],[],['Ovis'],['Ovis produces wool; it does not gather resources itself.'],['Ovis'])
add('Organic Polymer','Harvest eligible carcasses or map-specific polymer plants. Use a suitable tool for the source.',
 [('Wooden Club','Accessible Kairuku harvesting option.'),('Chainsaw','Listed high-efficiency corpse option.'),('Sword','Listed polymer harvesting option.')],
 [('Pelagornis','Polymer corpse harvester and carrier.'),('Moschops','Invest organic-polymer harvesting points.'),('Therizinosaur','Can gather from eligible polymer plants and corpses.'),('Achatina','Passive production, not corpse harvesting.')],
 ['Kairuku','Hesperornis','Mantis','Karkinos','Aberration: white bulb-like plants in the elemental area'],
 ['Spoils; harvesting and passive production are different mechanics.','Map-specific alternate sources must exist on the selected ASA map.'],['Organic_Polymer'],['Polymer'],[('Achatina',90),('Pelagornis',80),('Argentavis',50)])
add('Wood','Choose Metal Hatchet over Metal Pick for trees; Chainsaw is a dedicated tool.',
 [('Metal Hatchet','Favors wood.'),('Chainsaw','Wood gathering tool.')],
 [('Castoroides','Wood harvester.'),('Mammoth','Wood harvester and carrier.'),('Therizinosaur','Power harvest favors wood.'),('Roll Rat','Listed wood harvesting option.'),('Thorny Dragon','Listed wood harvesting option.')],
 ['Trees'],['Destroying a tree with a creature does not always mean collecting it.'],['Metal_Hatchet','Trees','Mammoth','Gathering_and_Weight_Reduction','Therizinosaur'],weights=[('Mammoth',75),('Roll Rat',80),('Castoroides',50),('Thorny Dragon',50)])
add('Thatch','Picks favor thatch from trees; larger area harvesters are bulk options.',
 [('Metal Pick','Favors thatch over wood.'),('Stone Pick','Early thatch tool.'),('Industrial Grinder','Converts gathered wood to thatch.')],
 [('Brontosaurus','Tree harvesting option.'),('Triceratops','Listed thatch collector.'),('Megatherium','Listed thatch collector.')],['Trees'],[],['Thatch','Metal_Pick'],weights=[('Castoroides',50),('Ravager',50),('Thorny Dragon',50)])
add('Stone','Metal Hatchet favors stone; Doedicurus specializes in bulk stone.',
 [('Metal Hatchet','Favors stone over flint.'),('Hands','Pick up small loose stones.')],
 [('Doedicurus','Tail swing; ASA has Stone/Sand Harvest Only selection.'),('Magmasaur','Listed stone gathering option.')],['Rocks','Loose ground stones'],
 ['Doedicurus is a stone collector, not a substitute for Ankylo metal farming.'],['Metal_Hatchet','Hands','Doedicurus','Stone'],weights=[('Doedicurus',75)])
add('Flint','Metal Pick favors flint from ordinary rocks; Ankylo is a bulk option.',
 [('Metal Pick','Favors flint.'),('Stone Pick','Early flint tool.'),('Industrial Grinder','Converts stone into flint.')],
 [('Ankylosaurus','Tail swing harvests rocks; ASA Harvest Only can select flint.'),('Fasolasuchus','Listed flint collector.')],['Rocks'],[],['Flint','Ankylosaurus','Metal_Pick'])
add('Metal','Target ore rocks instead of relying on the small metal yield of ordinary rocks.',
 [('Metal Pick','Ore hand tool.'),('Stone Pick','Possible early option, poor for rare resources.')],
 [('Ankylosaurus','Tail swing; ASA Harvest Only can select metal.'),('Magmasaur','Listed metal collector.'),('Dunkleosteus','Listed underwater mining option.')],
 ['Metal-bearing rocks','Rich metal rocks','Aberration: blue-striped ore rocks in the luminous region'],
 ['Metal ore weight reduction does not automatically apply to metal ingots.','Actual yield depends on the node, melee/tool quality and server settings.'],['Metal','Ankylosaurus','Metal_Pick'],['Rich Metal','Raw Metal'],[('Ankylosaurus',85),('Magmasaur',75),('Argentavis',50)])
add('Crystal','Use Metal Pick or Ankylo on crystalline nodes.', [('Metal Pick','Crystal node tool.')], [('Ankylosaurus','Tail swing collects crystalline nodes.')],['Crystal formations'],[],['Metal_Pick','Ankylosaurus','Weight_Reduction'],weights=[('Argentavis',50),('Dunkleosteus',50),('Ravager',50)])
add('Obsidian','Mine obsidian nodes with Metal Pick or Ankylo.', [('Metal Pick','Hand mining option.')], [('Ankylosaurus','Ore collector.'),('Magmasaur','Listed mining option.')],['Glossy dark obsidian rocks'],
 ['Doedicurus can gather from some obsidian node types but cannot gather from all visually similar rocks.','ASA obsidian nodes look more jagged than ASE nodes.'],['Obsidian'],weights=[('Dunkleosteus',75),('Argentavis',50),('Ravager',50)])
add('Fiber','Use Metal Sickle on plants, or a dedicated fiber collector.', [('Metal Sickle','Dedicated plant fiber tool.'),('Hands','Early manual collection.')],
 [('Therizinosaur','Use delicate harvesting on plants.'),('Dire Bear','Listed fiber collector.'),('Gigantopithecus','Can gather fiber autonomously.')],['Bushes and seed plants'],
 ['Ankylosaurus does not collect fiber.'],['Metal_Sickle','Hands','Gathering_and_Weight_Reduction','Therizinosaur','Ankylosaurus'])
add('Berries','Collect by hand or with a berry-harvesting tame; a pick/hatchet is not the default berry tool.', [('Hands','Manual bushes.'),('Whip','Manual collection alternative.')],
 [('Brontosaurus','Wide plant collection.'),('Triceratops','Berry collection option.'),('Stegosaurus','Backplate mode changes harvesting; berry mode matters.'),('Ankylosaurus','Bite collects bushes, unlike its rock tail swing.')],['Bushes'],
 ['Stegosaurus does not collect fiber.'],['Hands','Gathering_and_Weight_Reduction','Stegosaurus','Ankylosaurus'])
add('Oil','Separate mining oil rocks from tame production and oil-vein pumping.', [('Metal Pick','Mine oil rocks.'),('Oil Pump','Automatic production from an oil vein, where available.')],
 [('Dunkleosteus','Underwater oil-node collector.'),('Ankylosaurus','Oil-node collector.'),('Dung Beetle','Converts feces while wandering; ASA automatically collects feces.'),('Basilosaurus','Passively makes oil in its inventory.')],
 ['Oil rocks','Oil veins with a pump','Trilobite corpses: alternative, low and inconsistent pearl/oil drops'],
 ['Basilosaurus-produced oil is the spoilable creature variant.','Mining, passive production and vein extraction are distinct methods.'],['Oil/id','Dung_Beetle','Basilosaurus','Trilobite'],['Rich Oil','Oil Meat'])
add('Silica Pearls','Hand-pick pearl clams or use Anglerfish bite to collect them.', [('Hands','Collect clam nodes; no mining tool needed.'),('Whip','Scorched Earth exposed pearls.')],
 [('Anglerfish','Bite harvests clam nodes.'),('Otter','Harvest fish to obtain small amounts.')],
 ['Pearl clams','Giant Beaver Dams','Trilobite / Leech / Eurypterid / Ammonite corpses'],
 ['Corpse harvesting and clam gathering are different contexts.','The resource page says player melee does not increase hand-picked clam pearls.'],['Silica_Pearls','Anglerfish'],['Pearls'])
add('Black Pearls','Choose actual black-pearl sources; ordinary silica clams are a different resource.', [('Metal Pick','Listed corpse tool.'),('Chainsaw','Listed tool, only where corpse access permits it.')],
 [('Megalodon','Harvest pearl-dropping sea corpses.'),('Otter','Rare black pearls from fish corpses.'),('Beelzebufo','Increased harvesting from Eurypterid.'),('Gacha','Production only when that individual has Black Pearl in its production choices.')],
 ['Eurypterid','Ammonite','Tusoteuthis','Alpha Tusoteuthis','Alpha Mosasaur','Deathworm','Trilobite'],
 ['Eurypterid rapidly drains tame stamina.','Gacha being listed as a gatherer does not mean every Gacha can produce this resource.'],['Black_Pearl','Weight_Reduction'],['Black Pearl'],[('Argentavis',50),('Dunkleosteus',50)])
add('Sap','Tap eligible redwoods; Joshua trees use a different harvest method.', [('Tree Sap Tap','Attach to a supported Redwood tree.'),('Chainsaw','Harvest Joshua trees.'),('Pick / Hatchet','Joshua-tree alternative.')],
 [('Moschops','Invest sap harvesting points for Joshua trees.'),('Archaeopteryx','Slow wandering sap collection from Redwood/Joshua trees.')],['Redwood trees','Joshua trees on desert maps'],
 ['Ordinary sap and cactus sap are separate resources.','Archaeopteryx does not gather sap in stasis and can wander out of range.'],['Sap','Archaeopteryx'])
add('Cactus Sap','Small and large cactus nodes need different methods.', [('Hands','Small cacti.'),('Whip','Efficient small-cactus tool.'),('Chainsaw','Preferred large-cactus tool.'),('Pick / Hatchet','Large cactus alternative.')],
 [('Therizinosaur','Delicate harvest on bush cactus nodes.')],['Small cacti','Large cacti'],
 ['ASA hydration comes from consuming cactus sap; ASE hydration came from harvesting the plant.'],['Cactus_Sap','Therizinosaur'],['Cactus','Cactus with few berries'],[('Equus',80),('Stegosaurus',75)])
add('Rare Flowers','Use the correct special plants, or loot a Beaver Dam.', [('Metal Sickle','Rare-flower patches.')],
 [('Therizinosaur','Delicate/fiber attack for rare-flower plants.'),('Moschops','Can specialize in rare-flower harvesting.'),('Ankylosaurus','Listed rare-flower collector.')],
 ['Swamp cattails / pitcher plants / brambles','Snow shrubs','Giant Beaver Dams','Aberration poison mushroom patches'],
 ['Eating one attracts nearby wild creatures.','Not every plant is a rare-flower node.'],['Rare_Flower','Metal_Sickle','Therizinosaur'],['Rare Flower'])
add('Rare Mushrooms','Chop swamp trees or gather map-specific mushroom sources; crystal mining can also drop them.', [('Metal Hatchet','Swamp-tree wood harvest.'),('Metal Pick','Crystal mining alternative.')],
 [('Therizinosaur','Power harvest for swamp trees.'),('Mammoth','Listed mushroom collector.'),('Ankylosaurus','Aberration mushroom bite harvest.'),('Roll Rat','Aberration hallucinogenic mushroom collection.')],
 ['Swamp mangrove trees','Giant Beaver Dams','Crystal nodes','Aberration hallucinogenic mushrooms'],
 ['Rare Mushroom is not the same item as the four Aberration mushroom types.'],['Rare_Mushroom','Trees','Ankylosaurus','Therizinosaur'],['Rare Mushroom'])
add('Mushrooms','Aberration ground mushrooms are efficiently collected with Metal Sickle.', [('Metal Sickle','Ground mushroom patches.')],
 [('Triceratops','Berry-type gathering also collects mushrooms.'),('Stegosaurus','Berry-type gathering also collects mushrooms.')],
 ['Aberration small ground mushroom patches'], ['Each mushroom type has different consumption effects; do not treat all as Rare Mushroom.'],['Mushrooms','Metal_Sickle'])
add('Fungal Wood','Harvest large mushrooms; Chainsaw is the resource page preferred tool.', [('Chainsaw','Large mushroom harvest.'),('Metal Hatchet','Wood-style tool alternative.')],
 [('Roll Rat','Carrier with fungal-wood reduction.')], ['Large mushroom trees'], ['Some recipes specifically require fungal wood.'],['Fungal_Wood','Aberration'],weights=[('Roll Rat',80),('Ravager',50)])
add('Silk','Harvest desert flowers or Lymantria corpses with source-appropriate tools.', [('Metal Sickle','Purple/white desert flower patches.'),('Metal Hatchet','Lymantria corpses.')],
 [('Therizinosaur','Delicate plant harvest.'),('Sabertooth','Lymantria corpse harvest.')],['Purple and white desert flowers','Lymantria'],
 ['Hand collection is low yield; wiki marks its edition scope as uncertain.'],['Silk','Metal_Sickle','Therizinosaur'])
add('Sulfur','Mine yellow-streaked sulfur rocks on maps with these nodes.', [('Metal Pick','Sulfur mining.'),('Stone Pick','Early mining option.')],
 [('Ankylosaurus','Listed sulfur collector.'),('Phoenix','Listed collector when tame/map is available.')],
 ['Yellow-streaked sulfur rocks','Rock Elemental / Wyvern / Magmasaur corpses'],[],['Sulfur'])
add('Raw Salt','Mine salt pillars or eligible fossil deposits.', [('Metal Pick','Salt mining.'),('Stone Pick','Early salt mining.')],[],
 ['Salt pillars','Small fossil/bone deposits'],['Bones on a resource map are deposit types, not automatically the event Dinosaur Bone item.'],['Raw_Salt'],['Bones'])
add('Sand','Collect sand from appropriate rocks or ground nodes.', [('Metal Hatchet','Rock harvest.'),('Whip','Loose ground sand.'),('Hands','Loose ground sand.')],
 [('Doedicurus','Bulk sand collection; ASA Harvest Only includes sand.')],['Sand-bearing rocks','Loose ground sand'],['Sand is heavy; plan hauling.'],['Sand','Doedicurus'],['Sandpile'],[('Equus',80)])
add('Cementing Paste','Farm small insects with a frog, loot dams, or use Achatina production.', [('Mortar and Pestle / Chemistry Bench','Craft from stone and chitin/keratin.')],
 [('Beelzebufo','Tongue harvest of Meganeura, Titanomyrma, Glowbug or Jug Bug corpses yields paste.'),('Achatina','Produces Achatina Paste, a crafting substitute.')],
 ['Eligible small insect corpses','Giant Beaver Dams'], ['Beavers become hostile when a dam is accessed.','Do not assume every chitin-dropping corpse produces paste with a frog.'],['Cementing_Paste','Beelzebufo','Giant_Beaver_Dam'],['Beaver Dam'])
add('Giant Bee Honey','Collect from a hive; Dire Bear alternate attack avoids harming a wild hive.', [('Hands','Access hive, with bee risk.')],
 [('Dire Bear','Alternate attack on a reachable hive collects honey without angering bees.'),('Giant Bee','Tamed bee creates a honey-producing hive.')],['Wild bee hives','Tamed Bee Hive'],
 ['A honey-harvesting attack differs from destroying the hive to tame the queen.','Map-specific honey rocks are a separate node context.'],['Giant_Bee_Honey','Dire_Bear'],['Honey','Bee Hive'])
add('Green Gem','Mine green crystalline nodes or collect debris.', [('Metal Pick','Gem mining.'),('Stone Pick','Early gem mining.')],[],
 ['Green crystalline formations','Earthquake debris','Roll Rat diggings'],['Taking Roll Rat debris makes it hostile.'],['Green_Gem'],['Gem','Gem Light'],[('Ravager',50)])
add('Blue Gem','Mine blue crystalline formations; Roll Rat debris is another source.', [('Stone Pick','Source-listed mining tool.')],[],
 ['Blue crystalline formations','Roll Rat diggings'],['Taking Roll Rat debris makes it hostile.'],['Blue_Gem'],['Gem Bio'])
add('Red Gem','Metal Pick is a practical choice for red/purple gem formations.', [('Metal Pick','Source-recommended gem mining.')],
 [('Aberrant Ankylosaurus','ASA source states radiation immunity; do not apply the ASE warning to ASA.')],
 ['Red / purple crystalline formations','Rare earthquake debris','Rare Roll Rat diggings'],
 ['Radioactive regions require survivor protection.','Taking Roll Rat debris makes it hostile.'],['Red_Gem'],['Gem Element'])
add('Element Ore','Mine the small dark rocks containing a purple crystal.',[],[],
 ['Aberration surface','Aberration Grave of the Lost'],
 ['This entry verifies the node source, not an optimal tool or creature.','Element Ore is distinct from Element, Element Dust and Element Shard.'],['Element_Ore'])
add('Blue Crystalized Sap','Harvest pale fungal trees on Extinction for a Blue Gem substitute.', [('Metal Pick','Source-listed tree harvest.'),('Chainsaw','Source-listed tree harvest.')],
 [('Therizinosaur','Source-listed tree harvest.')],['Extinction pale/white-leaf fungal trees'],[],['Blue_Crystalized_Sap'])
add('Red Crystalized Sap','Harvest blood-ridden red-leaf trees on Extinction for a Red Gem substitute.', [('Metal Hatchet','Source-recommended tool.'),('Chainsaw','Source-recommended tool.')],
 [('Gacha','Only individuals with the appropriate production choice.')], ['Extinction blood-ridden trees'],[],['Red_Crystalized_Sap'])
data=dict(schemaVersion=1,verifiedAt=DATE,editionScope='ARK: Survival Ascended companion; shared wiki harvesting mechanics, with explicit ASA/ASE differences retained.',
 limitations=['Curated practical coverage, not an exhaustive whole-game harvest database.','Wiki ratings are qualitative; no star ranking or fixed yield is presented as measured production.','Node type, source species, tool quality, melee and server settings affect results.','Creature availability, variant tamability and expansion access must be checked for the selected ASA map.','General mechanics from shared ASE/ASA wiki pages are reference facts, not local gameplay measurements.'],entries=entries)
path=ROOT/'native/Ascended/Resources/harvesting-guide.json'
path.write_text(json.dumps(data,indent=2,ensure_ascii=False)+'\n')
report=dict(verifiedAt=DATE,entryCount=len(entries),method='Public web search results of ARK Official Community Wiki pages; direct web opens returned HTTP 403.',sourceURLs=sorted({u for e in entries for u in e['sourceURLs']}),
 limitations=data['limitations'],nodeCatalogueNotYetCovered=['Element Shards','Blood Sap','City Lights','City Prop','Clay','Plant Proto Species R','Plant Species X','Toxic Plant','Death Kiss Plant','Gargoyle Statue','Wood Coal','Carrots','Citronal','Corn','Potatoes'],
 keyVerifiedCorrections=['Metal Pick favors raw meat; Metal Hatchet favors hide.','Raw Prime Fish Meat has species-specific hatchet exceptions and Metal Sickle guidance.','ASA wild babies yield prime; Ankylo/Doedicurus ASA Harvest Only behavior differs from older ASE instructions.','Gathering a corpse, producing resources passively and reducing cargo weight are distinct roles.'])
(ROOT/'docs/codex-reports/2026-10-07-harvesting25-sources.json').write_text(json.dumps(report,indent=2)+'\n')
print(f'Wrote {len(entries)} entries and {len(report["sourceURLs"])} traced source URLs.')
