Unit bgiMisc;

Interface

Procedure Border(x,y,x2,y2: Integer);
Procedure DrawFrame(x,y,x2,y2 : Word; TitleMsg : String);

Implementation
   uses graph,bgiText;

Procedure Border(x,y,x2,y2: Integer);
begin
 Setcolor(LightGray);
 Rectangle(x,y,x2,y2);
 Rectangle(x+1,y+1,x2-1,y2-1);
end;

Procedure DrawFrame(x,y,x2,y2 : Word; TitleMsg : String);
begin
 SetFillStyle(SolidFill,Black);
 Bar(x,y,x2,y2);
 Border(x,y,x2,y2);
 SetFillStyle(SolidFill,White);
 Bar(x+3,y+22,x2-3,y2-3);
 SetFillStyle(SolidFill,LightGray);
 Bar(x+3,y+3,x2-3,y+20);
 ShadowText(x+8,y+8,TitleMsg);
end;

begin
end.
