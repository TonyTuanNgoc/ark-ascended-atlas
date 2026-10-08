import pathlib,subprocess
from PIL import Image,ImageDraw
r=pathlib.Path('/Users/admin/Ascended-iPad-Dev/tools/evidence/farming33/genesis');data=pathlib.Path('/Volumes/TONY SSD/TONY_WORKSPACE/CODE/TonyOS_Workspace/tools/youtube-intelligence/data/downloads')
for v in ['uDDmWwwuEIs','9qoIySzkzxU','njcxSDzSves','tAwMBQDx4NI','EPEUyHqQSqY','VeNGgP2eFj4','N5YixYyZOHA','-A6rpnfcqtw']:
 fs=list(data.glob(v+'.mp4'))+list(data.glob(v+'*.part'))
 if not fs:continue
 c=Image.new('RGB',(960,720));d=ImageDraw.Draw(c)
 for i,t in enumerate([5,10,15,20,25,30,35,40,45,50,55,60]):
  p=r/f'{v}-{t}.jpg';subprocess.run(['ffmpeg','-v','error','-ss',str(t),'-i',str(fs[0]),'-frames:v','1','-vf','scale=320:180','-y',str(p)],capture_output=True)
  if p.exists():c.paste(Image.open(p),(i%3*320,i//3*180));d.text((i%3*320,i//3*180),str(t),fill='red')
 c.save(r/f'{v}-sheet.jpg')
 print(v,fs[0].name)
