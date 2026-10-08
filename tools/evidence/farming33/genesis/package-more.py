import pathlib,subprocess,json,shutil
from PIL import Image,ImageDraw
root=pathlib.Path('/Users/admin/Ascended-iPad-Dev/tools/evidence/farming33/genesis')
media=pathlib.Path('/Volumes/TONY SSD/ASCENDED_MEDIA/farming33/genesis')
data=pathlib.Path('/Volumes/TONY SSD/TONY_WORKSPACE/CODE/TonyOS_Workspace/tools/youtube-intelligence/data/downloads')
rows=[('genesis-ocean-pearl-island-38-66', 'genesis-part-1-ocean', 'Eastern pearl island shallows', 'Silica Pearls', 38.4, 66.7, 'tAwMBQDx4NI', 24, 32, 'tAwMBQDx4NI-full40.jpg', 'Creator caption at 40s explicitly reads 38.4 LAT 66.7 LONG adjoining same island aerial shot.', 'Dedicated ASA Genesis silica guide identifies this filmed island as its first pearl location. Preview documents the island terrain; harvest yield not shown.'), ('genesis-ocean-coral-pearl-basin-57-56', 'genesis-part-1-ocean', 'Central coral pearl basin', 'Silica Pearls', 57.6, 56.62, 'EPEUyHqQSqY', 52, 58, 'EPEUyHqQSqY-full53.jpg', 'Actual underwater GPS at 53s and 58s reads 57.60 / 56.62. The earlier surface map at 40s is excluded because a teleport separates it from this underwater basin.', 'Dedicated ASA Genesis silica guide shows coral basin pearl farming terrain; nearby clam-like clusters appear around 60s. Harvest yield not shown; no resources beyond Silica Pearls claimed.'), ('genesis-ocean-southwest-shore-oil-89-15', 'genesis-part-1-ocean', 'Southwest island shore oil rocks', 'Oil', 89, 15.4, 'VeNGgP2eFj4', 35, 43, 'VeNGgP2eFj4-full30.jpg', 'In-game Ocean map at 30s reads LATITUDE 89 LONGITUDE 15.4 then closes to the same shoreline oil rocks.', 'Dedicated ASA Genesis Oil guide shows dark oil rocks scattered across shore and cliff. Terrain preview documents the resource rocks; harvest yield not shown.')]
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
(root/'more-additions.json').write_text(json.dumps(dict(schemaVersion=1,candidates=entries),indent=2))
