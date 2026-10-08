import sys,subprocess
from pathlib import Path
from PIL import Image,ImageDraw
vid=sys.argv[1];out=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/farming33/root');base=Path('/Volumes/TONY SSD/TONY_WORKSPACE/CODE/TonyOS_Workspace/tools/youtube-intelligence/data/downloads');fs=[p for p in base.glob(vid+'*') if '.mp4' in p.name]
if not fs:print('no source');raise SystemExit()
src=max(fs,key=lambda p:p.stat().st_size);d=out/(vid+'-frames');d.mkdir(exist_ok=True)
subprocess.run(['ffmpeg','-v','error','-i',str(src),'-t','120','-vf','fps=0.5,scale=320:-1','-y',str(d/'%03d.jpg')],capture_output=True)
ims=sorted(d.glob('*.jpg'));s=Image.new('RGB',(1280,200*((len(ims)+3)//4)))
for i,p in enumerate(ims):s.paste(Image.open(p),((i%4)*320,(i//4)*200));ImageDraw.Draw(s).text(((i%4)*320+5,(i//4)*200+180),str(i*2)+'s',fill='white')
s.save(out/(vid+'-context.jpg'));print('frames',len(ims),src.name)
