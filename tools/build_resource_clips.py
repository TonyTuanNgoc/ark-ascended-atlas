"""Create licensed, timestamped resource loops from approved local source videos.
No download is performed. Each selection is manually reviewed against source frames.
"""
import json, subprocess, hashlib
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
ROOT=Path(__file__).resolve().parents[1]
MEDIA=Path('/Volumes/TONY SSD/ASCENDED_MEDIA')
OUT=ROOT/'native/Ascended/Resources/ResourceClips'
# Distinct sequences in the SAME filmed region. Third title reports exactly the demonstrated evidence.
SELECTIONS={
'center-blue-metal':(15,21,25,'Resource view'),
'center-spire-obsidian':(46,56,64,'Resource view'),
'center-lava-metal':(177,186,194,'Resource view'),
'center-snow-crystal':(273,295,303,'Resource view'),
'center-beaver-pond':(489,509,517,'Dam loot'),
'center-ring-pearls':(534,546,551,'Resource view'),
'center-ice-polymer':(638,647,655,'Resource view'),
'rag-underwater-metal':(98,105,111,'Harvesting'),
'rag-dam-lakes':(506,523,515,'Dam loot'),
'rag-cactus-route':(755,741,746,'Harvesting'),
'rag-coast-flowers':(917,926,931,'Harvesting'),
'island-volcano-ore':(180,197,205,'Resource view'),
'island-west-black-pearls':(292,313,317,'Resource view'),
'island-redwood-fiber':(417,422,427,'Resource view'),
'island-west-starter':(480,489,511,'Creature view'),
'island-carno-crystal':(565,569,574,'Resource view'),
'island-redwood-paste':(652,658,662,'Dam view'),
'island-nw-oil':(728,741,745,'Harvesting'),
'rag-black-pearl-bed':(176,180,184,'Resource view'),
'rag-crystal-highland':(378,383,388,'Resource view'),
'rag-cave-metal-obsidian':(436,443,526,'Resource view'),
'rag-oil-north-shore':(597,590,594,'Resource view'),
'rag-polymer-plants':(716,721,726,'Resource view'),
'rag-flowers-nw':(829,833,837,'Resource view'),
'rag-pearls-cave':(1006,1011,1001,'Harvesting'),
'rag-silk-fields':(1069,1073,1077,'Resource view'),
'rag-sulfur-rocks':(1118,1122,1126,'Resource view'),
'rag-salt-columns':(1236,1228,1232,'Resource view'),
'island-ice-polymer':(775,767,780,'Resource view'),
'rag-lake-basic-hub':(506,532,536,'Resource view'),
'island-surface-pearls':(194,199,204,'Resource view'),
'rag-whale-keratin':(97,89,101,'Harvesting'),
'honey-center-redwoods':(143,126,134,'Hive view'),
'honey-island-redwoods':(37,31,44,'Hive view'),
'honey-ragnarok-queen-region':(83,154,164,'Queen interaction'),
'rag-shore-sand':(50,10,18,'Harvesting'),
'island-swamp-mushrooms':(77,89,97,'Harvesting'),
'center-extra-swamp-mushrooms':(135,112,119,'Tool demonstration'),
'island-east-dam-rares':(285,291,321,'Dam loot'),
'center-extra-lava-chitin':(553,479,527,'Creature combat'),
'center-extra-blue-basics':(15,21,25,'Resource view')
}
def probe(path):
 q=subprocess.run(['ffprobe','-v','error','-show_streams','-show_format','-of','json',str(path)],capture_output=True,check=True);return json.loads(q.stdout)
def main():
 OUT.mkdir(parents=True,exist_ok=True)
 paths=json.loads((MEDIA/'resource-clip-review/paths.json').read_text())
 spots=json.loads((ROOT/'native/Ascended/Resources/verified-resource-spots.json').read_text())['spots']
 extra=json.loads((ROOT/'tools/resource_clip_selections.json').read_text())
 jobs=[]; guides=[]
 for s in spots:
  selection=extra.get(s['id']); a,b,c=selection['starts'] if selection else SELECTIONS[s['id']][:3]; title=selection['title'] if selection else SELECTIONS[s['id']][3]; source=Path(paths[s['videoID']]); stream=next(x for x in probe(source)['streams'] if x['codec_type']=='video');steps=[]
  for idx,(start,label) in enumerate(zip([a,b,c],['Area / coordinates','Approach / surroundings',title])):
   name='Resource-'+s['id']+'-'+str(idx+1);duration=selection['duration'] if selection else 3.5
   step=dict(id=name,title=label,loop=name,poster=name,startSeconds=start,endSeconds=start+duration,sourceURL=f"https://www.youtube.com/watch?v={s['videoID']}&t={int(start)}s")
   steps.append(step);jobs.append((source,start,duration,name))
  demonstrated=title in ['Harvesting','Dam loot']
  guides.append(dict(sourceAcquisition=selection['sourceAcquisition'] if selection else 'Approved complete local source cache',spotID=s['id'],map=s['map'],videoID=s['videoID'],sourceURL=s['sourceURL'],rightsBasis='licensed',rightsApproval='User confirmed licenses for all source videos',sourceWidth=stream['width'],sourceHeight=stream['height'],coordinateEvidence=s['coordinateEvidence'],inventoryEvidence=s['inventoryEvidence'],harvestDemonstrated=demonstrated,evidenceLimitations='' if demonstrated else 'The source shows this region and resource or method. A completed harvest and measured yield are not demonstrated in these clips.',steps=steps))
 def render(job):
  source,start,duration,name=job;movie=OUT/(name+'.mp4');poster=OUT/(name+'.jpg')
  # Always regenerate: a same-duration file can belong to a different source/interval.
  subprocess.run(['ffmpeg','-v','error','-y','-ss',str(start),'-i',str(source),'-t',str(duration),'-an','-vf','scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,fps=24','-c:v','libx264','-preset','veryfast','-crf','23','-pix_fmt','yuv420p','-movflags','+faststart',str(movie)],check=True)
  subprocess.run(['ffmpeg','-v','error','-y','-i',str(movie),'-frames:v','1','-q:v','3',str(poster)],check=True)
  info=probe(movie);assert not any(x['codec_type']=='audio' for x in info['streams']);assert abs(float(info['format']['duration'])-duration)<.15
  return name,hashlib.sha256(movie.read_bytes()).hexdigest()
 hashes=dict(ThreadPoolExecutor(max_workers=4).map(render,jobs))
 for g in guides:
  for step in g['steps']:step['sha256']=hashes[step['loop']]
  assert len({step['sha256'] for step in g['steps']})==3
 allmaps=['the-island','the-center','ragnarok','scorched-earth','aberration','extinction','valguero','astraeos','lost-colony','genesis-part-1','genesis-part-1-ocean']
 doc=dict(schemaVersion=1,mediaFormat='Muted H.264 offline loops, 1280x720, 24 fps',guides=guides,coverage=[dict(map=m,verifiedRegions=sum(g['map']==m for g in guides),status='source-verified' if any(g['map']==m for g in guides) else 'needs-video-verification',reason='Filmed GPS regions reviewed against source footage; individual actors and respawns vary.' if any(g['map']==m for g in guides) else 'No licensed source sequence with verified map, GPS, approach and harvest has been validated for this map.') for m in allmaps])
 (ROOT/'native/Ascended/Resources/resource-guides.json').write_text(json.dumps(doc,indent=2)+'\n')
 print(json.dumps(dict(guides=len(guides),clips=len(jobs),bytes=sum(p.stat().st_size for p in OUT.iterdir()),harvestDemonstrated=sum(g['harvestDemonstrated'] for g in guides))))
if __name__=='__main__':main()
