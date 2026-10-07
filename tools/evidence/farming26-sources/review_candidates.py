import json, subprocess, pathlib
paths=json.load(open('/Volumes/TONY SSD/ASCENDED_MEDIA/resource-clip-review/paths.json'))
out=pathlib.Path('tools/evidence/farming26-sources')
for vid,start,dur,name in [('0i0-XEV85m8',130,30,'rag-pearl'),('0i0-XEV85m8',347,30,'rag-crystal'),('0i0-XEV85m8',450,50,'rag-metal'),('0i0-XEV85m8',525,60,'rag-obsidian'),('0i0-XEV85m8',650,50,'rag-oil'),('0i0-XEV85m8',755,60,'rag-polymer'),('0i0-XEV85m8',1000,55,'rag-silica'),('0i0-XEV85m8',1110,50,'rag-sulfur'),('bAqRvM-080g',347,15,'center-pond1'),('bAqRvM-080g',407,18,'center-pond2'),('bAqRvM-080g',434,20,'center-pond3'),('bAqRvM-080g',128,18,'center-mine'),('boGcZ2neH6g',62,14,'val-pearl'),('k73mk3nz0wI',17,23,'astra-crystal'),('k9IOWvnWMdg',50,11,'scorch-metal'),('IOCye6IYUCM',305,45,'island-pearl')]:
 subprocess.run(['ffmpeg','-v','error','-y','-ss',str(start),'-i',paths[vid],'-t',str(dur),'-vf',"fps=1,scale=320:-1,tile=5x12",'-frames:v','1',str(out/(name+'.jpg'))],check=True)
 print(name,flush=True)
