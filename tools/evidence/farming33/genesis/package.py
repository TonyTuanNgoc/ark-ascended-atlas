import pathlib,subprocess,json,shutil
from PIL import Image,ImageDraw
root=pathlib.Path('/Users/admin/Ascended-iPad-Dev/tools/evidence/farming33/genesis')
media=pathlib.Path('/Volumes/TONY SSD/ASCENDED_MEDIA/farming33/genesis')
data=pathlib.Path('/Volumes/TONY SSD/TONY_WORKSPACE/CODE/TonyOS_Workspace/tools/youtube-intelligence/data/downloads')
rows=[
('genesis-ocean-safe-beach-silica-90-15','genesis-part-1-ocean','Safe Beach pearl shallows','Silica Pearls',90.6,15.1,'ABmBfT2pUss',30,36.5,'ABmBfT2pUss-proof.jpg','Creator caption LAT 90.6 LON 15.1 throughout the pearl shallows shot; source chapter names Ocean Safe Beach.','Silica pearl shells visibly clustered under shallow water; dedicated ASA silica guide. Harvest yield not shown.'),
('genesis-ocean-dragon-bones-metal-5-94','genesis-part-1-ocean','Dragon Bones Island metal plateau','Metal',5.3,94.5,'qfx6EJtISms',30,36,'qfx6EJtISms-proof.jpg','Creator caption LAT 5.3 LON 94.5 throughout the Dragon Bones island shot; Ocean specified by chapter.','Exposed metallic ore nodes on desert island plateau, dedicated ASA Metal guide. Harvest yield not shown.'),
('genesis-ocean-central-island-oil-45-63','genesis-part-1-ocean','Central island underwater oil rocks','Oil',45.5,63.1,'MA0U1vcwmp0',30,38,'MA0U1vcwmp0-proof.jpg','In-game Ocean map at 19s reads LATITUDE 45.5 LONGITUDE 63.1 before continuous dive to adjacent submerged rocks.','Dark underwater oil rock approached and mined with pick; dedicated ASA Oil guide.'),
('genesis-arctic-crystal-76-26','genesis-part-1','Arctic snowy basin crystal cluster','Crystal',76,26.5,'98L1-1JxyYo',24,32,'98L1-1JxyYo-proof.jpg','In-game land map at 35s reads LATITUDE 76 LONGITUDE 26.5 adjoining same crystal cluster.','White crystal cluster shown and struck with pick in the dedicated ASA Crystal guide.'),
('genesis-arctic-obsidian-77-26','genesis-part-1','Arctic ridge obsidian outcrop','Obsidian',77,26,'kE5WWK5GOS4',28,36,'kE5WWK5GOS4-proof24.jpg','In-game land map at 24s reads LATITUDE 77 LONGITUDE 26 before return to adjacent black outcrops.','Black angular obsidian outcrops shown and mined with pick in dedicated ASA Obsidian guide.'),
('genesis-arctic-frozen-lake-polymer-74-14','genesis-part-1','Frozen lake Kairuku polymer shore','Organic Polymer',74.7,14,'ZqRdXrq3XE8',18,26,'ZqRdXrq3XE8-proof.jpg','In-game land map at 10s reads LATITUDE 74.7 LONGITUDE 14 before Kairuku harvest on same frozen lake.','Kairuku harvested on frozen lake; green Organic Polymer acquisition notification visible around 25s. Dedicated ASA Polymer guide.'),
('genesis-ocean-west-island-chitin-40-19','genesis-part-1-ocean','West island insect farming cliffs','Chitin',40.6,19.8,'O7JlNBe_EoM',5,13,'O7JlNBe_EoM-full30.jpg','In-game Ocean map at 30s reads LATITUDE 40.6 LONGITUDE 19.8 before adjacent island Beelzebufo demonstration.','Dedicated ASA Chitin farming guide; Beelzebufo inventory at 50s explicitly displays CHITIN tooltip and harvested stacks. Terrain clip shows the documented island cliffs.'),
]
entries=[]
for id,map,name,res,lat,lon,vid,start,end,proof,coord,inventory in rows:
 sources=list(data.glob(vid+'.mp4'))+list(data.glob(vid+'*.mp4.part'));src=sources[0]
 out=media/(id+'.mp4')
 p=subprocess.run(['ffmpeg','-v','error','-ss',str(start),'-i',str(src),'-t',str(end-start),'-an','-vf','scale=960:-2','-c:v','libx264','-preset','fast','-crf','22','-pix_fmt','yuv420p','-movflags','+faststart','-y',str(out)],capture_output=True,text=True)
 if p.returncode:raise RuntimeError(p.stderr)
 decode=subprocess.run(['ffmpeg','-v','error','-xerror','-i',str(out),'-f','null','-'],capture_output=True,text=True)
 if decode.returncode:raise RuntimeError(decode.stderr)
 poster=media/(id+'.jpg');subprocess.run(['ffmpeg','-v','error','-ss','2','-i',str(out),'-frames:v','1','-y',str(poster)],capture_output=True,check=True)
 sheet=Image.new('RGB',(960,540));d=ImageDraw.Draw(sheet)
 for i in range(9):
  t=i*(end-start-.1)/8;tmp=root/(id+f'-frame{i}.jpg');subprocess.run(['ffmpeg','-v','error','-ss',str(t),'-i',str(out),'-frames:v','1','-vf','scale=320:180','-y',str(tmp)],capture_output=True,check=True)
  sheet.paste(Image.open(tmp),(i%3*320,i//3*180));d.text((i%3*320,i//3*180),str(round(start+t,2)),fill='red')
 sheetPath=root/(id+'-contact.jpg');sheet.save(sheetPath)
 entries.append(dict(id=id,map=map,name=name,resources=[res],lat=lat,lon=lon,videoID=vid,sourceURL='https://www.youtube.com/watch?v='+vid,startSeconds=start,endSeconds=end,clipPath=str(out),posterPath=str(poster),coordinateEvidence=coord,coordinateFrame=str(root/proof),inventoryEvidence=inventory,status='pending-final-visual-review',mapOverlayVisible=False,inventoryOverlayVisible=False,rightsBasis='licensed',rightsEvidence='Trusted prior human confirmation: Duyệt,a có giấy phép hết; each new source triple-gated --apply --approval VIDEOID --rights licensed.',sourcePlane='Genesis Part 1 ASA Ocean coordinate plane' if map.endswith('ocean') else 'Genesis Part 1 ASA land coordinate plane: Arctic',sourceScope='ASA dedicated resource guide, July 2026',asaCompatibility='Source title explicitly identifies Ark Ascended Genesis 1',visualReview=dict(contactSheet=str(sheetPath),continuousShot=True,fullEncodedDecode=decode.returncode==0,decodedEveryFrame=True,mapOverlayVisible=False,inventoryOverlayVisible=False)))
(root/'reviewed-additions.json').write_text(json.dumps(dict(schemaVersion=1,candidates=entries),indent=2))
