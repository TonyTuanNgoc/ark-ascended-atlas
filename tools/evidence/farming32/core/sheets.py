import subprocess,io,json,sys
from pathlib import Path
from PIL import Image,ImageDraw
paths=json.load(open('/Volumes/TONY SSD/ASCENDED_MEDIA/resource-clip-review/paths.json'));out=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/farming32/core')
for vid in sys.argv[1:]:
 raw=subprocess.run(['ffmpeg','-v','error','-i',paths[vid],'-vf','fps=1/5,scale=400:225','-f','image2pipe','-vcodec','mjpeg','-'],capture_output=True).stdout
 parts=raw.split(b'\xff\xd8')[1:]
 for page in range((len(parts)+39)//40):
  chunk=parts[page*40:page*40+40];sheet=Image.new('RGB',(1600,245*((len(chunk)+3)//4)));d=ImageDraw.Draw(sheet)
  for i,b in enumerate(chunk):
   x=i%4*400;y=i//4*245;sheet.paste(Image.open(io.BytesIO(b'\xff\xd8'+b)),(x,y));d.text((x+3,y+225),str((i+page*40)*5),fill='white')
  sheet.save(out/f'{vid}-{page}.jpg')
 print(vid,len(parts),flush=True)
