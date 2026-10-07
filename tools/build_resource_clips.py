"""Render one clean continuous source interval per guide from licensed local caches.
No downloading, interpolation, concatenation, catalog/photo writes, or restriction bypass.
Run from any directory; selections and per-file ffprobe/decode results are reproducible.
"""
import argparse
import hashlib
import io
import json
import subprocess
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from PIL import Image, ImageDraw
ROOT = Path(__file__).resolve().parents[1]
MEDIA = Path('/Volumes/TONY SSD/ASCENDED_MEDIA')
OUT = ROOT / 'native/Ascended/Resources/ResourceClips'
EVIDENCE = ROOT / 'tools/evidence/resource-media26'

def run(args):
    return subprocess.run(args, capture_output=True, check=True)

def probe(path):
    return json.loads(run(['ffprobe','-v','error','-show_streams','-show_format','-of','json',str(path)]).stdout)

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    EVIDENCE.mkdir(parents=True,exist_ok=True)
    paths=json.loads((MEDIA/'resource-clip-review/paths.json').read_text())
    selections=json.loads((ROOT/'tools/resource_clip_selections.json').read_text())
    doc=json.loads((ROOT/'native/Ascended/Resources/resource-guides.json').read_text())
    parser=argparse.ArgumentParser();parser.add_argument('--only',nargs='+',help='Re-render selected spot ids and retain the other validated results');args=parser.parse_args()
    guides=[g for g in doc['guides'] if g['spotID'] in selections and (not args.only or g['spotID'] in args.only)]
    def render(g):
        s=selections[g['spotID']]; start=s['startSeconds']; duration=s['duration']
        assert 0<duration<=10 and s['visualReview']['result']=='Clean terrain/resource/approach; no map or inventory obstruction'
        source=Path(paths[g['videoID']]); stream=next(x for x in probe(source)['streams'] if x['codec_type']=='video')
        name='Resource-'+g['spotID']+'-1'; movie=OUT/(name+'.mp4'); poster=OUT/(name+'.jpg')
        run(['ffmpeg','-v','error','-y','-ss',str(start),'-i',str(source),'-t',str(duration),'-an','-vf',"scale=w='min(1920,iw)':h='min(1080,ih)':force_original_aspect_ratio=decrease:force_divisible_by=2,fps=24",'-c:v','libx264','-preset','veryfast','-crf','20','-pix_fmt','yuv420p','-movflags','+faststart',str(movie)])
        run(['ffmpeg','-v','error','-y','-i',str(movie),'-frames:v','1','-q:v','3',str(poster)])
        info=probe(movie); actual=float(info['format']['duration']); video=next(x for x in info['streams'] if x['codec_type']=='video')
        assert not any(x['codec_type']=='audio' for x in info['streams'])
        assert abs(actual-duration)<.15 and actual<=10.05 and video['codec_name']=='h264'
        decoded=run(['ffmpeg','-v','error','-xerror','-i',str(movie),'-f','null','-'])
        assert not decoded.stderr,decoded.stderr.decode()
        raw=run(['ffmpeg','-v','error','-i',str(movie),'-vf','fps=4,scale=240:135','-f','image2pipe','-vcodec','mjpeg','-']).stdout
        frames=raw.split(b'\xff\xd8')[1:]; sheet=Image.new('RGB',(1200,155*((len(frames)+4)//5))); draw=ImageDraw.Draw(sheet)
        for i,b in enumerate(frames):
            x=i%5*240;y=i//5*155;sheet.paste(Image.open(io.BytesIO(b'\xff\xd8'+b)),(x,y));draw.text((x+3,y+136),f'{start+i/4:.2f}s',fill='white')
        sheet.save(EVIDENCE/(g['spotID']+'-selected.jpg'))
        sha=hashlib.sha256(movie.read_bytes()).hexdigest()
        g['steps']=[dict(id=name,title='Terrain & approach',loop=name,poster=name,startSeconds=start,endSeconds=start+duration,sourceURL=f"https://www.youtube.com/watch?v={g['videoID']}&t={int(start)}s",mapOverlayVisible=False,inventoryOverlayVisible=False,visualReview=s['visualReview'],sha256=sha)]
        g['harvestDemonstrated']=s.get('harvestDemonstrated',False)
        g['evidenceLimitations']=s['evidenceLimitations']
        g['sourceWidth']=stream['width'];g['sourceHeight']=stream['height']
        g['sourceAcquisition']=s['sourceAcquisition']
        return dict(spotID=g['spotID'],videoID=g['videoID'],sourcePath=str(source),sourceBytes=source.stat().st_size,startSeconds=start,endSeconds=start+duration,continuousSourceInterval=True,spliced=False,durationSeconds=actual,width=video['width'],height=video['height'],codec=video['codec_name'],frameRate=video['avg_frame_rate'],audioStreams=0,fullDecodePassed=True,sha256=sha,bytes=movie.stat().st_size,reviewSheet=str((EVIDENCE/(g['spotID']+'-selected.jpg')).relative_to(ROOT)),limitation=s['evidenceLimitations'])
    validation=list(ThreadPoolExecutor(max_workers=4).map(render,guides))
    if args.only:
        previous=json.loads((EVIDENCE/'validation.json').read_text())['results']
        updated={v['spotID']:v for v in validation}
        validation=[updated.get(v['spotID'],v) for v in previous]
    # Retain the established first step id; retire only the superseded reviewed guide loops.
    for g in guides:
        for i in (2,3):
            for ext in ('mp4','jpg'):
                p=OUT/f"Resource-{g['spotID']}-{i}.{ext}"
                if p.exists():p.unlink()
    doc['schemaVersion']=2
    doc['mediaFormat']='One continuous muted H.264 offline autoplay clip per guide, <=10 seconds; source resolution capped at 1920x1080 without upscaling; CRF 20, 24 fps'
    (ROOT/'native/Ascended/Resources/resource-guides.json').write_text(json.dumps(doc,indent=2)+'\n')
    manifest=dict(guides=len(validation),clips=len(validation),reviewMethod='Manually reviewed 20-second context sheets at 1 fps and encoded interval sheets at 4 fps; sampled visual review is not frame-by-frame certification.',durationUnder6Seconds=[v['spotID'] for v in validation if v['durationSeconds']<6],restrictions='Only existing approved local received media used. Partial sources previously ended HTTP 403; no download or bypass attempted.',results=validation)
    (EVIDENCE/'validation.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(json.dumps(dict(guides=len(validation),clips=len(validation),bytes=sum(v['bytes'] for v in validation),shorterThan6=len(manifest['durationUnder6Seconds']))))
if __name__=='__main__':main()
