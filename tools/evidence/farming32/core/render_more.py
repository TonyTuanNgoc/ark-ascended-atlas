import json,subprocess,pathlib,io,hashlib
from PIL import Image,ImageDraw
out=pathlib.Path('/Volumes/TONY SSD/ASCENDED_MEDIA/farming32/core');ev=pathlib.Path('/Users/admin/Ascended-iPad-Dev/tools/evidence/farming32/core');paths=json.load(open('/Volumes/TONY SSD/ASCENDED_MEDIA/resource-clip-review/paths.json'))
rows=[
('rag-waterfall-cave-black','Waterfall cave Black Pearls','Black Pearls',21.3,24.6,130,138,122),
('rag-northwest-blue-black','Northwestern blue cavern','Black Pearls',8.2,14.5,157.5,165.5,152),
('rag-north-cavern-black','Northern cavern pearl bed','Black Pearls',6.2,63,180,188,175),
('rag-ice-water-crystal','Ice-water crystal cavern','Crystal',31.1,33.7,360,368,352),
('rag-northeast-crystal','Northeastern crystal ridge','Crystal',6.5,87.7,385,393,380),
('rag-northeast-metal','Northeastern metal plateau','Metal',7.1,86.3,455.75,461.75,450),
('rag-southwest-metal','Southwestern metal bluff','Metal',78.3,21.6,471.5,477.5,465),
('rag-volcanic-obsidian','Volcanic obsidian ridge','Obsidian',23.2,62.6,543,549,537),
('rag-north-coast-oil','Northern coast oil rocks','Oil',11.1,40.7,605,613,596),
('rag-southeast-seafloor-oil','Southeastern seafloor oil bed','Oil',79,71.1,670,678,665),
('rag-waterfall-polymer','Waterfall cave organic polymer','Organic Polymer',22.7,29.5,722,728,718),
('rag-northeast-polymer','Northeastern water cave polymer','Organic Polymer',22.6,85.4,763,769,758),
('rag-canyon-polymer','Canyon cave organic polymer','Organic Polymer',67.4,42.4,781,789,775),
('rag-green-cavern-silica','Green cavern Silica Pearls','Silica Pearls',21.8,33.1,1008,1016,1005),
('rag-west-seafloor-silica','Western seafloor Silica Pearls','Silica Pearls',74.2,31.2,1043,1049,1038),
('rag-northeast-silk','Northeastern silk flower field','Silk',11.7,83.7,1077,1083,1072),
('rag-southwest-sulfur','Southwestern sulfur rocks','Sulfur',77.5,27.5,1133,1139,1130),
]
rows=[r for r in rows if r[0] in {'rag-northwest-blue-black','rag-ice-water-crystal','rag-northeast-metal','rag-southwest-metal','rag-southeast-seafloor-oil','rag-northeast-polymer','rag-canyon-polymer','rag-west-seafloor-silica'}]
ledger=[];vid='0i0-XEV85m8'
for id,name,res,lat,lon,start,end,gps in rows:
 mp=out/(id+'.mp4');poster=out/(id+'.jpg');coord=out/(id+'-coordinates.jpg')
 subprocess.run(['ffmpeg','-v','error','-y','-ss',str(start),'-i',paths[vid],'-t',str(end-start),'-an','-vf','scale=1280:720,fps=24','-c:v','libx264','-preset','veryfast','-crf','20','-pix_fmt','yuv420p','-movflags','+faststart',str(mp)],check=True)
 subprocess.run(['ffmpeg','-v','error','-y','-i',str(mp),'-frames:v','1',str(poster)],check=True)
 subprocess.run(['ffmpeg','-v','error','-y','-ss',str(gps),'-i',paths[vid],'-frames:v','1',str(coord)],check=True)
 raw=subprocess.run(['ffmpeg','-v','error','-i',str(mp),'-vf','fps=4,scale=320:180','-f','image2pipe','-vcodec','mjpeg','-'],capture_output=True,check=True).stdout
 frames=raw.split(b'\xff\xd8')[1:];sheet=Image.new('RGB',(1280,200*((len(frames)+3)//4)));d=ImageDraw.Draw(sheet)
 for i,b in enumerate(frames):
  x=i%4*320;y=i//4*200;sheet.paste(Image.open(io.BytesIO(b'\xff\xd8'+b)),(x,y));d.text((x+2,y+180),str(start+i*.25),fill='white')
 review=out/(id+'-review.jpg');sheet.save(review)
 probe=json.loads(subprocess.run(['ffprobe','-v','error','-show_format','-of','json',str(mp)],capture_output=True,check=True).stdout)
 subprocess.run(['ffmpeg','-v','error','-xerror','-i',str(mp),'-f','null','-'],check=True)
 ledger.append(dict(id=id,map='ragnarok',name=name,resources=[res],lat=lat,lon=lon,videoID=vid,startSeconds=start,endSeconds=end,coordinateEvidence='Creator coordinate caption over filmed location immediately before clean terrain segment',coordinateEvidenceSeconds=gps,coordinateImage=str(coord),sourceURL=f'https://www.youtube.com/watch?v={vid}',sourcePath=paths[vid],rightsBasis='licensed',rightsApproval='Human persistent confirmation: Duyet, a co giay phep het; parent reconfirmed licensed cache reuse',acquisitionState='approved-complete-local-cache',moviePath=str(mp),posterPath=str(poster),reviewSheet=str(review),durationSeconds=float(probe['format']['duration']),fullDecodePassed=True,sha256=hashlib.sha256(mp.read_bytes()).hexdigest(),visualReviewStatus='pending',asaCompatibilityEvidence='Source title card explicitly reads ARK Ragnarok Ascended Ultimate Resource Guide',sourceCoordinateScope='Creator-labelled filmed farming region, not individual node GPS',evidenceLimitations='Creator coordinates locate the filmed region; no guaranteed yield or permanent spawns. Coordinate overlay is retained separately from clean preview.',inventoryEvidence='Creator resource chapter shows nodes or resource bed in this filmed region.'))
(ev/'more-draft.json').write_text(json.dumps(ledger,indent=2)+'\n');print('rendered',len(ledger))
