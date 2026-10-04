"""Rebuild source-enumerated ARK catalog and acquire original game item icons.
Wiki tables mix ASE and ASA; edition-specific records retain an explicit verification
notice. No recipes, levels, map availability or DLC ownership are inferred.
"""
from pathlib import Path
import json,re,html,subprocess,hashlib,concurrent.futures,io,time,sys
from urllib.parse import quote
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
RES=ROOT/'native/Ascended/Resources'; ASSETS=ROOT/'native/Ascended/Assets.xcassets'
def fetch(url):
 p=subprocess.run(['curl','--fail','--location','--silent','--show-error','--retry','3','--retry-delay','2','--max-time','35',url if '/images/' in url else url+ ('&' if '?' in url else '?')+'x=1'],capture_output=True)
 if p.returncode:raise RuntimeError(p.stderr.decode()[:180])
 return p.stdout
def table_records(page):
 cache=Path('/tmp')/('equipment-'+page.replace('/','-').lower()+'.html')
 if cache.exists() and '<table' in cache.read_text():raw=cache.read_text()
 else:
  raw=fetch('https://ark.wiki.gg/wiki/'+page).decode()
  if '<table' not in raw:raise RuntimeError('No source table returned')
  cache.write_text(raw)
 tables=re.findall(r'<table[^>]*>(.*?)</table>',raw,re.S)
 out=[]
 for t in tables:
  if 'Item' not in t and 'Name' not in t:continue
  for row in re.findall(r'<tr[^>]*>(.*?)</tr>',t,re.S):
   cell=re.search(r'<td[^>]*>(.*?)</td>',row,re.S)
   if not cell:continue
   c=cell.group(1)
   if 'itemlink-icon' not in c:continue
   link=re.search(r'<a href="(/wiki/[^"]+)" title="([^"]+)"',c)
   img=re.search(r'<img[^>]+src="([^"]+)"',c)
   if not link:continue
   name=html.unescape(link.group(2));path=html.unescape(link.group(1))
   if ':' in name or 'Primitive Plus' in name or '/id' in name:continue
   src=html.unescape(img.group(1)) if img else None
   if src and '/thumb/' in src:src='/images/'+src.split('/thumb/')[1].split('/')[0]
   out.append(dict(name=name,sourceURL='https://ark.wiki.gg'+path,imageURL='https://ark.wiki.gg'+src if src else None))
 return out
MACHINE_NAMES='Water Reservoir|Water Reservoir (Frontier Showdown)|Water Well|Air Conditioner|Alarm Clock|Auto Turret|Ballista Turret|Beer Barrel|Bookshelf|Campfire|Cannon|Catapult Turret|Charge Node|Chemistry Bench|Cloning Chamber|Compost Bin|Cooking Pot|Cryofridge|Delivery Crate|Dino Leash|Egg Incubator|Elevator Track|Fabricator|Feeding Trough|Fireplace|Gas Collector|Heavy Auto Turret|Industrial Cooker|Industrial Forge|Industrial Grill|Industrial Grinder|Lamppost|Large Crop Plot|Large Elevator Platform|Large Storage Box|Medium Crop Plot|Medium Elevator Platform|Metal Irrigation Pipe - Intake|Metal Irrigation Pipe - Tap|Metal Water Reservoir|Mortar and Pestle|Mortar And Pestle|Oil Pump|Omnidirectional Lamppost|Preserving Bin|Refining Forge|Refrigerator|Remote Keypad|Small Crop Plot|Small Elevator Platform|Smithy|Standing Torch|Stone Fireplace|Stone Irrigation Pipe - Intake|Stone Irrigation Pipe - Tap|Storage Box|Tek Cloning Chamber|Tek Dedicated Storage|Tek Forcefield|Tek Generator|Tek Light|Tek Replicator|Tek Sleeping Pod|Tek Teleporter|Tek Transmitter|Tek Trough|Tek Turret|Tek Crop Plot|Tek Water Reservoir|Toilet|Tree Sap Tap|Vault|Wall Torch|Water Tank|Wind Turbine|Wood Elevator Track|Small Wood Elevator Platform|Medium Wood Elevator Platform|Large Wood Elevator Platform|Wood Elevator Top Switch|Power Generator|Electrical Generator|Embryo Incubator|Cryo Hospital|Gene Storage|Industrial Preserving Bin|Wireless Crafting Station'.split('|')
PURPOSE={
'Fabricator':('Chế tạo thiết bị cơ khí và điện.','Dùng cho Polymer, Electronics và thiết bị cấp công nghiệp.','Smithy'),
'Chemistry Bench':('Trạm hóa học sản xuất theo lô.','Chế Narcotic, Cementing Paste, Sparkpowder và Gunpowder; ASA chỉ yêu cầu điện.','Fabricator'),
'Industrial Forge':('Lò luyện công nghiệp.','Luyện Metal Ingot và sản xuất Charcoal nhanh hơn lò nhỏ.','Fabricator'),
'Industrial Cooker':('Nấu món ăn và Kibble theo lô.','Cấp nước và năng lượng trước khi nấu.','Fabricator'),
'Industrial Grill':('Nướng thịt số lượng lớn.','Dự trữ thịt chín cho người và thú.','Fabricator'),
'Industrial Grinder':('Nghiền vật phẩm và tài nguyên.','Thu hồi một phần nguyên liệu; kiểm tra giới hạn của vật phẩm.','Fabricator'),
'Power Generator':('Nguồn điện không dây trong ASA.','Cấp điện cho thiết bị trong bán kính; không cần dây điện.','Fabricator'),
'Refrigerator':('Bảo quản thực phẩm bằng điện.','Kéo dài thời gian hỏng của thức ăn và vật phẩm hữu cơ phù hợp.','Fabricator'),
'Air Conditioner':('Điều hòa cách nhiệt quanh máy.','Hỗ trợ sống trong nhiệt độ khắc nghiệt và ấp trứng.','Fabricator'),
'Cryofridge':('Bảo quản và sạc Cryopod.','Kiểm tra điều kiện thả Cryopod theo cấu hình server hiện tại.','Kiểm tra engram ASA trong game'),
'Compost Bin':('Biến phân và Thatch thành Fertilizer.','Cung cấp phân bón cho Crop Plot.','Inventory'),
'Feeding Trough':('Cho thú ăn trong phạm vi.','Bỏ thức ăn phù hợp và kiểm tra biểu tượng máng trên từng thú. Baby chưa đạt Juvenile không tự ăn từ máng.','Inventory'),
'Preserving Bin':('Bảo quản và làm Jerky.','Dùng Sparkpowder; thêm Oil và thịt chín cho Jerky.','Inventory'),
'Mortar and Pestle':('Trạm nghiền và phối nguyên liệu ban đầu.','Chế Narcotic, Cementing Paste, Sparkpowder và Gunpowder.','Inventory'),
'Smithy':('Trạm chế đồ kim loại.','Chế và sửa công cụ, vũ khí, giáp và thiết bị tương ứng.','Inventory'),
'Refining Forge':('Lò luyện giai đoạn đầu.','Nung Metal thành Metal Ingot; chế Gasoline từ Oil và Hide.','Inventory')}
PURPOSE['Water Reservoir']=('Bồn chứa và truyền nước không dây ASA.','Đặt bồn nối vùng cấp nước; tưới trong 10 foundation và kết nối bồn khác khoảng 33 foundation.','Inventory')
PURPOSE['Water Reservoir (Frontier Showdown)']=('Bồn nước lớn thuộc Bob’s Tall Tales.','Dự trữ nước cho căn cứ; cần quyền sử dụng DLC Bob’s Tall Tales.','Smithy')
PURPOSE['Stone Irrigation Pipe - Intake']=('Đầu hút nước cho mạng tưới ASA.','Đặt đầu hút vào nước; ASA truyền nước không dây tới bồn và thiết bị trong vùng.','Inventory')
PURPOSE['Metal Irrigation Pipe - Intake']=('Đầu hút nước bằng kim loại.','Đặt đầu hút vào nước; kiểm tra chỉ báo cấp nước của vùng căn cứ ASA.','Smithy')
PURPOSE.update({
'Water Tank':('Bồn chứa nước cho căn cứ.','Dự trữ và mở rộng vùng nước không dây ASA; kiểm tra chỉ báo tưới.','Inventory'),
'Metal Water Reservoir':('Bồn chứa nước bằng kim loại.','Tăng lượng dự trữ nước và vùng cấp nước cho căn cứ.','Smithy'),
'Small Crop Plot':('Luống trồng nhỏ.','Trồng berry; cấp nước, phân bón và seed thích hợp.','Inventory'),
'Medium Crop Plot':('Luống trồng vừa.','Trồng rau và berry; giữ nước và phân bón để cây tiếp tục lớn.','Inventory'),
'Large Crop Plot':('Luống trồng lớn.','Trồng cây chiến đấu hoặc nông sản phù hợp; kiểm tra seed được chấp nhận.','Inventory'),
'Cooking Pot':('Nồi nấu thức ăn và Kibble ban đầu.','Cho nguyên liệu đúng công thức, nước và nhiên liệu; loại Charcoal nếu không muốn nhuộm màu.','Inventory'),
'Campfire':('Lửa trại nấu thịt và sưởi.','Thêm nhiên liệu, thịt sống và lấy Charcoal sau khi đốt Wood.','Inventory'),
'Beer Barrel':('Ủ Beer Liquid.','Cấp nước và nguyên liệu; chờ ủ rồi dùng Water Jar thu Beer.','Smithy'),
'Cloning Chamber':('Sao chép thú bằng công nghệ Tek.','Chuẩn bị Element Shards và xác nhận loài có thể clone; không thay việc breeding đột biến.','Tek Replicator'),
'Tek Replicator':('Trạm chế tạo cấp Tek.','Chế thiết bị Tek sau khi có Tekgram; ASA nhận điện từ Tek Generator.','Xem điều kiện Tekgram'),
'Tek Generator':('Nguồn điện cấp Tek.','Chuẩn bị Element phù hợp và kiểm tra phạm vi phủ thiết bị.','Tek Replicator'),
'Tek Trough':('Máng ăn có bảo quản bằng công nghệ Tek.','Cấp nguồn Tek và đặt thức ăn phù hợp cho đàn thú trong phạm vi.','Tek Replicator'),
'Storage Box':('Rương chứa đồ giai đoạn đầu.','Phân loại đồ gần trạm chế tạo và giữ đường đi trống.','Inventory'),
'Large Storage Box':('Rương chứa đồ lớn.','Dùng cho vật tư thông dụng; kiểm tra dung lượng theo server.','Inventory'),
'Vault':('Kho chứa đồ bền vững.','Đặt trên kết cấu ổn định; chia tài nguyên theo công việc căn cứ.','Fabricator'),
'Tree Sap Tap':('Vòi lấy Sap từ cây phù hợp.','Lắp trên Redwood thích hợp và quay lại lấy Sap.','Smithy'),
'Oil Pump':('Máy khai thác Oil Vein.','Đặt lên Oil Vein của map hỗ trợ; bảo vệ và kiểm tra kho định kỳ.','Fabricator'),
'Gas Collector':('Thu Congealed Gas Ball.','Lắp trên Gas Vein ở map hỗ trợ; theo dõi nguồn nguy hiểm quanh điểm đặt.','Smithy'),
'Dino Leash':('Giới hạn khu vực di chuyển của thú.','Kiểm tra điện và phạm vi trước khi bật wandering.','Fabricator'),
'Auto Turret':('Tháp súng bảo vệ tự động.','Cấp điện và đạn; cấu hình mục tiêu và kiểm tra góc bắn.','Fabricator'),
'Heavy Auto Turret':('Tháp súng hạng nặng.','Cấp điện và đủ đạn; chú ý giới hạn turret theo server.','Fabricator'),
'Tek Turret':('Tháp phòng thủ cấp Tek.','Cấp điện Tek và tài nguyên phù hợp; kiểm tra góc bắn và mục tiêu.','Tek Replicator'),
'Wind Turbine':('Máy phát điện theo gió.','Kiểm tra gió ở vị trí trên map; chuẩn bị nguồn dự phòng nếu gió không liên tục.','Fabricator'),
'Tek Dedicated Storage':('Kho chuyên dụng cho một loại vật tư.','Hỗ trợ kéo tài nguyên không dây tới trạm chế tạo ASA trong vùng phù hợp.','Tek Replicator'),
'Fireplace':('Lò sưởi và nấu thịt trong ASA.','Tạo vùng ấm và nấu thịt; kiểm tra nhiên liệu trước chuyến đi.','Smithy')
})
OBSOLETE=re.compile(r'Electrical Cable|Electrical Outlet|Irrigation Pipe - (Flexible|Inclined|Intersection|Straight|Vertical)|Inclined Electrical|Flexible Electrical|Straight Electrical')
def slug(n):return re.sub(r'[^a-z0-9]+','-',n.lower()).strip('-')
def current_evidence():
 evidence={}; map_types={}
 aliases={'Black Pearls':'Black Pearl','Rare Flowers':'Rare Flower','Rare Mushrooms':'Rare Mushroom','Rich Metal':'Metal','Rich Oil':'Oil','Wood Coal':'Charcoal'}
 for path in RES.glob('*-resources.json'):
  data=json.loads(path.read_text())
  if not isinstance(data,list):continue
  for row in data:
   n=aliases.get(row.get('resource_type'),row.get('resource_type'))
   if n:map_types.setdefault(n,set()).add(path.name.replace('-resources.json',''))
 eng=Path('/tmp/equipment-engrams.html')
 if eng.exists():raw=eng.read_text()
 else:
  try:raw=fetch('https://ark.wiki.gg/wiki/Engrams').decode()
  except Exception:raw=''
 for heading in ['Base_Game_Engrams','Scorched_Earth_Engrams','Aberration_Engrams','Extinction_Engrams']:
  start=raw.find('id="'+heading+'"')
  if start<0:continue
  end=raw.find('<h2>',start+1);part=raw[start:end if end>=0 else len(raw)]
  for row in re.findall(r'<tr[^>]*>(.*?)</tr>',part,re.S):
   cells=re.findall(r'<td[^>]*>(.*?)</td>',row,re.S)
   if len(cells)<3:continue
   m=re.search(r'<a href="/wiki/[^"]+" title="([^"]+)"',cells[0])
   if not m:continue
   name=html.unescape(m.group(1));vals=[re.sub('<[^>]+>','',x).strip() for x in cells[1:3]]
   evidence[name]=dict(group=heading,level=vals[0],ep=vals[1])
 return evidence,map_types
def main():
 engrams,map_types=current_evidence()
 visual={x['name'].casefold():x for x in json.loads((RES/'visual-facts.json').read_text())}; records={}; sources=[]; excluded=[]
 for category,page in [('resources','Resources'),('tools','Item_IDs/Tools'),('tools','Item_IDs/Weapons'),('tools','Item_IDs/Armor'),('tools','Item_IDs/Ammunition'),('structures','Structures')]:
  try: rows=table_records(page)
  except Exception as e:sources.append(dict(page=page,status='unavailable',error=str(e)));continue
  sources.append(dict(page=page,url='https://ark.wiki.gg/wiki/'+page,status='retrieved',enumerated=len(rows)))
  for row in rows:
   name=row['name']
   if OBSOLETE.search(name) or any(s in name for s in ['Flag','Trophy','Anniversary','Taxidermy Base','Decor Box']):excluded.append(name);continue
   if name in ['Admin Blink Rifle','Pliers','Electronic Binoculars'] or name.startswith('Tier ') or name.startswith('Federation Exo '):excluded.append(name);continue
   if name=='Empty Cryopod':name='Cryopod';row['name']=name;row['sourceURL']='https://ark.wiki.gg/wiki/Cryopod'
   if name=='Electrical Generator':name='Power Generator';row['name']=name;row['sourceURL']='https://ark.wiki.gg/wiki/Power_Generator'
   if name=='Stone Fireplace':name='Fireplace';row['name']=name
   if name in records:continue
   cat='machines' if name in MACHINE_NAMES else category
   known=PURPOSE.get(name)
   summary,use,station=known if known else ({'resources':('Nguyên liệu thu thập hoặc chế tạo.','Dùng trong công thức phù hợp; mở nguồn để xem cách lấy.','Thu thập / xem nguồn'), 'tools':('Trang bị, công cụ hoặc vật tư sử dụng.','Chọn theo mục đích thu hoạch, chiến đấu hoặc hỗ trợ sinh tồn.','Xem công thức trong game'), 'machines':('Thiết bị vận hành căn cứ.','Bố trí theo phạm vi hoạt động, nguồn điện/nước và nhu cầu căn cứ.','Xem công thức trong game'), 'structures':('Thành phần xây dựng căn cứ.','Dùng snap và biến thể ASA để xây kết cấu phù hợp.','Xem công thức trong game')}[cat])
   unlock='Kiểm tra engram, cấp độ và map/DLC trong ASA hiện tại; nguồn danh mục có cả ASE. Không suy ra cấp mở khóa.'
   if name=='Water Reservoir (Frontier Showdown)':unlock='Bob’s Tall Tales • Frontier Showdown; cấp 53, 25 EP theo nguồn chính thức.'
   if name.startswith('Tek '):unlock='Tekgram hoặc điều kiện riêng của vật phẩm; xác nhận boss/map trong ASA trước khi chế.'
   if name in ['Power Generator','Chemistry Bench','Fireplace']:unlock='Cơ chế ASA đã đối chiếu trang ARK: Survival Ascended; cấp engram xem trong game.'
   v=visual.get(name.casefold());asset=v['asset'] if v else None
   item=dict(id=slug(name),name=name,category=cat,summary=summary,use=use,station=station,unlock=unlock,mapIDs=[],sourceURL=row['sourceURL'])
   item['availability']='source-catalog-check-asa'
   item['editionNote']='Danh mục tham khảo có cả ASE/ASA; kiểm tra mục này trong ASA trước khi lên kế hoạch.'
   if name in ['Power Generator','Chemistry Bench','Fabricator','Industrial Forge','Industrial Cooker','Industrial Grill','Industrial Grinder']:
    item['availability']='asa-mechanics-verified'
    item['editionNote']='ASA: thiết bị có thể hoạt động bằng nguồn điện không dây. Cấp mở khóa xem engram trong game.'
    item['unlock']=item['editionNote']
   if name in ['Water Reservoir','Metal Water Reservoir','Stone Irrigation Pipe - Intake','Metal Irrigation Pipe - Intake','Water Well']:
    item['availability']='asa-mechanics-verified';item['editionNote']='ASA: cấp và nối nước không dây; không cần mạng ống thẳng của ASE.';item['unlock']='Engram trong game; cơ chế cấp nước ASA đã đối chiếu nguồn.'
   if name in ['Smithy','Compost Bin','Preserving Bin','Refrigerator','Small Crop Plot','Medium Crop Plot','Large Crop Plot','Storage Box','Large Storage Box','Bookshelf','Vault','Simple Bed']:
    item['availability']='asa-patch-verified';item['editionNote']='Vật phẩm nền được nhắc trong patch ASA85.0 (Garden skins); engram và quyền DLC xem trong game.';item['unlock']='Engram ASA trong game; skin Garden là mỹ phẩm riêng.'
   if name=='Feeding Trough':item['availability']='asa-patch-verified';item['editionNote']='ASA patch35.6/41.23 đối chiếu trang Feeding Trough; Baby chưa Juvenile vẫn cần thức ăn riêng.';item['unlock']='Engram: cấp18, 12EP theo nguồn Feeding Trough.'
   if name=='Cryofridge':item['availability']='asa-mechanics-verified';item['editionNote']='ASA: điện và điều kiện Cryopod phụ thuộc server; nguyên liệu đã có thay đổi riêng trong ASA.';item['unlock']='Engram và điều kiện server ASA; xem nguồn Cryofridge.'
   if name=='Water Reservoir (Frontier Showdown)':item['availability']='asa-dlc-verified';item['editionNote']=unlock
   if asset:item['asset']=asset
   records[name]=(item,row)
 # Reuse real existing item facts as a supplemental consumables / tribute catalog.
 # Pseudo node labels, generic armor placeholders and non-item guide symbols excluded.
 pseudo={'Base Seeds','Base Veggie','Beaver Dam','Cactus with few berries','Captains Hat','Carrots','Corn','Gem Bio','Little Ratfish Treats!','Mushrooms','Potatoes','Rare Flowers','Rare Mushrooms','Rich Metal','Rich Oil','Saddle','Sandpile','Black Pearls'}
 for fact in visual.values():
  name=fact['name']
  if fact.get('category')!='item' or name in records or name in pseudo:continue
  item=dict(id=slug(name),name=name,category='supplies',summary='Đồ tiêu hao, thực phẩm hoặc vật tư hỗ trợ sinh tồn.',use='Dùng đúng công thức, loài thú hoặc mục đích; mở nguồn để kiểm tra tác dụng và điều kiện.',station='Thu thập / xem công thức trong game',unlock='Kiểm tra nguồn thu thập hoặc công thức ASA hiện tại.',mapIDs=[],asset=fact['asset'],sourceURL='https://ark.wiki.gg/wiki/'+quote(name.replace(' ','_')),availability='source-catalog-check-asa',editionNote='Tên và artwork khớp chính xác thư viện nguồn có sẵn; khả dụng map/DLC xem nguồn.')
  if name=='Medical Brew':item.update(summary='Thuốc hồi máu cho người chơi.',use='Mang theo khi khám phá và chiến đấu; không dùng thay thuốc mê hay thức ăn cho thú.',station='Cooking Pot / Industrial Cooker')
  records[name]=(item,dict(name=name,sourceURL=item['sourceURL'],imageURL=fact['sourceURL']))
 for item,row in records.values():
  name=item['name'];original='Electrical Generator' if name=='Power Generator' else 'Stone Fireplace' if name=='Fireplace' else 'Empty Cryopod' if name=='Cryopod' else name
  ev=engrams.get(original)
  if ev:
   item['availability']='asa-core-engram-reference'
   item['editionNote']='Engram '+ev['group'].replace('_Engrams','').replace('_',' ')+'; đối chiếu danh mục Engrams. Biến thể kết cấu ASA có thể gộp trong cùng engram.'
   if ev['level'].isdigit() and ev['ep'].isdigit():item['unlock']='Cấp '+ev['level']+' • '+ev['ep']+' EP theo danh mục Engrams; tùy cấu hình server.'
  if item['category']=='resources' and name in ['Achatina Paste','Ammonite Bile','AnglerGel','Bio Toxin','Cactus Sap','Chitin','Congealed Gas Ball','Corrupted Nodule','Element','Element Dust','Element Shard','Fiber','Flint','Gasoline','Giant Bee Honey','Green Gem','Hide','Human Hair','Keratin','Leech Blood','Metal Ingot','Pelt','Raw Salt','Red Gem','Sand','Scrap Metal','Scrap Metal Ingot','Shell Fragment','Silicate','Stone','Thatch','Wood','Wool']:
   item['availability']='asa-core-resource-reference';item['editionNote']='Nguyên liệu dùng chung của game cơ bản hoặc map mở rộng đã có trong hướng dẫn ASA; cách lấy cụ thể xem nguồn.';item['unlock']='Thu thập hoặc chế tạo theo trang nguồn; không cần mở khóa nguyên liệu thô.'
  if name in map_types:
   item['availability']='asa-map-resource-verified';item['mapIDs']=sorted(map_types[name]);item['editionNote']='Đối chiếu tên resource với dữ liệu map đã có nguồn của app.';item['unlock']='Thu thập trong map được liệt kê; vị trí và cách farm xem Resource Guide.'
  if item['category']=='supplies' and not ev:
   item['availability']='source-item-reference';item['editionNote']='Vật phẩm nguồn được đối chiếu tên và artwork chính xác; cách dùng xem trang vật phẩm.'
 items=[]; images=[]
 def acquire(pair):
  item,row=pair
  if item.get('asset'):return dict(name=item['name'],status='reused-exact',asset=item['asset'],sourceURL=row['sourceURL'])
  aid='Equipment-'+item['id'];existing=ASSETS/(aid+'.imageset')/'image.png'
  if existing.exists():
   data=existing.read_bytes();Image.open(io.BytesIO(data)).verify();item['asset']=aid
   return dict(name=item['name'],asset=aid,status='downloaded-original',imageURL=row.get('imageURL'),sourceURL=row['sourceURL'],sha256=hashlib.sha256(data).hexdigest())
  base_art={'Behemoth Gate','Behemoth Gateway','Gasoline','Greenhouse Ceiling','Greenhouse Wall'}
  if '--base-art' in sys.argv and item['name'] not in base_art:return dict(name=item['name'],status='no-local-artwork',sourceURL=row['sourceURL'])
  if '--key-only' in sys.argv and item['name'] not in PURPOSE:return dict(name=item['name'],status='no-local-artwork',sourceURL=row['sourceURL'])
  if '--no-download' in sys.argv or (item['category']!='machines' and not ('--base-art' in sys.argv and item['name'] in base_art)) or not row.get('imageURL'):return dict(name=item['name'],status='no-local-artwork',sourceURL=row['sourceURL'])
  try:
   time.sleep(6.5)
   data=fetch(row['imageURL']);im=Image.open(io.BytesIO(data));im.verify()
   aid='Equipment-'+item['id'];folder=ASSETS/(aid+'.imageset');folder.mkdir(exist_ok=True)
   (folder/'image.png').write_bytes(data);(folder/'Contents.json').write_text(json.dumps({'images':[{'filename':'image.png','idiom':'universal'}],'info':{'author':'xcode','version':1}},indent=2)+'\n');item['asset']=aid
   return dict(name=item['name'],asset=aid,status='downloaded-original',imageURL=row['imageURL'],sourceURL=row['sourceURL'],sha256=hashlib.sha256(data).hexdigest(),attribution='ARK Official Community Wiki; original game artwork belongs to Studio Wildcard; personal reference use')
  except Exception as e:return dict(name=item['name'],status='unavailable',error=str(e),sourceURL=row['sourceURL'])
 with concurrent.futures.ThreadPoolExecutor(max_workers=1) as pool:images=list(pool.map(acquire,records.values()))
 if len(records)<200:raise RuntimeError('Incomplete acquisition; existing catalog preserved')
 items=sorted([x[0] for x in records.values()],key=lambda x:(x['category'],x['name']))
 (RES/'equipment-library.json').write_text(json.dumps(dict(categories=[dict(id='resources',title='Tài nguyên',symbol='shippingbox.fill'),dict(id='tools',title='Công cụ & trang bị',symbol='wrench.and.screwdriver.fill'),dict(id='machines',title='Máy & tiện ích',symbol='gearshape.2.fill'),dict(id='structures',title='Kết cấu xây dựng',symbol='building.2.fill'),dict(id='supplies',title='Đồ tiêu hao & thực phẩm',symbol='takeoutbag.and.cup.and.straw.fill')],items=items),ensure_ascii=False,indent=2)+'\n')
 report=dict(date='2026-10-04',method='Full published catalog tables; no handpicked quantity target. Excludes explicit namespaces, Primitive Plus, obsolete ASA wiring/pipes and decorative trophies.',scope='Source-enumerated cross-edition reference, not a claim every entry is obtainable in current ASA. Availability, levels and DLC ownership remain explicit verification conditions; mapIDs empty means not verified, not universal spawn.',asaMechanicsSource='https://ark.wiki.gg/wiki/ARK_Survival_Ascended',asaVerificationSources=['https://ark.wiki.gg/wiki/Engrams','https://ark.wiki.gg/wiki/Electricity','https://ark.wiki.gg/wiki/Water_Reservoir','https://ark.wiki.gg/wiki/Stone_Irrigation_Pipe_-_Intake','https://ark.wiki.gg/wiki/Water_Well','https://ark.wiki.gg/wiki/Cryofridge','https://ark.wiki.gg/wiki/Feeding_Trough','https://ark.wiki.gg/wiki/ARK:_Survival_Ascended/Patch/85.0','https://ark.wiki.gg/wiki/Water_Reservoir_(Frontier_Showdown)'],counts={c:sum(x['category']==c for x in items) for c in ['resources','tools','machines','structures','supplies']},catalogSources=sources,engramEvidenceCount=len(engrams),mapResourceEvidenceCount=len(map_types),availabilityCounts={k:sum(x.get('availability')==k for x in items) for k in sorted({x.get('availability') for x in items})},excluded=sorted(set(excluded)),artwork=images,limitations=['Wiki catalogs combine ASE and ASA; individual availability is not asserted without edition evidence.','No fabricated recipes or level values.','No mod/Primitive Plus/ATLAS namespace imports.','Source game icon edition may be ASE shared art; artwork is never claimed as an ASA screenshot.','Supplemental supplies enumerate existing source-linked real item facts; skins, saddles and cosmetic variants are not claimed complete.'])
 (ROOT/'docs/codex-reports/2026-10-04-equipment-sources.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
 print(report['counts']);print('Artwork downloaded',sum(x['status']=='downloaded-original' for x in images),'reused',sum(x['status']=='reused-exact' for x in images));print('unavailable',[x['name'] for x in images if x['status']=='unavailable'])
if __name__=='__main__':main()
