"""Bake approximate reconstructed Stone kit to portable triangle data for SceneKit."""
import bpy, json, math
from pathlib import Path
from mathutils import Vector
ROOT=Path('/Users/admin/Ascended-iPad-Dev');R=ROOT/'native/Ascended/Resources'
# Reuse reviewed angular stone modelling functions, without overwriting the sample scene.
prefix=(ROOT/'tools/create_stone_visual_sample.py').read_text().split("foundation=group")[0]
exec(prefix)
models=[]
specs=[('stone-foundation','Móng','Stone Foundation',(80,40,30),'stone-foundation'),('stone-triangle-foundation','Móng tam giác','Stone Triangle Foundation',(40,20,15),'stone-triangle-quarter-foundation'),('stone-wall','Tường','Stone Wall',(40,20,15),'stone-wall-doorways-windowframe'),('stone-doorframe','Khung cửa','Stone Doorframe',(40,20,15),'stone-wall-doorways-windowframe'),('reinforced-wooden-door','Cửa','Reinforced Wooden Door',(20,14,8),'stone-reinforced-doors-windows'),('stone-ceiling','Trần','Stone Ceiling',(60,30,20),'stone-ceiling-hatchframe'),('stone-triangle-ceiling','Trần tam giác','Stone Triangle Ceiling',(30,15,10),'stone-quarter-triangle-ceiling'),('sloped-stone-roof','Mái dốc','Sloped Stone Roof',(60,30,20),'stone-roof-ramp-stairs'),('stone-stairs','Cầu thang','Stone Stairs',(60,30,20),'stone-roof-ramp-stairs'),('stone-pillar','Cột','Stone Pillar',(30,15,10),'stone-pillar'),('stone-railing','Lan can','Stone Railing',(20,10,7),'stone-quarter-wall-railing')]
catalog={i['id']:i for i in json.loads((R/'equipment-library.json').read_text())['items']}
def masonry(c,x0=-.5,x1=.5,height=1,bottom=.25,depth=.16):
 rows=max(1,round(height/.165))
 for row in range(rows):
  widths=[rng.uniform(.6,1.4) for _ in range(max(1,round((x1-x0)*4)))];span=x1-x0;total=sum(widths);x=x0;h=height/rows
  for w in widths:
   w=w*span/total;block(c,'Rough stone',(x+w/2,0,bottom+h*(row+.5)),(w-.005,depth,h-.004),.014,min(.012,w*.06));x+=w

def slab(c,thickness=.22,triangle=False):
 if triangle:
  verts=[(-.5,-.5,0),(.5,-.5,0),(0,.366,0),(-.5,-.5,thickness),(.5,-.5,thickness),(0,.366,thickness)]
  me=bpy.data.meshes.new('Triangular stone');me.from_pydata(verts,[],[(0,2,1),(3,4,5),(0,1,4,3),(1,2,5,4),(2,0,3,5)]);me.update();o=bpy.data.objects.new('Triangular cap',me);c.objects.link(o);me.materials.append(stone[3])
 else:
  for row in range(2 if thickness>.1 else 1):
   for y in [-.42,.42]:
    for j in range(4):block(c,'Side stone',(-.375+j*.25,y,thickness*(row+.5)/(2 if thickness>.1 else 1)),(.245,.16,thickness/(2 if thickness>.1 else 1)),.012,.008)
  block(c,'Worn cap',(0,0,thickness-.015),(.99,.99,.06),.014,.008)
for ident,title,name,cost,slug in specs:
 c=group(name);c['id']=ident;c['approximate']=True
 if 'foundation' in ident:slab(c,.22,'triangle' in ident)
 elif 'ceiling' in ident:slab(c,.065,'triangle' in ident)
 elif ident=='stone-wall':masonry(c)
 elif ident=='stone-doorframe':
  masonry(c,-.5,-.32,.85);masonry(c,.32,.5,.85);masonry(c,-.5,.5,.15,1.1)
 elif ident=='reinforced-wooden-door':
  wood=bpy.data.materials.new('Aged wood');wood.diffuse_color=(.19,.11,.05,1)
  for j in range(6):
   o=block(c,'Door plank',(-.267+j*.107,0,.675),(.104,.08,.85),.01,.002);o.data.materials.clear();o.data.materials.append(wood)
  for z in [.45,.95]:block(c,'Stone reinforcement',(0,-.07,z),(.64,.055,.08),.01,.002)
 elif ident=='stone-pillar':
  for j in range(6):block(c,'Pillar block',(0,0,.25+(j+.5)/6),(.24,.24,1/6),.012,.012)
 elif ident=='stone-railing':masonry(c,height=.35)
 elif ident=='stone-stairs':
  for j in range(8):
   for i in range(4):block(c,'Stair stone',(-.375+i*.25,-.5+(j+.5)/8,.25+(j+1)/8-.05),(.245,.13,.1),.012,.006)
 elif ident=='sloped-stone-roof':
  slab(c,.07)
  from mathutils import Matrix
  rotation=Matrix.Rotation(math.pi/4,4,'X')@Matrix.Diagonal(Vector((1,math.sqrt(2),1,1)))
  for o in c.objects:
   o.matrix_world=rotation@o.matrix_world;o.location.z+=.75
 bpy.context.view_layer.update();dg=bpy.context.evaluated_depsgraph_get();positions=[];normals=[];uv=[];colors=[]
 for o in c.objects:
  evaluated=o.evaluated_get(dg);mesh=evaluated.to_mesh();mesh.calc_loop_triangles()
  for tri in mesh.loop_triangles:
   n=(o.matrix_world.to_3x3()@tri.normal).normalized();color=mesh.materials[0].diffuse_color if mesh.materials else (.12,.12,.1,1)
   for vi in tri.vertices:
    v=o.matrix_world@mesh.vertices[vi].co
    positions.extend([round(v.x,5),round(v.z,5),round(-v.y,5)])
    normals.extend([round(n.x,5),round(n.z,5),round(-n.y,5)])
    uv.extend([round(v.x*2,5),round((v.y if 'foundation' in ident or 'ceiling' in ident else v.z)*2,5)])
    colors.extend([round(float(t),4) for t in color])
  evaluated.to_mesh_clear()
 c.asset_mark();c.asset_data.description='Reference reconstruction; approximate planning dimensions'
 models.append({'id':ident,'title':title,'name':name,'asset':catalog.get(ident,{}).get('asset'),'positions':positions,'normals':normals,'uv':uv,'colors':colors,'ingredients':dict(zip(['Stone','Wood','Thatch'],cost)),'sourceURL':'https://wikily.gg/ark-survival-ascended/items/'+slug+'/'})
(R/'stone-building-kit.json').write_text(json.dumps({'schema':1,'approximate':True,'models':models},separators=(',',':'))+'\n')
# Display all11 in Blender via shifted collection objects after exporting local coordinates.
for idx,c in enumerate([c for c in bpy.data.collections if c.get('id')]):
 for o in c.objects:o.location.x+=(idx%4)*1.5;o.location.y+=(idx//4)*1.7
bpy.ops.wm.save_as_mainfile(filepath='/Volumes/TONY SSD/ASCENDED_MEDIA/base-planning/Ascended-Stone-Building-Kit.blend',compress=True)
print('MODELS',len(models),'TRIANGLES',sum(len(m['positions'])//9 for m in models))
