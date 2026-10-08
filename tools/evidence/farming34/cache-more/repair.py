import json,pathlib,subprocess,hashlib
r=pathlib.Path('/Users/admin/Ascended-iPad-Dev/tools/evidence/farming34/cache-more'); data=json.load(open(r/'pending.json')); cs=data['candidates']
for ix,a,b in [(21,322,328),(22,337,343),(27,401,407),(28,411,417)]:
 c=cs[ix];c['startSeconds']=a;c['endSeconds']=b;c['encodedDurationSeconds']=b-a
 cmd=['ffmpeg','-v','error','-ss',str(a),'-i',c['sourcePath'],'-t',str(b-a),'-vf','crop=1360:1080:560:0,scale=960:-2','-an','-c:v','libx264','-preset','fast','-crf','21','-pix_fmt','yuv420p','-movflags','+faststart','-y',c['clipPath']];subprocess.run(cmd,check=True)
 for cmd in [['ffmpeg','-v','error','-i',c['clipPath'],'-f','null','-'],['ffmpeg','-v','error','-ss','2','-i',c['clipPath'],'-frames:v','1','-y',c['posterPath']],['ffmpeg','-v','error','-ss',str(a+2),'-i',c['sourcePath'],'-frames:v','1','-y',c['visualReview']['coordinateFrame']],['ffmpeg','-v','error','-i',c['clipPath'],'-vf','fps=4,scale=320:-1,tile=8x4','-frames:v','1','-y',c['visualReview']['contactSheet']]]:subprocess.run(cmd,check=True)
 for key,path in [('clipSHA256',c['clipPath']),('posterSHA256',c['posterPath'])]:c[key]=hashlib.sha256(pathlib.Path(path).read_bytes()).hexdigest()
(r/'pending.json').write_text(json.dumps(data,indent=2)+'\n')
