import json,subprocess,io
from pathlib import Path
from PIL import Image,ImageDraw
out=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/farming32/core');src=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/resource-sources/IOCye6IYUCM.mp4')
chap=json.load(open('/Users/admin/Ascended-iPad-Dev/tools/evidence/farming26-sources/inspect-island.json'))['chapters']
for c in chap[3:]:
 start=c['start'];end=c['end'];raw=subprocess.run(['ffmpeg','-v','error','-ss',str(start),'-i',str(src),'-t',str(end-start),'-vf','fps=1/4,scale=400:225','-f','image2pipe','-vcodec','mjpeg','-'],capture_output=True).stdout
 parts=raw.split(b'\xff\xd8')[1:];sheet=Image.new('RGB',(1600,245*((len(parts)+3)//4)));d=ImageDraw.Draw(sheet)
 for i,b in enumerate(parts):
  x=i%4*400;y=i//4*245;sheet.paste(Image.open(io.BytesIO(b'\xff\xd8'+b)),(x,y));d.text((x+3,y+225),str(start+i*4),fill='white')
 name=c['title'].replace(' ','-');sheet.save(out/(name+'.jpg'));print(name,len(parts))
