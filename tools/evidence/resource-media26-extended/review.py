import json, subprocess,io
from PIL import Image,ImageDraw
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
R=Path(__file__).resolve().parents[3];P=json.load(open('/Volumes/TONY SSD/ASCENDED_MEDIA/resource-clip-review/paths.json'));G={g['spotID']:g for g in json.load(open(R/'native/Ascended/Resources/resource-guides.json'))['guides']}
ranges={'rag-cactus-route':(739,777),'island-redwood-fiber':(400,469),'rag-black-pearl-bed':(150,189),'rag-cave-metal-obsidian':(516,546),'rag-silk-fields':(1057,1110),'rag-sulfur-rocks':(1110,1166),'island-east-dam-rares':(276,336),'extinction-oil-lake':(0,63),'rag-blue-gem-cavern':(1166,1208)}
def go(item):
 n,(a,b)=item;raw=subprocess.run(['ffmpeg','-v','error','-ss',str(a),'-i',P[G[n]['videoID']],'-t',str(b-a),'-vf','fps=1,scale=320:180','-f','image2pipe','-vcodec','mjpeg','-'],capture_output=True).stdout; frames=raw.split(b'\xff\xd8')[1:];im=Image.new('RGB',(1600,200*((len(frames)+4)//5)));d=ImageDraw.Draw(im)
 for j,f in enumerate(frames):
  x=j%5*320;y=j//5*200;im.paste(Image.open(io.BytesIO(b'\xff\xd8'+f)),(x,y));d.text((x+4,y+182),f'{n} @{a+j}s',fill='white')
 im.save(R/f'tools/evidence/resource-media26-extended/{n}-chapter.jpg');print(n,len(frames),flush=True)
list(ThreadPoolExecutor(max_workers=4).map(go,ranges.items()))
