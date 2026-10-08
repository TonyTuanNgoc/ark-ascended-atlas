import subprocess,hashlib,json,shutil
from pathlib import Path
src=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/farming34/browser-recording/Oxyw-jv19xQ-active-2x.mp4');out=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/farming34/lost-active');ev=Path('/Users/admin/Ascended-iPad-Dev/tools/evidence/farming34/lost-active')
specs=[('lost-colony-river-metal-crystal-859-313',59,8,56),('lost-colony-oil-cave-69-464',564,8,83),('lost-colony-river-metal-crystal-474-761',39,8,35)]
for id,t,d,gps in specs:
 clip=out/f'{id}.mp4';poster=out/f'{id}.jpg'
 subprocess.run(['ffmpeg','-loglevel','error','-y','-ss',str(8.743+(t-.046994)/2),'-t',str(d/2),'-i',str(src),'-an','-vf','crop=1184:514:0:76,setpts=2*(PTS-STARTPTS),fps=30','-c:v','libx264','-crf','18','-pix_fmt','yuv420p','-movflags','+faststart',str(clip)],check=True)
 subprocess.run(['ffmpeg','-loglevel','error','-y','-ss','4','-i',str(clip),'-frames:v','1','-pix_fmt','yuvj420p','-threads','1','-q:v','2',str(poster)],check=True)
 shutil.copy(ev/f'source-{gps}.jpg',ev/f'{id}-coordinate.jpg')
 subprocess.run(['ffmpeg','-loglevel','error','-y','-i',str(clip),'-vf','fps=4,scale=296:128,tile=4x8','-frames:v','1','-pix_fmt','yuvj420p','-threads','1',str(ev/f'{id}-contact.jpg')],check=True)
 subprocess.run(['ffmpeg','-v','error','-i',str(clip),'-f','null','-'],check=True)
h=hashlib.sha256()
with src.open('rb') as f:
 while b:=f.read(8*1024*1024):h.update(b)
(ev/'capture-clock-evidence.json').write_text(json.dumps({'sourcePath':str(src),'sourceSHA256':h.hexdigest(),'sourceDimensions':[1184,666],'captureFirstFrameUTC':'2026-10-08T05:25:56.702Z','sourceAnchor':{'sourceSeconds':0.046994,'UTC':'2026-10-08T05:26:05.445Z'},'formula':'movieSeconds = 8.743 + (sourceSeconds - 0.046994) / 2','sourceDurationSeconds':594.261,'parentAcquisitionProof':'Normal Chrome actual active address/native screenshot verified; expected-title v2 matched ALLE RESSOURCEN every15sec; moving capture averageMAD14.75; maxstatic23.6 at ended tail.','clipConversion':'Cut actual capture seconds and setpts=2 restores natural1x source motion; no looping/interpolation.'},indent=2))
print('generated3 clips',h.hexdigest())
