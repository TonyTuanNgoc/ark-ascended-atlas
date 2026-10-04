#!/usr/bin/env python3
"""Decode every bundled loop and verify the reviewed route recipes and source render keys."""
import concurrent.futures, hashlib, json, subprocess
from pathlib import Path
from PIL import Image
root=Path(__file__).resolve().parents[1]; resources=root/'native/Ascended/Resources'; media=resources/'CaveGIFs'
render=json.loads((root/'docs/codex-reports/2026-10-04-hq-render-manifest.json').read_text())
clips={x['name']:x for x in render['clips']}; expected_files=set(); jobs=[]; summary={}
for map_id in ['ragnarok','the-island','the-center']:
 recipe=json.loads((root/f'docs/codex-reports/2026-10-04-{map_id}-gif-recipe.json').read_text())
 manifest=json.loads((resources/f'{map_id}-cave-gifs.json').read_text())
 routes=json.loads((resources/f'{map_id}-exploration.json').read_text())['routes']
 assert {g['routeID'] for g in manifest}=={x['id'] for x in routes if x['artifactIDs']}
 assert len(manifest)==len(recipe['guides']); count=0
 for guide,original in zip(manifest,recipe['guides']):
  assert guide['routeID']==original['routeID'] and len(guide['sections'])==len(original['sections'])
  for section,rs in zip(guide['sections'],original['sections']):
   assert section['id']==rs['id'] and len(section['steps'])==len(rs['steps'])
   for step,source in zip(section['steps'],rs['steps']):
    assert source['visuallyReviewed'] and step['gif']==source['gif'] and step['loop']==source['gif']
    assert step.get('direction')==source.get('direction')
    record=clips[step['loop']]; assert record['videoID']==source['videoID'] and record['start']==source['start'] and record['end']==source['end']
    key=hashlib.sha256(json.dumps([render['sources'][source['videoID']]['sha256'],source['start'],source['end'],source.get('speed',1),render['profile']]).encode()).hexdigest()
    assert record['renderKey']==key
    movie=media/(step['loop']+'.mp4'); poster=media/(step['poster']+'.jpg')
    assert movie.name not in expected_files; expected_files.update([movie.name,poster.name]); assert movie.stat().st_size==record['bytes']
    with Image.open(poster) as im: im.load(); assert im.size==(1920,1080)
    jobs.append((movie,source,record));count+=1
 summary[map_id]={'routes':len(manifest),'loops':count}
assert expected_files=={p.name for p in media.iterdir() if p.is_file()},'Orphan or missing files'
def validate(job):
 movie,source,record=job
 data=json.loads(subprocess.check_output(['ffprobe','-v','error','-show_streams','-show_format','-of','json',str(movie)]))
 assert len(data['streams'])==1
 stream=data['streams'][0];assert stream['codec_type']=='video' and stream['codec_name']=='hevc' and stream['codec_tag_string']=='hvc1'
 assert (stream['width'],stream['height'])==(1920,1080)
 num,den=map(float,stream['avg_frame_rate'].split('/'));assert abs(num/den-record['fps'])<.01
 target=(source['end']-source['start'])/source.get('speed',1); assert abs(float(data['format']['duration'])-target)<.12
 result=subprocess.run(['ffmpeg','-v','error','-xerror','-i',str(movie),'-f','null','-'],capture_output=True)
 assert result.returncode==0,(movie,result.stderr.decode());return movie.name
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
 for i,name in enumerate(pool.map(validate,jobs),1):
  if i%25==0: print(f'{i}/{len(jobs)} decoded',flush=True)
summary.update(totalLoops=len(jobs),assetBytes=sum(p.stat().st_size for p in media.iterdir()),resolution=[1920,1080],codec='HEVC hvc1',audioStreams=0,fullyDecoded=True)
(root/'docs/codex-reports/2026-10-04-hq-loop-validation.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps(summary,indent=2))
