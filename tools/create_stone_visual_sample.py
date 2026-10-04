"""Reference-guided reconstruction sample, not original ARK mesh or texture.
Dimensions intentionally approximate. Leaves both earlier library files intact.
"""
import bpy, random, math
from pathlib import Path
from mathutils import Vector
rng=random.Random(104)
OUT=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/base-planning')
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
scene=bpy.context.scene;scene['scope']='Two reference-guided stone reconstructions; no original game mesh; approximate foundation-module scale.'
stone=[]
for i in range(9):
 mat=bpy.data.materials.new('Rough stone '+str(i));mat.use_nodes=True
 nodes=mat.node_tree.nodes;links=mat.node_tree.links
 p=next(n for n in nodes if n.type=='BSDF_PRINCIPLED');p.inputs['Roughness'].default_value=.88
 noise=nodes.new('ShaderNodeTexNoise');noise.inputs['Scale'].default_value=18;noise.inputs['Detail'].default_value=5
 ramp=nodes.new('ShaderNodeValToRGB');v=.045+i*.006
 ramp.color_ramp.elements[0].color=(v*.65,v*.63,v*.57,1);ramp.color_ramp.elements[1].color=(v*1.75,v*1.7,v*1.5,1)
 links.new(noise.outputs['Fac'],ramp.inputs['Fac']);links.new(ramp.outputs['Color'],p.inputs['Base Color'])
 fine=nodes.new('ShaderNodeTexNoise');fine.inputs['Scale'].default_value=125;fine.inputs['Detail'].default_value=3
 bump=nodes.new('ShaderNodeBump');bump.inputs['Strength'].default_value=.7;bump.inputs['Distance'].default_value=.025
 links.new(fine.outputs['Fac'],bump.inputs['Height']);links.new(bump.outputs['Normal'],p.inputs['Normal'])
 mat.diffuse_color=(v*1.4,v*1.35,v*1.25,1);stone.append(mat)

def group(name):
 c=bpy.data.collections.new(name);bpy.context.scene.collection.children.link(c);c['representation']='Reconstructed from inventory silhouette, not game asset';return c

def block(c,name,loc,size,bevel=.015,jitter=.015):
 # Chipped angular outline with uneven face relief; not a rounded brick box.
 w,d,h=size
 outline=[(-.5,-.36),(-.39,-.5),(.22,-.5),(.43,-.46),(.5,-.3),(.5,.29),(.37,.5),(.05,.48),(-.3,.5),(-.49,.35)]
 points=[(x*w+rng.uniform(-jitter,jitter),z*h+rng.uniform(-jitter,jitter)) for x,z in outline]
 verts=[(x,-d/2+rng.uniform(-jitter*.5,jitter*.5),z) for x,z in points]
 verts += [(x,d/2,z) for x,z in points]
 n=len(points);verts.append((rng.uniform(-w*.15,w*.15),-d/2-rng.uniform(.001,jitter*.7),rng.uniform(-h*.15,h*.15)))
 faces=[(n*2,i,(i+1)%n) for i in range(n)]
 faces += [tuple(range(n,n*2))]
 faces += [(i,n+i,n+(i+1)%n,(i+1)%n) for i in range(n)]
 mesh=bpy.data.meshes.new(name+' fractured mesh');mesh.from_pydata(verts,[],faces);mesh.update()
 o=bpy.data.objects.new(name,mesh);c.objects.link(o);o.location=loc;o.data.materials.append(rng.choice(stone))
 m=o.modifiers.new('Small chipped edges','BEVEL');m.width=bevel*.3;m.segments=1
 return o
foundation=group('Stone Foundation - reconstruction');wall=group('Stone Wall - reconstruction')
foundation['reference']='Equipment-stone-foundation/image.png';wall['reference']='Equipment-stone-wall/image.png'
# Deep slab with uneven stone courses on the sides and worn top cap.
for row in range(2):
 for y in [-.41,.41]:
  for j in range(4):block(foundation,'Foundation side stone',(-.85-.375+j*.25,y,.04+row*.1),(.245,.18,.095),.014,.012)
 for x in [-1.27,-.43]:
  for j in range(3):block(foundation,'Foundation end stone',(x,-.28+j*.28,.04+row*.1),(.17,.275,.095),.014,.012)
block(foundation,'Worn stone cap',(-.85,0,.22),(.98,.98,.09),.017,.013)
# Irregular staggered joints and staggered stone sizes, instead of a flat box.
for row in range(6):
 count=4 if row%2 else 5;weights=[rng.uniform(.55,1.65) for _ in range(count)];total=sum(weights);x=.32
 for idx,w in enumerate(weights):
  width=w/total
  block(wall,'Hand-hewn wall stone',(x+width/2,0,.075+row*.163),(width-.003,.19+rng.uniform(-.035,.035),.161),.014,.014)
  x+=width
for col in [foundation,wall]:
 col.asset_mark();col.asset_data.description='Visual reconstruction; estimated scale; not the original ARK asset.'
# Keep actual source images packed for comparison while editing.
for key in ['stone-foundation','stone-wall']:
 path=Path('/Users/admin/Ascended-iPad-Dev/native/Ascended/Assets.xcassets')/('Equipment-'+key+'.imageset')/'image.png'
 im=bpy.data.images.load(str(path));im.pack();im.use_fake_user=True
stage=group('Presentation only')
bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,-.025));floor=bpy.context.object;floor.name='Presentation floor'
mat=bpy.data.materials.new('Backdrop');mat.use_nodes=True;next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED').inputs['Base Color'].default_value=(.07,.085,.1,1);floor.data.materials.append(mat)
for old in list(floor.users_collection):old.objects.unlink(floor)
stage.objects.link(floor)
for loc,power,size in [((0,-3,4),220,4),((3,2,3),250,3),((-3,1,2),120,2)]:
 bpy.ops.object.light_add(type='AREA',location=loc);o=bpy.context.object;o.data.energy=power;o.data.shape='DISK';o.data.size=size;o.rotation_euler=(Vector((0,0,.3))-o.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(2.1,-3.8,2.1));cam=bpy.context.object;cam.rotation_euler=(Vector((0,0,.4))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=2.9;scene.camera=cam
try:scene.render.engine='CYCLES'
except TypeError:pass
if hasattr(scene,'cycles'):scene.cycles.samples=48
scene.render.resolution_x=1400;scene.render.resolution_y=1000;scene.render.resolution_percentage=100
scene.world.color=(.18,.18,.18)
for screen in bpy.data.screens:
 for a in screen.areas:
  if a.type=='VIEW_3D':
   a.spaces.active.region_3d.view_location=(0,0,.4);a.spaces.active.region_3d.view_distance=3.5
   a.spaces.active.region_3d.view_rotation=cam.rotation_euler.to_quaternion()
   a.spaces.active.shading.color_type='MATERIAL';a.spaces.active.overlay.show_extras=False
bpy.ops.object.select_all(action='DESELECT')
readme=bpy.data.texts.new('Read me - visual sample');readme.write('Stone Foundation and Wall rebuilt from the exact inventory reference images packed in this file. Sculpted stone blocks and procedural rough materials, not original meshes/textures. No claim of matching ASA visual detail or measured dimensions. Two-item sample only; remaining 376 kit items have not been upgraded.\n')
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Ascended-Stone-Visual-Sample.blend'),compress=True)
scene.render.filepath=str(OUT/'stone-visual-sample.png');bpy.ops.render.render(write_still=True)
print('VISUAL_SAMPLE_SAVED',len(foundation.objects),len(wall.objects))
