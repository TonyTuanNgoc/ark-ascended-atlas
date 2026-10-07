import json,subprocess,io
from pathlib import Path
from PIL import Image,ImageDraw
from concurrent.futures import ThreadPoolExecutor
ROOT=Path(__file__).resolve().parents[3]
paths=json.load(open('/Volumes/TONY SSD/ASCENDED_MEDIA/resource-clip-review/paths.json'))
guides=json.load(open(ROOT/'native/Ascended/Resources/resource-guides.json'))['guides']
sel=json.load(open(ROOT/'tools/resource_clip_selections.json'))
def go(pair):
 i,g=pair; start=max(0,int(sel[g['spotID']]['starts'][0])-3)
 raw=subprocess.run(['ffmpeg','-v','error','-ss',str(start),'-i',paths[g['videoID']],'-t','20','-vf','fps=1,scale=320:180','-f','image2pipe','-vcodec','mjpeg','-'],capture_output=True).stdout
 chunks=raw.split(b'\xff\xd8')[1:]; im=Image.new('RGB',(1600,800));d=ImageDraw.Draw(im)
 for j,b in enumerate(chunks[:20]):
  frame=Image.open(io.BytesIO(b'\xff\xd8'+b));x=j%5*320;y=j//5*200;im.paste(frame,(x,y));d.text((x+4,y+182),f'{g["spotID"]} @ {start+j}s',fill='white')
 im.save(ROOT/f'tools/evidence/resource-media26/{i:02}-{g["spotID"]}-context.jpg')
 print(i,g['spotID'],len(chunks),flush=True)
list(ThreadPoolExecutor(max_workers=4).map(go,enumerate(guides)))
