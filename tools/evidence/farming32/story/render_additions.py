import pathlib,json,subprocess,io,hashlib
from PIL import Image,ImageDraw
p=pathlib.Path('/Users/admin/Ascended-iPad-Dev/tools/evidence/farming32/story');out=pathlib.Path('/Volumes/TONY SSD/ASCENDED_MEDIA/farming32/story');paths=json.loads(pathlib.Path('/Volumes/TONY SSD/ASCENDED_MEDIA/resource-clip-review/paths.json').read_text())
rows=[('scorched-northeast-cliff-metal','scorched-earth','Northeastern metal cliff','Metal','k9IOWvnWMdg',36.8,68.8,56.375,57.375,60),('aberration-northwest-metal-cave','aberration','Northwestern green metal cave approach','Metal','BZVk5xrksxk',19.5,27.7,39.625,44.5,46),('lost-colony-northwest-metal','lost-colony','Northwestern snowy metal mountain','Metal','WKNYEAeuSDA',3.0,5.8,61.25,67.5,69),('extinction-south-oil-pool','extinction','Southern oil pool','Oil','85xkdr_UYAo',82.9,42.7,24.1,26.5,28),('extinction-southwest-oil-pool','extinction','Southwestern oil pool','Oil','85xkdr_UYAo',87.7,33.6,29.5,30.6,32)]
entries=[]
for id,map,name,res,vid,lat,lon,start,end,gps in rows:
 movie=out/(id+'.mp4');poster=out/(id+'.jpg')
 r=subprocess.run(['ffmpeg','-v','error','-y','-ss',str(start),'-i',paths[vid],'-t',str(end-start),'-an','-vf','scale=1280:-2,fps=24','-c:v','libx264','-preset','fast','-crf','20','-pix_fmt','yuv420p','-movflags','+faststart',str(movie)],capture_output=True)
 probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-show_format','-show_streams','-of','json',str(movie)]));dec=subprocess.run(['ffmpeg','-v','error','-xerror','-i',str(movie),'-f','null','-'],capture_output=True)
 subprocess.run(['ffmpeg','-v','error','-y','-i',str(movie),'-frames:v','1',str(poster)],capture_output=True)
 raw=subprocess.check_output(['ffmpeg','-v','error','-i',str(movie),'-vf','fps=8,scale=320:180','-f','image2pipe','-vcodec','mjpeg','-']);frames=raw.split(b'\xff\xd8')[1:];sheet=Image.new('RGB',(1600,200*((len(frames)+4)//5)));draw=ImageDraw.Draw(sheet)
 for i,b in enumerate(frames):
  x=i%5*320;y=i//5*200;sheet.paste(Image.open(io.BytesIO(b'\xff\xd8'+b)),(x,y));draw.text((x+3,y+181),f'{start+i/8:.3f}s',fill='white')
 sheet.save(p/(id+'-selected.jpg'))
 entries.append(dict(id=id,map=map,name=name,resources=[res],lat=lat,lon=lon,videoID=vid,startSeconds=start,endSeconds=end,coordinateEvidence=f'In-game camera coordinates visible at {gps}s in {vid}-{gps}.jpg; region/camera position, not every individual actor.',license='User-asserted licensed; platform metadata license null',rightsBasis='Root recovered prior explicit user approval: Duyệt, a có giấy phép hết; persists for this task.',sourcePath=paths[vid],clipPath=str(movie),posterPath=str(poster),clipSHA256=hashlib.sha256(movie.read_bytes()).hexdigest(),actualDuration=float(probe['format']['duration']),decodeExitCode=dec.returncode,decodeErrors=dec.stderr.decode(),renderErrors=r.stderr.decode(),contactSheet=str(p/(id+'-selected.jpg')),visualReview='pending',harvestDemonstrated=False,sourceCoordinateScope='Filmed camera region',sourceURL='https://www.youtube.com/watch?v='+vid))
(p/'additions.json').write_text(json.dumps({'entries':entries},indent=2));print(len(entries))
