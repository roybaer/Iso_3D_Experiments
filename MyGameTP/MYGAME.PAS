program test;

uses
 graph,crt;

var
 termap,map:array[1..32,1..32]of byte;
 xstart,ystart:integer;
 maxx,maxy:word;
 ch:char;
 mapfile:file;
 bauwerke,gelaende:text;
 c,cmode,res:byte;
 buildings:array[1..63]of string[13];
 terraign:array[0..15]of string[12];


procedure drv_svgatc;external;
{$L svgatc.obj}

procedure drv_svga64k;external;
{$L svga64k.obj}

procedure drv_svga32k;external;
{$L svga32k.obj}

procedure svga256_driver;external;
{$L svga256.obj}

procedure drv_svga16;external;
{$L svga16.obj}

procedure drv_cga;external;
{$L cga.obj}


const
 res320x200=0;
 res640x200=1;
 res640x350=2;
 res640x400=3;
 res640x480=4;
 res800x600=5;
 res1024x768=6;
 res1280x1024=7;

 grey1bit=0;
 color4bit=1;
 grey4bit=2;
 color8bit=3;
 grey8bit=4;
 color15bit=5;
 color16bit=6;
 color24bit=7;

procedure initmode(res,cmode:byte);
var
 gd,gm:integer;
 a,b,c:byte;
begin
 case cmode of
  0:begin
     gd:=cga;
     registerbgidriver(@drv_cga);
     case res of
      0:gm:=0;
      1:gm:=4;
      4:gm:=5;
      else exit;
     end;
     initgraph(gd,gm,'');
    end;
  1:begin
     gd:=installuserdriver('svga16',nil);
     registerbgidriver(@drv_svga16);
     if res<3 then gm:=res else if res in[4..6] then gm:=res-1 else exit;
     initgraph(gd,gm,'');
     for c:=0 to 1 do for b:=0 to 3 do for a:=0 to 1 do
     begin
      setrgbpalette(c or(b shl 1)or(a shl 3),(a*255)div 4,(b*85)div 4,(c*255)div 4);
      setpalette(c or(b shl 1)or(a shl 3),c or(b shl 1)or(a shl 3));
     end;
    end;
  2:begin
     gd:=installuserdriver('svga16',nil);
     registerbgidriver(@drv_svga16);
     if res<3 then gm:=res else if res in[4..6] then gm:=res-1 else exit;
     initgraph(gd,gm,'');
     for a:=0 to 15 do
     begin
      setrgbpalette(a,a shl 2,a shl 2,a shl 2);
      setpalette(a,a);
     end;
    end;
  3:begin
     gd:=installuserdriver('svga256',nil);
     registerbgidriver(@svga256_driver);
     if res=0 then gm:=0 else if res in[3..6] then gm:=res-2 else
      if res=7 then gm:=6 else exit;
     initgraph(gd,gm,'');
     for c:=0 to 3 do for b:=0 to 7 do for a:=0 to 7 do
      setrgbpalette
       (c or(b shl 2)or(a shl 5),(a*36)div 4,(b*36)div 4,(c*85)div 4);
    end;
  4:begin
     gd:=installuserdriver('svga256',nil);
     registerbgidriver(@svga256_driver);
     if res=0 then gm:=0 else if res in[3..6] then gm:=res-2 else
      if res=7 then gm:=6 else exit;
     initgraph(gd,gm,'');
     for a:=0 to 255 do setrgbpalette(a,a shr 2,a shr 2,a shr 2);
    end;
  5:begin
     gd:=installuserdriver('svga32k',nil);
     registerbgidriver(@drv_svga32k);
     if res=0 then gm:=res else if res in[2..7] then gm:=res-1 else exit;
     initgraph(gd,gm,'');
    end;
  6:begin
     gd:=installuserdriver('svga64k',nil);
     registerbgidriver(@drv_svga64k);
     if res=0 then gm:=res else if res in[2..7] then gm:=res-1 else exit;
     initgraph(gd,gm,'');
    end;
  7:begin
     gd:=installuserdriver('svgatc',nil);
     registerbgidriver(@drv_svgatc);
     if res=0 then gm:=res else if res in[2..7] then gm:=res-1 else exit;
     initgraph(gd,gm,'');
    end;
 end;
end;

procedure rgbpixel(x,y:word;r,g,b:byte);
var r2,g2,b2,a:byte;
const raster:array[0..16,0..3,0..3]of byte=
 (((0,0,0,0),(0,0,0,0),(0,0,0,0),(0,0,0,0)),
  ((0,0,0,0),(0,0,0,0),(0,0,0,0),(1,0,0,0)),
  ((0,0,0,0),(0,0,1,0),(0,0,0,0),(1,0,0,0)),
  ((0,0,0,0),(1,0,1,0),(0,0,0,0),(1,0,0,0)),
  ((0,0,0,0),(1,0,1,0),(0,0,0,0),(1,0,1,0)),
  ((0,1,0,0),(1,0,1,0),(0,0,0,0),(1,0,1,0)),
  ((0,1,0,0),(1,0,1,0),(0,0,0,1),(1,0,1,0)),
  ((0,1,0,1),(1,0,1,0),(0,0,0,1),(1,0,1,0)),
  ((0,1,0,1),(1,0,1,0),(0,1,0,1),(1,0,1,0)),
  ((0,1,0,1),(1,0,1,0),(0,1,1,1),(1,0,1,0)),
  ((1,1,0,1),(1,0,1,0),(0,1,1,1),(1,0,1,0)),
  ((1,1,0,1),(1,0,1,0),(1,1,1,1),(1,0,1,0)),
  ((1,1,1,1),(1,0,1,0),(1,1,1,1),(1,0,1,0)),
  ((1,1,1,1),(1,0,1,0),(1,1,1,1),(1,1,1,0)),
  ((1,1,1,1),(1,0,1,1),(1,1,1,1),(1,1,1,0)),
  ((1,1,1,1),(1,1,1,1),(1,1,1,1),(1,1,1,0)),
  ((1,1,1,1),(1,1,1,1),(1,1,1,1),(1,1,1,1)));
begin
 case cmode of
  7:begin
     setrgbpalette(1026,r,g,b);
     putpixel(x,y,0);
    end;
  6:begin
     r2:=r shr 3+raster[r mod 8 shl 1,x mod 4,y mod 4];
     g2:=g shr 2+raster[g mod 4 shl 2,x mod 4,y mod 4];
     b2:=b shr 3+raster[b mod 8 shl 1,x mod 4,y mod 4];
     if r2>31 then r2:=31;
     if g2>63 then g2:=63;
     if b2>31 then b2:=31;
     setrgbpalette(1026,r2,g2,b2);
     putpixel(x,y,0);
    end;
  5:begin
     r2:=r shr 3+raster[r mod 8 shl 1,x mod 4,y mod 4];
     g2:=g shr 3+raster[g mod 8 shl 1,x mod 4,y mod 4];
     b2:=b shr 3+raster[b mod 8 shl 1,x mod 4,y mod 4];
     if r2>31 then r2:=31;
     if g2>31 then g2:=31;
     if b2>31 then b2:=31;
     setrgbpalette(1026,r2,g2,b2);
     putpixel(x,y,0);
    end;
  4:begin
     a:=(r*30+g*59+b*11)div 100;
     putpixel(x,y,a);
    end;
  3:begin
     r2:=r div 36;
     if r2<>7 then inc(r2,raster[(((r mod 36)*256 div 36) div 16)+
      raster[((r mod 36)*256 div 36) mod 16,(x div 4)mod 4,(y div 4)mod 4],x mod 4,y mod 4]);
     g2:=g div 36;
     if g2<>7 then inc(g2,raster[(((g mod 36)*256 div 36) div 16)+
      raster[((g mod 36)*256 div 36) mod 16,(x div 4)mod 4,(y div 4)mod 4],x mod 4,y mod 4]);
     b2:=b div 85;
     if b2<>3 then inc(b2,raster[(((b mod 85)*256 div 85) div 16)+
      raster[((b mod 85)*256 div 85) mod 16,(x div 4)mod 4,(y div 4)mod 4],x mod 4,y mod 4]);
     putpixel(x,y,b2 or(g2 shl 2)or(r2 shl 5));
    end;
  2:begin
     a:=(r*30+g*59+b*11)div 100;
     a:=a shr 4+raster[a mod 16,x mod 4,y mod 4];
     if a>15 then a:=15;
     putpixel(x,y,a);
    end;
  1:begin
     g2:=g div 85;
     if g2<>3 then inc(g2,raster[(((g mod 85)*256 div 85) div 16)+
      raster[((g mod 85)*256 div 85) mod 16,(x div 4)mod 4,(y div 4)mod 4],x mod 4,y mod 4]);
     r:=r*(r+1)shr 8;
     if r=255 then r2:=1 else
     r2:=raster[(r div 16)+raster[r mod 16,(x div 4)mod 4,(y div 4)mod 4],x mod 4,y mod 4];
     b:=b*(b+1)shr 8;
     if b=255 then b2:=1 else
     b2:=raster[(b div 16)+raster[b mod 16,(x div 4)mod 4,(y div 4)mod 4],x mod 4,y mod 4];
     putpixel(x,y,b2 or(g2 shl 1)or(r2 shl 3));
    end;
  0:begin
     a:=(r*30+g*59+b*11)div 100;
     a:=a*(a+1)shr 8;        {Filter fÅr realistischere Helligkeit}
     if a<255 then
     begin
      a:=raster[(a div 16)+
         raster[a mod 16,(x div 4)mod 4,(y div 4)mod 4],
         x mod 4,y mod 4]*15;
     end else a:=15;
     putpixel(x,y,a);
    end;
 end;
end;

procedure setrgbcolor(r,g,b:byte);
begin
 case cmode of
  7:setrgbpalette(1024,r,g,b);
  6:setrgbpalette(1024,r shr 3,g shr 2,b shr 3);
  5:setrgbpalette(1024,r shr 3,g shr 3,b shr 3);
  4:setcolor((r*30+g*59+b*11)div 100);
  3:setcolor(b shr 6 or(g shr 5 shl 2)or(r shr 5 shl 5));
  2:setcolor(((r*30+g*59+b*11)div 100)shr 4);
  1:setcolor(b shr 7 or(g shr 6 shl 1)or(r shr 7 shl 3));
  0:setcolor(((r*30+g*59+b*11)div 100)shr 7);
 end;
end;


procedure draw(xpos,ypos:byte;fname:string);
var
 f:file;
 x,y,width,height:word;
 a:byte;
 zeile:array[0..2047]of record b,g,r:byte end;
 xoffset,yoffset:integer;
begin
 assign(f,fname);
 reset(f,1);
 seek(f,18);
 blockread(f,width,2);
 seek(f,22);
 blockread(f,height,2);
 xoffset:=maxx div 2 -width div 2 +(ypos-1+(1-ystart))*50+((xpos-xstart)*50);
 yoffset:=maxy div 2+ 25-height -(xpos-(ypos+(xstart-1))+(ystart-1))*25;
 if (xoffset+width>=0)and(xoffset<=maxx)and
  (yoffset+height>=0)and(yoffset<=maxy) then
 begin
  seek(f,54);
  for y:=height-1 downto 0 do
  begin
   blockread(f,zeile[0],width*3);
   for x:=0 to width-1 do
   begin
    if not((zeile[x].r=$ff)and(zeile[x].g=$00)and(zeile[x].b=$ff))then
     rgbpixel(x+xoffset,
      y+yoffset,zeile[x].r,zeile[x].g,zeile[x].b);
   end;
   if (width*3)mod 4<>0 then for x:=1 to 4-(width*3)mod 4 do blockread(f,a,1);
  end;
 end;
 close(f);
end;

procedure redraw;
var
 x,y,a,b,c:byte;
 color:record r,g,b:byte end;
begin
 {---Zeichnen der GebÑude-------}
 for c:=1 to 67 do
 begin
  if c<=63 then
  begin
   a:=32-abs(32-c);
   for b:=1 to a do
   begin
    if c<=32 then begin y:=a-(a-b); x:=32-(a-b); end else
     begin y:=(64-a)-(32-b); x:=b; end;
    if keypressed then exit;
    if terraign[termap[y,x]]<>''then draw(x,y,terraign[termap[y,x]]);
   end;
  end;
  if c>4 then
  begin
   a:=32-abs(32-(c-4));
   for b:=1 to a do
   begin
    if (c-4)<=32 then begin y:=a-(a-b); x:=32-(a-b); end else
     begin y:=(64-a)-(32-b); x:=b; end;
    if keypressed then exit;
    if (buildings[map[y,x]]<>'')and(map[y,x]<>0)then
     draw(x-(ord(buildings[map[y,x]][1])-ord('0'))div 2,
      y+(ord(buildings[map[y,x]][1])-ord('0'))div 2,
      copy(buildings[map[y,x]],2,12));
   end;
  end;
 end;
 {------------------------------}
 if keypressed then exit;
 for x:=0 to 35 do
 begin
  if x mod 2=0 then setrgbcolor($60,$40,$20)else setrgbcolor($30,$20,$10);
  line(0,x,134,x);
 end;
 for x:=35 to 68 do
 begin
  if x mod 2=0 then setrgbcolor($60,$40,$20)else setrgbcolor($30,$20,$10);
  line(0,x,204-x*2,x);
 end;
 setrgbcolor($A0,$70,$30);
 line(134,0,134,35);
 setrgbcolor($D0,$A0,$60);
 line(68,68,134,35);
 setrgbcolor($A7,$77,$37);
 line(0,68,68,68);

 setrgbcolor($90,$60,$20);
 line(2,33,67,65);
 line(67,0,131,32);
 setrgbcolor($D0,$A0,$60);
 line(66,65,131,33);
 line(2,32,67,0);

 for y:=1 to 32 do
 for x:=1 to 32 do
 begin
  case termap[y,x]of
   1:with color do begin r:=$40; g:=$A0; b:=$40 end;
   2:with color do begin r:=$C0; g:=$80; b:=$40 end;
   3:with color do begin r:=$E0; g:=$D0; b:=$40 end;
   4:with color do begin r:=$E0; g:=$E0; b:=$F0 end;
   5:with color do begin r:=$60; g:=$80; b:=$60 end;
   else with color do begin r:=$20; g:=$40; b:=$80 end;
  end;
  rgbpixel((x+y)*2,integer(y-x)+32,color.r,color.g,color.b);
  rgbpixel((x+y)*2+1,integer(y-x)+32,color.r,color.g,color.b);
  rgbpixel((x+y)*2,integer(y-x)+33,color.r,color.g,color.b);
  rgbpixel((x+y)*2+1,integer(y-x)+33,color.r,color.g,color.b);
  if map[y,x]<>0 then
   rgbpixel((x+y)*2,integer(y-x)+32,0,0,0);
 end;
 for x:=0 to 24 do
 begin
  if x mod 2=0 then setrgbcolor($60,$40,$20)else setrgbcolor($30,$20,$10);
  line(maxx-184+x,x,maxx,x);
 end;
 setrgbcolor($90,$60,$20);
 line(maxx-184,0,maxx-160,24);
 setrgbcolor($A0,$70,$30);
 line(maxx-160,24,maxx,24);
 setrgbcolor($A0,$70,$30);
 outtextxy(maxx-159,9,'(C) 2006, B.Freisen');
 outtextxy(17,9,'N');
 outtextxy(105,9,'O');
 outtextxy(17,49,'W');
 setrgbcolor(0,0,0);
 outtextxy(maxx-160,8,'(C) 2006, B.Freisen');
 outtextxy(16,8,'N');
 outtextxy(104,8,'O');
 outtextxy(16,48,'W');
end;

{**********************************************************************}

begin
 cmode:=color16bit;
 res:=res1024x768;
 for c:=1 to paramcount do
 begin
  if paramstr(c)='320x200'then res:=res320x200;
  if paramstr(c)='640x200'then res:=res640x200;
  if paramstr(c)='640x350'then res:=res640x350;
  if paramstr(c)='640x400'then res:=res640x400;
  if paramstr(c)='640x480'then res:=res640x480;
  if paramstr(c)='800x600'then res:=res800x600;
  if paramstr(c)='1024x768'then res:=res1024x768;
  if paramstr(c)='1280x1024'then res:=res1280x1024;

  if paramstr(c)='1bit'then cmode:=grey1bit;
  if paramstr(c)='4bit'then cmode:=color4bit;
  if paramstr(c)='4bit-grey'then cmode:=grey4bit;
  if paramstr(c)='8bit'then cmode:=color8bit;
  if paramstr(c)='8bit-grey'then cmode:=grey8bit;
  if paramstr(c)='15bit'then cmode:=color15bit;
  if paramstr(c)='16bit'then cmode:=color16bit;
  if paramstr(c)='24bit'then cmode:=color24bit;
 end;
 initmode(res,cmode);

 maxx:=getmaxx;
 maxy:=getmaxy;

 xstart:=1;
 ystart:=1;

 assign(bauwerke,'bauwerke.txt');
 reset(bauwerke);
 for c:=1 to 63 do
 begin
  if eof(bauwerke)then buildings[c]:=''else readln(bauwerke,buildings[c]);
 end;
 close(bauwerke);
 assign(gelaende,'gelaende.txt');
 reset(gelaende);
 for c:=0 to 15 do
 begin
  if eof(gelaende)then terraign[c]:=''else readln(gelaende,terraign[c]);
 end;
 close(gelaende);

 repeat
  clearviewport;
  redraw;
  rgbpixel((xstart+ystart)*2,integer(ystart-xstart)+32,$ff,$ff,$ff);
  rgbpixel((xstart+ystart)*2-1,integer(ystart-xstart)+32-1,$ff,$ff,$ff);
  rgbpixel((xstart+ystart)*2+1,integer(ystart-xstart)+32-1,$ff,$ff,$ff);
  rgbpixel((xstart+ystart)*2-1,integer(ystart-xstart)+32+1,$ff,$ff,$ff);
  rgbpixel((xstart+ystart)*2+1,integer(ystart-xstart)+32+1,$ff,$ff,$ff);
  setrgbcolor($00,$ff,$00);
  line(maxx div 2-50,maxy div 2,maxx div 2,maxy div 2-25);
  line(maxx div 2,maxy div 2-25,maxx div 2+50,maxy div 2);
  line(maxx div 2-50,maxy div 2,maxx div 2,maxy div 2+25);
  line(maxx div 2,maxy div 2+25,maxx div 2+50,maxy div 2);
  setlinestyle(4,$8888,1);
  line(maxx div 2-150,maxy div 2,maxx div 2,maxy div 2-75);
  line(maxx div 2,maxy div 2-75,maxx div 2+150,maxy div 2);
  line(maxx div 2-150,maxy div 2,maxx div 2,maxy div 2+75);
  line(maxx div 2,maxy div 2+75,maxx div 2+150,maxy div 2);
  setlinestyle(1,0,1);
  line(maxx div 2-100,maxy div 2+25,maxx div 2,maxy div 2-25);
  line(maxx div 2,maxy div 2-25,maxx div 2+100,maxy div 2+25);
  setlinestyle(4,$8080,1);
  line(maxx div 2-200,maxy div 2+25,maxx div 2,maxy div 2+125);
  line(maxx div 2,maxy div 2+125,maxx div 2+200,maxy div 2+25);
  setlinestyle(0,0,1);
  setrgbcolor($ff,$ff,$ff);
  outtextxy(8,maxy-16,'0-9:Untergrund setzen   a-z:GebÑude setzen   '+
   'Entf:Feld lîschen   Pos1:alles lîschen   Einfg:laden   '+
   'Ende:speichern   Esc:Ende');
  ch:=readkey;
  case ch of
   '0'..'9':termap[ystart,xstart]:=ord(ch)-ord('0');
   'a'..'z':map[ystart,xstart]:=ord(ch)-ord('a');
   'A'..'Z':map[ystart,xstart]:=ord(ch)-ord('A')+26;

   #0 :begin
        ch:=readkey;
        case ch of
         #75:if xstart>1 then dec(xstart);
         #77:if xstart<32 then inc(xstart);
         #72:if ystart>1 then dec(ystart);
         #80:if ystart<32 then inc(ystart);
         #82:begin
              assign(mapfile,'mapfile.bin');
              reset(mapfile,1);
              if ioresult=0 then
              begin
               blockread(mapfile,termap[1,1],1024);
               blockread(mapfile,map[1,1],1024);
              end;
              close(mapfile);
             end;
         #83:begin
              termap[ystart,xstart]:=0;
              map[ystart,xstart]:=0;
             end;
         #71:begin
              fillchar(termap[1,1],1024,termap[ystart,xstart]);
              fillchar(map[1,1],1024,0);
             end;
         #79:begin
              assign(mapfile,'mapfile.bin');
              rewrite(mapfile,1);
              blockwrite(mapfile,termap[1,1],1024);
              blockwrite(mapfile,map[1,1],1024);
              close(mapfile);
             end;
        end;
       end;
  end;
 until ch=#27;

 closegraph;
end.