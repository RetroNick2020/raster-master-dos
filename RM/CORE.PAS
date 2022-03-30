Unit Core;

 Interface

Function MostColors : Word;
Procedure Fill(xx,yy: Word);
Procedure ReduceTo16;
Procedure DrawFullIconImage(x,y,x2,y2 : word);

 Implementation
   Uses Vars,graph;


Procedure ReduceTo16;
Var
 i,j : Word;
 T   : byte;
begin
  For i:=1 to 100 do
  begin
   For j:=1 to 100 do
   begin
     T:=IconImage[i,j] SHL 4;
     IconImage[i,j]:=T SHR 4;
   end;
  end;
end;


Function MostColors : Word;
Var
 colorList : Array[0..255] of Word;
 oc,mc,i,j : Word;

begin
  FillChar(colorList,sizeof(colorList),0);
  For i:=1 to 100 do
  begin
   For j:=1 to 100 do
   begin
     Inc(colorList[IconImage[i,j]]);
   end;
  end;
  mc:=0;
  oc:=0;
  for i:=0 to 255 do
  begin
    if colorList[i]>mc then
    begin
     mc:=colorList[i];
     oc:=i;
    end;
  end;
  MostColors:=oc;

end;

Procedure Fill(xx,yy: Word);
const
 Left =1;
 right=2;
 up   =3;
 down =4;

Type
 stype = Array[0..10000] of byte;
 stypePtr=^Stype;
Var
 StackHolderX : stypePtr;
 StackHolderY : stypePtr;
 StackHolderPos : stypePtr;
 sthnum    : word;
 pp        : Word;
 coltofill : Word;


Procedure CheckRight;
begin
if xx<100 then
begin
if IconImage[xx+1,yy] = ColTofill then
   begin
(*   Pplot2(xx+1,yy,false);*)
   IconImage[xx+1,yy] :=Ncolor;
   inc(sthnum);
   StackHolderx^[sthnum]:=xx+1;
   StackHoldery^[sthnum]:=yy;
   StackHolderpos^[sthnum]:=Right;
end;
end;
end;


Procedure CheckLeft;
Begin
if xx >1 then
begin
if IconImage[xx-1,yy] = ColTofill then
   begin
(*     Pplot2(xx-1,yy,false);*)
     IconImage[xx-1,yy]:=Ncolor;
     inc(sthnum);
   StackHolderx^[sthnum]:=xx-1;
   StackHoldery^[sthnum]:=yy;
   StackHolderpos^[sthnum]:=left;
end;
end;
end;

Procedure CheckUp;
begin
if yy>1 then
begin
if IconImage[xx,yy-1] = ColTofill then
   begin
(*   Pplot2(xx,yy-1,false);*)
   IconImage[xx,yy-1]:=Ncolor;
   inc(sthnum);
   StackHolderx^[sthnum]:=xx;
   StackHoldery^[sthnum]:=yy-1;
   StackHolderpos^[sthnum]:=up;
end;
end;

end;

Procedure CheckDown;
var c : integer;
begin
if yy<100 then
begin
If IconImage[xx,yy+1]=ColTofill then
   begin
(*    Pplot2(xx,yy+1,false);*)
    IconImage[xx,yy+1]:=Ncolor;
    inc(sthnum);
    StackHolderx^[sthnum]:=xx;
    StackHoldery^[sthnum]:=yy+1;
    StackHolderpos^[sthnum]:=down;
end;
end;
end;

Procedure GetColortoFill;
begin
ColToFill:=IconImage[xx,yy];
end;



Procedure GetNewCord;
begin
 if sthnum > 0 then
 begin
  xx:=StackHolderx^[sthnum];
  yy:=StackHoldery^[sthnum];
  pp:=StackHolderpos^[sthnum];
  dec(sthnum);
 end;
end;




begin
GetMem(StackHolderX,SizeOf(Stype));
GetMem(StackHolderY,SizeOf(Stype));
GetMem(StackHolderPos,SizeOf(Stype));


FillChar(StackHolderX^,SizeOf(StackHolderX),0);
FillChar(StackHolderY^,SizeOf(StackHolderY),0);
FillChar(StackHolderPos^,SizeOf(StackHolderPos),0);

sthnum:=1;
GetColorTofill;
IconImage[xx,yy]:=Ncolor;
Repeat
 case pp of
 Left: begin
          CheckLeft;
          CheckDown;
          Checkup;
      end;
 Right:begin
          CheckRight;
          CheckUp;
          CheckDown;
       end;
 Up:   begin
           CheckRight;
           CheckLeft;
           Checkup;
       end;
 Down: begin
           CheckDown;
           CheckRight;
           CheckLeft;
       end;
 else
    begin
           CheckRight;
           CheckUP;
           CheckDown;
           CheckLeft;
    end;
 end;
 GetNewCord;
Until sthnum=0;
FreeMem(StackHolderX,SizeOf(Stype));
FreeMem(StackHolderY,SizeOf(Stype));
FreeMem(StackHolderPos,SizeOf(Stype));

end;

Procedure DrawFullIconImage(x,y,x2,y2 : word);
Var
 i,j : Word;
 Back : Word;
begin
  Back:=MostColors;
  For i:=x to x2 do
  begin
   For j:=y to y2 do
   begin
   if IconImage[i+xoff,j+yoff] <> Back then
   begin
   SetFillStyle(SolidFill,IconImage[i+xoff,j+yoff]);
   Bar(GridBox_x+(i-1)*CellW+1,GridBox_y+(j-1)*CellH+1,
      GridBox_x+(i-1)*CellW+CellW-1+GridLine,GridBox_y+(j-1)*CellH+CellH-1+GridLine);
   end;
   end;
  end;
end;


begin
end.