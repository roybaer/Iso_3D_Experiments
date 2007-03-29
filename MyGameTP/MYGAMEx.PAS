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



procedure initmode;
var
 gd,gm:integer;
begin
 gd:=installuserdriver('svgatc',nil);
 gm:=5;
 registerbgidriver(@drv_svgatc);
 initgraph(gd,gm,'');
end;

procedure rgbpixel(x,y:word;r,g,b:byte);
begin
 setrgbpalette(1026,r,g,b);
 putpixel(x,y,0);
end;

procedure setrgbcolor(r,g,b:byte);
begin
 setrgbpalette(1024,r,g,b);
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
 {---Zeichnen der Geb„ude-------}
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
 initmode;

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
  outtextxy(8,maxy-16,'0-9:Untergrund setzen   a-z:Geb„ude setzen   '+
   'Entf:Feld l”schen   Pos1:alles l”schen   Einfg:laden   '+
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