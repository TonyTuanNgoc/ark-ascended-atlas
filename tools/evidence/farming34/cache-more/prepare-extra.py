import pathlib,subprocess,json,hashlib,concurrent.futures
R=pathlib.Path('/Users/admin/Ascended-iPad-Dev/tools/evidence/farming34/cache-more'); O=pathlib.Path('/Volumes/TONY SSD/ASCENDED_MEDIA/farming34/cache-more'); O.mkdir(parents=True,exist_ok=True)
S=next(pathlib.Path('/Volumes/TONY SSD/ASCENDED_MEDIA/resource-sources').rglob('d3d4cAzEpr0.mp4'))
rows=[('Oil',56.8,24.6,329,335),('Silica Pearls',51,12.1,425,431)]
#original=[('Metal',41,32,41.5,47.5),('Metal',15,50.3,50,56),('Metal',28,85.6,65,71),('Metal',84.3,89,75,83),('Metal',95,69.6,84.5,90.5),('Metal',89,47.7,92,98),('Metal',88,32.2,99,105),('Metal',52.7,42,106.5,112.5),('Metal',52.3,69.2,120,126),('Metal',41.3,61,129,135),('Metal',69.6,89,155,163),('Obsidian',64,68.7,178,186),('Obsidian',15,50.3,191,197),('Obsidian',40,91.2,212,218),('Crystal',85.6,37.9,237.5,243.5),('Crystal',69,96.3,254,260),('Crystal',19.3,85.7,262,268),('Crystal',15,50.3,268,274),('Crystal',29.1,53.9,275,281),('Crystal',66,73.7,294,300),('Oil',49.2,98,316,322),('Oil',41.5,32,324,332),('Oil',56.8,24.6,335,341),('Oil',36.5,60,343,349),('Silica Pearls',44.6,64,375,381),('Silica Pearls',20,49.8,383,391),('Silica Pearls',64.8,92,393,399),('Silica Pearls',43.7,32,401,409),('Silica Pearls',45.1,99,412,419)]
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
sourcehash=h(S)
def go(row):
 res,lat,lon,a,b=row; id='center-cache-'+res.lower().replace(' ','-')+'-'+str(lat).replace('.','')+'-'+str(lon).replace('.','')
 clip=O/(id+'.mp4'); poster=O/(id+'.jpg'); proof=R/(id+'-coordinate.jpg'); contact=R/(id+'-contact.jpg')
 def run(cmd):subprocess.run(cmd,check=True,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
 run(['ffmpeg','-v','error','-ss',str(a),'-i',str(S),'-t',str(b-a),'-vf','crop=1360:1080:560:0,scale=960:-2','-an','-c:v','libx264','-preset','fast','-crf','21','-pix_fmt','yuv420p','-movflags','+faststart','-y',str(clip)])
 run(['ffmpeg','-v','error','-i',str(clip),'-f','null','-'])
 run(['ffmpeg','-v','error','-ss','2','-i',str(clip),'-frames:v','1','-y',str(poster)])
 run(['ffmpeg','-v','error','-ss',str(a+2),'-i',str(S),'-frames:v','1','-y',str(proof)])
 run(['ffmpeg','-v','error','-i',str(clip),'-vf','fps=4,scale=320:-1,tile=8x4','-frames:v','1','-y',str(contact)])
 return dict(id=id,map='the-center',name=f'Center {res.lower()} region {lat}/{lon}',resources=[res],lat=lat,lon=lon,videoID='d3d4cAzEpr0',startSeconds=a,endSeconds=b,coordinateEvidence=f'Creator numeric caption {lat} Lat, {lon} Lon over filmed {res} region at source {a+2}s; no map cursor inference.',inventoryEvidence=f'Visible {res} deposits in explicitly titled {res} segment; no guaranteed yield.',clipPath=str(clip),posterPath=str(poster),sourceURL='https://www.youtube.com/watch?v=d3d4cAzEpr0',sourcePlane='The Center ASA coordinate plane',sourceCoordinateScope='Creator-labelled farming region',mapOverlayVisible=False,creatorInsetVisible=False,inventoryOverlayVisible=False,rightsBasis='licensed',acquisitionState='Previously approved complete licensed local source; no network acquisition in farming34',sourcePath=str(S),sourceSHA256=sourcehash,clipSHA256=h(clip),posterSHA256=h(poster),visualReview=dict(contactSheet=str(contact),coordinateFrame=str(proof),fullEncodedDecode=True,sampleRateFPS=4,continuousShot=True,reviewed=False,result='Pending manual review'),evidenceLimitations='Creator-labelled regional waypoint; no permanent node count or guaranteed availability. Creator inset removed from delivered video; uncropped source GPS proof retained.',visualReviewStatus='pending',sourceCrop=dict(x=560,y=0,width=1360,height=1080,sourceWidth=1920,sourceHeight=1080,reason='Remove creator map and resource/GPS inset.'),encodedDurationSeconds=b-a)
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as e: candidates=list(e.map(go,rows))
(R/'extra-pending.json').write_text(json.dumps(dict(candidates=candidates),indent=2)+'\n')
print('prepared',len(candidates))
