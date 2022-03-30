
Unit Screen;
Interface
Procedure TogleMode;
Function SetSVGA16(Mode : Word) : Boolean;
Function SetSVGA256(Mode :Word) : Boolean;
Procedure RedrawImage;
Implementation
  uses graph,Vars,core,Messages,Panel,bgiMouse,bgiPal;

procedure Svga16; external;
{$L SVGA16.OBJ }


Procedure Svga256 ;external;
{$L SVGA256.OBJ}


(*
procedure Svga16; external;
{$L EGAVGA.OBJ }
*)

{$F+}
Function DetectSVGA256 : integer;
begin
    DetectSVGA256 :=2;
end;
{$F-}

{$F+}
Function DetectSVGA16 : integer;
begin
    DetectSVGA16 :=3;
end;
{$F-}


Function SetsVGA256(Mode : Word) : Boolean;
Var
 Error : Word;
 gd,gm : Integer;
begin
 SetsVga256:=TRUE;

 GD :=InstallUserDriver('svga256',@detectsvga256);
 GM :=Mode;

 Initgraph(gd,gm,'');
 If GraphResult <> 0 then
 begin
   SetsVGA256:=FALSE;
 end;
end;


Function SetSVGA16(Mode : Word) : Boolean;
Var
 gd,gm : Integer;
begin
 GD:=InstallUserDriver('svga16',@detectsvga16);
 GM:=Mode;

 Initgraph(gd,gm,'');
 If GraphResult <> 0 then
 begin
   SetSVGA16:=FALSE;
 end;
end;



(*
Function SetVGA16(Mode : Word) : Boolean;
var
 gd,gm : Integer;
begin
 IF RegisterBGIDriver(@EGAVGADriverProc) < 0 then
 begin
    Writeln('Could not load video driver.');
    halt(1);
 end;

 DetectGraph(gd,gm);
 if gd=VGA then
 begin
    gm:=Mode;
    initgraph(gd,gm,'');
 end
 else
 begin
   SetVGA16:=false;
 end;

end;

  *)









Procedure TogleMode;
Var
 myPal : PaletteT;
begin
 GrabPaletteList(myPal,256);
 MouseHide;
 If GetMaxColor = 15 then
 begin
   ClearDevice;
   CloseGraph;
   if setsvga256(2)=False then
   begin
     if SetSVga16(3) then
     begin
      SetPaletteList(myPal,16);
      MouseMode(1);
      MouseShow;
      InfoMessage(200,175,
                          {$IFDEF RMP}
                          'Raster Master cannot set',
                          {$ELSE}
                          'MagniPaint cannot set',
                          {$ENDIF}
                          'the 640X480X256 mode on',
                          'your SVGA card.');
      MouseHide;
     end;
   end
   else
   begin
    SetPaletteList(myPal,256);
    MouseMode(2);
   end;
 end
 else if GetMaxColor=255 then
 begin
   ClearDevice;
   CloseGraph;
   ReduceTo16;
   if NColor > 15 then NColor:=White;
   if SetSVga16(3) then
   begin
    SetPaletteList(myPal,16);
    MouseMode(1);
   end
 end;

end;

Procedure RedrawImage;
var
 i,j,Back : Word;
begin
 Back:=MostColors;
  For i:=1 to 100 do
  begin
   For j:=1 to 100 do
   begin
     if IconImage[i,j] <> Back then
     begin
       PutPixel(ActualBox_x+i,ActualBox_y+j,IconImage[i,j]);
     end;
   end;
   end;

  DrawFullIconImage(1,1,MaxWH,MaxWH);
end;


begin
end.
