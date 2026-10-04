"""Editable primitive-based ARK planning assets, explicitly approximate.
Run in background Blender. Does not alter the existing five-house .blend.
One Blender unit is one planning foundation module, not measured metres.
"""
import bpy, json, math
from pathlib import Path
from mathutils import Quaternion
ROOT=Path('/Users/admin/Ascended-iPad-Dev')
OUT=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/base-planning')
OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
scene=bpy.context.scene
scene['representation']='Approximate primitive planning library; not game meshes; one unit = one assumed foundation module, not measured metres.'
items=[i for i in json.loads((ROOT/'native/Ascended/Resources/equipment-library.json').read_text())['items'] if i['category'] in ['structures','machines']]
colors={'stone':(.36,.4,.43,1),'wood':(.34,.18,.08,1),'adobe':(.58,.32,.2,1),'metal':(.28,.34,.4,1),'tek':(.13,.5,.56,1),'greenhouse':(.22,.55,.44,1),'other':(.36,.42,.46,1),'label':(.9,.94,.95,1),'soil':(.2,.1,.04,1),'warm':(.7,.25,.04,1)}
mats={}
for k,v in colors.items():
 m=bpy.data.materials.new(k);m.diffuse_color=v;m.use_nodes=True
 next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED').inputs['Base Color'].default_value=v
 mats[k]=m
col=None
parts=[]
def move(obj):
 for c in list(obj.users_collection):c.objects.unlink(obj)
 col.objects.link(obj);parts.append(obj);return obj

def box(name,loc,size,material):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=move(bpy.context.object);o.name=name;o.scale=size;o.data.materials.append(material)
 return o

def cylinder(name,loc,radius,depth,material):
 bpy.ops.mesh.primitive_cylinder_add(vertices=24,radius=radius,depth=depth,location=loc);o=move(bpy.context.object);o.name=name;o.data.materials.append(material);return o

def frame(w=1,h=1,window=False):
 bottom=.35 if window else 0;top=.8 if window else h-.15
 box('left jamb',(-w/2+.08,0,h/2),(.16,.12,h),mat)
 box('right jamb',(w/2-.08,0,h/2),(.16,.12,h),mat)
 box('lintel',(0,0,(h+top)/2),(w-.32,.12,h-top),mat)
 if window:box('sill',(0,0,bottom/2),(w-.32,.12,bottom),mat)

def table(w=1.1,d=.5,h=.55):
 box('worktop',(0,0,h),(w,d,.08),mat)
 for x in [-w/2+.07,w/2-.07]:
  for y in [-d/2+.07,d/2-.07]:box('leg',(x,y,h/2),(.1,.1,h),mat)

def triangular(thick=.1):
 verts=[(-.5,-.5,0),(.5,-.5,0),(0,.366,0),(-.5,-.5,thick),(.5,-.5,thick),(0,.366,thick)]
 mesh=bpy.data.meshes.new('triangular slab');mesh.from_pydata(verts,[],[(0,2,1),(3,4,5),(0,1,4,3),(1,2,5,4),(2,0,3,5)]);mesh.update()
 o=bpy.data.objects.new('triangle',mesh);col.objects.link(o);o.data.materials.append(mat);parts.append(o)

manifest=[];assets={}
for item in items:
 col=bpy.data.collections.new(item['name']+' [approx]');col.use_fake_user=True;parts=[]
 key=next((k for k in ['greenhouse','tek','metal','adobe','stone','wood'] if k in item['id']),'other');mat=mats[key];s=item['id'];family='footprint-only'
 if 'gateway' in s or 'doorframe' in s or 'windowframe' in s:
  w,h=(7,6) if 'behemoth' in s else ((2,3) if 'gateway' in s else (1,1));frame(w,h,'windowframe' in s);family='opening'
 elif 'triangle' in s:triangular(.2 if 'foundation' in s else .1);family='triangle'
 elif 'foundation' in s or 'ceiling' in s or 'trapdoor' in s or 'platform' in s:
  w=2 if 'large' in s else 1;box('slab',(0,0,.08),(w,w,.16),mat);family='slab'
 elif 'hatchframe' in s:
  for x in [-.42,.42]:box('edge',(x,0,.05),(.16,1,.1),mat)
  for y in [-.42,.42]:box('edge',(0,y,.05),(.68,.16,.1),mat)
  family='opening'
 elif 'gate' in s or 'door' in s:
  w,h=(6.7,5.8) if 'behemoth' in s else ((1.7,2.8) if 'gate' in s else (.68,.85));box('door leaf',(0,0,h/2),(w,.1,h),mat);family='door'
 elif 'window' in s:box('window leaf',(0,0,.575),(.68,.06,.45),mat);family='window'
 elif 'ramp' in s or 'roof' in s:
  o=box('slope',(0,0,.5),(1,math.sqrt(2),.1),mat);o.rotation_euler.x=math.pi/4;family='slope'
 elif 'stair' in s:
  for t in range(8):box('step',(0,-.5+(t+.5)/8,(t+1)/16),(1,.125,(t+1)/8),mat)
  family='stairs'
 elif 'ladder' in s:
  for x in [-.2,.2]:box('rail',(x,0,.5),(.05,.08,1),mat)
  for t in range(5):box('rung',(0,0,.1+t*.2),(.4,.08,.04),mat)
  family='ladder'
 elif 'railing' in s:
  for x in [-.45,.45]:box('post',(x,0,.25),(.08,.08,.5),mat)
  for z in [.15,.45]:box('rail',(0,0,z),(1,.08,.06),mat)
  family='railing'
 elif 'pillar' in s:cylinder('pillar',(0,0,.5),.15,1,mat);family='pillar'
 elif 'wall' in s:box('wall',(0,0,.5),(1,.12,1),mat);family='wall'
 elif 'crop-plot' in s or 'trough' in s:
  w=1 if 'large' in s or 'tek' in s else .6
  box('soil or feed',(0,0,.06),(w,.65,.12),mats['soil'])
  for x in [-w/2,w/2]:box('rim',(x,0,.14),(.06,.7,.25),mat)
  for y in [-.35,.35]:box('rim',(0,y,.14),(w,.06,.25),mat)
  family='tray'
 elif 'forge' in s:
  r,h=(1,2) if 'industrial' in s else (.32,.7)
  cylinder('furnace',(0,0,h/2),r,h,mat);box('fire door',(0,-r,.25),(r,.08,.35),mats['warm']);cylinder('chimney',(0,0,h+.15),r*.4,.3,mat);family='furnace'
 elif 'bench' in s or 'smithy' in s or 'fabricator' in s or 'grill' in s:
  table(1.4 if 'fabricator' in s else 1.1,.65,.55)
  if 'smithy' not in s:box('machine housing',(0,.12,.85),(1,.35,.55),mat)
  family='workbench'
 elif 'fridge' in s or 'vault' in s or 'bookshelf' in s:
  box('cabinet',(0,0,.7),(.65,.55,1.4),mat)
  box('door panel',(0,-.29,.72),(.57,.04,1.25),mats['metal']);box('handle',(.22,-.33,.8),(.04,.04,.18),mats['tek']);family='cabinet'
 elif 'barrel' in s or 'reservoir' in s or 'cooking-pot' in s or 'cooker' in s or 'grinder' in s:
  cylinder('vessel',(0,0,.45),.35,.9,mat);cylinder('lid',(0,0,.92),.38,.05,mat);family='vessel'
 elif 'generator' in s or 'air-conditioner' in s or 'incubator' in s:
  box('housing',(0,0,.3),(.85,.65,.6),mat);cylinder('vent',(0,0,.65),.23,.08,mats['metal']);family='utility'
 elif 'bed' in s or 'sleeping' in s:
  table(.6,1,.25);box('mattress',(0,0,.35),(.6,1,.16),mats['wood']);box('pillow',(0,.32,.46),(.5,.2,.06),mats['stone']);family='bed'
 elif 'teleporter' in s or 'forcefield' in s:cylinder('pad',(0,0,.08),1.5,.16,mat);family='pad'
 elif 'lamp' in s or 'torch' in s or 'turbine' in s:
  cylinder('base',(0,0,.06),.2,.12,mat);cylinder('mast',(0,0,.7),.045,1.3,mat);box('head',(0,0,1.4),(.35,.25,.16),mats['warm']);family='mast'
 else:box('unverified footprint',(0,0,.3),(.8,.6,.6),mat)
 # Align complete asset origin to the bottom center; retain dimensions in planning units.
 bpy.context.view_layer.update()
 for o in parts:o['item_id']=item['id'];o['representation']='approximate '+family
 col['item_id']=item['id'];col['sourceURL']=item['sourceURL'];col['family']=family;col['scale_note']='Estimated foundation modules, not verified game dimensions';col.asset_mark();col.asset_data.description=item['name']+' — approximate planning model; not original game mesh.'
 assets[item['id']]=col
 manifest.append({'id':item['id'],'name':item['name'],'category':item['category'],'family':family,'parts':len(parts),'verifiedDimensions':False})

# Show common building pieces and production equipment first. All remaining assets stay in the file's Asset Browser.
core=['stone-foundation','stone-wall','stone-doorframe','reinforced-wooden-door','stone-ceiling','stone-stairs','stone-ramp','stone-pillar','stone-railing','stone-dinosaur-gateway','reinforced-dinosaur-gate','greenhouse-wall','greenhouse-ceiling','greenhouse-doorframe','greenhouse-door','smithy','fabricator','refining-forge','industrial-forge','chemistry-bench','power-generator','refrigerator','industrial-cooker','industrial-grill','large-crop-plot','feeding-trough','large-storage-box','vault','air-conditioner','egg-incubator','mortar-and-pestle','simple-bed']
gallery=bpy.data.collections.new('Common practical kit');scene.collection.children.link(gallery)
for idx,key in enumerate(k for k in core if k in assets):
 x=(idx%8)*3.2;y=(idx//8)*3.4
 o=bpy.data.objects.new(key,None);o.instance_type='COLLECTION';o.instance_collection=assets[key];o.location=(x,y,0);gallery.objects.link(o)
 bpy.ops.object.text_add(location=(x-1,y-1,.03));label=bpy.context.object;label.name='Label '+key;label.data.body=assets[key].name.replace(' [approx]','');label.data.size=.17;label.data.align_x='LEFT';label.data.materials.append(mats['label'])
 # Root instances duplicate cleanly as complete items; editable mesh parts are within the asset collection.
 scene['common_preview_count']=len([o for o in gallery.objects if o.instance_collection])
scene['asset_count']=len(assets);scene['real_game_meshes']=0
readme=bpy.data.texts.new('READ ME - approximate library');readme.write('378 catalog assets: 299 structures + 79 machines. Primitive family approximations only. Footprint-only items have no recognisable game geometry. No verified dimensions or exact placement/snapping. One unit is an assumed foundation module, not a metre. Browse Current File assets, duplicate collection instances for planning. Existing five-house plan is preserved in the separate Ascended-Practical-Base.blend. No new houses constructed.\n')
for screen in bpy.data.screens:
 for area in screen.areas:
  if area.type=='VIEW_3D':
   area.spaces.active.region_3d.view_location=(10,5,0)
   area.spaces.active.region_3d.view_distance=26
   area.spaces.active.region_3d.view_rotation=Quaternion((.88,.33,.13,.3)).normalized()
   area.spaces.active.shading.color_type='MATERIAL'
   area.spaces.active.overlay.show_extras=False
bpy.ops.object.select_all(action='DESELECT')
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Ascended-Building-Kit-Approx.blend'),compress=True)
(OUT/'building-kit-manifest.json').write_text(json.dumps({'scope':scene['representation'],'assets':manifest},ensure_ascii=False,indent=2)+'\n')
print('ASSETS',len(assets),'PREVIEW',scene['common_preview_count'],'FOOTPRINT_ONLY',sum(i['family']=='footprint-only' for i in manifest))
