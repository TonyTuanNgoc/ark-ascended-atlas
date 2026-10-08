import pathlib,json,subprocess,io
from PIL import Image,ImageDraw
p=pathlib.Path('/Users/admin/Ascended-iPad-Dev/tools/evidence/farming32/story');paths=json.loads(pathlib.Path('/Volumes/TONY SSD/ASCENDED_MEDIA/resource-clip-review/paths.json').read_text())
for id,secs in [('k9IOWvnWMdg',[57,58,59,60,61]),('BZVk5xrksxk',[43,44,45,46,47]),('WKNYEAeuSDA',[68,69,70,71]),('85xkdr_UYAo',[24,25,26,27,28,29,30,31,32,33,34])]:
 for t in secs:
  out=p/(id+f'-{t}.jpg');subprocess.run(['ffmpeg','-v','error','-y','-ss',str(t),'-i',paths[id],'-frames:v','1','-vf','scale=1920:-1',str(out)],capture_output=True)
