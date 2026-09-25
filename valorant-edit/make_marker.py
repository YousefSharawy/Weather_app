"""Build marker.html inside the clips folder: watch each clip and press K on every one of YOUR kills.

  python make_marker.py /Volumes/lexa4/valorant
  open /Volumes/lexa4/valorant/marker.html

Keys: K = mark kill at current time, Space = play/pause, Left/Right = -/+ 2 s, , / . = -/+ 1 frame,
      N / P = next / previous clip, Z = undo last mark in this clip, 1-4 = playback speed.
Marks auto-save in the browser. "Download marks.json" saves the file; then:
  python find_kills.py /Volumes/lexa4/valorant --marks ~/Downloads/marks.json
"""
import glob, json, os, sys

EXTS = (".mp4", ".mov", ".mkv", ".m4v", ".webm")
folder = sys.argv[1] if len(sys.argv) > 1 else "."
files = sorted(os.path.basename(p) for p in glob.glob(os.path.join(folder, "*"))
               if p.lower().endswith(EXTS) and not os.path.basename(p).startswith(("._", "yousef_edit")))
if not files:
    sys.exit(f"no videos in {folder}")

page = """<!doctype html><html><head><meta charset="utf-8"><title>Kill Marker</title>
<meta name="viewport" content="width=device-width,initial-scale=1">
<style>
body{margin:0;background:#0f1115;color:#e8e8ea;font:14px/1.4 system-ui,sans-serif;display:flex;height:100vh}
aside{width:280px;overflow:auto;border-right:1px solid #262a31;flex:none}
aside div{padding:6px 10px;cursor:pointer;display:flex;justify-content:space-between;gap:8px;white-space:nowrap}
aside div span:first-child{overflow:hidden;text-overflow:ellipsis}
aside div.cur{background:#ff465533} aside div .n{color:#ff4655;font-weight:600}
main{flex:1;display:flex;flex-direction:column;min-width:0}
video{flex:1;min-height:0;background:#000;width:100%}
.bar{padding:10px 14px;display:flex;gap:10px;align-items:center;flex-wrap:wrap;border-top:1px solid #262a31}
button{background:#ff4655;color:#fff;border:0;border-radius:6px;padding:8px 12px;font-weight:600;cursor:pointer}
button.g{background:#2a2e36} .marks span{background:#23262d;border-radius:5px;padding:2px 7px;margin-right:4px}
kbd{background:#23262d;border-radius:4px;padding:1px 5px}
</style></head><body>
<aside id="list"></aside>
<main><video id="v" controls></video>
<div class="bar"><b id="name"></b><span class="marks" id="marks"></span></div>
<div class="bar"><button id="k">K &middot; mark my kill</button><button class="g" id="z">Z &middot; undo</button>
<button class="g" id="p">P &middot; prev</button><button class="g" id="n">N &middot; next</button>
<span id="total"></span><button id="dl" style="margin-left:auto">Download marks.json</button></div>
<div class="bar" style="color:#9aa0aa"><span>Only mark <b>your</b> kills (your kill banner pops at the bottom centre).
<kbd>Space</kbd> play <kbd>&larr;</kbd><kbd>&rarr;</kbd> 2s <kbd>,</kbd><kbd>.</kbd> frame <kbd>1</kbd>-<kbd>4</kbd> speed</span></div>
</main>
<script>
const FILES=__FILES__;
let marks={}; try{marks=JSON.parse(localStorage.getItem('valo-marks')||'{}')}catch(e){}
let i=0; const v=document.getElementById('v');
function save(){try{localStorage.setItem('valo-marks',JSON.stringify(marks))}catch(e){}}
function render(){
  const L=document.getElementById('list'); L.innerHTML='';
  FILES.forEach((f,j)=>{const d=document.createElement('div');d.className=j===i?'cur':'';
    d.innerHTML='<span></span><span class="n">'+((marks[f]||[]).length||'')+'</span>';d.firstChild.textContent=f;
    d.onclick=()=>load(j);L.appendChild(d);});
  document.getElementById('name').textContent=(i+1)+'/'+FILES.length+'  '+FILES[i];
  document.getElementById('marks').innerHTML=(marks[FILES[i]]||[]).map(t=>'<span>'+t.toFixed(2)+'s</span>').join('');
  document.getElementById('total').textContent=Object.values(marks).reduce((a,b)=>a+b.length,0)+' kills marked';
  L.children[i]&&L.children[i].scrollIntoView({block:'nearest'});
}
function load(j){i=Math.max(0,Math.min(FILES.length-1,j));v.src=encodeURI(FILES[i]);v.play().catch(()=>{});render();}
function mark(){const f=FILES[i];(marks[f]=marks[f]||[]).push(+v.currentTime.toFixed(2));marks[f].sort((a,b)=>a-b);save();render();}
function undo(){const f=FILES[i];if(marks[f]&&marks[f].length){marks[f].pop();save();render();}}
document.getElementById('k').onclick=mark; document.getElementById('z').onclick=undo;
document.getElementById('n').onclick=()=>load(i+1); document.getElementById('p').onclick=()=>load(i-1);
document.getElementById('dl').onclick=()=>{const b=new Blob([JSON.stringify(marks,null,1)],{type:'application/json'});
  const a=document.createElement('a');a.href=URL.createObjectURL(b);a.download='marks.json';a.click();};
document.addEventListener('keydown',e=>{const k=e.key.toLowerCase();
  if(k==='k')mark(); else if(k==='z')undo(); else if(k==='n')load(i+1); else if(k==='p')load(i-1);
  else if(k===' '){e.preventDefault();v.paused?v.play().catch(()=>{}):v.pause();}
  else if(e.key==='ArrowRight')v.currentTime+=2; else if(e.key==='ArrowLeft')v.currentTime-=2;
  else if(k==='.'){v.pause();v.currentTime+=1/30;} else if(k===','){v.pause();v.currentTime-=1/30;}
  else if('1234'.includes(k)&&k)v.playbackRate=[0.25,0.5,1,2][+k-1];});
v.addEventListener('ended',()=>{});
load(0);
</script></body></html>"""
out = os.path.join(folder, "marker.html")
open(out, "w").write(page.replace("__FILES__", json.dumps(files)))
print(f"{len(files)} clips -> {out}")
