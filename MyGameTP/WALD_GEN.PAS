var f:file; x,y,a:byte;
begin
 assign(f,'d:\eigene~1\benedikt\mygametp\mapfile.bin');
 rewrite(f,1);
 for y:=1 to 32 do
 for x:=1 to 32 do
 begin
  a:=random(4);
  inc(a);
  blockwrite(f,a,1);
 end;
 for y:=1 to 32 do
 for x:=1 to 32 do
 begin
  a:=random(4);
  case a of
   2:a:=9;
   3:a:=10;
  end;
  blockwrite(f,a,1);
 end;
 close(f);
end.