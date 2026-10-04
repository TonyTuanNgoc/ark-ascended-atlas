"""Import entire construction catalogue as reconstructed families or explicit image references."""
import bpy,json,math
from pathlib import Path
ROOT=Path('/Users/admin/Ascended-iPad-Dev');R=ROOT/'native/Ascended/Resources'
code=(ROOT/'tools/create_building_proxy_library.py').read_text().split('# Show common building pieces')[0]
# Correct forge planning envelope to legacy wiki clearance, not a claimed ASA mesh measurement.
code=code.replace("r,h=(1,2) if 'industrial' in s else (.32,.7)","r,h=(1.35,5.6) if 'industrial' in s else (.32,.7)")
exec(code)
# Asset collections must be linked for dependency-graph transforms/modifiers to evaluate.
for collection in assets.values():
 if collection.name not in bpy.context.scene.collection.children:bpy.context.scene.collection.children.link(collection)
bpy.context.view_layer.update()
# Refine common visual silhouettes while retaining explicit reconstruction status.
for info in manifest:
 key=info['id'];col=assets[key];parts=[]
 if info['family']=='wall' and 'large-' in key:
  for o in col.objects:o.scale.z*=4;o.location.z*=4
 if key in ['stone-ramp']:
  pass
 if info['family']=='wall' and not any(k in key for k in ['sloped','large-']):
  for o in list(col.objects):bpy.data.objects.remove(o,do_unlink=True)
  if 'greenhouse' in key:
   glass=bpy.data.materials.new('Glass reference');glass.diffuse_color=(.22,.58,.63,.32)
   box('glass',(0,0,.5),(.96,.035,.96),glass)
   for x in [-.48,0,.48]:box('metal stile',(x,-.025,.5),(.035,.05,1),mats['metal'])
   for z in [.02,.5,.98]:box('metal rail',(0,-.025,z),(1,.05,.035),mats['metal'])
  elif 'wood' in key or 'thatch' in key:
   for i in range(8):box('plank',(-.4375+i*.125,0,.5),(.119,.1,1),mats['wood'])
   for z in [.13,.85]:box('cross brace',(0,-.065,z),(1,.05,.08),mats['wood'])
  elif 'adobe' in key or 'stone' in key:
   material=mats['adobe'] if 'adobe' in key else mats['stone']
   for row in range(6):
    for i in range(4):box('masonry',(-.375+i*.25,0,(row+.5)/6),(.242,.14,.16),material)
  else:
   box('armour plate',(0,0,.5),(1,.065,1),mats['metal'])
   for x in [-.46,.46]:
    for z in [.04,.5,.96]:cylinder('rivet',(x,-.05,z),.025,.025,mats['metal']).rotation_euler.x=math.pi/2
 if key=='beer-barrel':
  # Legacy wiki item body allowance; not an ASA mesh measurement.
  for o in col.objects:o.scale.x*=.5/.76;o.location.x*=.5/.76;o.scale.y*=.75/.76;o.location.y*=.75/.76;o.scale.z*=1/.945;o.location.z*=1/.945
 if key=='fireplace':
  for o in list(col.objects):bpy.data.objects.remove(o,do_unlink=True)
  box('stone hearth',(0,0,.4),(.58,.48,.8),mats['stone']);box('fire opening',(0,-.25,.3),(.38,.025,.45),mats['warm']);box('stone chimney',(0,.1,2.4),(.22,.22,3.2),mats['stone'])
  info['family']='hearth'
 if key=='mortar-and-pestle':
  for o in list(col.objects):bpy.data.objects.remove(o,do_unlink=True)
  cylinder('mortar bowl',(0,0,.1),.19,.2,mats['stone']);cylinder('bowl interior',(0,0,.205),.14,.008,mats['soil'])
  cylinder('pestle',(.08,.04,.22),.035,.28,mats['stone']).rotation_euler.y=.65
 if key=='smithy':
  box('anvil waist',(-.1,0,.75),(.28,.2,.25),mats['metal']);box('anvil top',(-.1,0,.9),(.55,.24,.08),mats['metal'])
  cylinder('anvil horn',(.25,0,.9),.09,.22,mats['metal']).rotation_euler.y=math.pi/2
 if key=='fabricator':
  cylinder('lathe shaft',(0,-.12,.84),.11,1,mats['metal']).rotation_euler.y=math.pi/2
  for x in [-.45,.45]:box('lathe head',(x,-.12,.85),(.2,.3,.34),mats['metal'])
 if key=='chemistry-bench':
  for i in range(4):
   cylinder('glass vessel',(-.38+i*.25,-.13,.78),.07,.35,mats['greenhouse'])
   cylinder('flask neck',(-.38+i*.25,-.13,1),.035,.12,mats['greenhouse'])
 if key=='industrial-forge':
  for z in [.45,1.2,2.5,4,5.2]:cylinder('steel band',(0,0,z),1.38,.07,mats['metal'])
  box('service opening',(0,-1.37,1.2),(.7,.1,.9),mats['warm'])
 for o in col.objects:
  if o.type=='MESH':
   bevel=o.modifiers.new('Soft machined edges','BEVEL');bevel.width=.008;bevel.segments=1
bpy.context.view_layer.update()
catalog={i['id']:i for i in json.loads((R/'build-crafting.json').read_text())['items']}
old={m['id'] for m in json.loads((R/'stone-building-kit.json').read_text())['models']}
result=[]
for info in manifest:
 key=info['id'];c=assets[key]
 if key in old:continue
 source=catalog[key];pos=[];norm=[];uv=[];color=[];reference=info['family']=='footprint-only' or 'staircase' in key or key.startswith('giant-')
 if not reference:
  dg=bpy.context.evaluated_depsgraph_get()
  for o in c.objects:
   mesh=o.evaluated_get(dg).to_mesh();mesh.calc_loop_triangles()
   for tri in mesh.loop_triangles:
    normal=(o.matrix_world.to_3x3().inverted().transposed()@tri.normal).normalized()
    mat=mesh.materials[0].diffuse_color if mesh.materials else (.3,.3,.3,1)
    for vi in tri.vertices:
     v=o.matrix_world@mesh.vertices[vi].co
     pos.extend([round(v.x,5),round(v.z,5),round(-v.y,5)]);norm.extend([round(normal.x,5),round(normal.z,5),round(-normal.y,5)]);uv.extend([v.x,v.z]);color.extend(mat)
   o.evaluated_get(dg).to_mesh_clear()
 row={'id':key,'title':source['name'],'name':source['name'],'category':source['category'],'asset':source['asset'],'positions':pos,'normals':norm,'uv':uv,'colors':color,'ingredients':source['ingredients'] if source['recipeVerified'] else {},'referenceOnly':reference,'sizeStatus':'unmeasured','representation':'inventory-reference' if reference else 'family-reconstruction'}
 result.append(row)
(R/'construction-models.json').write_text(json.dumps({'models':result,'approximate':True},ensure_ascii=False,separators=(',',':'))+'\n')
# Arrange collection instances in a gallery after exporting their local geometry.
for col in assets.values():
 if col.name in bpy.context.scene.collection.children:bpy.context.scene.collection.children.unlink(col)
gallery=bpy.data.collections.new("Construction gallery");bpy.context.scene.collection.children.link(gallery)
for index,(key,col) in enumerate(assets.items()):
 instance=bpy.data.objects.new(key,None);instance.instance_type="COLLECTION";instance.instance_collection=col
 instance.location=((index%20)*5,(index//20)*5,0);gallery.objects.link(instance)
# Assets stay collection-local and browsable; earlier files remain intact.
bpy.ops.wm.save_as_mainfile(filepath='/Volumes/TONY SSD/ASCENDED_MEDIA/base-planning/Ascended-Construction-Catalogue.blend',compress=True)
print('models',len(result)+len(old),'referenceOnly',sum(x['referenceOnly'] for x in result))
