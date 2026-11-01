"""Procedurally make the original fictional poster artwork used by CINEFLIX.

Requires: python -m pip install pillow numpy
Run from the project root: python tools/generate_art.py
The images do not contain screenshots from Netflix or copyrighted film posters.
"""
from __future__ import annotations
import math
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
OUT_POSTERS = ROOT / 'assets' / 'posters'
OUT_FEATURED = ROOT / 'assets' / 'featured'
OUT_POSTERS.mkdir(parents=True, exist_ok=True)
OUT_FEATURED.mkdir(parents=True, exist_ok=True)

W, H = 720, 1080
FONT_BOLD = '/usr/share/fonts/opentype/inter/InterDisplay-Bold.otf'
FONT_MED = '/usr/share/fonts/opentype/inter/InterDisplay-Medium.otf'
# Font file paths are authoring-time dependencies only; they are NOT bundled with the app.
if not Path(FONT_BOLD).exists():
    FONT_BOLD = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
    FONT_MED = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'

MOVIES = [
    ('eclipse_protocol', 'ECLIPSE\nPROTOCOL', 'SCI-FI', (7,14,30), (65,13,23), (239,68,50)),
    ('neon_district', 'NEON\nDISTRICT', 'ACTION', (10,15,44), (75,13,90), (255,50,165)),
    ('last_transmission', 'LAST\nTRANSMISSION', 'THRILLER', (20,24,43), (95,21,31), (255,146,66)),
    ('shadow_heist', 'SHADOW\nHEIST', 'ACTION', (7,16,31), (47,44,56), (235,182,102)),
    ('silent_current', 'SILENT\nCURRENT', 'DRAMA', (4,28,48), (6,65,91), (68,217,220)),
    ('beyond_orbit', 'BEYOND\nORBIT', 'SCI-FI', (7,24,41), (16,61,78), (111,232,205)),
    ('wild_atlas', 'WILD\nATLAS', 'ADVENTURE', (20,37,38), (42,67,51), (224,199,112)),
    ('cipher_zero', 'CIPHER\nZERO', 'THRILLER', (4,23,18), (7,50,38), (78,242,162)),
    ('blue_divide', 'BLUE\nDIVIDE', 'DRAMA', (4,25,47), (17,82,124), (96,203,255)),
    ('after_fire', 'AFTER\nTHE FIRE', 'DRAMA', (29,12,22), (105,25,15), (255,126,51)),
    ('velocity_one', 'VELOCITY\nONE', 'ACTION', (7,11,35), (36,11,80), (192,69,255)),
    ('golden_sky', 'GOLDEN\nSKY', 'ADVENTURE', (44,27,41), (120,59,47), (255,191,94)),
]


def rgba(rgb, a):
    return (int(rgb[0]), int(rgb[1]), int(rgb[2]), int(a))


def gradient_base(seed, top, low, accent):
    rng = np.random.default_rng(seed)
    yy, xx = np.mgrid[0:H, 0:W]
    ratio = (yy / H) ** 0.78
    rgb = np.empty((H, W, 3), dtype=np.float32)
    for channel in range(3):
        rgb[:, :, channel] = top[channel] * (1 - ratio) + low[channel] * ratio
    for i in range(3):
        cx = rng.uniform(0.13*W, 0.85*W)
        cy = rng.uniform(0.1*H, 0.69*H)
        r = rng.uniform(0.13*W, 0.43*W)
        dist = ((xx-cx)**2 + (yy-cy)**2) / (r*r)
        glow = np.exp(-dist / 2.2) * rng.uniform(0.08, 0.20)
        for ch in range(3):
            rgb[:, :, ch] = rgb[:, :, ch] * (1-glow) + accent[ch]*glow
    # Film grain and subtle vignette.
    grain = rng.normal(0, 6, (H, W, 1))
    vignette = ((xx - W/2)/(W*.93))**2 + ((yy-H/2)/(H*.97))**2
    rgb = np.clip((rgb+grain)*(1-0.28*vignette[..., None]), 0, 255)
    return Image.fromarray(rgb.astype('uint8'), 'RGB').convert('RGBA')


def glow_line(image, xy, color, width=5, blur=16, glow_alpha=140):
    layer = Image.new('RGBA', (W, H))
    draw = ImageDraw.Draw(layer)
    draw.line(xy, fill=rgba(color, glow_alpha), width=width*3, joint='curve')
    image.alpha_composite(layer.filter(ImageFilter.GaussianBlur(blur)))
    layer2 = Image.new('RGBA', (W, H))
    ImageDraw.Draw(layer2).line(xy, fill=rgba(color, 200), width=width, joint='curve')
    image.alpha_composite(layer2)


def circle_glow(image, center, radius, color, alpha=190, blur=90):
    layer = Image.new('RGBA', (W,H))
    ImageDraw.Draw(layer).ellipse((center[0]-radius, center[1]-radius,
                                    center[0]+radius, center[1]+radius),
                                   fill=rgba(color, alpha))
    image.alpha_composite(layer.filter(ImageFilter.GaussianBlur(blur)))


def starfield(draw, rng, qty=110):
    for _ in range(qty):
        x = int(rng.uniform(10,W-10)); y = int(rng.uniform(40,H*.7))
        r = rng.choice([1,1,1,2,3])
        val = int(rng.uniform(120,225))
        draw.ellipse((x-r,y-r,x+r,y+r),fill=(220,234,255,val))


def cityscape(draw, rng, ground=800, minheight=150, maxheight=540, palette=((7,9,22),(16,18,34))):
    for i in range(-20, W+80, 70):
        bh = int(rng.integers(minheight, maxheight))
        bw = int(rng.integers(54,100))
        x0, y0 = i, ground-bh
        color = palette[int(rng.integers(0,len(palette)))]
        draw.rectangle((x0,y0,x0+bw,ground+30), fill=rgba(color,235))
        for wx in range(x0+11, x0+bw-9, 15):
            for wy in range(y0+22,ground-12,23):
                if rng.random()>.5:
                    draw.rectangle((wx,wy,wx+5,wy+10), fill=(255,190,122, int(rng.uniform(70,150))))


def mountain(draw, rng, y, color, amp=140, points=13):
    xs = np.linspace(-20,W+20,points)
    ys = [y-int(rng.uniform(-amp*.45,amp)) for _ in xs]
    xy = [(int(x),int(yy)) for x,yy in zip(xs,ys)] + [(W+20,H+50),(-20,H+50)]
    draw.polygon(xy, fill=rgba(color,255))


def scene(identifier, seed, top, low, accent):
    rng = np.random.default_rng(seed)
    img = gradient_base(seed, top, low, accent)
    d = ImageDraw.Draw(img, 'RGBA')

    if identifier == 'eclipse_protocol':
        starfield(d,rng,170)
        circle_glow(img,(390,390),210,(251,73,40),170,75)
        d = ImageDraw.Draw(img, 'RGBA')
        for r,alpha in [(230,40),(212,110),(195,255)]:
            d.ellipse((390-r,400-r,390+r,400+r), outline=(255,102,62,alpha),width=7 if r==195 else 12)
        d.ellipse((199,209,581,591), fill=(7,11,21,255))
        # Dramatic red solar crescent and a figure looking up.
        d.arc((194,203,586,597), 205, 445, fill=(255,195,110,240), width=9)
        mountain(d,rng,850,(9,12,22),70)
        d.ellipse((340,644,399,703),fill=(4,5,12,255))
        d.polygon([(327,704),(410,704),(451,873),(300,873)],fill=(5,7,14,255))
        glow_line(img,[(0,746),(210,730),(345,746),(700,692)],(252,75,52),3,17)

    elif identifier == 'neon_district':
        circle_glow(img,(355,335),180,(247,54,187),175,90)
        d = ImageDraw.Draw(img,'RGBA')
        cityscape(d,rng,ground=832,minheight=270,maxheight=610,palette=((10,13,38),(17,20,54),(21,13,44)))
        d.polygon([(287,640),(434,640),(720,H),(0,H)],fill=(8,13,29,255))
        for x in range(-3,4):
            glow_line(img,[(360+x*44,630),(360+x*155,H)],(92,138,255) if x%2 else (255,56,183),3,12)
        glow_line(img,[(0,647),(W,647)],(253,60,162),3,17)
        for x in [150,244,478,592]:
            glow_line(img,[(x,360),(x,650)],(204,55,230),2,14)

    elif identifier == 'last_transmission':
        circle_glow(img,(504,364),130,(255,158,62),220,65)
        d=ImageDraw.Draw(img,'RGBA')
        d.ellipse((380,245,630,495),fill=(246,170,89,220))
        mountain(d,rng,754,(81,38,49),150)
        mountain(d,rng,860,(31,27,37),90)
        # radio mast tower
        d.polygon([(313,858),(354,420),(371,420),(412,858)], fill=(8,15,29,255))
        for y in range(470,800,56):
            s = 13+int((y-420)*.05)
            d.line((362-s,y,362+s,y+32),fill=(187,166,154,210),width=3)
            d.line((362+s,y,362-s,y+32),fill=(187,166,154,210),width=3)
        for rad in [90,140,190]:
            d.arc((362-rad,390-rad,362+rad,390+rad),180,360,fill=(255,157,90,115),width=4)
        d.ellipse((356,404,367,415),fill=(255,129,79,255))

    elif identifier == 'shadow_heist':
        circle_glow(img,(490,334),150,(255,191,112),145,89)
        d = ImageDraw.Draw(img,'RGBA')
        cityscape(d,rng,ground=850,minheight=280,maxheight=580,palette=((15,22,33),(19,22,35)))
        d.polygon([(40,740),(W,745),(W,H),(0,H)],fill=(5,9,19,255))
        # simple figure silhouette at rooftop edge
        d.ellipse((413,594,465,648),fill=(6,10,22,255))
        d.polygon([(423,645),(457,645),(500,770),(395,770)],fill=(8,10,21,255))
        glow_line(img,[(0,731),(720,726)],(255,185,113),4,15)
        d.line((445,655,510,692),fill=(8,10,20,255),width=20)

    elif identifier == 'silent_current':
        circle_glow(img,(359,330),190,(75,217,216),130,105)
        d=ImageDraw.Draw(img,'RGBA')
        for i in range(8):
            y=215+i*75
            pts=[]
            for x in range(0,W+15,15):
                pts.append((x,int(y+23*math.sin(x*.014+i*.67))))
            d.line(pts,fill=(89,218,223,max(38,130-i*12)),width=3)
        d.polygon([(0,700),(720,660),(720,1080),(0,1080)],fill=(4,23,40,160))
        # moon jellyfish shapes
        for x,y,r in [(190,460,55),(530,584,34),(445,310,24)]:
            d.arc((x-r,y-r,x+r,y+r),180,360,fill=(157,241,235,185),width=4)
            for xx in (x-r//2,x,x+r//2):
                d.line((xx,y,xx-8,y+95),fill=(113,221,231,90),width=2)

    elif identifier == 'beyond_orbit':
        starfield(d,rng,190)
        circle_glow(img,(423,384),250,(88,227,213),110,86)
        d=ImageDraw.Draw(img,'RGBA')
        d.ellipse((190,180,655,645),fill=(31,129,151,255))
        d.pieslice((190,180,655,645),20,165,fill=(17,66,91,160))
        d.arc((170,265,670,555),170,350,fill=(160,239,228,190),width=8)
        d.ellipse((135,180,183,228),fill=(240,242,217,200))
        mountain(d,rng,790,(8,30,44),125)
        mountain(d,rng,905,(5,19,30),68)

    elif identifier == 'wild_atlas':
        circle_glow(img,(510,342),185,(255,218,126),195,75)
        d=ImageDraw.Draw(img,'RGBA')
        d.ellipse((395,232,620,457),fill=(251,204,122,180))
        mountain(d,rng,700,(77,107,81),210)
        mountain(d,rng,800,(32,74,65),140)
        mountain(d,rng,910,(17,46,46),80)
        for x in np.linspace(0,W,28):
            xx=int(x+rng.uniform(-13,13))
            yy=int(rng.uniform(775,870))
            h=int(rng.uniform(55,135))
            d.polygon([(xx-26,yy),(xx,yy-h),(xx+28,yy)],fill=(7,36,31,200))
            d.rectangle((xx-4,yy-15,xx+3,yy+30),fill=(8,28,28,255))

    elif identifier == 'cipher_zero':
        circle_glow(img,(345,430),140,(52,243,164),150,100)
        d=ImageDraw.Draw(img,'RGBA')
        for col in range(28):
            x=col*28+int(rng.integers(-9,9))
            y=int(rng.integers(-340,-20))
            for row in range(24):
                yy=y+row*41
                if yy<30 or yy>860:continue
                a=int(rng.uniform(22,140))
                d.rectangle((x,yy,x+4,yy+int(rng.integers(5,28))),fill=(52,240,148,a))
        # digital padlock / circular focus
        for rad,a in [(169,66),(150,104),(124,200)]:
            d.arc((360-rad,430-rad,360+rad,430+rad),20,336,fill=(95,253,177,a),width=5)
        d.rounded_rectangle((288,395,433,516),radius=16,outline=(95,241,184,190),width=6)
        d.arc((315,325,406,437),180,360,fill=(120,251,200,200),width=7)
        glow_line(img,[(20,706),(702,690)],(64,229,151),4,14)

    elif identifier == 'blue_divide':
        circle_glow(img,(492,300),175,(139,215,255),160,100)
        d=ImageDraw.Draw(img,'RGBA')
        d.ellipse((390,190,620,420),fill=(139,222,255,155))
        d.polygon([(0,748),(170,450),(260,640),(384,333),(540,650),(650,470),(720,660),(720,H),(0,H)],fill=(38,110,153,245))
        d.polygon([(125,565),(170,450),(214,568),(384,333),(460,534),(650,470),(710,632),(634,550),(537,693),(376,463),(265,719),(173,554)],fill=(175,227,242,135))
        d.polygon([(0,820),(720,753),(720,H),(0,H)], fill=(10,48,75,240))
        for i in range(7):
            pts=[(x,int(822+i*29+11*math.sin(x*.012+i*.7))) for x in range(0,W+12,12)]
            d.line(pts,fill=(113,214,247,100-i*9),width=4)

    elif identifier == 'after_fire':
        circle_glow(img,(376,420),230,(255,123,44),195,87)
        d=ImageDraw.Draw(img,'RGBA')
        cityscape(d,rng,ground=900,minheight=280,maxheight=540,palette=((37,21,30),(22,20,29),(43,24,29)))
        for i in range(24):
            x=int(rng.uniform(-30,W+30)); y=int(rng.uniform(500,900))
            h=int(rng.uniform(70,230))
            d.polygon([(x-25,y),(x,y-h),(x+32,y),(x,y+60)],fill=(245,87,27,int(rng.uniform(50,120))))
        mountain(d,rng,925,(18,15,22),70)
        for i in range(70):
            x=int(rng.uniform(0,W)); y=int(rng.uniform(50,800))
            d.ellipse((x,y,x+int(rng.uniform(2,6)),y+int(rng.uniform(2,6))),fill=(255,150,60,145))

    elif identifier == 'velocity_one':
        circle_glow(img,(360,440),160,(182,87,255),170,87)
        d=ImageDraw.Draw(img,'RGBA')
        d.polygon([(330,510),(400,510),(720,1080),(0,1080)],fill=(7,12,38,220))
        for i in range(-4,5):
            glow_line(img,[(360+i*21,510),(360+i*230,1080)],(239,67,230) if i%2 else (61,137,255),3,20)
        for i in range(12):
            yy=int(590+i*44 + i*i*1.3)
            glow_line(img,[(0,yy),(720,yy)],(91,95,251),2,13,90)
        d=ImageDraw.Draw(img,'RGBA')
        d.polygon([(170,785),(228,695),(490,695),(560,785),(544,855),(184,855)],fill=(10,16,38,255))
        d.polygon([(245,700),(297,635),(423,635),(488,700)],fill=(42,33,90,255))
        for cx in [219,512]:
            d.ellipse((cx-29,797,cx+29,856),fill=(3,6,21,255))
            d.ellipse((cx-13,810,cx+13,840),fill=(164,114,255,230))
        glow_line(img,[(194,783),(277,783)],(255,71,151),10,16)
        glow_line(img,[(459,783),(540,783)],(255,71,151),10,16)

    elif identifier == 'golden_sky':
        circle_glow(img,(403,363),240,(255,206,112),220,83)
        d=ImageDraw.Draw(img,'RGBA')
        d.ellipse((275,238,531,494),fill=(255,216,135,170))
        mountain(d,rng,710,(133,78,75),180)
        mountain(d,rng,842,(64,57,61),112)
        mountain(d,rng,950,(28,34,45),75)
        for x in (90,630):
            d.line((x,830,x+20,370),fill=(22,35,38,220),width=15)
            for angle in range(-70,50,18):
                ex=x+20+int(160*math.cos(math.radians(angle)))
                ey=370+int(130*math.sin(math.radians(angle)))
                d.polygon([(x+20,370),(ex,ey),(x+20,388)],fill=(16,43,42,220))

    # Cinematic grading; detail is strongest in the upper two-thirds of the art.
    return img.convert('RGB')


def create_poster(art, title, genre):
    image = art.convert('RGBA')
    shadow = Image.new('RGBA',(W,H),(0,0,0,0))
    pix = np.zeros((H,W,4),dtype=np.uint8)
    # dark bottom gradient behind readable typography
    a = np.clip((np.arange(H)-615)/380,0,1)
    pix[:,:,3]=(a[:,None]*244).astype(np.uint8)
    overlay=Image.fromarray(pix,'RGBA')
    image.alpha_composite(overlay)
    d=ImageDraw.Draw(image,'RGBA')
    d.rounded_rectangle((54,70,64,96),radius=2,fill=(229,9,20,255))
    d.text((81,69),'A CINEFLIX ORIGINAL',font=ImageFont.truetype(FONT_MED,19),fill=(255,255,255,225),stroke_width=0)

    fs = 75 if max(len(line) for line in title.split('\n'))<=11 else 57
    font=ImageFont.truetype(FONT_BOLD,fs)
    yy = 740 if title.count('\n')==1 else 812
    for line in title.split('\n'):
        # faint soft type shadow for contrast
        d.text((53,yy+3),line,font=font,fill=(0,0,0,130),stroke_width=1,stroke_fill=(0,0,0,130))
        d.text((53,yy),line,font=font,fill=(255,255,255,245))
        yy+=int(fs*1.01)
    d.rectangle((57,950,126,954),fill=(230,9,20,255))
    d.text((57,971),f'2026   /   {genre}   /   ORIGINAL FILM',font=ImageFont.truetype(FONT_MED,19),fill=(213,214,227,220))
    return image.convert('RGB')


for n,(movie_id,title,genre,top,low,accent) in enumerate(MOVIES, 1):
    art=scene(movie_id,800+n,top,low,accent)
    poster=create_poster(art,title,genre)
    poster.save(OUT_POSTERS/f'{movie_id}.jpg', quality=88, subsampling=0, optimize=True)
    if n<=3:
        art.save(OUT_FEATURED/f'{movie_id}.jpg',quality=91,subsampling=0,optimize=True)
    print(f'Generated {movie_id}')
print('Done.')
