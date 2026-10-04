#!/usr/bin/env python3
"""Build source-native 1080p silent loops from the already reviewed GIF recipes.
Output stays in a staging directory until all 467 clips finish. Never upscales.
"""
import argparse, concurrent.futures, hashlib, json, subprocess
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument('--source-root',type=Path,required=True)
p.add_argument('--output',type=Path,required=True)
a=p.parse_args();root=Path(__file__).resolve().parents[1];a.output.mkdir(parents=True,exist_ok=True)
profile='1080p-source-fps/hevc_videotoolbox/q60/hvc1/no-audio/v2'
records=[];sources={}
for recipe_path in sorted((root/'docs/codex-reports').glob('*-gif-recipe.json')):
 d=json.loads(recipe_path.read_text())
 for g in d['guides']:
  for s in g['sections']:
   for x in s['steps']:
    assert x['visuallyReviewed'],x['id']
    source=a.source_root/(x['videoID']+'.mp4')
    assert source.is_file() and not source.is_symlink(),source
    if x['videoID'] not in sources:
     info=json.loads(subprocess.check_output(['ffprobe','-v','error','-select_streams','v:0','-show_entries','stream=width,height,r_frame_rate:format=duration','-of','json',str(source)]))
     assert info['streams'][0]['width']>=1920 and info['streams'][0]['height']>=1080,source
     sources[x['videoID']]={'sha256':hashlib.file_digest(source.open('rb'),'sha256').hexdigest(),'duration':float(info['format']['duration']),'fps':info['streams'][0]['r_frame_rate']}
    assert 0 <= x['start'] < x['end'] <= sources[x['videoID']]['duration']
    assert (x['end']-x['start'])/x.get('speed',1)<=16
    name=x['gif']
    key=hashlib.sha256(json.dumps([sources[x['videoID']]['sha256'],x['start'],x['end'],x.get('speed',1),profile]).encode()).hexdigest()
    records.append((name,source,x,key,sources[x['videoID']]['fps']))
def render(record):
 name,source,x,key,source_fps=record;movie=a.output/(name+'.mp4');poster=a.output/(name+'.jpg');stamp=a.output/(name+'.key')
 if not(movie.exists() and poster.exists() and stamp.exists() and stamp.read_text()==key):
  temp=a.output/(name+'.tmp.mp4')
  vf=f"setpts=(PTS-STARTPTS)/{x.get('speed',1)},fps={min(60,float(source_fps.split('/')[0])/float(source_fps.split('/')[1])*x.get('speed',1))},scale=1920:1080:flags=bicubic"
  subprocess.run(['ffmpeg','-y','-v','error','-ss',str(x['start']),'-t',str(x['end']-x['start']),'-i',str(source),'-an','-vf',vf,'-c:v','hevc_videotoolbox','-q:v','60','-tag:v','hvc1','-pix_fmt','yuv420p','-movflags','+faststart',str(temp)],check=True)
  subprocess.run(['ffmpeg','-y','-v','error','-ss',str(x['start']+.2),'-i',str(source),'-frames:v','1','-vf','scale=1920:1080:flags=bicubic','-q:v','3',str(poster)],check=True)
  temp.replace(movie);stamp.write_text(key)
 return {'name':name,'videoID':x['videoID'],'start':x['start'],'end':x['end'],'speed':x.get('speed',1),'renderKey':key,'fps':min(60,float(source_fps.split('/')[0])/float(source_fps.split('/')[1])*x.get('speed',1)),'bytes':movie.stat().st_size}
results=[]
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
 for result in pool.map(render,records):
  results.append(result)
  print(f"{len(results)}/{len(records)} {result['name']} {result['bytes']}",flush=True)
(a.output/'render-manifest.json').write_text(json.dumps({'profile':profile,'sources':sources,'clips':results},indent=2)+'\n')
print('COMPLETE',len(results),sum(x['bytes'] for x in results),flush=True)
