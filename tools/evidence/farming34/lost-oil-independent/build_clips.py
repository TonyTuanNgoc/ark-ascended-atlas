import subprocess,hashlib,json,shutil
from pathlib import Path
src=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/farming34/browser-recording/LKOZNBaoCpc-active-2x.mp4');out=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/farming34/lost-oil-independent');ev=Path('/Users/admin/Ascended-iPad-Dev/tools/evidence/farming34/lost-oil-independent')
specs=[('lost-colony-safe-cave-oil-656-483',65,8,60),('lost-colony-central-river-oil-595-586',104.75,6,96)]
for id,t,d,gps in specs:
 clip=out/f'{id}.mp4';poster=out/f'{id}.jpg'
 subprocess.run(['ffmpeg','-loglevel','error','-y','-ss',str(12.383+(t-.04244)/2),'-t',str(d/2),'-i',str(src),'-an','-vf','crop=1100:520:0:60,setpts=2*(PTS-STARTPTS),fps=30','-c:v','libx264','-crf','18','-pix_fmt','yuv420p','-movflags','+faststart',str(clip)],check=True)
 subprocess.run(['ffmpeg','-loglevel','error','-y','-ss','4','-i',str(clip),'-frames:v','1','-pix_fmt','yuvj420p','-threads','1','-q:v','2',str(poster)],check=True)
 shutil.copy(ev/f'source-{gps}.jpg',ev/f'{id}-coordinate.jpg')
 subprocess.run(['ffmpeg','-loglevel','error','-y','-i',str(clip),'-vf','fps=4,scale=275:130,tile=4x8','-frames:v','1','-pix_fmt','yuvj420p','-threads','1',str(ev/f'{id}-contact.jpg')],check=True)
 r=subprocess.run(['ffmpeg','-v','error','-i',str(clip),'-f','null','-'],capture_output=True,text=True,check=True);(ev/f'{id}-decode.txt').write_text(r.stderr or 'Complete encodedclip decode, exit0, no diagnostics.\n')
h=hashlib.sha256()
with src.open('rb') as f:
 while b:=f.read(8*1024*1024):h.update(b)
(ev/'capture-clock-evidence.json').write_text(json.dumps({'sourcePath':str(src),'sourceSHA256':h.hexdigest(),'sourceDimensions':[1184,666],'captureFirstFrameUTC':'2026-10-08T05:54:38.486Z','sourceAnchor':{'sourceSeconds':0.04244,'UTC':'2026-10-08T05:54:50.869Z'},'formula':'movieSeconds = 12.383 + (sourceSeconds -0.04244) /2','sourceDurationSeconds':140,'captureDurationSeconds':100.286,'parentAcquisitionProof':'Isolated nativeChrome window553; activeURL/title plus video0terrain/Oilrock confirmed; expectedtitle WhereToFindOil matched; avgMAD7.93/no stagnationwarning;2935frames.','fullCaptureDecode':{'completed':True,'exitCode':0,'diagnostics':'Screen recording variable timestamps produce nonmonotonicallyincreasingDTS warnings in null muxer; no unreadablevideo packets reported. Delivery clips normalizefps30 and decodewith no diagnostics.'},'clipConversion':'Cut actual capture seconds and setpts=2 restores natural1x source motion; no looping/interpolation.'},indent=2))
print('generated2clips',h.hexdigest())
