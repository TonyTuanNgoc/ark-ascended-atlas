import subprocess,pathlib,json,hashlib,copy
E=pathlib.Path('/Users/admin/Ascended-iPad-Dev/tools/evidence/farming34/local-more');D=pathlib.Path('/Volumes/TONY SSD/ASCENDED_MEDIA/farming34/local-more');S='/Volumes/TONY SSD/ASCENDED_MEDIA/resource-sources/fynix-avc/0i0-XEV85m8.mp4'
def sha(p):
 with open(p,'rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
h=sha(S);base=json.load(open('/Users/admin/Ascended-iPad-Dev/tools/evidence/farming34/local/reviewed-additions.json'))['candidates'][0];rows=json.load(open(E/'intervals.json'));out=[]
names=['Southwestern seabed oil shelf','Southern flooded cave polymer plants','Highland boulder field rare flowers','Desert red rock rare flower ledges','Southeastern seabed silica pearl pocket','Southeastern seabed black pearl bed']
proofs=['Black oil deposits with bubble trails on a stratified underwater rock shelf in the Oil chapter.','Pink organic polymer plants beside the flooded southern cave pool in the Polymer chapter.','Blue rare flower plants between highland boulders in the Rare Flowers chapter.','Blue flower plants on the red rock ledges in the Rare Flowers chapter.','Bright clam pearl nodes between the seabed rocks in the Silica Pearls chapter.','Dark rounded black pearl nodes on the southeastern seabed in the Black Pearls chapter.']
for row,name,proof in zip(rows,names,proofs):
 id,r,lat,lon,a,b,g=row
 if r=='Organic Polymer':g=794
 p=D/(id+'.mp4');poster=D/(id+'.jpg')
 subprocess.run(['ffmpeg','-v','error','-i',str(p),'-f','null','-'],check=True)
 m=json.loads(subprocess.check_output(['ffprobe','-v','error','-show_entries','format=duration:stream=codec_name,codec_type','-of','json',str(p)]))
 assert 6<=float(m['format']['duration'])<=10 and len(m['streams'])==1 and m['streams'][0]['codec_name']=='h264'
 c=copy.deepcopy(base);c.update(id=id,name=name,resources=[r],lat=lat,lon=lon,startSeconds=a,endSeconds=b,clipPath=str(p),posterPath=str(poster),sourcePath=S,sourceSHA256=h,clipSHA256=sha(p),posterSHA256=sha(poster),coordinateEvidence=f'Creator explicitly captions Coordinates {lat} Latitude {lon} Longitude over this filmed region at source{g}s. Numeric creator caption used, not M-map cursor interpretation.',inventoryEvidence=proof+' No guaranteed yield or node availability claim.',encodedDurationSeconds=float(m['format']['duration']))
 c['visualReview'].update(contactSheet=str(E/(id+'-contact.jpg')),coordinateFrame=str(E/(id+'-coordinate.jpg')),result='Final encoded chronological4fps frames manually reviewed: continuous resource/terrain shot, no map, creator caption, inventory or edit cut. Full uncropped GPS proof retained separately.')
 out.append(c)
rejected=[{'resource':'Rare Flowers','coords':[63.6,44.2],'reason':'Captioned beehive/exchange structure, followed by brief interior footage; no reviewed6s direct wild resource proof. Not relabelled as Honey.'},{'resource':'Rare Mushrooms','sourceBounds':[871,918],'reason':'Harvest footage and overview M-map but creator supplies no matching numeric GPS caption; title obscures lower map readout and cursor not accepted.'},{'resource':'Sap','sourceBounds':[924,983],'reason':'Tapped trees filmed, no numeric creator GPS for new sites; M-map cursor not used.'},{'resource':'Giant Bee Honey / Chitin / Cementing Paste','sourceBounds':[0,1269.78],'reason':'No additional dedicated GPS-labelled independent sites in this complete guide; beaver dam demonstration around900s has no numeric label and cannot be counted.'}]
json.dump({'candidates':out,'rejected':rejected,'reviewedSourceDurationSeconds':1269.78322,'networkRequests':0,'newDownloads':0},open(E/'reviewed-additions.json','w'),indent=2)
for t,name in [(853,'rejected-exchange'),(875,'rejected-mushroom-map'),(948,'rejected-sap-map')]:subprocess.run(['ffmpeg','-v','error','-ss',str(t),'-i',S,'-frames:v','1','-y',str(E/(name+'.jpg'))],check=True)
for pattern in ['survey-*.jpg','oil.jpg','poly-flowers-*.jpg','pearls.jpg','late-*.jpg','early.jpg','black.jpg']:
 for p in E.glob(pattern):p.unlink()
print('verified',len(out),h)
