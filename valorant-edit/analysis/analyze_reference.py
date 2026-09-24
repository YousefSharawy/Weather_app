import cv2, numpy as np, librosa, json
import sys
V=sys.argv[1]
cap=cv2.VideoCapture(V); prev=None; prevh=None; rows=[]; i=0
while True:
    ok,f=cap.read()
    if not ok: break
    g=cv2.cvtColor(cv2.resize(f,(360,203)),cv2.COLOR_BGR2GRAY)
    hsv=cv2.cvtColor(cv2.resize(f,(360,203)),cv2.COLOR_BGR2HSV)
    h=cv2.calcHist([hsv],[0,1],None,[30,32],[0,180,0,256]); cv2.normalize(h,h)
    r={"f":i,"t":round(i/30,3),"bright":float(g.mean()),"sat":float(hsv[...,1].mean()),
       "sharp":float(cv2.Laplacian(g,cv2.CV_64F).var())}
    if prev is not None:
        r["diff"]=float(np.abs(g.astype(int)-prev).mean())
        r["hist"]=float(cv2.compareHist(prevh,h,cv2.HISTCMP_BHATTACHARYYA))
        fl=cv2.calcOpticalFlowFarneback(prev.astype(np.uint8),g,None,0.5,3,15,3,5,1.2,0)
        H,W=g.shape; ys,xs=np.mgrid[0:H,0:W]; cx,cy=xs-W/2,ys-H/2
        n=np.sqrt(cx**2+cy**2)+1e-6
        r["flow_mag"]=float(np.linalg.norm(fl,axis=2).mean())
        r["flow_dx"]=float(fl[...,0].mean()); r["flow_dy"]=float(fl[...,1].mean())
        r["zoom"]=float(((fl[...,0]*cx+fl[...,1]*cy)/n).mean())  # + = zoom in (radial outward)
        r["rot"]=float(((-fl[...,0]*cy+fl[...,1]*cx)/n).mean())
    else: r.update(diff=0,hist=0,flow_mag=0,flow_dx=0,flow_dy=0,zoom=0,rot=0)
    rows.append(r); prev=g; prevh=h; i+=1
y,sr=librosa.load(sys.argv[2],sr=22050)
tempo,beats=librosa.beat.beat_track(y=y,sr=sr,units="time")
on_env=librosa.onset.onset_strength(y=y,sr=sr)
onsets=librosa.onset.onset_detect(onset_envelope=on_env,sr=sr,units="time")
rms=librosa.feature.rms(y=y)[0]; rt=librosa.times_like(rms,sr=sr)
json.dump({"frames":rows,"tempo":float(np.atleast_1d(tempo)[0]),"beats":beats.tolist(),"onsets":onsets.tolist(),
  "onset_strength":[[float(t),float(v)] for t,v in zip(librosa.times_like(on_env,sr=sr),on_env)],
  "rms":[[float(t),float(v)] for t,v in zip(rt,rms)]},open("analysis.json","w"))
print("tempo",tempo,"beats",len(beats),"onsets",len(onsets))
