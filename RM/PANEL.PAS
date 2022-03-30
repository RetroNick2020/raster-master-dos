
Unit Panel;
 Interface
   Uses Vars,Core,Graph,bgiMouse,bgiGadge,bgiImage,bgiMisc,bgiPal;

 Var
  ScrollGads : GLPtr;
  ClipGads   : GLPtr;
  ToolGads   : GLPtr;
  MainGads   : GLPtr;
  ColorGads  : GLPtr;

Function  GetMainGadget   : Word;
Function  GetClipGadget   : Word;
Function  GetScrollGadget : Word;
Function  GetToolGadget   : Word;
Function  GetColorGadget  : Word;

Procedure SetMainToolGadget(x,y : Word);
Procedure SetMainColorGadget(x,y : Word);
Procedure SetMainGridGadget(x,y : Word);
Procedure SetHorizScrollers(x,y : Word);
Procedure SetVirtScrollers(x,y : Word);
Procedure SetClipGadgets(x,y : Word);
Procedure SetToolGadgets(x,y : Word);
Procedure SetColorGadgets(x,y : Word);

Procedure GetGadgetMemory;
Procedure FreeGadgetMemory;
Procedure DrawClipGadgets;
Procedure DrawScrollGadgets;
Procedure DrawColorGadgets;

Procedure DrawToolGadgets;
Procedure DrawGridBox(x,y : word);
Procedure DrawActualBox(x,y : word);
Procedure DrawRMBox(x,y : Word);
Procedure SelectColor;

Function  GetZoomSize(x,y : word) : word;
Function  GetScreenSize(x,y : word) : word;

Procedure UpColors;
Procedure DownColors;
Procedure Pal;


 Implementation


Function GetZoomSize(x,y : word) : word;
var
 ReqGads : GLPtr;
      gn : Word;
    size : Word;
    Img  : Pointer;

begin
 size:=ImageSize(x,y,x+140,y+135);
 GetMem(Img,size);
 GetGadgetMem(ReqGads,4);
 DefineStringGadget(ReqGads,1,x+10,y+25,'  25 X 25  ',TRUE,FALSE);
 DefineStringGadget(ReqGads,2,x+10,y+50,'  50 X 50  ',TRUE,FALSE);
 DefineStringGadget(ReqGads,3,x+10,y+75,' 100 X 100 ',TRUE,FALSE);
 DefineStringGadget(ReqGads,4,x+60,y+105,' CANCEL ',TRUE,FALSE);
 MouseHide;
 GetImage(x,y,x+140,y+135,Img^);
 DrawFrame(x,y,x+140,y+135,'Zoom Size...');
 DrawAllGadgets(ReqGads,4);
 MouseShow;
 Repeat
   MouseWaitForKeyRelease;
   MouseWaitForLKey;
   gn:=GetGadgetPressed(ReqGads,4);
 until gn > 0;
 MouseHide;
 DrawGadget(reqGads,gn,TRUE);
 MouseShow;
 MouseWaitForKeyRelease;
 MouseHide;
 DrawGadget(reqGads,gn,FALSE);
 PutImage(x,y,Img^,normalput);
 Freemem(Img,size);
 FreeGadgetMem(ReqGads,4);
 MouseShow;
 if gn < 4 then
 begin
   GetZoomSize:=gn;
 end
 else
 begin
   GetZoomSize:=0;
 end;
end;

Function GetScreenSize(x,y : word) : word;
var
 gn     : word;
 size   : word;
 Img    : Pointer;
 ReqGads: GLPtr;
begin
 size:=ImageSize(x,y,x+150,y+155);
 GetMem(Img,size);

 GetGadgetMem(ReqGads,5);
 If GetMaxColor = 15 then
 begin
   DefineStringGadget(ReqGads,1,x+10,y+25, ' 320 X 200 ',TRUE,FALSE);
   DefineStringGadget(ReqGads,2,x+10,y+50, ' 640 X 200 ',TRUE,FALSE);
   DefineStringGadget(ReqGads,3,x+10,y+75, ' 640 X 350 ',TRUE,FALSE);
   DefineStringGadget(ReqGads,4,x+10,y+100,' 640 X 480 ',FALSE,FALSE);
   DefineStringGadget(ReqGads,5,x+80,y+130,' CANCEL ',TRUE,FALSE);
 end
 else if GetMaxColor=255 then
 begin
   DefineStringGadget(ReqGads,1,x+10,y+25, ' 320 X 200 ',TRUE,FALSE);
   DefineStringGadget(ReqGads,2,x+10,y+50,' 640 X 400 ',TRUE,FALSE);
   DefineStringGadget(ReqGads,3,x+10,y+75,' 640 X 480 ',TRUE,FALSE);
   DefineBlankGadget(ReqGads,4,1000,0,0,0,FALSE,FALSE);
   DefineStringGadget(ReqGads,5,x+80,y+130,' CANCEL ',TRUE,FALSE);
 end;

 MouseHide;
 GetImage(x,y,x+150,y+155,Img^);
 DrawFrame(x,y,x+150,y+155,'View Image in...');
 DrawAllGadgets(ReqGads,5);
 MouseShow;
 Repeat
   MouseWaitForKeyRelease;
   MouseWaitForLKey;
   gn:=GetGadgetPressed(ReqGads,5);
 until gn > 0;
 MouseHide;
 DrawGadget(reqGads,gn,TRUE);
 MouseShow;
 MouseWaitForKeyRelease;
 MouseHide;
 DrawGadget(reqGads,gn,FALSE);

 PutImage(x,y,Img^,normalput);
 MouseShow;

 Freemem(Img,size);
 FreeGadgetMem(ReqGads,5);
 if (gn < 5) then
 begin
   GetScreenSize:=gn
 end
 else
 begin
   GetScreenSize:=0;
 end;
end;



Procedure GetGadgetMemory;
begin
 GetGadgetMem(MainGads,3);
 GetGadgetMem(ScrollGads,6);
 GetGadgetMem(ClipGads,9);
 GetGadgetMem(ToolGads,18);
 GetGadgetMem(ColorGads,4);
end;

Procedure FreeGadgetMemory;
begin
 FreeGadgetMem(MainGads,3);
 FreeGadgetMem(ScrollGads,6);
 FreeGadgetMem(ClipGads,9);
 FreeGadgetMem(ToolGads,18);
 FreeGadgetMem(ColorGads,4);
end;

Procedure SetMainToolGadget(x,y : Word);
begin
 DefineBlankGadget(MainGads,1,x,y,107,238,TRUE,FALSE);
end;

Procedure SetMainColorGadget(x,y : Word);
begin
 DefineBlankGadget(MainGads,2,x,y,525,50,FALSE,FALSE);
end;

Procedure SetMainGridGadget(x,y : Word);
begin
 DefineBlankGadget(MainGads,3,x,y,500,400,TRUE,FALSE);
end;

Function GetMainGadget : Word;
begin
 GetMainGadget:=GetGadgetPressed(MainGads,3);
end;


Procedure SetHorizScrollers(x,y : Word);
Var
 P,P2 : Pointer;
begin
  if GetMaxColor=15 then
  begin
    P:=@Left16a;
    P2:=@Left16b;
  end
  else
  begin
    P:=@Left256a;
    P2:=@Left256b;
  end;

  DefineImageGadget(ScrollGads,1,x,y,17,16,P,P2,TRUE,FALSE);
  if GetMaxColor = 15 then
  begin
    P:=@Right16a;
    P2:=@Right16b;
  end
  else
  begin
    P:=@right256a;
    P2:=@right256b;
  end;
  DefineImageGadget(ScrollGads,2,x+493,y,17,16,P,P2,TRUE,FALSE);
  DefineBlankGadget(ScrollGads,3,x+18,y,474,17,TRUE,FALSE);
end;

Procedure SetVirtScrollers(x,y : Word);
Var
 P,P2 : Pointer;
begin
  If GetMaxColor=15 then
  begin
    P:=@Up16a;
    P2:=@Up16b;
  end
  else
  begin
    P:=@Up256a;
    P2:=@Up256b;
  end;

  DefineImageGadget(ScrollGads,4,x,y,17,16,P,P2,TRUE,FALSE);
  If GetMaxColor=15 then
  begin
    P:=@Down16a;
    P2:=@Down16b;
  end
  else
  begin
    P:=@Down256a;
    P2:=@Down256b;
  end;

  DefineImageGadget(ScrollGads,5,x,y+393,17,16,P,P2,TRUE,FALSE);
  DefineBlankGadget(ScrollGads,6,x,y+19,17,372,TRUE,FALSE);
end;

Function GetScrollGadget : Word;
begin
 GetScrollGadget:=GetGadgetPressed(ScrollGads,6);
end;


Procedure DrawScrollGadgets;
Var
 x,y,x2,y2 : Word;
begin
 DrawAllGadgets(ScrollGads,6);
 GetGadgetCords(ScrollGads,3,x,y,x2,y2);
 if MaxWH <> 100 then
 begin
   DrawHSlider(x,y,x2-x+1,y2-y+1,xoff,100-MaxWH);
 end
 else
 begin
   DrawHSlider(x,y,x2-x+1,y2-y+1,0,100);
 end;
 GetGadgetCords(ScrollGads,6,x,y,x2,y2);
 if MaxWH <> 100 then
 begin
   DrawVSlider(x,y,x2-x+1,y2-y+1,yoff,100-MaxWH);
 end
 else
 begin
   DrawVSlider(x,y,x2-x+1,y2-y+1,0,100);
 end;
end;


Procedure SetClipGadgets(x,y : Word);
begin
 DefineStringGadget(ClipGads,1,x+5,y+5,' OPEN ',TRUE,FALSE);
 DefineStringGadget(ClipGads,2,x+55,y+5,' SAVE ',TRUE,FALSE);
 DefineStringGadget(ClipGads,3,x+5,y+30,' HFLIP ',TRUE,FALSE);
 DefineStringGadget(ClipGads,4,x+5,y+55,' VFLIP ',TRUE,FALSE);
 DefineStringGadget(ClipGads,5,x+5,y+80,' LEFT  ',TRUE,FALSE);
 DefineStringGadget(ClipGads,6,x+5,y+105,' RIGHT ',TRUE,FALSE);
 DefineStringGadget(ClipGads,7,x+5,y+130,' UP    ',TRUE,FALSE);
 DefineStringGadget(ClipGads,8,x+5,y+155,' DOWN  ',TRUE,FALSE);
 DefineStringGadget(ClipGads,9,x+5,y+180,' EXIT ',TRUE,FALSE);
end;

Procedure DrawClipGadgets;
Var
 x,y,x2,y2 : Word;
begin
 GetGadgetCords(MainGads,1,x,y,x2,y2);
 Draw3dRect(x,y,x2-x+1,y2-y+1,FALSE);
 DrawAllGadgets(ClipGads,9);
end;

Function GetClipGadget : Word;
Var
 gn : Word;
begin
 gn:=GetGadgetPressed(ClipGads,9);
 If gn > 0 then
 begin
   MouseHide;
   DrawGadget(ClipGads,gn,TRUE);
   MouseShow;
   MouseWaitForKeyRelease;
   MouseHide;
   DrawGadget(ClipGads,gn,FALSE);
   MouseShow;
 end;
 GetClipGadget:=gn;
end;


Procedure SetToolGadgets(x,y : Word);
Var
 P,P2 : Pointer;
begin
  DefineStringGadget(ToolGads,1,x+5,y+5,' OPEN ',TRUE,FALSE);
  DefineStringGadget(ToolGads,2,x+55,y+5,' SAVE ',TRUE,FALSE);
  DefineStringGadget(ToolGads,3,x+5,y+30,' CLR  ',TRUE,FALSE);
  DefineStringGadget(ToolGads,4,x+55,y+30,' UNDO ',TRUE,FALSE);
  DefineStringGadget(ToolGads,5,x+5,y+55,' GRID ',TRUE,FALSE);
  DefineStringGadget(ToolGads,6,x+55,y+55,' SIZE ',TRUE,FALSE);
  DefineStringGadget(ToolGads,7,x+5,y+80,' VIEW ',TRUE,FALSE);
  DefineStringGadget(ToolGads,8,x+55,y+80,' MODE ',TRUE,FALSE);
  DefineStringGadget(ToolGads,10,x+5,y+105,' CLIP ',TRUE,FALSE);
  DefineStringGadget(ToolGads,9,x+55,y+105,' EXIT ',TRUE,FALSE);
  if GetMaxColor=15 then
  begin
    P:=@PAINT16a; P2:=@PAINT16b;
    DefineImageGadget(ToolGads,11,x+80,y+205,23,20,P,P2,TRUE,FALSE);

    P:=@CIRCE16a; P2:=@CIRCE16b;
    DefineImageGadget(ToolGads,12,x+55,y+180,23,20,P,P2,TRUE,FALSE);


    P:=@CIRC16a; P2:=@CIRC16b;
    DefineImageGadget(ToolGads,13,x+80,y+180,23,20,P,P2,TRUE,FALSE);


    P:=@SPRAY16a; P2:=@SPRAY16b;
    DefineImageGadget(ToolGads,14,x+55,y+205,23,20,P,P2,TRUE,FALSE);


    P:=@DOT16a; P2:=@DOT16b;
    DefineImageGadget(ToolGads,15,x+55,y+130,23,20,P,P2,TRUE,FALSE);

    P:=@SQE16a; P2:=@SQE16b;
    DefineImageGadget(ToolGads,16,x+55,y+155,23,20,P,P2,TRUE,FALSE);

    P:=@SQ16a; P2:=@SQ16b;
    DefineImageGadget(ToolGads,17,x+80,y+155,23,20,P,P2,TRUE,FALSE);

    P:=@LINE16a; P2:=@LINE16b;
    DefineImageGadget(ToolGads,18,x+80,y+130,23,20,P,P2,TRUE,FALSE);

  end
  else
  begin
    P:=@PAIN256a; P2:=@PAIN256b;
    DefineImageGadget(ToolGads,11,x+80,y+205,23,20,P,P2,TRUE,FALSE);

    P:=@CIRE256a; P2:=@CIRE256b;
    DefineImageGadget(ToolGads,12,x+55,y+180,23,20,P,P2,TRUE,FALSE);


    P:=@CIR256a; P2:=@CIR256b;
    DefineImageGadget(ToolGads,13,x+80,y+180,23,20,P,P2,TRUE,FALSE);


    P:=@SPRA256a; P2:=@SPRA256b;
    DefineImageGadget(ToolGads,14,x+55,y+205,23,20,P,P2,TRUE,FALSE);


    P:=@DOT256a; P2:=@DOT256b;
    DefineImageGadget(ToolGads,15,x+55,y+130,23,20,P,P2,TRUE,FALSE);

    P:=@SQE256a; P2:=@SQE256b;
    DefineImageGadget(ToolGads,16,x+55,y+155,23,20,P,P2,TRUE,FALSE);

    P:=@SQ256a; P2:=@SQ256b;
    DefineImageGadget(ToolGads,17,x+80,y+155,23,20,P,P2,TRUE,FALSE);

    P:=@LIN256a; P2:=@LIN256b;
    DefineImageGadget(ToolGads,18,x+80,y+130,23,20,P,P2,TRUE,FALSE);
  end;
  SetGadget(ToolGads,Tool+9,TRUE,TRUE);
end;

Procedure DrawToolGadgets;
Var
 x,y,x2,y2 : Word;
begin
 GetGadgetCords(MainGads,1,x,y,x2,y2);
 Draw3dRect(x,y,x2-x+1,y2-y+1,FALSE);
 DrawAllGadgets(ToolGads,18);
end;

Function GetToolGadget : Word;
Const
 LastTool : Word =15;
Var
 gn : Word;
begin
 gn:=GetGadgetPressed(ToolGads,18);
 If (gn > 0) AND (gn < 10) then
 begin
   MouseHide;
   DrawGadget(ToolGads,gn,TRUE);
   MouseShow;
   MouseWaitForKeyRelease;
   MouseHide;
   DrawGadget(ToolGads,gn,FALSE);
   MouseShow;
   GetToolGadget:=gn;
 end
 else if (gn > 9)  then
 begin
   if (LastTool<>gn) then
   begin
     MouseHide;
     SetGadget(ToolGads,LastTool,TRUE,FALSE);
     DrawGadget(ToolGads,LastTool,FALSE);
     DrawGadget(ToolGads,gn,TRUE);
     SetGadget(ToolGads,gn,TRUE,TRUE);
     MouseShow;
     Tool:=gn-9;
     LastTool:=gn;
   end;
 end;
end;


Procedure DrawGridBox(x,y : word);
Var
 i : word;
 xc,yc,xstep,ystep : word;
 back : Word;
begin
  GridBox_x:=x;
  GridBox_y:=y;
  Border(x-4,y-4,x+504,y+404);
  Back:=MostColors;
  SetFillStyle(SolidFill,Back);
  bar(x,y,x+500,y+400);

if gridline = 0 then
begin
  yc:=y;
  xc:=x;
  SetColor(lightGray);
  For i:=1 to MaxWH+1 do
  begin
    Line(x,yc,x+499,yc);
    Line(xc,y,xc,y+400);
    Inc(yc,Cellh);
    Inc(xc,Cellw);
  end;
end;

end;

Procedure SetColorGadgets(x,y : word);
Var
 P,P2 : Pointer;
begin
  DefineStringGadget(ColorGads,2,x+40,y+15,' PAL ',TRUE,FALSE);
  If GetMaxColor=15 then
  begin
    DefineBlankGadget(ColorGads,1,x+85,y+10,400,30,TRUE,FALSE);
  end
  else if GetMaxColor=255 then
  begin
    P:=@Up256a;
    P2:=@Up256b;
    DefineBlankGadget(ColorGads,1,x+105,y+10,400,30,TRUE,FALSE);
    DefineImageGadget(ColorGads,3,x+85,y+9,17,16,P,P2,TRUE,FALSE);
    P:=@Down256a;
    P2:=@Down256b;
    DefineImageGadget(ColorGads,4,x+85,y+25,17,16,P,P2,TRUE,FALSE);
  end;
end;


Function GetColorGadget : Word;
begin
 If GetMaxColor=15 then
 begin
   GetColorGadget:=GetGadgetPressed(ColorGads,2);
 end
 else if GetMaxCOlor=255 then
 begin
   GetColorGadget:=GetGadgetPressed(ColorGads,4);
 end;
end;


Procedure DrawPal;
Var
 i,j,x,y,x2,y2   : Word;
 Width,Height : Word;
begin
  GetGadgetCords(ColorGads,1,x,y,x2,y2);
  If GetMaxColor = 15 then
  begin
    Height:=y2-y+1;
    Width:=(x2-x+1) Div 16;
    For i:=0 to 15 do
    begin
      SetFillStyle(SolidFill,i);
      Bar(x+(i*Width),y,x+(I*Width+Width-1),y+Height);
    end;
    j:=y;
    GetGadgetCords(MainGads,2,x,y,x2,y2);
    SetFillStyle(SolidFill,Ncolor);
    Bar(x+10,j,x+10+Width-1,j+Height-1);
  end
  else if GetMaxColor=255 then
  begin
    Height:=(y2-y+1) Div 2;
    Width:=(x2-x+1) Div 32;
    For i:=0 to 31 do
    begin
       SetFillStyle(SolidFill,ColorOff+i);
       Bar(x+(i*Width),y,x+(I*Width+Width-1),y+Height);
       SetFillStyle(SolidFill,ColorOff+32+i);
       Bar(x+(i*Width),y+Height,x+(I*Width+Width-1),y+(Height*2));
    end;
    j:=y;
    GetGadgetCords(MainGads,2,x,y,x2,y2);
    SetFillStyle(SolidFill,Ncolor);
    Bar(x+10,j,x+10+(Width*2),j+Height*2-1);
  end;

end;

Procedure DrawColorGadgets;
Var
 x,y,x2,y2 : Word;
     Width : Word;
     Height: Word;
     I,J   : Word;
begin
  GetGadgetCords(MainGads,2,x,y,x2,y2);
  Draw3dRect(x,y,x2-x+1,y2-y+1,FALSE);
  If GetMaxColor=15 then
  begin
    DrawAllGadgets(ColorGads,2);
  end
  else if GetMaxCOlor = 255 then
  begin
    DrawAllGadgets(ColorGads,4);
  end;
  DrawPal;
end;


Procedure UpColors;
begin
  MouseHide;
  DrawGadget(ColorGads,3,TRUE);
  MouseShow;
  If ColorOff > 31 then
  begin
    Dec(ColorOff,32);
    MouseHide;
    DrawPal;
    MouseShow;
  end;
  MouseWaitForKeyRelease;
  MouseHide;
  DrawGadget(ColorGads,3,FALSE);
  MouseShow;
end;

Procedure DownColors;
begin
  MouseHide;
  DrawGadget(ColorGads,4,TRUE);
  MouseShow;
  If ColorOff < 191 then
  begin
    Inc(ColorOff,32);
    MouseHide;
    DrawPal;
    MouseShow;
  end;
  MouseWaitForKeyRelease;
  MouseHide;
  DrawGadget(ColorGads,4,FALSE);
  MouseShow;
end;

Procedure Pal;
begin
  MouseHide;
  DrawGadget(ColorGads,2,TRUE);
  MouseShow;
  MouseWaitForKeyRelease;
  MouseHide;
  DrawGadget(ColorGads,2,FALSE);
  MouseShow;
  PalEdit(172,244,NColor);
end;

Procedure SelectColor;
Var
 x,y,x2,y2 : Word;
 Width,Height : Word;
 st,my,mx : Integer;
       j : Word;
begin
  GetGadgetCords(ColorGads,1,x,y,x2,y2);
  MouseGetStatus(st,my,mx);
  Height:=y2-y+1;
  If GetMaxColor=15 then
  begin
    Width:=(x2-x+1) Div 16;
    NColor:=(mx-x) Div Width;
    Width:=(x2-x+1) Div 32;
  end
  else if GetMaxColor=255 then
  begin
    Width:=(x2-x+1) Div 32;
    NColor:=((mx-x) Div Width) + ColorOff;
    if (my-y+1) > (Height div 2) then
    begin
     inc(NColor,32);
    end;

  end;
  j:=Y;
  GetGadgetCords(MainGads,2,x,y,x2,y2);
  MouseHide;
  SetFillStyle(SolidFill,Ncolor);
  Bar(x+10,j,x+10+(Width*2),j+Height-1);
  MouseShow;
end;


Procedure DrawActualBox(x,y : word);
Var
 Back : Word;
begin
 Border(x-3,y-3,x+104,y+104);
 Back:=MostColors;
 SetFillStyle(SolidFill,Back);
 Bar(x+1,y+1,x+100,y+100);

 ActualBox_x:=x;
 ActualBox_y:=y;
end;

Procedure RML16;external;
{$L RML16.OBJ}

Procedure RML256;external;
{$L RML256.OBJ}


Procedure DrawRMBox(x,y : Word);
Var
 Img : Pointer;
begin
 if GetMaxColor = 15 then
 begin
  Img:=@RML16;
 end
 else
 begin
   Img:=@RML256;
 end;
 Draw3dRect(x,y,107,131,FALSE);
 PutImage(x+20,y+50,Img^,NormalPut);
end;


begin
end.