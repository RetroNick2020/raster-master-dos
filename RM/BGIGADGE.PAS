Unit bgiGadge;

 Interface

Type
  GadgetRec = Record
                x,y         : Word;
                Width,Height: Word;
                GadgetType  : Byte;
                ImagePtr1   : Pointer;
                ImagePtr2   : Pointer;
                TextPtr     : ^String;
                Active      : Boolean;
                Pressed     : Boolean;
              End;

  GadgetList = Array[1..1000] Of GadgetRec;

  GLPtr = ^GadgetList;

Procedure GetGadgetMem(Var tGLPtr : GLPtr; Ngs : Word);


Procedure DefineBlankGadget(Var tGadgetListPtr : GLPtr;
                                gadgetNum, x, y, Width, Height : Word;
                                Active,Pressed : Boolean);

Procedure DefineBoxGadget(Var tGadgetListPtr : GLPtr;
                                gadgetNum, x, y, Width, Height : Word;
                                Active,Pressed : Boolean);

Procedure DefineStringGadget(Var tGadgetListPtr : GLPtr;
                                gadgetNum, x, y : Word; TextStr : String;
                                Active,Pressed : Boolean);

Procedure DefineImageGadget(Var tGLPtr : GLPtr;
                                gadgetNum, x, y, Width, Height : Word;
                                Var ImagePtr1,ImagePtr2 : Pointer;
                                Active,Pressed : Boolean);

Procedure SetGadget(Var tGLPtr : GLPtr; gn : Word;Active,Pressed : Boolean);

Procedure FreeGadgetMem(Var tGLPtr : GLPtr; Ngs : Word);

Procedure DrawGadget(Var tGLPtr : GLPtr; gN : Word;Pressed : Boolean);

Procedure DrawAllGadgets(Var tGLPtr : GLPtr; Ngs : Word);

Procedure DrawVSlider(x,y,Width,Height,BPos,Brange : Word);


Procedure Draw3DRect(x,y,Width,Height : Word;Pressed : Boolean);

Function  GetGadgetPressed(Var tGLPtr : GLPtr; Ngs : Word) : Word;

Procedure GetGadgetCords(Var tGLPtr : GLPtr; Gn : Word;Var x,y,x2,y2 : Word);

Function GetVSliderPos(x,y,Width,Height,Brange : Word) : Word;

Function GetHSliderPos(x,y,Width,Height,Brange : Word) : Word;

Procedure DrawHSlider(x,y,Width,Height,BPos,Brange : Word);

 Implementation
   uses Graph,bgiText,bgiMouse;

Procedure GetGadgetMem(Var tGLPtr : GLPtr; Ngs : Word);
begin
 GetMem(tGLPtr,SizeOf(GadgetRec)*Ngs);
end;

Procedure FreeGadgetMem(Var tGLPtr : GLPtr; Ngs : Word);
Var
 I : Word;
begin
 For i:=1 To Ngs do
 begin
  If tGLPtr^[i].GadgetType=2 then
  begin
   If tGLPtr^[i].TextPtr<>NIL then
   begin
     FreeMem(tGLPtr^[i].TextPtr,Length(tGLPtr^[i].TextPtr^)+1);
   end;
  end;
 end;
 FreeMem(tGLPtr,SizeOf(GadgetRec)*Ngs);
end;

Procedure DefineBlankGadget(Var tGadgetListPtr : GLPtr;
                                gadgetNum, x, y, Width, Height : Word;
                                Active,Pressed : Boolean);
begin
 tGadgetListPtr^[gadgetNum].x:=x;
 tGadgetListPtr^[gadgetNum].y:=y;
 tGadgetListPtr^[gadgetNum].Width:=Width;
 tGadgetListPtr^[gadgetNum].Height:=Height;
 tGadgetListPtr^[gadgetNum].GadgetType:=0;
 tGadgetListPtr^[gadgetNum].Active:=Active;
 tGadgetListPtr^[gadgetNum].Pressed:=Pressed;
 tGadgetListPtr^[gadgetNum].ImagePtr1:=NIL;
 tGadgetListPtr^[gadgetNum].ImagePtr2:=NIL;
 tGadgetListPtr^[gadgetNum].TextPtr:=NIL;
end;

Procedure DefineBoxGadget(Var tGadgetListPtr : GLPtr;
                                gadgetNum, x, y, Width, Height : Word;
                                Active,Pressed : Boolean);
begin
 tGadgetListPtr^[gadgetNum].x:=x;
 tGadgetListPtr^[gadgetNum].y:=y;
 tGadgetListPtr^[gadgetNum].Width:=Width;
 tGadgetListPtr^[gadgetNum].Height:=Height;
 tGadgetListPtr^[gadgetNum].GadgetType:=1;
 tGadgetListPtr^[gadgetNum].Active:=Active;
 tGadgetListPtr^[gadgetNum].Pressed:=Pressed;
 tGadgetListPtr^[gadgetNum].ImagePtr1:=NIL;
 tGadgetListPtr^[gadgetNum].ImagePtr2:=NIL;
 tGadgetListPtr^[gadgetNum].TextPtr:=NIL;

end;

Procedure DefineStringGadget(Var tGadgetListPtr : GLPtr;
                                gadgetNum, x, y : Word; TextStr : String;
                                Active,Pressed : Boolean);
begin
 tGadgetListPtr^[gadgetNum].x:=x;
 tGadgetListPtr^[gadgetNum].y:=y;
 tGadgetListPtr^[gadgetNum].Width:=Length(TextStr)*8;
 tGadgetListPtr^[gadgetNum].Height:=20;
 tGadgetListPtr^[gadgetNum].GadgetType:=2;
 tGadgetListPtr^[gadgetNum].Active:=Active;
 tGadgetListPtr^[gadgetNum].Pressed:=Pressed;
 tGadgetListPtr^[gadgetNum].ImagePtr1:=NIL;
 tGadgetListPtr^[gadgetNum].ImagePtr2:=NIL;

 GetMem(tGadgetListPtr^[gadgetNum].TextPtr,Length(TextStr)+1);
 if tGadgetListPtr^[gadgetNum].TextPtr =NIL  then
 begin
  writeln('not enough mem to allocate gadget');

 end;

 tGadgetListPtr^[gadgetNum].TextPtr^:=TextStr;
end;

Procedure DefineImageGadget(Var tGLPtr : GLPtr;
                                gadgetNum, x, y, Width, Height : Word;
                                Var ImagePtr1,ImagePtr2 : Pointer;
                                Active,Pressed : Boolean);
begin
 tGLPtr^[gadgetNum].x:=x;
 tGLPtr^[gadgetNum].y:=y;
 tGLPtr^[gadgetNum].Width:=Width;
 tGLPtr^[gadgetNum].Height:=Height;
 tGLPtr^[gadgetNum].GadgetType:=3;
 tGLPtr^[gadgetNum].Active:=Active;
 tGLPtr^[gadgetNum].Pressed:=Pressed;
 tGLPtr^[gadgetNum].ImagePtr1:=ImagePtr1;
 tGLPtr^[gadgetNum].ImagePtr2:=ImagePtr2;
 tGLPtr^[gadgetNum].TextPtr:=NIL;
end;

Procedure SetGadget(Var tGLPtr : GLPtr; gn : Word;Active,Pressed : Boolean);
begin
 tGLPtr^[gN].Active:=Active;
 tGLPtr^[gN].Pressed:=Pressed;
end;

Procedure Draw3DRect(x,y,Width,Height : Word;Pressed : Boolean);
Var
 x2,y2 : Word;
begin
  x2:=x+Width-1;
  y2:=y+Height-1;

  SetFillStyle(SolidFill,Black);
  Bar(x,y,x2,y2);
  If Pressed = True then
  begin
     SetFillStyle(SolidFill,LightGray);
     Bar(x+1,y+1,x2-1,y2-1);
  end
  else
  begin
     Setcolor(White);
     MoveTo(x+1,y2-1);
     LineTo(x+1,y+1);
     LineTo(x2-1,y+1);
     SetFillStyle(SolidFill,LightGray);
     Bar(x+2,y+2,x2-2,y2-2);
  end;
end;

Procedure DrawGadget(Var tGLPtr : GLPtr; gN : Word;Pressed : Boolean);
Var
 x,y,Width,Height : Word;
begin
  x:=tGLPtr^[gN].x;
  y:=tGLPtr^[gN].y;
  Width:=tGLPtr^[gN].Width;
  Height:=tGLPtr^[gN].Height;

  Case tGLPtr^[gN].GadgetType Of

       1:begin
           Draw3DRect(x,y,Width,Height,Pressed);
         end;
       2:begin
           Draw3Drect(x,y,Width,Height,Pressed);
           If Pressed then
           begin
             ShadowText(x+1,y+7,tGLPtr^[gN].TextPtr^);
           end
           else
           begin
             ShadowText(x,y+6,tGLPtr^[gN].TextPtr^);
           end;
         end;
       3:begin
           If Pressed then
           begin
             PutImage(x,y,tGLPtr^[gN].ImagePtr2^,NormalPut);
           end
           else
           begin
             PutImage(x,y,tGLPtr^[gN].ImagePtr1^,NormalPut);
           end;
         end;

  end;
end;

Procedure DrawAllGadgets(Var tGLPtr : GLPtr; Ngs : Word);
Var
 I : Word;
begin
  For i:=1 to Ngs do
  begin
    DrawGadget(tGLPtr,i,tGLPtr^[i].Pressed);
  end;
end;

Function GetGadgetPressed(Var tGLPtr : GLPtr; Ngs : Word) : Word;
Var
 Stat,Row,Col : Integer;
 I : Word;
begin
  GetGadgetPressed:=0;

  MouseGetStatus(Stat,Row,Col);

  For i:=1 to Ngs do
  begin
    IF (Col >= tGLPtr^[i].x ) AND
       (Col <= tGLPtr^[i].x+tGLPtr^[i].Width-1) AND
       (Row >= tGLPtr^[i].y ) AND
       (Row <=tGLPtr^[i].y+tGLPtr^[i].Height-1) Then
    begin
        GetGadgetPressed:=I;
        Exit;
    end;
  end;
end;


Procedure GetGadgetCords(Var tGLPtr : GLPtr; Gn : Word;Var x,y,x2,y2 : Word);
begin
  x:=tGLPtr^[gN].x;
  y:=tGLPtr^[gN].y;
  x2:=x+tGLPtr^[gN].Width-1;
  y2:=y+tGLPtr^[gN].Height-1;
end;

Procedure DrawVSlider(x,y,Width,Height,BPos,Brange : Word);
Var
 h,n : Word;
 x2,y2 : Word;
begin
 x2:=x+Width-1;
 y2:=y+Height-1;
 SetFillStyle(SolidFill,LightGray);
 Bar(x+1,y+1,x2-1,y2-1);
 Setcolor(Black);
 Rectangle(x,y,x2,y2);
 dec(y2,15);
 h:=y2-y;
 n:=(bpos*h) Div brange;
 Draw3DRect(x,y+n,Width,15,false);
end;

Procedure DrawHSlider(x,y,Width,Height,BPos,Brange : Word);
Var
 h,n : Word;
 x2,y2 : Word;
begin
 x2:=x+Width-1;
 y2:=y+Height-1;
 SetFillStyle(SolidFill,LightGray);
 Bar(x+1,y+1,x2-1,y2-1);
 Setcolor(Black);
 Rectangle(x,y,x2,y2);
 dec(x2,15);
 h:=x2-x;
 n:=(bpos*h) Div brange;
 Draw3dRect(x+n,y,15,Height,false);
end;

Function GetVSliderPos(x,y,Width,Height,Brange : Word) : Word;
Var
 h,n : Word;
 st,mx,my : Integer;
 Old_my   : Integer;
 f        : boolean;
 x2,y2    : Word;
begin
 x2:=x+Width-1;
 y2:=y+Height-1;
 MouseHide;
 SetFillStyle(SolidFill,LightGray);
 Bar(x+1,y+1,x2-1,y2-1);
 MouseShow;
 dec(y2,15);
 f:=false;
Repeat
 mouseGetStatus(st,my,mx);
 dec(my,7);
 if my < y then my:=y;
 if my > y2 then my:=y2;
 if Old_my <> my then
 begin
   MouseHide;                  (* mouse hide *)
   if f then
   begin
     SetColor(LightGray);
     Rectangle(x+1,Old_my+1,x2-1,old_my+14);
   end;
   f:=true;
   SetColor(White);
   Rectangle(x+1,my+1,x2-1,my+14);
   MouseShow;;
   Old_my:=my;                   (* mouse show *)
  end;
Until st =0;
 if my < y then my:=y;
 h:=y2-y;
 GetVSliderPos:=(Brange*(my-y)) div h;
end;

Function GetHSliderPos(x,y,Width,Height,Brange : Word) : Word;
Var
 h,n : Word;
 st,mx,my : Integer;
 Old_mx   : Integer;
 f        : boolean;
 x2,y2    : Word;
begin
 x2:=x+Width-1;
 y2:=y+Height-1;

 MouseHide;
 SetFillStyle(SolidFill,LightGray);
 Bar(x+1,y+1,x2-1,y2-1);
 MouseShow;
 dec(x2,15);
 f := false;
Repeat
 MouseGetStatus(st,my,mx);
 dec(mx,7);
 if mx < x then mx:=x;
 if mx > x2 then mx:=x2;
 if Old_mx <> mx then
 begin
  MouseHide;
  if f then
  begin
    SetColor(LightGray);
    Rectangle(Old_mx+1,y+1,Old_mx+14,y2-1);
  end;
  SetColor(White);
  Rectangle(mx+1,y+1,mx+14,y2-1);
  MouseShow;
  f:=true;
  Old_mx:=mx;
end;
Until st =0;
 if mx < x then mx:=x;
 h:=x2-x;
 GetHSliderPos:=(Brange*(mx-x)) div h;
end;




begin
end.