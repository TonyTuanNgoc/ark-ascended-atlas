#!/usr/bin/env python3
"""Render only curated, visually reviewed licensed source ranges. Originals stay outside Git."""
import argparse,json,subprocess,hashlib
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--source-root',type=Path,required=True);p.add_argument('--recipe',type=Path,required=True);p.add_argument('--resources',type=Path,required=True);a=p.parse_args()
d=json.loads(a.recipe.read_text());a.resources.mkdir(parents=True,exist_ok=True)
for guide in d['guides']:
 for section in guide['sections']:
  for step in section['steps']:
   if not step.get('visuallyReviewed'): raise SystemExit('Unreviewed clip: '+step['id'])
   source=a.source_root/(step['videoID']+'.mp4')
   if source.is_symlink() or not source.is_file(): raise SystemExit('Missing regular source: '+str(source))
   start,end=step['start'],step['end'];speed=step.get('speed',1)
   if not 0<=start<end or (end-start)/speed>16: raise SystemExit('Invalid clip range: '+step['id'])
   name='gif-'+d['map']+'-'+guide['routeID']+'-'+step['id']
   gif=a.resources/(name+'.gif');poster=a.resources/(name+'.jpg')
   renderKey=hashlib.sha256(json.dumps([step['videoID'],start,end,speed,'512x288/8fps/64colors/bayer5'],sort_keys=True).encode()).hexdigest()
   changed=step.get('renderKey')!=renderKey
   if changed or not gif.exists():
    vf=f'setpts=(PTS-STARTPTS)/{speed},fps=8,scale=512:288:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=64:stats_mode=diff[p];[s1][p]paletteuse=dither=bayer:bayer_scale=5'
    subprocess.run(['ffmpeg','-y','-v','error','-ss',str(start),'-t',str(end-start),'-i',str(source),'-an','-filter_complex',vf,'-loop','0',str(gif)],check=True)
   if changed or not poster.exists():
    subprocess.run(['ffmpeg','-y','-v','error','-ss',str(start+.2),'-i',str(source),'-frames:v','1','-vf','scale=640:360:flags=lanczos','-q:v','3',str(poster)],check=True)
   step['gif']=name;step['poster']=name;step['renderKey']=renderKey
   print(name, gif.stat().st_size,flush=True)
out=[]
for guide in d['guides']:
 out.append({'routeID':guide['routeID'],'sections':[{'id':s['id'],'title':s['title'],'steps':[{k:v for k,v in x.items() if k in ['id','title','gif','poster','direction']} for x in s['steps']]} for s in guide['sections']]})
(a.resources.parent/(d['map']+'-cave-gifs.json')).write_text(json.dumps(out,ensure_ascii=False,indent=2)+'\n')
a.recipe.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
