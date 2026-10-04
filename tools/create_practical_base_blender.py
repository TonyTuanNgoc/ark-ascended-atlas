"""Generate an editable five-house layout and pack source icon references.
Units are foundation modules, not surveyed ARK metres. Icon planes are 2D references,
not genuine meshes of inventory items. Run with Blender --background --python FILE.
"""
import bpy,json,math
from pathlib import Path
ROOT=Path('/Users/admin/Ascended-iPad-Dev'); OUT=Path('/Volumes/TONY SSD/ASCENDED_MEDIA/base-planning')
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
houses=json.loads((ROOT/'native/Ascended/Resources/base-layout.json').read_text()); catalog=json.loads((ROOT/'native/Ascended/Resources/equipment-library.json').read_text())
scene=bpy.context.scene;scene['scope']='Layout proxy. One unit = one foundation module; not measured metres. Item PNG planes are references, not exported game meshes.'
for h in houses:
 mat=bpy.data.materials.new(h['id']);mat.diffuse_color=(.12,.5,.35,1) if h['id']=='garden' else (.12,.35,.45,1)
 bpy.ops.mesh.primitive_cube_add(size=1,location=(h['x']+h['width']/2,h['z']+h['depth']/2,-.04));obj=bpy.context.object;obj.name=h['id']+'_foundation';obj.scale=(h['width'],h['depth'],.08);obj.data.materials.append(mat)
 for axis in [0,1]:
  for side in [0,1]:
   size=(h['width'],.08,h['levels']) if axis==0 else (.08,h['depth'],h['levels'])
   loc=(h['x']+h['width']/2,h['z']+side*h['depth'],h['levels']/2) if axis==0 else (h['x']+side*h['width'],h['z']+h['depth']/2,h['levels']/2)
   bpy.ops.mesh.primitive_cube_add(size=1,location=loc);wall=bpy.context.object;wall.name=h['id']+'_wall_proxy';wall.scale=size;wall.data.materials.append(mat)
 bpy.ops.object.text_add(location=(h['x']+.3,h['z']+.3,.08));label=bpy.context.object;label.name='Label_'+h['id'];label.data.body=h['id']+f" {h['width']}x{h['depth']}";label.data.size=.6
 bpy.context.object['building_recipe_counts']='Foundation=width*depth; Ceiling=width*depth; Wall=2*(width+depth)*levels-1; Doorframe=1; Door=1. Default one human door only, no Dino gateway/greenhouse/interiors.'
collection=bpy.data.collections.new('Inventory source icons (2D reference, not item meshes)');scene.collection.children.link(collection)
count=0
for item in catalog['items']:
 asset=item.get('asset')
 if not asset:continue
 folder=ROOT/'native/Ascended/Assets.xcassets'/(asset+'.imageset'); metadata=json.loads((folder/'Contents.json').read_text());filename=next(i['filename'] for i in metadata['images'] if 'filename' in i)
 image=bpy.data.images.load(str(folder/filename),check_existing=True);image.pack()
 bpy.ops.mesh.primitive_plane_add(size=1,location=(40+(count%24)*1.4,(count//24)*1.4,0));plane=bpy.context.object;plane.name=item['name'];plane['sourceURL']=item['sourceURL'];plane['representation']='2D inventory icon only';plane['category']=item['category']
 for c in list(plane.users_collection):c.objects.unlink(plane)
 collection.objects.link(plane)
 mat=bpy.data.materials.new('Icon_'+item['id']);mat.use_nodes=True;tex=mat.node_tree.nodes.new('ShaderNodeTexImage');tex.image=image;bsdf=mat.node_tree.nodes.get('Principled BSDF');mat.node_tree.links.new(tex.outputs['Color'],bsdf.inputs['Base Color']);mat.node_tree.links.new(tex.outputs['Alpha'],bsdf.inputs['Alpha']);plane.data.materials.append(mat);count+=1
collection.hide_render=True
scene['inventory_icon_references']=count;scene['real_game_meshes']=0
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Ascended-Practical-Base.blend'),compress=True)
(OUT/'README.txt').write_text('5-house editable layout in foundation units. Inventory collection packs original game PNGs as flat reference planes, not actual game meshes. Frame budget excludes gates, greenhouse and interiors. Source recipes in repository.\n')
print('PACKED_ICONS',count)
