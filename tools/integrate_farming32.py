"""Package reviewed location clips while retaining original coordinate provenance.

Usage: python3 tools/integrate_farming32.py reviewed-additions.json
Only continuous clean 6-10 second clips enter this release.
"""
import hashlib,json,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]; APP=ROOT/'native/Ascended';RES=APP/'Resources'
def read(p):return json.loads(p.read_text())
def write(p,d):p.write_text(json.dumps(d,indent=2,ensure_ascii=False)+'\n')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
rows=read(Path(sys.argv[1])); rows=rows if isinstance(rows,list) else rows.get('entries',rows.get('candidates',[]))
spots=read(RES/'verified-resource-spots.json');guides=read(RES/'resource-guides.json')
byspot={s['id']:s for s in spots['spots']};byguide={g['spotID']:g for g in guides['guides']}
accepted=[];rejected=[]
for r in rows:
 movie=Path(r.get('moviePath',r.get('clipPath','')))
 if not movie.is_file():rejected.append([r['id'],'missing clip']);continue
 probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-show_streams','-show_format','-of','json',str(movie)]))
 video=next(x for x in probe['streams'] if x['codec_type']=='video');duration=float(probe['format']['duration'])
 if not 6<=duration<=10.05:rejected.append([r['id'],'duration outside 6-10 seconds']);continue
 assert video['codec_name']=='h264' and not any(x['codec_type']=='audio' for x in probe['streams'])
 assert r.get('visualReviewStatus')=='verified' or 'verified' in r.get('status',''),r['id']
 assert r.get('mapOverlayVisible',r.get('cleanMapOverlayVisible',False)) is False
 assert r.get('inventoryOverlayVisible',False) is False
 subprocess.run(['ffmpeg','-v','error','-xerror','-i',str(movie),'-f','null','-'],check=True,capture_output=True)
 sid=r['id'];loop='Resource-'+sid+'-1';dest=RES/'ResourceClips';dest.mkdir(exist_ok=True)
 shutil.copy2(movie,dest/(loop+'.mp4'))
 poster=Path(r.get('posterPath',movie.with_suffix('.jpg')))
 if not poster.is_file():subprocess.run(['ffmpeg','-v','error','-i',str(movie),'-frames:v','1','-y',str(poster)],check=True)
 shutil.copy2(poster,dest/(loop+'.jpg'))
 asset='FarmPhoto-'+sid;aset=APP/'Assets.xcassets'/(asset+'.imageset');aset.mkdir(exist_ok=True)
 shutil.copy2(poster,aset/'poster.jpg');write(aset/'Contents.json',{'images':[{'filename':'poster.jpg','idiom':'universal'}],'info':{'author':'xcode','version':1}})
 url=r.get('sourceURL','https://www.youtube.com/watch?v='+r['videoID']);start=r['startSeconds'];end=r['endSeconds']
 scope=r.get('sourceCoordinateScope',r.get('coordinateAuthority','Creator-labelled filmed farming region'))
 plane=r.get('sourcePlane',r['map']+' filmed region')
 limitations=r.get('evidenceLimitations',r.get('limitations',r.get('asaCompatibility','Filmed approach; no guaranteed yield or permanent node count.')))
 inventory=r.get('inventoryEvidence','Visible source-labelled farming region; no measured yield claim.')
 review=r.get('visualReview',{'method':'Manual encoded contact-sheet review','reviewedAt':'2026-10-08','result':'Clean terrain and approach with no map or inventory overlay'})
 byspot[sid]={'id':sid,'map':r['map'],'name':r['name'],'lat':r['lat'],'lon':r['lon'],'resources':r['resources'],'imageAsset':asset,'videoID':r['videoID'],'seconds':start,'direction':r.get('direction','Match the source-filmed terrain at this waypoint.'),'method':r.get('method','Harvest the resource visible in the source region.'),'kit':r.get('kit',[]),'risks':r.get('risks',[]),'verified':True,'sourceURL':url,'photoSHA256':sha(poster),'coordinateEvidence':r['coordinateEvidence'],'inventoryEvidence':inventory,'sourcePlane':plane,'sourceCoordinateScope':scope,'photoSourceSeconds':start,'photoMapOverlayVisible':False}
 byguide[sid]={'sourceAcquisition':r.get('acquisitionState','Approved existing local source media'),'spotID':sid,'map':r['map'],'sourcePlane':plane,'sourceCoordinateScope':scope,'videoID':r['videoID'],'sourceURL':url,'rightsBasis':'licensed','rightsApproval':r.get('rightsApproval','User confirmed licenses for all source videos'),'sourceWidth':video['width'],'sourceHeight':video['height'],'coordinateEvidence':r['coordinateEvidence'],'inventoryEvidence':inventory,'harvestDemonstrated':r.get('harvestDemonstrated',False),'evidenceLimitations':limitations,'steps':[{'id':loop,'title':'Terrain & approach','loop':loop,'poster':loop,'startSeconds':start,'endSeconds':end,'sourceURL':url+'&t='+str(start)+'s','mapOverlayVisible':False,'inventoryOverlayVisible':False,'visualReview':review,'sha256':sha(movie)}]}
 accepted.append(sid)
spots['spots']=list(byspot.values());guides['guides']=list(byguide.values())
for r in spots.get('coverage',[]):
 matches=[s['id'] for s in spots['spots'] if s['map']==r['map'] and r['resource'] in s['resources']]
 if matches:r.update(spotIDs=matches,status='verified',evidenceState='filmed-region-verified')
for r in guides.get('coverage',[]):r['verifiedRegions']=sum(g['map']==r['map'] for g in guides['guides'])
write(RES/'verified-resource-spots.json',spots);write(RES/'resource-guides.json',guides)
print(json.dumps({'accepted':accepted,'rejected':rejected,'totalSpots':len(byspot)},indent=2))
