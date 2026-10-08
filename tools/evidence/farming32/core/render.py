import json,subprocess,pathlib,io,hashlib
from PIL import Image,ImageDraw
out=pathlib.Path('/Volumes/TONY SSD/ASCENDED_MEDIA/farming32/core');ev=pathlib.Path('/Users/admin/Ascended-iPad-Dev/tools/evidence/farming32/core');paths=json.load(open('/Volumes/TONY SSD/ASCENDED_MEDIA/resource-clip-review/paths.json'))
rows=[
('island-north-central-pearls','North central snow pond','Silica Pearls',27.5,29.9,'0JqFIlmuq9o',51,59,47,'Creator coordinate overlay in North Central Pond segment'),
('island-north-coast-pearls','North coast pearl beach','Silica Pearls',9.1,30.7,'0JqFIlmuq9o',92,100,82,'Creator coordinate overlay in North Coast Beach segment'),
('island-north-peninsula-pearls','North coast peninsula','Silica Pearls',9.4,39.7,'0JqFIlmuq9o',122,130,112,'Creator coordinate overlay in North Coast Peninsula segment'),
('island-west-lake-flowers','Western lake Rare Flowers','Rare Flowers',79.8,17.1,'6d_iRk7tFBk',52,60,90,'In-game map GPS visible at 90s'),
('island-east-canyon-flowers','Eastern canyon flower route','Rare Flowers',44.1,76.3,'6d_iRk7tFBk',111,119,107,'In-game map GPS visible at 107s; camera overlooks river route followed to flower plants'),
('island-east-swamp-flowers','Eastern swamp flower route','Rare Flowers',54.8,85.1,'6d_iRk7tFBk',157,165,150,'In-game map GPS visible at 150s; camera overlooks swamp route followed in clip')]
ledger=[]
for id,name,res,lat,lon,vid,start,end,gps,evidence in rows:
 mp=out/(id+'.mp4');poster=out/(id+'.jpg');coord=out/(id+'-coordinates.jpg')
 subprocess.run(['ffmpeg','-v','error','-y','-ss',str(start),'-i',paths[vid],'-t',str(end-start),'-an','-vf','scale=1280:720,fps=24','-c:v','libx264','-preset','veryfast','-crf','20','-pix_fmt','yuv420p','-movflags','+faststart',str(mp)],check=True)
 subprocess.run(['ffmpeg','-v','error','-y','-i',str(mp),'-frames:v','1',str(poster)],check=True)
 subprocess.run(['ffmpeg','-v','error','-y','-ss',str(gps),'-i',paths[vid],'-frames:v','1',str(coord)],check=True)
 raw=subprocess.run(['ffmpeg','-v','error','-i',str(mp),'-vf','fps=4,scale=320:180','-f','image2pipe','-vcodec','mjpeg','-'],capture_output=True,check=True).stdout
 frames=raw.split(b'\xff\xd8')[1:];sheet=Image.new('RGB',(1280,200*((len(frames)+3)//4)));d=ImageDraw.Draw(sheet)
 for i,b in enumerate(frames):
  x=i%4*320;y=i//4*200;sheet.paste(Image.open(io.BytesIO(b'\xff\xd8'+b)),(x,y));d.text((x+2,y+180),str(start+i*.25),fill='white')
 review=out/(id+'-review.jpg');sheet.save(review)
 probe=json.loads(subprocess.run(['ffprobe','-v','error','-show_streams','-show_format','-of','json',str(mp)],capture_output=True,check=True).stdout)
 subprocess.run(['ffmpeg','-v','error','-xerror','-i',str(mp),'-f','null','-'],check=True)
 ledger.append(dict(id=id,map='the-island',name=name,resources=[res],lat=lat,lon=lon,videoID=vid,startSeconds=start,endSeconds=end,coordinateEvidence=evidence,coordinateEvidenceSeconds=gps,coordinateImage=str(coord),sourceURL=f'https://www.youtube.com/watch?v={vid}',sourcePath=paths[vid],rightsBasis='licensed',rightsApproval='Existing source acquisition ledger: User confirmed all source licenses; parent reconfirmed in-scope reuse',acquisitionState='approved-complete-local-cache',moviePath=str(mp),posterPath=str(poster),reviewSheet=str(review),durationSeconds=float(probe['format']['duration']),fullDecodePassed=True,sha256=hashlib.sha256(mp.read_bytes()).hexdigest(),visualReviewStatus='pending',asaCompatibilityEvidence='Existing inspected source explicitly titled ARK Survival Ascended The Island'))
(ev/'additions.json').write_text(json.dumps(ledger,indent=2)+'\n');print('rendered',len(ledger))
