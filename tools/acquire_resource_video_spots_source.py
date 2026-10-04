import argparse,sys,json,re
from pathlib import Path
from yt_dlp import YoutubeDL
p=argparse.ArgumentParser();p.add_argument('--url',required=True);p.add_argument('--apply',action='store_true');p.add_argument('--approval',required=True);p.add_argument('--rights',required=True);p.add_argument('--source-root',required=True);p.add_argument('--format',default='bv*[height<=1080][vcodec^=avc1]+ba/b[height<=1080]');a=p.parse_args()
class SafeLog:
 def debug(self,s):
  if not s.startswith('[debug]'): print(re.sub(r'https?://\S+','[URL omitted]',s),flush=True)
 def info(self,s): self.debug(s)
 def warning(self,s): print('WARNING: '+re.sub(r'https?://\S+','[URL omitted]',s),flush=True)
 def error(self,s): print('ERROR: '+re.sub(r'https?://\S+','[URL omitted]',s),flush=True)
if not a.apply or not a.approval.strip() or a.rights != 'licensed':
 raise SystemExit('Explicit apply, approval record and licensed rights required')
root=Path(a.source_root);root.mkdir(parents=True,exist_ok=True)
opts={'noplaylist':True,'js_runtimes':{'deno':{}},'logger':SafeLog(),'cachedir':str(root/'cache'),'format':a.format,'merge_output_format':'mp4','outtmpl':str(root/'%(id)s.%(ext)s'),'quiet':True,'noprogress':True}
# No cookies, token providers, forced player clients or account/access bypasses.
from yt_dlp.networking.impersonate import ImpersonateTarget
# Default public HTTP transport; no cookies or account credentials.
with YoutubeDL(opts) as ydl:
 info=ydl.extract_info(a.url,download=False)
 if info.get('age_limit',0)>0 or info.get('availability') in ['private','premium_only','subscriber_only','needs_auth']:
  raise SystemExit('Restricted source; use an authorized local export')
 gate={'approval':a.approval,'rights':a.rights,'apply':a.apply}
 print(json.dumps({'gate':gate,'videoId':info['id'],'availability':info.get('availability'),'ageLimit':info.get('age_limit')}),flush=True)
 ydl.process_info(info)
 print(json.dumps({'status':'ready','videoId':info['id'],'media':str(root/(info['id']+'.mp4'))}),flush=True)
