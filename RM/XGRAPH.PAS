Unit XGraph; (* some things to fix *)
Interface
 uses graph;

Function ImageSize(x,y,x2,y2 : longint) : LongInt;

Implementation

Function ImageSize(x,y,x2,y2 : longint) : LongInt;
begin
 if GetMaxColor = 255 then
 begin
   ImageSize:=6+(x2-x+1)*(y2-y+1);
 end
 else
 begin
   ImageSize:=graph.ImageSize(x,y,x2,y2);
 end;
end;

begin
end.