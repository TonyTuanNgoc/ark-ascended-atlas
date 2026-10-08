from pathlib import Path
import subprocess
from PIL import Image,ImageDraw
out=Path('/Users/admin/Ascended-iPad-Dev/tools/evidence/farming33/story')
cache=Path('/Volumes/TONY SSD/TONY_WORKSPACE/CODE/TonyOS_Workspace/tools/youtube-intelligence/data/downloads')
for vid in ['85xkdr_UYAo','tKK3AuwvUgU','YrTsOP-2Yjg','fEz7_AUMZEM']:
 sources=list(cache.glob(vid+'*.part'))
 if not sources:continue
 frames=out/vid;frames.mkdir(exist_ok=True)
 p=subprocess.run(['ffmpeg','-v','error','-i',str(sources[0]),'-vf','fps=1,scale=480:-1','-frames:v','65','-y',str(frames/'%03d.jpg')],capture_output=True,text=True)
 files=sorted(frames.glob('*.jpg'))
 for offset in range(0,len(files),20):
  chunk=files[offset:offset+20];sheet=Image.new('RGB',(1920,5*300))
  d=ImageDraw.Draw(sheet)
  for i,f in enumerate(chunk):
   im=Image.open(f);x=i%4*480;y=i//4*300;sheet.paste(im,(x,y));d.text((x+5,y+272),f'{int(f.stem)-1}s',fill='white')
  sheet.save(out/f'{vid}-{offset}-detail.jpg')
