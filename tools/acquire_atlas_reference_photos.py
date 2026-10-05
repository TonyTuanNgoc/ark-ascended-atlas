"""Download only exact photo references returned by ASA Wiki entrance records."""
import hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];p=ROOT/'native/Ascended/Resources/map-reference-locations.json';d=json.loads(p.read_text());count=0
for x in d['locations']:
 if not x.get('photoURL') or x.get('imageAsset'):continue
 r=subprocess.run(['curl','-fLs','--max-time','30',x['photoURL']],capture_output=True)
 if r.returncode:
  print('Source refused; stop',x['id'],r.returncode);break
 # Never accept error HTML as a photograph.
 if not r.stdout.startswith(b'\xff\xd8'):
  print('Not JPEG; stop',x['id']);break
 a='ReferencePhoto-'+x['id'];folder=ROOT/'native/Ascended/Assets.xcassets'/(a+'.imageset');folder.mkdir(exist_ok=True);(folder/'image.jpg').write_bytes(r.stdout);(folder/'Contents.json').write_text(json.dumps(dict(images=[dict(filename='image.jpg',idiom='universal')],info=dict(author='xcode',version=1)),indent=2)+'\n');x.update(imageAsset=a,photoStatus='downloadedSourceReference',photoSHA256=hashlib.sha256(r.stdout).hexdigest());count+=1
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n');print(count,'new photos')
