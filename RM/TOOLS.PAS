{$I RM.INC}
Unit Tools;
  Interface
   uses Crt,Dos,Panel,Vars,core,bgiMouse,bgiGadge,bgiReq,
        bgiPal,Screen,Graph,Messages,Format,RWPCX,RWico,RWBMP,
        RWCUSTOM,RWXGF,Wcon,WDEF,WPRF,WMask,RWCEL;


Procedure GetCords(Var x,y : Word);
Procedure WaitForClick;
Procedure DotP;
Procedure LineP;
Procedure RectangleP;
Procedure FRectangleP;
Procedure CircleP;
Procedure FCircleP;
Procedure FillP;
Procedure SprayP;
Procedure ClipP;
Procedure GridP;
Procedure OpenP;
Procedure SaveP;
Procedure CLRP;
Procedure SaveUndoImg;
Procedure UndoP;
Procedure SweepRight;
Procedure SweepLeft;
Procedure SweepH;
PRocedure SweepDown;
Procedure SweepUp;
Procedure SweepV;
Procedure GridAdjustP;
Procedure ViewP;
Procedure SaveFormatP;
Procedure OpenFormatP;
Implementation

Procedure SwapV(Var x,y : word);
var
 t : Word;
begin
  t:=x;
  x:=y;
  y:=t;
end;

Function FileExists(FilePattern : String) : Boolean;
Var
 DirInfo : SearchRec;
begin
 FindFirst(FilePattern,Archive,DirInfo);
 FileExists:=False;
 If DosError = 0 then
 begin
  FileExists:=True;
 end;
end;

Procedure ChangeExt(Var path : String; ext: string);
var
d : dirstr;
n : namestr;
e : extstr;
begin
 fsplit(path,d,n,e);
 path :=d+'*.'+ext;
end;


Procedure WaitForClick;
Var
 st,mx,my : Integer;
begin
Repeat
 MouseGetStatus(st,my,mx);
until st<>0;
end;

Function ClickReleased : Boolean;
Var
 st,mx,my : Integer;
begin
 ClickReleased := false;
 MouseGetStatus(st,my,mx);
 if st = 0 then ClickReleased :=true;
end;

Procedure GetCords(Var x,y : Word);
Var
 st,mx,my : Integer;
 tx,ty : integer;
begin
 MouseGetStatus(st,my,mx);
 tx:=(mx-GridBox_x+1) div CellW + 1;
 ty:=(my-GridBox_y+1) div  CellH + 1;
 if tx < 1 then
 begin
   tx:=1
 end
 else if tx > MaxWH then
 begin
   tx:=MaxWH;
 end;

 if ty < 1 then
 begin
   ty:=1;
 end
 else if ty > MaxWH then
 begin
   ty:=MaxWH;
 end;
 x:=tx;
 y:=ty;
end;

Procedure Cplot(x,y : Word);
begin
 if (x < 1) or (x > 100) or (y < 1) or (y > 100) then exit;
 if IconImage[x,y] <> NColor then
 begin
   IconImage[x,y] :=NColor;
   PutPixel(ActualBox_x+x,ActualBox_y+y,NColor);
   if (x > MaxWH) or (y > MaxWH) then exit;
   SetFillStyle(SolidFill,NColor);
   Bar(GridBox_x+(x-1)*CellW+1,GridBox_y+(y-1)*CellH+1,
      GridBox_x+(x-1)*CellW+CellW-1+GridLine,GridBox_y+(y-1)*CellH+CellH-1+GridLine);

 end;
end;

Procedure Dplot(x,y : Word);
begin
   IconImage[x+xoff,y+yoff] :=NColor;
   SetFillStyle(SolidFill,NColor);
   Bar(GridBox_x+(x-1)*CellW+1,GridBox_y+(y-1)*CellH+1,
      GridBox_x+(x-1)*CellW+CellW-1+GridLine,GridBox_y+(y-1)*CellH+CellH-1+GridLine);
   PutPixel(ActualBox_x+x+xoff,ActualBox_y+y+yoff,NColor);
end;

Procedure Rplot(x,y : Word;Rubber : Boolean);
begin

If Rubber then
begin
  SetWriteMode(XorPut);
  SetColor(Yellow);
  Rectangle(GridBox_x+(x-1)*CellW+1,GridBox_y+(y-1)*CellH+1,
           GridBox_x+(x-1)*CellW+CellW-1+GridLine,GridBox_y+(y-1)*CellH+CellH-1+GridLine);
  Line(ActualBox_x+x+xoff,ActualBox_y+y+yoff,ActualBox_x+x+xoff,ActualBox_y+y+yoff);
  SetWriteMode(CopyPut);
end
else
 begin
 if IconImage[x+xoff,y+yoff] <> NColor then
  begin
   IconImage[x+xoff,y+yoff]:=NColor;
   SetFillStyle(SolidFill,NColor);
   Bar(GridBox_x+(x-1)*CellW+1,GridBox_y+(y-1)*CellH+1,
      GridBox_x+(x-1)*CellW+CellW-1+GridLine,GridBox_y+(y-1)*CellH+CellH-1+GridLine);
   PutPixel(ActualBox_x+x+xoff,ActualBox_y+y+yoff,NColor);
 end;
end;
end;

Procedure Pplot(x,y : Word;Rubber : Boolean);

begin
 if  (xoff+x<1) or (xoff+x>100) or (yoff+y<1) or (yoff+y>100) then  exit;

If Rubber then
begin
  SetWriteMode(XorPut);
  SetColor(Yellow);

   SetViewPort(ActualBox_x,ActualBox_y,ActualBox_x+100,ActualBox_y+100,true);

   Line(x+xoff,y+yoff,x+xoff,y+yoff);

   SetViewPort(GridBox_x,GridBox_y,GridBox_x+500,GridBox_y+400,true);
   if (x < 1) or (x > maxwh) or (y<1) or (y>maxwh) then
   begin
    SetWriteMode(CopyPut);
    SetViewPort(0,0,639,479,false);
    exit;
   end;
   Rectangle((x-1)*CellW+1,(y-1)*CellH+1,
            (x-1)*CellW+CellW-1+GridLine,(y-1)*CellH+CellH-1+GridLine);

  SetWriteMode(CopyPut);
  SetViewPort(0,0,639,479,false);
end
else
 begin

 if IconImage[x+xoff,y+yoff] <> NColor then
  begin
   IconImage[x+xoff,y+yoff]:=NColor;
   SetFillStyle(SolidFill,NColor);
   SetViewPort(ActualBox_x,ActualBox_y,ActualBox_x+100,ActualBox_y+100,true);
   PutPixel(x+xoff,y+yoff,NColor);
   SetViewPort(GridBox_x,GridBox_y,GridBox_x+500,GridBox_y+400,true);
   if (x < 1) or (x > maxwh) or (y<1) or (y>maxwh) then
   begin
    SetViewPort(0,0,639,479,false);
    exit;
   end;

   Bar((x-1)*CellW+1,(y-1)*CellH+1,
      (x-1)*CellW+CellW-1+GridLine,(y-1)*CellH+CellH-1+GridLine);
   SetViewPort(0,0,639,479,false);

 end;
end;
end;

Procedure Pplot2(x,y : Word;Rubber : Boolean);

begin



   SetFillStyle(SolidFill,NColor);
   SetViewPort(ActualBox_x,ActualBox_y,ActualBox_x+100,ActualBox_y+100,true);
   PutPixel(x,y,NColor);
   SetViewPort(GridBox_x,GridBox_y,GridBox_x+500,GridBox_y+400,true);

   Bar((x-xoff-1)*CellW+1,(y-yoff-1)*CellH+1,
      (x-xoff-1)*CellW+CellW-1+GridLine,(y-yoff-1)*CellH+CellH-1+GridLine);
   SetViewPort(0,0,639,479,false);


end;

Procedure DotP;
Var
 x,y  : Word;
   gn : Word;
begin
 Repeat
  gn:=GetGadgetPressed(MainGads,3);

  if gn=3 then
  begin
    GetCords(x,y);
    If IconImage[x+xoff,y+yoff] <> NColor then
    begin
      Mousehide;
      DPlot(x,y);
      Mouseshow;
    end;
  end;
Until ClickReleased;
end;

Procedure DrawLine(x1,y1,x2,y2:Integer;Rubber:boolean);
var
 xr,yr,dxr,dyr:real;
 x,y,dx,dy:integer;
begin
 if abs(x2-x1)>=abs(y2-y1) then begin
    if x1<=x2 then dx:=1 else dx:=-1;
    if x1<>x2 then dyr:=(y2-y1)/abs(x2-x1) else dyr:=0;
  x:=x1-dx;
  yr:=y1;
  repeat
   x:=x+dx;
   Rplot(x,round(yr),Rubber);
   yr:=yr+dyr;
  until x=x2;
  end
  else begin
   dxr:=(x2-x1)/abs(y2-y1);
   if y1<y2 then dy:=1 else dy:=-1;
   y:=y1-dy;
   xr:=x1;
   repeat
    y:=y+dy;
    Rplot(round(xr),y,Rubber);
    xr:=xr+dxr;
   until y=y2;
  end;
 end;

Procedure LineP;
Var
 x, y : Word;
x2,y2 : Word;
Old_x2: Word;
Old_y2: Word;
    gn: Word;
begin
 GetCords(x,y);
 Old_x2:=x;
 Old_y2:=y;
 MouseHide;
 Rplot(x,y,True);
 MouseShow;
 Repeat
   gn:=GetGadgetPressed(MainGads,3);
   if gn=3 then
   begin
     GetCords(x2,y2);
     If (x2<>Old_x2) or (y2<>old_y2) then
     begin
       MouseHide;
       DrawLine(x,y,Old_x2,old_y2,True);
       DrawLine(x,y,x2,y2,True);
       MouseShow;
       Old_x2:=x2;
       Old_y2:=y2;
     end;
   end;
 Until ClickReleased;
 MouseHide;
 DrawLine(x,y,Old_x2,old_y2,True);
 DrawLine(x,y,Old_x2,old_y2,False);
 MouseShow;
end;



Procedure DrawRectangle(x,y,x2,y2 : word;Rubber : Boolean);
begin
 if x > x2 then SwapV(x,x2);
 If y > y2 then SwapV(y,y2);
 if (x = x2) and (y = y2) then
 begin
    RPlot(x,y,Rubber);
 end
 Else if (x = x2) then
 begin
    DrawLine(x,y,x,y2,Rubber);
 end
 Else if (y = y2) then
 begin
    DrawLine(x,y,x2,y,Rubber);
 end
 Else If (x = (x2-1)) then
 begin
     DrawLine(x,y,x,y2,Rubber);
     DrawLine(x2,y,x2,y2,Rubber);
 end
 Else If (y = (y2-1)) then
 begin
     DrawLine(x,y,x2,y,Rubber);
     DrawLine(x,y2,x2,y2,Rubber);
 end
 Else
  begin
   Drawline(x,y,x2,y,Rubber);
   DrawLine(x,y2,x2,y2,Rubber);
   if (x<>(x2-1)) then
   begin
      DrawLine(x,y+1,x,y2-1,Rubber);
      DrawLine(x2,y+1,x2,y2-1, Rubber);
   end;
 end;
end;




Procedure RectangleP;
Var
 x, y : Word;
x2,y2 : Word;
Old_x2: Word;
Old_y2: Word;
    gn: Word;
begin
 GetCords(x,y);
 Old_x2:=x;
 Old_y2:=y;
 MouseHide;
 Rplot(x,y,True);
 MouseShow;
 Repeat
   gn:=GetGadgetPressed(MainGads,3);
   if gn=3 then
   begin
     GetCords(x2,y2);
     If (x2<>Old_x2) or (y2<>old_y2) then
     begin
       MouseHide;
       DrawRectangle(x,y,Old_x2,old_y2,True);
       DrawRectangle(x,y,x2,y2,True);
       MouseShow;
       Old_x2:=x2;
       Old_y2:=y2;
     end;
   end;
 Until ClickReleased;
 MouseHide;
 DrawRectangle(x,y,Old_x2,old_y2,True);
 DrawRectangle(x,y,Old_x2,old_y2,False);
 MouseShow;
end;

Procedure FRectangleP;
Var
 i, j : Word;
 x, y : Word;
x2,y2 : Word;
Old_x2: Word;
Old_y2: Word;
    gn: Word;
begin
 GetCords(x,y);
 Old_x2:=x;
 Old_y2:=y;
 MouseHide;
 Rplot(x,y,True);
 MouseShow;
 Repeat
   gn:=GetGadgetPressed(MainGads,3);
   if gn=3 then
   begin
     GetCords(x2,y2);
     If (x2<>Old_x2) or (y2<>old_y2) then
     begin
       MouseHide;
       DrawRectangle(x,y,Old_x2,old_y2,True);
       DrawRectangle(x,y,x2,y2,True);
       MouseShow;
       Old_x2:=x2;
       Old_y2:=y2;
     end;
   end;
 Until ClickReleased;
 MouseHide;
 DrawRectangle(x,y,Old_x2,old_y2,True);
 if (x > Old_x2) then SwapV(x,Old_x2);
 if (y > Old_y2) then SwapV(y,Old_y2);
 for i:=x to Old_x2 do
 begin
  For j:=y to Old_y2 do
  begin
    if IconImage[i+xoff,j+yoff] <> NColor then
    begin
      DPlot(i,j);
    end;
  end;
 end;
 MouseShow;
end;


Procedure Draw_Circle(xc,yc,x2,y2:Integer;Rubber,Full:boolean);
var
 radius : Integer;
 x,y,d : Integer;
 r1,r2:Integer;
 i : word;
 CBuf : Array[1..100,1..100] of byte;


Function IsOn(x,y:integer) : Boolean;
begin
 IsOn:=True;
 if (x+xoff < 1) or (x+xoff > 100) or (y+yoff < 1) or (y+yoff > 100) then
 begin
    IsOn :=True;
    exit;
 end
 else if Cbuf[x+xoff,y+yoff] = 0 then
 begin
   IsOn :=False;
   Cbuf[x+xoff,y+yoff] :=1;
   exit;
 end;

end;

Procedure CircPoint(x,y,xc,yc: integer;Rubber,Full:boolean);
var
 xxcp,xxcm,xycp,xycm,yxcp,yxcm,yycp,yycm : integer;
i : integer;
begin
xxcp:=xc+x;
xxcm:=xc-x;
xycp:=xc+y;
xycm:=xc-y;
yxcp:=yc+x;
yxcm:=yc-x;
yycp:=yc+y;
yycm:=yc-y;

if full = false then
begin
  if IsOn(xxcp,yycp) = false then Pplot(xxcp,yycp,Rubber);
  if IsOn(xxcm,yycp) = false then Pplot(xxcm,yycp,Rubber);
  if IsOn(xxcp,yycm) = false then Pplot(xxcp,yycm,Rubber);
  if IsOn(xxcm,yycm) = false then Pplot(xxcm,yycm,Rubber);
  if IsOn(xycp,yxcp) = false then Pplot(xycp,yxcp,Rubber);
  if IsOn(xycp,yxcm) = false then Pplot(xycp,yxcm,Rubber);
  if IsOn(xycm,yxcp) = false then Pplot(xycm,yxcp,Rubber);
  if IsOn(xycm,yxcm) = false then Pplot(xycm,yxcm,Rubber);
end
else
begin
  for i:=xxcm to xxcp do
  begin
    Pplot(i,yycp,false);
    Pplot(i,yycm,false);
  end;
  for i:= xycm to xycp do
  begin
    Pplot(i,yxcp,false);
    Pplot(i,yxcm,false);
  end;
end;
end;



begin

  FillChar(CBuf,Sizeof(CBuf),0);
  r1:=abs(xc-x2);
  r2:=abs(yc-y2);
  radius:=r2;
  if r1>r2 then
  begin
    radius:=r1
  end;
  x:=0;
  y:=radius;
  d:=3-(2*radius);

  while x<y do
  begin
    Circpoint(x,y,xc,yc,Rubber,Full);
    if d < 0 then
    begin
      d:=d+(4*x)+6;
    end
    else
    begin
      d:=d+4*(x-y)+10;
      y:=y-1;
    end;
    x:=x+1
   end;
   if (x=y)  then CircPoint(x,y,xc,yc,Rubber,Full);
end;


Procedure CircleP;
Var
 x, y : Word;
x2,y2 : Word;
Old_x2: Word;
Old_y2: Word;
    gn : Word;
begin
 GetCords(x,y);
 Old_x2:=x;
 Old_y2:=y;
 MouseHide;
 Rplot(x,y,True);
 MouseShow;
 Repeat
   gn:=GetGadgetPressed(MainGads,3);
   if gn=3 then
   begin
     GetCords(x2,y2);
     If (x2<>Old_x2) or (y2<>old_y2) then
     begin
       MouseHide;
       Draw_Circle(x,y,Old_x2,old_y2,True,false);
       Draw_Circle(x,y,x2,y2,True,false);
       MouseShow;
       Old_x2:=x2;
       Old_y2:=y2;
     end;
    end;
 Until ClickReleased;
 MouseHide;
 Draw_Circle(x,y,Old_x2,old_y2,True,false);
 Draw_Circle(x,y,Old_x2,old_y2,false,False);
 MouseShow;
end;

Procedure FCircleP;
Var
 x, y : Word;
x2,y2 : Word;
Old_x2: Word;
Old_y2: Word;
    gn: Word;
begin
 GetCords(x,y);
 Old_x2:=x;
 Old_y2:=y;
 MouseHide;
 Rplot(x,y,True);
 MouseShow;
 Repeat
   gn:=GetGadgetPressed(MainGads,3);
   if gn=3 then
 begin
  GetCords(x2,y2);
  If (x2<>Old_x2) or (y2<>old_y2) then
  begin
     MouseHide;
     Draw_Circle(x,y,Old_x2,old_y2,True,false);
     Draw_Circle(x,y,x2,y2,True,false);
     MouseShow;
     Old_x2:=x2;
     Old_y2:=y2;
  end;
 end;
 Until ClickReleased;
 MouseHide;
 Draw_Circle(x,y,Old_x2,old_y2,True,false);
 Draw_Circle(x,y,Old_x2,old_y2,false,true);
 MouseShow;
end;




Procedure DrawIconImage(x,y,x2,y2 : word);
Var
 i,j : Word;
begin
  For i:=x to x2 do
  begin
   For j:=y to y2 do
   begin
   if IconImage[i,j] <> UndoImage[i,j] then
   begin
   PutPixel(ActualBox_x+i,ActualBox_y+j,IconImage[i,j]);
   end;
   if (maxwh>=i) and (maxwh>=j) then
   begin
   if IconImage[i+xoff,j+yoff] <> UndoImage[i+xoff,j+yoff] then
   begin
   SetFillStyle(SolidFill,IconImage[i+xoff,j+yoff]);
   Bar(GridBox_x+(i-1)*CellW+1,GridBox_y+(j-1)*CellH+1,
      GridBox_x+(i-1)*CellW+CellW-1+GridLine,GridBox_y+(j-1)*CellH+CellH-1+GridLine);
   end;
   end;
   end;
  end;
end;


Procedure DrawIconImage2(x,y,x2,y2 : word);
Var
 i,j : Word;
begin
  For i:=x to x2 do
  begin
   For j:=y to y2 do
   begin
   PutPixel(ActualBox_x+i+xoff,ActualBox_y+j+yoff,IconImage[i+xoff,j+yoff]);

   if (maxwh>=i) and (maxwh>=j) then
   begin

   SetFillStyle(SolidFill,IconImage[i+xoff,j+yoff]);
   Bar(GridBox_x+(i-1)*CellW+1,GridBox_y+(j-1)*CellH+1,
      GridBox_x+(i-1)*CellW+CellW-1+GridLine,GridBox_y+(j-1)*CellH+CellH-1+GridLine);
   end;
   end;
  end;
end;


Procedure FillP;
Var
 x,y : word;
   gn : Word;
Begin
   gn:=GetGadgetPressed(MainGads,3);
   if gn=3 then
 begin
  GetCords(x,y);
  If IconImage[x+xoff,y+yoff] <> NColor then
  begin
   MouseHide;
    Fill(x+xoff,y+yoff);
    DrawIconImage(1,1,100,100);
    MouseShow;
    Repeat Until ClickReleased;
  end;
 end;
end;

Procedure SprayP;
Var
 x,y : word;
 n,n2   : integer;
   gn : Word;
Begin
 Repeat
 n:=Random(5)-2;
 n2:=Random(5)-2;
   gn:=GetGadgetPressed(MainGads,3);
   if gn=3 then
 begin
  GetCords(x,y);
  MouseHide;
  Pplot(x+n,y+n2,false);
  MouseShow;
  delay(10);
 end;
 Until ClickReleased;
end;


Procedure DrawRubberBand(x,y,x2,y2:Word);
begin
 If x > x2 then SwapV(x,x2);
 If y > y2 then SwapV(y,y2);
 SetWriteMode(XorPut);
 SetLineStyle(DashedLn,0,1);
 SetColor(White);
 Rectangle(GridBox_x+(x-1)*CellW,GridBox_y+(y-1)*CellH,
            GridBox_x+(x2-1)*CellW+CellW-1+GridLine+1,GridBox_y+(y2-1)*CellH+CellH-1+GridLine+1);
(* Rectangle(GridBox_x+(x-1)*12-1,GridBox_y+(y-1)*8-1,
            GridBox_x+(x2-1)*12+11+GridLine+2,GridBox_y+(y2-1)*8+7+GridLine+2);
*)
 SetLineStyle(SolidLn,0,1);
 SetWriteMode(CopyPut);
end;

Procedure Hflip(x,y,x2,y2: word);
Var
 i,j : word;
 L,T   : word;
 C,C2,A  : Word;
begin
  L :=(x2-x) Div 2;
  A :=x2;
  For i:=x to (x2-L-1) do
  begin
    For j:=y to y2 do
    begin
     C:=IconImage[i+xoff,j+yoff];
     C2:=IconImage[A+xoff,j+yoff];
     IconImage[i+xoff,j+yoff]:=C2;
     IconImage[A+xoff,J+yoff]:=C;
    end;
    Dec(A);
  end;
  MouseHide;
  DrawRubberBand(x,y,x2,y2);
  DrawIconImage2(x,y,x2,y2);
  DrawRubberBand(x,y,x2,y2);
  MouseShow;
end;

Procedure VFlip(x,y,x2,y2 : word);
Var
 i,j : word;
 L,T   : word;
 C,C2,A  : Word;
begin
  L :=(y2-y) Div 2;
  A :=y2;
  For j:=y to (y2-L-1) do
  begin
    For i:=x to x2 do
    begin
     C:=IconImage[i+xoff,j+yoff];
     C2:=IconImage[i+xoff,A+yoff];
     IconImage[i+xoff,j+yoff]:=C2;
     IconImage[i+xoff,A+yoff]:=C;
    end;
    Dec(A);
  end;
  MouseHide;
  DrawRubberBand(x,y,x2,y2);
  DrawIconImage2(x,y,x2,y2);
  DrawRubberBand(x,y,x2,y2);
  MouseShow;

end;

Procedure SLeft(x,y,x2,y2 : word);
Var
 i,j,c,d : Word;
begin
 For j:=y to y2 do
 begin
   d:=IconImage[x+xoff,j+yoff];
   For i:=x+1 to x2 do
   begin
    c:=IconImage[i+xoff,j+yoff];
    IconImage[i-1+xoff,j+yoff]:=c;
   end;
   IconImage[x2+xoff,j+yoff]:=d;
 end;
 MouseHide;
 DrawRubberBand(x,y,x2,y2);
 DrawIconImage2(x,y,x2,y2);
 DrawRubberBand(x,y,x2,y2);
 MouseShow;

end;
Procedure SRight(x,y,x2,y2 : word);
Var
 i,j,c,d : Word;
begin
 For j:=y to y2 do
 begin
   d:=IconImage[x2+xoff,j+yoff];
   For i:=x2-1 downto x do
   begin
    c:=IconImage[i+xoff,j+yoff];
    IconImage[i+1+xoff,j+yoff]:=c;
   end;
   IconImage[x+xoff,j+yoff]:=d;
 end;
 MouseHide;
 DrawRubberBand(x,y,x2,y2);

 DrawIconImage2(x,y,x2,y2);

 DrawRubberBand(x,y,x2,y2);
 MouseShow;

end;

Procedure Sup(x,y,x2,y2 : word);
Var
 i,j,c,d : Word;
begin
 For i:=x to x2 do
 begin
   d:=IconImage[i+xoff,y+yoff];
   For j:=y to y2-1 do
   begin
    c:=IconImage[i+xoff,j+1+yoff];
    IconImage[i+xoff,j+yoff]:=c;
   end;
   IconImage[i+xoff,y2+yoff]:=d;
 end;
 MouseHide;
 DrawRubberBand(x,y,x2,y2);
 DrawIconImage2(x,y,x2,y2);
 DrawRubberBand(x,y,x2,y2);
 MouseShow;
end;

Procedure SDown(x,y,x2,y2 : word);
Var
 i,j,c,d : Word;
begin
 For i:=x to x2 do
 begin
   d:=IconImage[i+xoff,y2+yoff];
   For j:=y2  downto y+1 do
   begin
    c:=IconImage[i+xoff,j-1+yoff];
    IconImage[i+xoff,j+yoff]:=c;
   end;
   IconImage[i+xoff,y+yoff]:=d;
 end;
 MouseHide;
 DrawRubberBand(x,y,x2,y2);
 DrawIconImage2(x,y,x2,y2);
 DrawRubberBand(x,y,x2,y2);
 MouseShow;

end;

Procedure SaveFormatP;
begin
 SetFormat(80,120,2,wftype,WFrec);
end;

Procedure OpenFormatP;
begin
 SetFormat(30,120,1,rftype,RFrec);
end;

Procedure OpenClip(x,y,x2,y2:word);
Var
 Oname : string;
 Error : Word;
begin
 oname:='';
 ChangeExt(cpath,Rfrec.PrgPat);
 if GetFile(170,90,'Open File',cpath,oname,TRUE) then
 begin
  if Pos('.',oname) = 0 then
  begin
    oname:=FExpand(oname)+rfrec.PrgPat;
  end;
  error:=0;
  If (rfType<>6) then
  begin
    mousehide;
  end;
  CASE rftype of 1: Error:=ReadPcxImg(x+xoff,y+yoff,x2+xoff,y2+yoff,0,oname);
                 2: Error:=ReadBMP(x+xoff,y+yoff,x2+xoff,y2+yoff,0,oname);
                 3: Error:=ReadIco(x+xoff,y+yoff,x2+xoff,y2+yoff,oname);
                 4: Error:=ReadICN(x+xoff,y+yoff,x2+xoff,y2+yoff,oname);
     {$IFDEF RMP}
                 4: Error:=ReadCEL(x+xoff,y+yoff,x2+xoff,y2+yoff,0,oname);
                 5: Error:=ReadRaw(x+xoff,y+yoff,x2+xoff,y2+yoff,0,oname);
                 6: begin
                     Error:=ReadPAL(oname);
                     Exit;
                    end;
     {$ENDIF}
                 else
                   Error:=ReadCustom(x+xoff,y+yoff,x2+xoff,y2+yoff,1,Rfrec,oname);
  END;
  mouseshow;
  if error = 0 then
  begin
     MouseHide;
     DrawRubberBand(x,y,x2,y2);
     DrawIconImage2(x,y,x2,y2);
     DrawRubberBand(x,y,x2,y2);
     MouseShow;
  end
  else
   begin
     ErrorMessage(200,175,Error);
  end;
 end;
end;


Procedure WriteClip(x,y,x2,y2:word);
Var
 Oname : string;
 Error : Word;
begin
 Oname:='';
 ChangeExt(cpath,wfrec.PrgPat);
 if GetFile(170,90,'Save File',cpath,oname,TRUE) then
 begin
  if Pos('.',oname) = 0 then
  begin
    oname:=FExpand(oname)+'.'+wfrec.PrgPat;
  end;
  if FileExists(oname) then
  begin
    If overWriteFile(200,175) =false then
    begin
      exit;
    end;
  end;
  Mousehide;
  error:=0;
  CASE wftype of 1: Error:=SavePcxImg(x+xoff,y+yoff,x2+xoff,y2+yoff,oname);
                 2: Error:=WriteBMP(x+xoff,y+yoff,x2+xoff,y2+yoff,oname);
                 3: Error:=WriteIco(x+xoff,y+yoff,x2+xoff,y2+yoff,oname);
                 4: Error:=WriteXGF(x+xoff,y+yoff,x2+xoff,y2+yoff,TPLan,oname);
    {$IFDEF RMP}
                 4: Error:=WriteCel(x+xoff,y+yoff,x2+xoff,y2+yoff,oname);
                 5: Error:=WriteRaw(x+xoff,y+yoff,x2+xoff,y2+yoff,oname);
                 6: Error:=WritePal(oname);
                 7: Error:=WriteDat(0,0,0,0,PALSource,TCLan,oname);
                 8: Error:=WriteDat(0,0,0,0,PALSource,TPLan,oname);
                 9: Error:=WriteDat(0,0,0,0,PALSource,QBLan,oname);
                10: Error:=WriteXGF(x+xoff,y+yoff,x2+xoff,y2+yoff,TPLan,oname);
                11: CASE GetMaxColor of 15:
                      Error:=WriteDat(x+xoff,y+yoff,x2+xoff,y2+yoff,Source16,TPLan,oname);
                    ELSE
                      Error:=WriteDat(x+xoff,y+yoff,x2+xoff,y2+yoff,Source256,TPLan,oname);
                    END;
                12: CASE GetMaxColor of 15:
                      Error:=WriteDat(x+xoff,y+yoff,x2+xoff,y2+yoff,Source16,TCLan,oname);
                    ELSE
                      Error:=WriteDat(x+xoff,y+yoff,x2+xoff,y2+yoff,Source256,TCLan,oname);
                    END;
                13: Error:=WriteXGF(x+xoff,y+yoff,x2+xoff,y2+yoff,QBLan,oname);
                14: CASE GetMaxColor of 15:
                      Error:=WriteDat(x+xoff,y+yoff,x2+xoff,y2+yoff,Source16,QCLan,oname);
                    ELSE
                      Error:=WriteDat(x+xoff,y+yoff,x2+xoff,y2+yoff,Source256,QCLan,oname);
                    END;
                15: CASE GetMaxColor of 15:
                      Error:=WriteDat(x+xoff,y+yoff,x2+xoff,y2+yoff,Source16,QBLan,oname);
                    ELSE
                      Error:=WriteDat(x+xoff,y+yoff,x2+xoff,y2+yoff,Source256,QBLan,oname);
                    END;
                16: Error:=WriteDEF(x+xoff,y+yoff,x2+xoff,y2+yoff,oname);
                17: Error:=WritePPR(x+xoff,y+yoff,x2+xoff,y2+yoff,oname);
                18: Error:=WriteSPR(x+xoff,y+yoff,x2+xoff,y2+yoff,oname);
                19: Error:=WriteDat(x+xoff,y+yoff,x2+xoff,y2+yoff,PPRSource,TCLan,oname);
                20: Error:=WriteDat(x+xoff,y+yoff,x2+xoff,y2+yoff,SPRSource,TCLan,oname);
                21: Error:=WriteDat(x+xoff,y+yoff,x2+xoff,y2+yoff,PPRSource,TPLan,oname);
                22: Error:=WriteDat(x+xoff,y+yoff,x2+xoff,y2+yoff,SPRSOurce,TPLan,oname);
                23: Error:=WriteDat(x+xoff,y+yoff,x2+xoff,y2+yoff,PPRSource,QBLan,oname);
                24: Error:=WriteDat(x+xoff,y+yoff,x2+xoff,y2+yoff,SPRSOurce,QBLan,oname);
                25: Error:=WriteMouseMask(x+xoff,y+yoff,x2+xoff,y2+yoff,TCLan,oname);
                26: Error:=WriteMouseMask(x+xoff,y+yoff,x2+xoff,y2+yoff,TPLan,oname);
                27: Error:=WriteMouseMask(x+xoff,y+yoff,x2+xoff,y2+yoff,QBLan,oname);
     {$ENDIF}
                else
                 Error:=WriteCustom(x+xoff,y+yoff,x2+xoff,y2+yoff,wfrec,oname);
  END;

  Mouseshow;
  if Error <> 0 then
  begin
   ErrorMessage(200,175,Error);
  end;

 end;
end;


Procedure ClipP;
Var
 x, y : Word;
x2,y2 : Word;
Old_x2: Word;
Old_y2: Word;
   gn : Word;
  RKey: Boolean;
begin
 GetCords(x,y);
 Old_x2:=x;
 Old_y2:=y;
 MouseHide;


 DrawRubberBand(x,y,Old_x2,Old_y2);
 MouseShow;
 Repeat
   gn:=GetGadgetPressed(MainGads,3);
   if gn=3 then
 begin
  GetCords(x2,y2);
  If (x2<>Old_x2) or (y2<>old_y2) then
  begin
     MouseHide;
     DrawRubberBand(x,y,Old_x2,Old_y2);
     DrawRubberBand(x,y,x2,y2);
     MouseShow;
     Old_x2:=x2;
     Old_y2:=y2;
  end;
 end;
 Until ClickReleased;

 MouseHide;
 DrawClipGadgets;
(* DrawButton(ColorBox_x,ColorBox_y,Colorbox_x+525,ColorBox_y+40,false);*)

 MouseShow;

 If x > Old_x2 then SwapV(x,Old_x2);
 If y > Old_y2 then SwapV(y,Old_y2);



 Repeat
 MouseWaitForAnyKey;
 RKey:=MouseIsRKey;
 Case GetClipGadget of 3:begin
                           if x <> Old_x2 then HFlip(x,y,Old_x2,Old_y2);
                         end;
                       4:begin
                           if y <> Old_y2 then VFLip(x,y,Old_x2,Old_y2);
                         end;
                       5:begin
                           If x <> Old_x2 then SLeft(x,y,Old_x2,Old_y2);
                         end;
                       6:begin
                           If x <> Old_x2 then SRight(x,y,Old_x2,Old_y2);
                         end;
                       7:begin
                           if x <> Old_x2 then Sup(x,y,Old_x2,Old_y2);
                         end;
                       8:begin
                           if x <> Old_x2 then Sdown(x,y,Old_x2,Old_y2);
                         end;

                       9:begin
                          MouseHide;
                          DrawToolGadgets;
                          DrawRubberBand(x,y,Old_x2,Old_y2);   (* turn rubber band Off *)
                          DrawscrollGadgets;
                          DrawColorGadgets;
                          MouseShow;
                          exit;
                         end;

                       1:begin
                          if Rkey then
                          begin
                            OpenFormatP;
                          end
                          else
                          begin
                            OpenClip(x,y,Old_x2,Old_y2);
                          end;
                        end;
                       2:begin
                           if RKey then
                           begin
                             SaveFormatP;
                           end
                           else
                           begin
                             WriteClip(x,y,Old_x2,Old_y2);
                           end;
                        end;

 end;

 Until 1=0;
end;


Procedure GridP;
Var
 i : word;
 x,y,xc,yc,xstep,ystep : word;
begin
x:=GridBox_x;
y:=GridBox_y;
Case GridLine of 0:begin
                    GridLine:=1;
                    MouseHide;
                    SetColor(Black);
                    Rectangle(x,y,x+500,y+400);
                    DrawIconImage2(1,1,MaxWH,MaxWH);
                    MouseShow;
                   end;
                 1:begin
                    GridLine:=0;
                    MouseHide;
                      yc:=GridBox_y;
                      xc:=GridBox_x;
                      SetColor(LightGray);
                      for i:=1 to MaxWH+1 do
                      begin
                        Line(x,yc,x+499,yc);
                        Line(xc,y,xc,y+400);
                        inc(yc,Cellh);
                        inc(xc,Cellw);
                      end;

                    MouseShow;
                   end;
end;
end;

Procedure GridAdjustP;
Var
 n : word;
begin
 n:=GetZoomSize(80,170);
 if n > 0 then
 begin
 if n <> Rmode then
 begin
    Rmode:=n;
    xoff:=0;
    yoff:=0;
    if rmode = 1 then
    begin
       MaxWH:=25;
       CellH:=16;
       CellW:=20;
    end
    else if rmode = 2 then
    begin
       MaxWH:=50;
       CellH:=8;
       CellW:=10;
    end
    else if rmode = 3 then
    begin
       MaxWH:=100;
       CellH:=4;
       CellW:=5;
    end;
    mousehide;
    DrawGridBox(GridBox_x,GridBox_y);
    DrawscrollGadgets;
    DrawFullIconImage(1,1,MaxWH,MaxWH);
    mouseshow;

 end;
end;
end;

Procedure CLRP;
begin
 FillChar(IconImage,SizeOf(IconImage),Blue);
 xoff:=0;
 yoff:=0;
 Mousehide;
 SetDefaultPalette;
 DrawActualBox(ActualBox_x,ActualBox_y);
 DrawGridBox(GridBox_x,GridBox_y);
 DrawscrollGadgets;
 mouseshow;
end;

Procedure OpenP;
Var
 Oname : string;
 Error : Word;
begin
 oname:='';
 ChangeExt(cpath,Rfrec.PrgPat);
 if GetFile(170,90,'Open File',cpath,oname,TRUE) then
 begin
  If rftype <> 6 then
  begin
    CLRP;
    mousehide;
  end;
  error:=0;

  CASE rftype of 1: Error:=ReadPcxImg(1,1,100,100,1,oname);
                 2: Error:=ReadBMP(1,1,100,100,1,oname);
                 3: Error:=ReadIco(1,1,32,32,oname);
                 4: Error:=ReadICN(1,1,100,100,oname);
     {$IFDEF RMP}
                 4: Error:=ReadCEL(1,1,100,100,1,oname);
                 5: Error:=ReadRaw(1,1,100,100,1,oname);
                 6: begin
                      Error:=ReadPAL(oname);
                      If Error <>0 then
                      begin
                        ErrorMessage(200,175,Error);
                      end;
                      Exit;
                    End;
                 else
                   Error:=ReadCustom(1,1,100,100,1,Rfrec,oname);
     {$ENDIF}
  END;

  mouseshow;
  if error = 0 then
  begin
     Mousehide;
     DrawActualBox(ActualBox_x,ActualBox_y);
     DrawGridBox(GridBox_x,GridBox_Y);
     ReDrawImage;
     DrawFullIconImage(1,1,MaxWH,MaxWH);
     Mouseshow;
  end
  else
   begin
     ErrorMessage(200,175,Error);
  end;
 end;

end;




Procedure SaveP;
Var
 Oname : string;
 Error : Word;
begin
 Oname:='';
 ChangeExt(cpath,wfrec.PrgPat);
 if GetFile(170,90,'Save File',cpath,oname,TRUE) then
 begin
  if Pos('.',oname) = 0 then
  begin
    oname:=FExpand(oname)+'.'+wfrec.PrgPat;
  end;
  if FileExists(oname) then
  begin
    If overWriteFile(200,175) =false then
    begin
      exit;
    end;
  end;
  Mousehide;
  error:=0;


  CASE wftype of 1: Error:=SavePcxImg(1,1,100,100,oname);
                 2: Error:=WriteBMP(1,1,100,100,oname);
                 3: Error:=WriteIco(1,1,32,32,oname);
                 4: Error:=WriteXGF(1,1,100,100,TPLan,oname);
      {$IFDEF RMP}
                 4: Error:=WriteCEL(1,1,100,100,oname);
                 5: Error:=WriteRaw(1,1,100,100,oname);
                 6: Error:=WritePAL(oname);
                 7: Error:=WriteDat(0,0,0,0,PALSource,TCLan,oname);
                 8: Error:=WriteDat(0,0,0,0,PALSource,TPLan,oname);
                 9: Error:=WriteDat(0,0,0,0,PALSource,QBLan,oname);
                10: Error:=WriteXGF(1,1,100,100,TPLan,oname);
                11: CASE GetMaxColor of 15:
                      Error:=WriteDat(1,1,100,100,Source16,TPLan,oname);
                    ELSE
                      Error:=WriteDat(1,1,100,100,Source256,TPLan,oname);
                    END;
                12: CASE GetMaxColor of 15:
                      Error:=WriteDat(1,1,100,100,Source16,TCLan,oname);
                    ELSE
                      Error:=WriteDat(1,1,100,100,Source256,TCLan,oname);
                    END;
                13: Error:=WriteXGF(1,1,100,100,QBLan,oname);
                14: CASE GetMaxColor of 15:
                      Error:=WriteDat(1,1,100,100,Source16,QCLan,oname);
                    ELSE
                      Error:=WriteDat(1,1,100,100,Source256,QCLan,oname);
                    END;
                15: CASE GetMaxColor of 15:
                      Error:=WriteDat(1,1,100,100,Source16,QBLan,oname);
                    ELSE
                      Error:=WriteDat(1,1,100,100,Source256,QBLan,oname);
                    END;
                16: Error:=WriteDEF(1,1,100,100,oname);
                17: Error:=WritePPR(1,1,100,100,oname);
                18: Error:=WriteSPR(1,1,100,100,oname);
                19: Error:=WriteDat(1,1,100,100,PPRSource,TCLan,oname);
                20: Error:=WriteDat(1,1,100,100,SPRSource,TCLan,oname);
                21: Error:=WriteDat(1,1,100,100,PPRSource,TPLan,oname);
                22: Error:=WriteDat(1,1,100,100,SPRSource,TPLan,oname);
                23: Error:=WriteDat(1,1,100,100,PPRSource,QBLan,oname);
                24: Error:=WriteDat(1,1,100,100,SPRSource,QBLan,oname);
                25: Error:=WriteMouseMask(1,1,16,16,TCLan,oname);
                26: Error:=WriteMouseMask(1,1,16,16,TPLan,oname);
                27: Error:=WriteMouseMask(1,1,16,16,QBLan,oname);

     {$ENDIF}
                else
                 Error:=WriteCustom(1,1,100,100,wfrec,oname);
  END;


  Mouseshow;
  if Error <> 0 then
  begin
   ErrorMessage(200,175,Error);
  end;
 end;
end;




Procedure SaveUndoImg;
begin
 UndoImage :=IconImage;
end;

Procedure UndoP;
begin
 TempImage:=IconImage;
 IconImage:=UndoImage;
 UndoImage:=TempImage;
 MouseHide;
 DrawIconImage(1,1,100,100);
 MouseShow;
end;


Procedure DrawIconImage3(x,y,x2,y2 : word);
Var
 i,j : Word;
begin
  For i:=x to x2 do
  begin
   For j:=y to y2 do
   begin
   if IconImage[i+xoff-1,j+yoff] <> IconImage[i+xoff,j+yoff] then
   begin
   SetFillStyle(SolidFill,IconImage[i+xoff,j+yoff]);
   Bar(GridBox_x+(i-1)*CellW+1,GridBox_y+(j-1)*CellH+1,
      GridBox_x+(i-1)*CellW+CellW-1+GridLine,GridBox_y+(j-1)*CellH+CellH-1+GridLine);
   end;
   end;
  end;
end;


Procedure SweepRight;
Var
 x,y,x2,y2 : Word;
begin
 if xoff < (100-MaxWH) then
 begin
    inc(xoff);
    Mousehide;
    DrawGadget(ScrollGads,2,TRUE);
    GetGadgetCords(ScrollGads,3,x,y,x2,y2);
    DrawHSlider(x,y,x2-x+1,y2-y+1,xoff,100-MaxWH);
    DrawIconImage3(1,1,MaxWH,MaxWH);
    DrawGadget(ScrollGads,2,FALSE);
    Mouseshow;
 end;
end;



Procedure DrawIconImage4(x,y,x2,y2 : word);
Var
 i,j : Word;
begin
  For i:=x to x2 do
  begin
   For j:=y to y2 do
   begin
   if IconImage[i+xoff+1,j+yoff] <> IconImage[i+xoff,j+yoff] then
   begin
   SetFillStyle(SolidFill,IconImage[i+xoff,j+yoff]);
   Bar(GridBox_x+(i-1)*CellW+1,GridBox_y+(j-1)*CellH+1,
      GridBox_x+(i-1)*CellW+CellW-1+GridLine,GridBox_y+(j-1)*CellH+CellH-1+GridLine);
   end;
   end;
  end;
end;


Procedure SweepLeft;
Var
 x,y,x2,y2 : Word;
begin
 if xoff > 0 then
 begin
    dec(xoff);
    Mousehide;
    DrawGadget(ScrollGads,1,TRUE);
    GetGadgetCords(ScrollGads,3,x,y,x2,y2);
    DrawHSlider(x,y,x2-x+1,y2-y+1,xoff,100-MaxWH);
    DrawIconImage4(1,1,MaxWH,MaxWH);
    DrawGadget(ScrollGads,1,FALSE);
    Mouseshow;
 end;
end;

Procedure DrawIconImage5(x,y,x2,y2 : word);
Var
 i,j : Word;
begin
  For i:=x to x2 do
  begin
   For j:=y to y2 do
   begin
   SetFillStyle(SolidFill,IconImage[i+xoff,j+yoff]);
   Bar(GridBox_x+(i-1)*CellW+1,GridBox_y+(j-1)*CellH+1,
       GridBox_x+(i-1)*CellW+CellW-1+GridLine,GridBox_y+(j-1)*CellH+CellH-1+GridLine);
   end;
  end;
end;


Procedure SweepH;
Var
 t : word;
 x,y,x2,y2 : Word;
begin
if rmode <> 3 then
begin
t:=xoff;
 GetGadgetCords(ScrollGads,3,x,y,x2,y2);
 xoff:=GetHSliderPos(x,y,x2-x+1,y2-y+1,100-MaxWH);
 Mousehide;
 DrawHSlider(x,y,x2-x+1,y2-y+1,xoff,100-MaxWH);
 if t <> xoff then
 begin
  DrawIconImage5(1,1,MaxWH,MaxWH);
 end;
 MouseShow;

end;
end;




Procedure DrawIconImage6(x,y,x2,y2 : word);
Var
 i,j : Word;
begin
  For i:=x to x2 do
  begin
   For j:=y to y2 do
   begin
   if IconImage[i+xoff,j+yoff-1] <> IconImage[i+xoff,j+yoff] then
   begin
   SetFillStyle(SolidFill,IconImage[i+xoff,j+yoff]);
   Bar(GridBox_x+(i-1)*CellW+1,GridBox_y+(j-1)*CellH+1,
      GridBox_x+(i-1)*CellW+CellW-1+GridLine,GridBox_y+(j-1)*CellH+CellH-1+GridLine);
   end;
   end;
  end;
end;


Procedure SweepDown;
Var
 x,y,x2,y2 : Word;
begin
 if yoff < (100-MaxWH) then
 begin
   inc(yoff);
   Mousehide;
   DrawGadget(ScrollGads,5,TRUE);
   GetGadgetCords(ScrollGads,6,x,y,x2,y2);
   DrawVSlider(x,y,x2-x+1,y2-y+1,yoff,100-MaxWH);
   DrawIconImage6(1,1,MaxWH,MaxWH);
   DrawGadget(ScrollGads,5,FALSE);
   Mouseshow;
 end;
end;

Procedure DrawIconImage7(x,y,x2,y2 : word);
Var
 i,j : Word;
begin
  For i:=x to x2 do
  begin
   For j:=y to y2 do
   begin
   if IconImage[i+xoff,j+yoff+1] <> IconImage[i+xoff,j+yoff] then
   begin
   SetFillStyle(SolidFill,IconImage[i+xoff,j+yoff]);
   Bar(GridBox_x+(i-1)*CellW+1,GridBox_y+(j-1)*CellH+1,
      GridBox_x+(i-1)*CellW+CellW-1+GridLine,GridBox_y+(j-1)*CellH+CellH-1+GridLine);
   end;
   end;
  end;
end;


Procedure SweepUp;
Var
 x,y,x2,y2 : Word;
begin

 if yoff > 0 then
 begin
    dec(yoff);
    Mousehide;
    DrawGadget(ScrollGads,4,TRUE);
    GetGadgetCords(ScrollGads,6,x,y,x2,y2);
    DrawVSlider(x,y,x2-x+1,y2-y+1,yoff,100-MaxWH);
    DrawIconImage7(1,1,MaxWH,MaxWH);
    DrawGadget(ScrollGads,4,FALSE);
    Mouseshow;
 end;

end;


Procedure SweepV;
var
 t : word;
 x,y,x2,y2 : Word;
begin
if Rmode <> 3 then
begin
 t:=yoff;
 GetGadgetCords(ScrollGads,6,x,y,x2,y2);
 yoff:=GetVSliderPos(x,y,x2-x+1,y2-y+1,100-MaxWH);

 Mousehide;
 DrawVSlider(x,y,x2-x+1,y2-y+1,yoff,100-MaxWH);
 if t <> yoff then
 begin
 DrawIconImage5(1,1,MaxWH,MaxWH);
 end;
 MouseShow;

end;
end;




Procedure ViewP;
var
 i,j  : word;
 n    : word;
 back : Word;
 omode : Integer;
 od    : Word;
 myPal : PaletteT;
 d     : Boolean;
 c     : Word;
begin
 n:=GetScreenSize(30,196);
 if n > 0 then
 begin
   omode:=GetGraphMode;
   od:=GetMaxColor;

   GrabPaletteList(myPal,od+1);
   mousehide;

   SetGraphMode(n-1);

   SetPaletteList(myPal,od+1);

   MouseColrange(0,639);
   MouseRowrange(0,GetMaxY);


   SetFillStyle(SolidFill,Blue);
   Bar(0,0,getmaxx,getmaxy);

   back:=MostColors;

   SetFillStyle(SolidFill,back);
   c:=(GetMaxX-100) Div 2;
   Bar(c,1,c+99,100);

  For i:=1 to 100 do
  begin
   For j:=1 to 100 do
   begin
     if IconImage[i,j] <> Back then
     begin
        PutPixel(c+i-1,j,IconImage[i,j]);
     end;
   end;
  end;
  if GetMaxColor=15 then
  begin
   MouseMode(1);
  end;
  MouseShow;
  MouseWaitforAnyKey;
  MouseWaitForKeyRelease;
  MouseHide;

  SetGraphMode(omode);
  SetPaletteList(myPal,od+1);

  DrawActualBox(ActualBox_x,ActualBOx_y);
  DrawToolGadgets;
  DrawRMBox(2,350);
  DrawColorGadgets;
  DrawGridBox(GridBox_x,GridBox_y);

  ReDrawImage;
  DrawScrollGadgets;
  MouseColrange(0,629);
  MouseRowrange(0,464);
  If GetMaxColor = 15 then
  begin
    MouseMode(1);
  end;
  mouseshow;
end;
end;


begin
end.