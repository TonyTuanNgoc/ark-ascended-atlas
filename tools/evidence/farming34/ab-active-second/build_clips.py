import hashlib,json,subprocess,shutil
from pathlib import Path
src=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/farming34/browser-recording/TUoB8ouWPYk-active-2x.mp4');out=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/farming34/ab-active-second');ev=Path('/Users/admin/Ascended-iPad-Dev/tools/evidence/farming34/ab-active-second')
specs=[('aberration-trench-black-676-52',667.8,7.1,665),('aberration-blue-crystal-487-786',569,8,563),('aberration-red-crystal-45-367',601,8,596),('aberration-polymer-617-729',958,4.9,955),('aberration-honey-441-31',1250.5,7.4,1260),('aberration-honey-382-39',1263,4.5,1269)]
for id,t,d,gps in specs:
 clip=out/f'{id}.mp4';poster=out/f'{id}.jpg'
 subprocess.run(['ffmpeg','-loglevel','error','-y','-ss',str(12.251+(t-.068941)/2),'-t',str(d/2),'-i',str(src),'-an','-vf','setpts=2*(PTS-STARTPTS),fps=30','-c:v','libx264','-crf','18','-pix_fmt','yuv420p','-movflags','+faststart',str(clip)],check=True)
 subprocess.run(['ffmpeg','-loglevel','error','-y','-ss',str(d*.5),'-i',str(clip),'-frames:v','1','-pix_fmt','yuvj420p','-threads','1','-q:v','2',str(poster)],check=True)
 shutil.copy(ev/f'detail-{gps}.jpg',ev/f'{id}-coordinate.jpg')
 subprocess.run(['ffmpeg','-loglevel','error','-y','-i',str(clip),'-vf','fps=4,scale=296:166,tile=4x8','-frames:v','1','-pix_fmt','yuvj420p','-threads','1',str(ev/f'{id}-contact.jpg')],check=True)
 subprocess.run(['ffmpeg','-v','error','-i',str(clip),'-f','null','-'],check=True)
h=hashlib.sha256()
with src.open('rb') as f:
 while b:=f.read(8*1024*1024):h.update(b)
(ev/'capture-clock-evidence.json').write_text(json.dumps({'sourcePath':str(src),'sourceSHA256':h.hexdigest(),'sourceDimensions':[1184,666],'captureFirstFrameUTC':'2026-10-08T05:12:34.963Z','sourceAnchor':{'sourceSeconds':0.068941,'UTC':'2026-10-08T05:12:47.214Z'},'formula':'movieSeconds = 12.251 + (sourceSeconds - 0.068941) / 2','independentProgressCheck':{'sourceSeconds':896.438464,'UTC':'2026-10-08T05:20:15.396Z'},'acquisitionProof':'Parent confirmed native active Chrome source/address, moving preflight, and independent source-time check; valid active capture only. No rejected frozen part1/part2 used.','clipConversion':'Cut actual capture seconds, setpts=2 restoring natural 1x source motion; silent H264 clips; no interpolation, looping or fabricated location.'},indent=2))
print('clips generated; sourceSHA256',h.hexdigest())
