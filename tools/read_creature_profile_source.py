#!/usr/bin/env python3
"""Inspect cached public wiki infoboxes and sections without importing variant stats."""
import argparse,json,re
from html.parser import HTMLParser
from pathlib import Path
class Node:
 def __init__(self,tag='',attrs=(),parent=None):self.tag=tag;self.attrs=dict(attrs);self.parent=parent;self.children=[]
 def text(self):return ' '.join(''.join(self.parts()).split())
 def parts(self):
  if self.tag in ('script','style'):return []
  out=[]
  for c in self.children:out += c.parts() if isinstance(c,Node) else [c+' ']
  return out
 def nodes(self):
  yield self
  for c in self.children:
   if isinstance(c,Node):yield from c.nodes()
class Tree(HTMLParser):
 def __init__(self):super().__init__();self.root=Node();self.current=self.root
 def handle_starttag(self,t,a):
  n=Node(t,a,self.current);self.current.children.append(n)
  if t not in ('area','base','br','col','embed','hr','img','input','link','meta','param','source','track','wbr'):self.current=n
 def handle_endtag(self,t):
  n=self.current
  while n.parent is not None:
   if n.tag==t:self.current=n.parent;return
   n=n.parent
 def handle_data(self,d):self.current.children.append(d)
def inspect(path):
 html=Path(path).read_text();p=Tree();p.feed(html);fields={}
 for n in p.root.nodes():
  if 'info-unit-row' in n.attrs.get('class','').split():
   cells=[c for c in n.children if isinstance(c,Node) and c.tag=='div']
   if len(cells)==2:
    fields.setdefault(cells[0].text(),cells[1].text())
 # First domestication value row; supplement via subsequent text markers.
 plain=p.root.text();m=re.search(r'Domestication Tameable Rideable Breedable (Yes|No)',plain)
 if m:fields['Tameable']=m.group(1)
 sections={}
 for key in ['Taming','KO_Strategy','Taming_Method','Drops','Utility','Breeding']:
  m=re.search(r'<h[23][^>]*>\s*<span[^>]*id="'+key+r'"',html)
  if m:
   end=re.search(r'<h[23]\b',html[m.end():]);part=html[m.start():m.end()+end.start()] if end else html[m.start():];q=Tree();q.feed(part);sections[key]=q.root.text()
 return dict(fields=fields,sections=sections)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('paths',nargs='+');a=p.parse_args()
 for path in a.paths:print(json.dumps(dict(path=path,**inspect(path)),ensure_ascii=False,indent=2))
