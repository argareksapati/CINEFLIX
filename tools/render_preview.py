"""Create an illustrative design preview, NOT a Flutter emulator screenshot."""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
from pathlib import Path
import json
import numpy as np

ROOT=Path(__file__).resolve().parent.parent
ASSET=ROOT/'assets'
OUT=ROOT/'docs'/'preview_mockup.png'
MOVIE_LOOKUP={m['slug']:m for m in json.loads((ROOT/'tools/demo_movies.json').read_text())}
W,H=1360,1060
TOP=(13,15,29)
BOTTOM=(21,16,32)
y,x=np.mgrid[0:H,0:W]; r=(y/H)[...,None]
a=np.zeros((H,W,3),dtype=np.uint8)
for i in range(3):
    a[:,:,i]=np.clip(TOP[i]*(1-r[:,:,0])+BOTTOM[i]*r[:,:,0],0,255)
canvas=Image.fromarray(a,'RGB').convert('RGBA')
d=ImageDraw.Draw(canvas)
F_REG='/usr/share/fonts/opentype/inter/InterDisplay-Regular.otf'
F_BOLD='/usr/share/fonts/opentype/inter/InterDisplay-Bold.otf'
F_MED='/usr/share/fonts/opentype/inter/InterDisplay-Medium.otf'
F_HEAVY='/usr/share/fonts/opentype/inter/InterDisplay-ExtraBold.otf'
fonts={}
def f(sz,bold=False,heavy=False):
    key=(sz,bold,heavy)
    if key not in fonts:
        fonts[key]=ImageFont.truetype(F_HEAVY if heavy else (F_BOLD if bold else F_REG),sz)
    return fonts[key]

def rr(draw,coords,rad,fill,outline=None,width=1):
    draw.rounded_rectangle(coords,radius=rad,fill=fill,outline=outline,width=width)

def text(draw,x,y,s,size=16,fill='white',bold=False,heavy=False):
    draw.text((x,y),s,font=f(size,bold,heavy),fill=fill)

def paste_rounded(base,im,box,radius):
    xx,yy,ww,hh=box
    src=im.convert('RGB')
    sw,sh=src.size
    target=ww/hh
    if sw/sh>target:
        neww=int(sh*target)
        src=src.crop(((sw-neww)//2,0,(sw+neww)//2,sh))
    else:
        newh=int(sw/target)
        src=src.crop((0,(sh-newh)//2,sw,(sh+newh)//2))
    src=src.resize((ww,hh),Image.Resampling.LANCZOS).convert('RGBA')
    mask=Image.new('L',(ww,hh),0); ImageDraw.Draw(mask).rounded_rectangle((0,0,ww,hh),radius,fill=255)
    base.paste(src,(xx,yy),mask)

def phone(left,top,scroll=False):
    outer=(left,top,left+440,top+930)
    glow=Image.new('RGBA',(W,H))
    dd=ImageDraw.Draw(glow)
    dd.rounded_rectangle((left-15,top-11,left+455,top+947),radius=57,fill=(0,0,0,125))
    canvas.alpha_composite(glow.filter(ImageFilter.GaussianBlur(24)))
    d=ImageDraw.Draw(canvas)
    rr(d,outer,51,(30,31,39,255),outline=(83,81,97,255),width=2)
    ox,oy=left+11,top+11
    pw,ph=418,908
    rr(d,(ox,oy,ox+pw,oy+ph),43,(11,11,16,255))
    # status bar
    text(d,ox+28,oy+12,'9:41',12,'#F0F0F3',True)
    d.rounded_rectangle((ox+164,oy+11,ox+254,oy+26),radius=10,fill=(1,1,6,255))
    text(d,ox+342,oy+12,'●  ▰',10,'#F2F2F2',True)
    ix,iy=ox,oy+42
    text(d,ix+21,iy,'CINE',26,'#FFFFFF',heavy=True)
    text(d,ix+88,iy,'FLIX',26,'#E50914',heavy=True)
    # search/profile
    d.ellipse((ix+326,iy+10,ix+337,iy+21),outline='#F2F2F5',width=2)
    d.line((ix+336,iy+19,ix+345,iy+28),fill='#F2F2F5',width=2)
    rr(d,(ix+362,iy+2,ix+395,iy+35),11,(101,33,62,255),outline=(175,80,112,255))
    d.ellipse((ix+373,iy+9,ix+386,iy+21),fill=(241,159,195,255))
    d.arc((ix+368,iy+18,ix+391,iy+32),180,360,fill=(241,159,195,255),width=3)
    text(d,ix+22,iy+39,'FILM FAVORIT DALAM SATU TEMPAT',9,'#888995',True)
    cy=iy+81
    chips=[('Semua',68),('Sci-Fi',65),('Aksi',61),('Thriller',74),('Drama',70)]
    cx=ix+22
    for index,(name,width) in enumerate(chips):
        if cx+width>ix+pw-17:break
        rr(d,(cx,cy,cx+width,cy+33),16,(229,9,20,255) if index==0 else (34,34,43,255))
        text(d,cx+14,cy+8,name,11,'#FFF' if index==0 else '#BABAC4',True)
        cx+=width+8

    nav_y=oy+ph-65
    rr(d,(ix+2,nav_y,ix+pw-2,oy+ph-2),0,(17,17,22,255))
    d.line((ix+2,nav_y,ix+pw-2,nav_y),fill=(42,42,50,255),width=1)
    for j,label in enumerate(['Home','Explore','My List']):
        cx=ix+75+j*134
        color='#E50914' if j==0 else '#878792'
        if j==0:
            d.line([(cx-10,nav_y+24),(cx,nav_y+14),(cx+10,nav_y+24)],fill=color,width=2)
            d.rectangle((cx-7,nav_y+22,cx+7,nav_y+33),outline=color,width=2)
        elif j==1:
            d.ellipse((cx-10,nav_y+13,cx+10,nav_y+33),outline=color,width=2)
            d.line((cx-5,nav_y+29,cx+5,nav_y+17),fill=color,width=2)
        else:
            text(d,cx-11,nav_y+9,'♡',26,color,True)
        text(d,cx-14 if j==1 else cx-11,nav_y+41,label,10,color,True)

    if not scroll:
        text(d,ix+23,cy+66,'FEATURED COLLECTION',10,'#E50914',True)
        text(d,ix+22,cy+83,'Now Playing',27,'#FFFFFF',heavy=True)
        text(d,ix+338,cy+99,'HOT',10,'#E8B175',True)
        bx,by,bw,bh=ix+28,cy+130,pw-56,364
        paste_rounded(canvas,Image.open(ASSET/'featured/eclipse_protocol.jpg'),(bx,by,bw,bh),18)
        # gradient to mimic flutter featured card
        ov=Image.new('RGBA',(bw,bh))
        a=np.zeros((bh,bw,4),dtype=np.uint8)
        a[:,:,3]=np.clip(((np.arange(bh)-160)/200)*248,0,248).astype(np.uint8)[:,None]
        ov=Image.fromarray(a,'RGBA')
        m=Image.new('L',(bw,bh)); ImageDraw.Draw(m).rounded_rectangle((0,0,bw,bh),radius=18,fill=255)
        backdrop=canvas.crop((bx,by,bx+bw,by+bh)).convert('RGBA')
        backdrop.alpha_composite(ov)
        canvas.paste(backdrop,(bx,by),m)
        d=ImageDraw.Draw(canvas)
        rr(d,(bx+16,by+15,bx+146,by+41),5,(8,8,13,209),outline=(91,91,96,255))
        text(d,bx+26,by+22,'C • FEATURED',10,'#FFFFFF',True)
        text(d,bx+19,by+207,'★  8.4     •     2024  •  Sci-Fi',12,'#F6D194',True)
        text(d,bx+19,by+230,'DUNE:',30,'#FFFFFF',heavy=True)
        text(d,bx+19,by+261,'PART TWO',30,'#FFFFFF',heavy=True)
        text(d,bx+19,by+305,'Perjalanan epik menembus gurun Arrakis...',10,'#C9C9D0')
        rr(d,(bx+17,by+328,bx+199,by+357),9,(229,9,20,255))
        text(d,bx+70,by+335,'▶  Play',12,'#FFFFFF',True)
        rr(d,(bx+210,by+328,bx+345,by+357),9,(50,50,59,255),outline=(115,115,122,255))
        text(d,bx+247,by+335,'ⓘ  Info',12,'#FFFFFF',True)
        dots_y=by+bh+16
        for i in range(3):
            rr(d,(ix+177+i*29,dots_y,ix+198+i*29 if i==0 else ix+185+i*29,dots_y+6),3,
               (229,9,20,255) if i==0 else (82,82,93,255))
        sec_y=dots_y+40
        d.rounded_rectangle((ix+22,sec_y+2,ix+26,sec_y+25),radius=2,fill='#E50914')
        text(d,ix+37,sec_y,'Trending Now',21,'#FFFFFF',True)
        text(d,ix+323,sec_y+8,'Lagi ramai',10,'#A1A1A9')
        # partial thumbnails are intentionally clipped by visual-only navbar
        for i,poster in enumerate(['spider_verse','dune_part_two','inside_out_2']):
            posterx=ix+22+i*129
            paste_rounded(canvas,Image.open(ASSET/f'offline_posters/{poster}.jpg'),(posterx,sec_y+39,117,175),10)
        # navbar re-applied over the poster strip (mask effectively hides bottom)
        d=ImageDraw.Draw(canvas)
        d.rectangle((ix+2,nav_y,ix+pw-2,oy+ph-2), fill=(17,17,22,255))
        d.line((ix+2,nav_y,ix+pw-2,nav_y),fill=(42,42,50,255),width=1)
    else:
        sec_y=cy+62
        rows=[('Trending Now','Lagi ramai',['spider_verse','dune_part_two','inside_out_2']),
              ('Popular','Favorit penonton',['interstellar','the_batman','kung_fu_panda_4']),
              ('Top Rated','Rating tertinggi',['interstellar','oppenheimer','spider_verse'])]
        for title,subtitle,posters in rows:
            d=ImageDraw.Draw(canvas)
            rr(d,(ix+22,sec_y+1,ix+26,sec_y+24),2,(229,9,20,255))
            text(d,ix+37,sec_y,title,21,'#FFFFFF',True)
            text(d,ix+303,sec_y+7,subtitle,10,'#A0A0AB')
            for j,name in enumerate(posters):
                xx=ix+22+j*132
                poster_y=sec_y+36
                if poster_y >= nav_y: continue
                visible_h=min(168,nav_y-poster_y)
                if visible_h>=168:
                    paste_rounded(canvas,Image.open(ASSET/f'offline_posters/{name}.jpg'),(xx,poster_y,118,168),9)
                else:
                    src=Image.open(ASSET/f'offline_posters/{name}.jpg').resize((118,176),Image.Resampling.LANCZOS)
                    canvas.paste(src.crop((0,0,118,visible_h)),(xx,poster_y))
                d=ImageDraw.Draw(canvas)
                txt=MOVIE_LOOKUP[name]['title'].title()
                if len(txt)>16:txt=txt[:15]+'…'
                if sec_y+225 < nav_y:
                    text(d,xx,sec_y+210,txt,11,'#FFFFFF',True)
                if sec_y+250 < nav_y:
                    text(d,xx,sec_y+231,f"★  {MOVIE_LOOKUP[name]['rating']:.1f}   {MOVIE_LOOKUP[name]['genre']}",10,'#A3A3AC')
            sec_y+=273
        d=ImageDraw.Draw(canvas)
        d.rectangle((ix+2,nav_y,ix+pw-2,oy+ph-2),fill=(17,17,22,255))
        d.line((ix+2,nav_y,ix+pw-2,nav_y),fill=(42,42,50,255),width=1)
    # redraw footer icons on top
    d=ImageDraw.Draw(canvas)
    for j,label in enumerate(['Home','Explore','My List']):
        cx=ix+75+j*134
        color='#E50914' if j==0 else '#878792'
        if j==0:
            d.line([(cx-10,nav_y+24),(cx,nav_y+14),(cx+10,nav_y+24)],fill=color,width=2)
            d.rectangle((cx-7,nav_y+22,cx+7,nav_y+33),outline=color,width=2)
        elif j==1:
            d.ellipse((cx-10,nav_y+13,cx+10,nav_y+33),outline=color,width=2)
            d.line((cx-5,nav_y+29,cx+5,nav_y+17),fill=color,width=2)
        else:
            text(d,cx-11,nav_y+9,'♡',26,color,True)
        text(d,cx-14 if j==1 else cx-11,nav_y+41,label,10,color,True)

phone(160,72,False)
phone(760,72,True)
d=ImageDraw.Draw(canvas)
text(d,180,1013,'HOME · CAROUSEL VIEW',15,'#C7C8D0',True)
text(d,784,1013,'SCROLL · MOVIE COLLECTIONS',15,'#C7C8D0',True)
# label above phones
text(d,160,19,'CINEFLIX  /  NETFLIX-INSPIRED UI CONCEPT V2',16,'#D3D3DF',True)
text(d,1050,20,'TASK 01  •  2026',13,'#E50914',True)
canvas.convert('RGB').save(OUT,quality=93)
print(OUT)
