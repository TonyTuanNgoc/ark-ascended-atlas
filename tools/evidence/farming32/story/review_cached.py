import pathlib,json,subprocess,io
from PIL import Image,ImageDraw
p=pathlib.Path('/Users/admin/Ascended-iPad-Dev/tools/evidence/farming32/story');paths=json.loads(pathlib.Path('/Volumes/TONY SSD/ASCENDED_MEDIA/resource-clip-review/paths.json').read_text())
for id in ['k9IOWvnWMdg','85xkdr_UYAo','WKNYEAeuSDA','BZVk5xrksxk','a_Os1QOHqkE']:
 r=subprocess.run(['ffmpeg','-v','error','-i',paths[id],'-t','140','-vf','fps=1/3,scale=360:203','-f','image2pipe','-vcodec','mjpeg','-'],capture_output=True)
 frames=r.stdout.split(b'\xff\xd8')[1:];sheet=Image.new('RGB',(1800,225*((len(frames)+4)//5)));draw=ImageDraw.Draw(sheet)
 for i,b in enumerate(frames):
  x=i%5*360;y=i//5*225;sheet.paste(Image.open(io.BytesIO(b'\xff\xd8'+b)),(x,y));draw.text((x+3,y+204),f'{i*3+1.5:.1f}s approx',fill='white')
 if frames:sheet.save(p/(id+'-cached-context.jpg'))
 (p/(id+'-cached-decode.json')).write_text(json.dumps({'samples':len(frames),'stderr':r.stderr.decode(),'returncode':r.returncode}))
 print(id,len(frames))
