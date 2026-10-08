import sys,json,re,subprocess,pathlib
sys.path.insert(0,"/Volumes/TONY SSD/TONY_WORKSPACE/CODE/TonyOS_Workspace/tools/youtube-intelligence/src")
from tony_youtube_intelligence import acquisition as a
from tony_youtube_intelligence.utils import YouTubeIntelligenceError
video=sys.argv[1];start=float(sys.argv[2]);end=float(sys.argv[3]);out=pathlib.Path(sys.argv[4]);diagnostics=[]
def safe_run(command,timeout=1800):
 completed=subprocess.run(command,text=True,capture_output=True,timeout=timeout)
 raw=(completed.stderr or "")+"\n"+(completed.stdout or "")
 codes=sorted(set(re.findall(r"(?:HTTP(?: Error)?|Server returned|HTTP error|status(?: code)?)\s*[:=]?\s*(\d{3})",raw,re.I)))
 ff=sorted(set(re.findall(r"ffmpeg exited with code (\d+)",raw)))
 diagnostics.append({"processExitCode":completed.returncode,"httpStatusCodes":codes,"ffmpegExitCodes":ff,"forbiddenMentioned":"403 Forbidden" in raw,"signedURLsLogged":False,"restrictionMentioned":bool(re.search(r"403|PO.token|private video|captcha|sign in to confirm",raw,re.I)),"safeErrorClasses":sorted(set(re.findall(r"(?:HTTP Error \d+|Server returned \d+|Invalid data found|Error opening input|Connection refused|Unable to open resource|TLS error|Protocol not found|Requested format is not available)",raw,re.I)))})
 if completed.returncode: raise YouTubeIntelligenceError("Authorized acquisition failed; sanitized diagnostic recorded")
 return completed
a.run=safe_run
try:
 result=a.download("https://www.youtube.com/watch?v="+video,apply=True,approval=video,rights="licensed",section=None if start<0 else (start,end))
except Exception as e:
 result={"status":"failed","videoId":video,"errorType":type(e).__name__}
result["diagnostics"]=diagnostics;out.write_text(json.dumps(result,indent=2)+"\n");print(json.dumps(result))
