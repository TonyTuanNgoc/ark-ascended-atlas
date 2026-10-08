import subprocess,pathlib,json
E=pathlib.Path('/Users/admin/Ascended-iPad-Dev/tools/evidence/farming34/local-more');D=pathlib.Path('/Volumes/TONY SSD/ASCENDED_MEDIA/farming34/local-more');S='/Volumes/TONY SSD/ASCENDED_MEDIA/resource-sources/fynix-avc/0i0-XEV85m8.mp4'
rows=[('rag-southwest-oil-793-368','Oil',79.3,36.8,655,662,655),('rag-south-polymer-936-489','Organic Polymer',93.6,48.9,789.5,796.5,794),('rag-highland-flowers-221-776','Rare Flowers',22.1,77.6,838,844,840),('rag-desert-flowers-611-553','Rare Flowers',61.1,55.3,858,866,862),('rag-southeast-silica-874-730','Silica Pearls',87.4,73,1049,1056,1050),('rag-southeast-black-944-917','Black Pearls',94.4,91.7,221.2,227.2,222)]
json.dump(rows,open(E/'intervals.json','w'),indent=2)
for id,r,lat,lon,a,b,g in rows:
 p=str(D/(id+'.mp4'))
 subprocess.run(['ffmpeg','-v','error','-ss',str(a),'-t',str(b-a),'-i',S,'-vf','crop=1380:960:540:120,scale=960:-2,fps=24','-an','-c:v','libx264','-crf','20','-preset','fast','-pix_fmt','yuv420p','-movflags','+faststart','-y',p],check=True)
 subprocess.run(['ffmpeg','-v','error','-i',p,'-vf','fps=4,scale=300:-1,tile=8x4','-frames:v','1','-y',str(E/(id+'-contact.jpg'))],check=True)
 subprocess.run(['ffmpeg','-v','error','-ss',str(g),'-i',S,'-frames:v','1','-y',str(E/(id+'-coordinate.jpg'))],check=True)
 subprocess.run(['ffmpeg','-v','error','-ss','2','-i',p,'-frames:v','1','-y',str(D/(id+'.jpg'))],check=True)
 print(id,flush=True)
