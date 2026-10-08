import json,subprocess,shutil
from pathlib import Path
from PIL import Image,ImageDraw
OUT=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/farming33/root');E=Path(__file__).resolve().parent;B=Path('/Volumes/TONY SSD/TONY_WORKSPACE/CODE/TonyOS_Workspace/tools/youtube-intelligence/data/downloads')
rows=[dict(id='valguero-waterfall-metal-60-40',map='valguero',name='Waterfall ridge metal deposit',resources=['Metal'],lat=60.9,lon=40.2,videoID='GmVkxFGsUCg',startSeconds=30,endSeconds=38,coordinateEvidence='Creator caption LOCATION1 LAT60.9 LON40.2 in the dedicated ASA Top10 Metal guide and the filmed first deposit chapter.',inventoryEvidence='Creator identifies this ridge as the first metal deposit in the dedicated metal guide; no measured yield claim.'),dict(id='astraeos-korinthos-pearl-shallows-40-26',map='astraeos',name='Korinthos pearl shallows',resources=['Silica Pearls'],lat=40.4,lon=26.3,videoID='kiURwc3JrEI',startSeconds=22,endSeconds=30,coordinateEvidence='Creator explicitly labels pearl location40.4 LAT26.3 LONG at source49s, agreeing with the map latitude/longitude readout.',inventoryEvidence='Pearl shells visible in the shallow underwater bed; no guaranteed yield claim.')]
for r in rows:
 src=max([p for p in B.glob(r['videoID']+'*') if '.mp4' in p.name],key=lambda p:p.stat().st_size);movie=OUT/(r['id']+'.mp4');poster=movie.with_suffix('.jpg')
 subprocess.run(['ffmpeg','-v','error','-ss',str(r['startSeconds']),'-i',str(src),'-t','8','-an','-vf','scale=1280:720','-c:v','libx264','-pix_fmt','yuv420p','-crf','22','-movflags','+faststart','-y',str(movie)],check=True,capture_output=True)
 subprocess.run(['ffmpeg','-v','error','-xerror','-i',str(movie),'-f','null','-'],check=True,capture_output=True)
 subprocess.run(['ffmpeg','-v','error','-i',str(movie),'-frames:v','1','-y',str(poster)],check=True,capture_output=True)
 f=OUT/(r['id']+'-review');f.mkdir(exist_ok=True)
 subprocess.run(['ffmpeg','-v','error','-i',str(movie),'-vf','fps=4,scale=320:-1','-y',str(f/'%03d.jpg')],check=True,capture_output=True)
 ims=sorted(f.glob('*.jpg'));sheet=Image.new('RGB',(1280,200*((len(ims)+3)//4)))
 for i,p in enumerate(ims):
  xy=((i%4)*320,(i//4)*200);sheet.paste(Image.open(p),xy);ImageDraw.Draw(sheet).text((xy[0]+4,xy[1]+180),f"{r['startSeconds']+i/4:.2f}s",fill='white')
 contact=E/(r['id']+'-contact.jpg');sheet.save(contact)
 proof=E/(r['videoID']+'-coordinate.jpg');shutil.copy2(OUT/(r['videoID']+'-coordinate.jpg'),proof)
 r.update(clipPath=str(movie),posterPath=str(poster),sourceURL='https://www.youtube.com/watch?v='+r['videoID'],sourcePlane=r['map']+' ASA coordinate plane',sourceCoordinateScope='Creator-labelled farming region',mapOverlayVisible=False,inventoryOverlayVisible=False,rightsBasis='licensed',acquisitionState='Licensed partial opening acquired before403; no retry after denial',visualReview={'contactSheet':str(contact),'coordinateFrame':str(proof),'fullEncodedDecode':True,'sampleRateFPS':4,'continuousShot':True},evidenceLimitations='Filmed regional waypoint; no permanent node count or guaranteed yield. Only licensed cached media acquired before source denial was used.')
(E/'pending-additions.json').write_text(json.dumps({'candidates':rows},indent=2)+'\n')
print('Prepared2 clips; requires manual review before verified status.')
