import json, subprocess, hashlib
from pathlib import Path
ROOT=Path('/Users/admin/Ascended-iPad-Dev'); RES=ROOT/'native/Ascended/Resources/verified-resource-spots.json'; AS=ROOT/'native/Ascended/Assets.xcassets'; SRC=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/resource-sources')
spots=[]
def add(id,map,name,lat,lon,resources,video,photo,gps,direction,method,kit,risks,evidence):
 asset='FarmPhoto-'+id; out=AS/(asset+'.imageset');out.mkdir(exist_ok=True)
 subprocess.run(['ffmpeg','-v','error','-y','-ss',str(photo),'-i',str(SRC/(video+'.mp4')),'-frames:v','1','-vf','scale=1280:-1','-q:v','3',str(out/'photo.jpg')],check=True)
 (out/'Contents.json').write_text(json.dumps({'images':[{'filename':'photo.jpg','idiom':'universal'}],'info':{'author':'xcode','version':1}},indent=2))
 spots.append(dict(id=id,map=map,name=name,lat=lat,lon=lon,resources=resources,imageAsset=asset,videoID=video,seconds=photo,direction=direction,method=method,kit=kit,risks=risks,verified=True,sourceURL='https://www.youtube.com/watch?v='+video,photoSHA256=hashlib.sha256((out/'photo.jpg').read_bytes()).hexdigest(),coordinateEvidence=f'In-game map camera GPS visible at {gps}s: latitude {lat}, longitude {lon}. Pin identifies the filmed farming region, not every individual resource actor.',inventoryEvidence=evidence))
old=json.loads(RES.read_text());ids={s['id'] for s in spots};spots=[s for s in old.get('spots',[]) if s['id'] not in ids]+spots
RES.write_text(json.dumps({'spots':spots,'coverage':old.get('coverage',[])},ensure_ascii=False,indent=2))
print(len(spots),'spots written')
