import subprocess, pathlib,json,hashlib
E=pathlib.Path('/Users/admin/Ascended-iPad-Dev/tools/evidence/farming34/ab-active-first');D=pathlib.Path('/Volumes/TONY SSD/ASCENDED_MEDIA/farming34/ab-active-first');S='/Volumes/TONY SSD/ASCENDED_MEDIA/farming34/browser-recording/TUoB8ouWPYk-active-2x.mp4'
rows=[('ab-portal-metal-438-293','Metal',43.8,29.3,46,49,52),('ab-portal-plateau-metal-418-345','Metal',41.8,34.5,62,65.5,60),('ab-surface-cave-metal-195-282','Metal',19.5,28.2,95.5,99.5,94),('ab-blue-slope-metal-414-604','Metal',41.4,60.4,131,135,130),('ab-blue-cavern-metal-503-755','Metal',50.3,75.5,138.5,142.5,137),('ab-element-obsidian-574-505','Obsidian',57.4,50.5,169.3,173.3,174),('ab-fertile-pearls-205-363','Silica Pearls',20.5,36.3,184.6,187.8,188.5),('ab-fertile-pearls-129-461','Silica Pearls',12.9,46.1,192.2,196.2,198),('ab-luminous-pearls-439-614','Silica Pearls',43.9,61.4,212,216,207)]
json.dump(rows,open(E/'draft-intervals.json','w'),indent=2)
for id,r,lat,lon,a,b,g in rows:
 p=str(D/(id+'.mp4'));subprocess.run(['ffmpeg','-v','error','-ss',str(a),'-t',str(b-a),'-i',S,'-vf','crop=1184:526:0:140,setpts=2*(PTS-STARTPTS),fps=30,scale=960:-2','-an','-c:v','libx264','-crf','20','-preset','fast','-pix_fmt','yuv420p','-movflags','+faststart','-y',p],check=True)
 subprocess.run(['ffmpeg','-v','error','-i',p,'-vf','fps=4,scale=300:-1,tile=8x4','-frames:v','1','-y',str(E/(id+'-contact.jpg'))],check=True)
 subprocess.run(['ffmpeg','-v','error','-ss',str(g),'-i',S,'-frames:v','1','-y',str(E/(id+'-coordinate.jpg'))],check=True)
 subprocess.run(['ffmpeg','-v','error','-ss','2','-i',p,'-frames:v','1','-y',str(D/(id+'.jpg'))],check=True)
 print(id,flush=True)
