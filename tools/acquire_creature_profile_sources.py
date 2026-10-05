#!/usr/bin/env python3
"""Acquire public wiki HTML sequentially, preserving source evidence; no auth or challenge bypass."""
import argparse, hashlib, json, pathlib, subprocess, time

def main():
 p=argparse.ArgumentParser();p.add_argument('--manifest',type=pathlib.Path,required=True);p.add_argument('--cache',type=pathlib.Path,required=True);p.add_argument('--ledger',type=pathlib.Path,required=True);p.add_argument('--interval',type=float,default=12);a=p.parse_args();a.cache.mkdir(parents=True,exist_ok=True)
 results=[]
 for item in json.loads(a.manifest.read_text()):
  target=a.cache/(item['id']+'.html')
  if target.exists() and 'mw-parser-output' in target.read_text(errors='replace'):
   status='cached'
  else:
   result=subprocess.run(['curl','-sSL','--max-time','30','-w','%{http_code}','-o',str(target),item['url']],capture_output=True,text=True)
   code=result.stdout[-3:];status=code
   if code!='200' or 'mw-parser-output' not in target.read_text(errors='replace'):
    results.append(dict(**item,status=status));print(item['id'],status,flush=True)
    if code=='429':break
    time.sleep(a.interval);continue
  results.append(dict(**item,status=status,path=str(target),sha256=hashlib.sha256(target.read_bytes()).hexdigest()));print(item['id'],status,flush=True);time.sleep(a.interval)
 a.ledger.parent.mkdir(parents=True,exist_ok=True);a.ledger.write_text(json.dumps(results,indent=2)+'\n')
if __name__=='__main__':main()
