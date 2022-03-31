{$I RM.INC}
Unit Vars;
  InterFace
    Uses Dos,Graph;


Const

   CompanyName = 'RetroNick';
   ProgramName = 'Raster Master v3.8';
   CopyRight1  = '(c) Copyright 1991-2022 By '+CompanyName+'.';
   CopyRight2  = 'All Rights Reserved.';
   GitHub1     = 'Get source and latest version from github:';
   GitHub2     = 'https://github.com/RetroNick2020';

   TPLan   = 1;
   TCLan   = 2;
   QCLan   = 3;
   QBLan   = 4;
   PBLan   = 5;
   GWLan   = 6;

   Binary2   = 1;
   Binary4   = 2;
   Binary16  = 3;
   Binary256 = 4;

   Source2   = 5;
   Source4   = 6;
   Source16  = 7;
   Source256 = 8;

   SPRBinary = 9;
   SPRSource = 10;

   PPRBinary = 11;
   PPRSource = 12;

   TEGLText  = 13;

   PALSource = 14;
Type
  IcoBuf = Array[1..100,1..100] of byte;

   FormatRec = Record
                PrgName   : String[12];
                PrgPat    : String[3];
                PrgRW     : String[2];
                PrgFormat : String[3];
                PrgDis    : String[20];
             end;



Var
 RMBox_x               : Word;
 RMBox_y               : Word;
 ToolBox_x,ToolBox_y   : Word;
 ColorBox_x,ColorBox_y : Word;
 GridBox_x,GridBox_y   : Word;
 ActualBox_x,Actualbox_y : Word;
 HScrollerBox_y        : Word;
 HSCrollerBox_x        : word;
 VScrollerBox_y        : Word;
 VSCrollerBox_x        : word;
 GridLine              : Word;
 Tool                  : Word;
 NColor                : Word;
 ColorOff              : Word;
 IconImage             : IcoBuf;
 UndoImage             : IcoBuf;
 TempImage             : IcoBuf;
 Rmode                 : Word;
 MaxWH                 : Word;
 CellH                 : Word;
 CellW                 : Word;
 Xoff                  : Word;
 Yoff                  : Word;
 RFtype                : Word;
 WFtype                : Word;
 RFrec                 : FormatRec;
 Wfrec                 : FormatRec;
 Cpath                 : String;
 DPath                 : String;
(* gd,gm               : Integer;*)
 LanType               : Word;

Implementation


Procedure GetPath;
var
   n     : nameStr;
   d     : dirStr;
   e     : extStr;
BEGIN
 fsplit(ParamStr(0),d,n,e);
 Dpath:=d;
 If POS('\',Dpath) =Length(Dpath) then
 begin
   Delete(Dpath,Length(Dpath),1);
 end;
end;

begin
(*
{$IFDEF RMP}
  Verify;
{$ENDIF}
*)
  Rmode :=2; (* 1) 25 X 25  2) 50 X 50  3) 100 x 100 *)
  MaxWH :=50;
  CellH :=8;
  CellW :=10;
  Xoff  :=0;
  Yoff  :=0;
  GridLine:=0;
  Ncolor  :=White;
  ColorOff:=0;
  Tool    :=6;
  FillChar(IconImage,sizeof(IconImage),Blue);
  FillChar(TempImage,sizeof(TempImage),Blue);
  FillChar(UndoImage,sizeof(UndoImage),Blue);

  RFtype:=1;
  WFtype:=1;
  Rfrec.PrgPat:='PCX';
  Wfrec.PrgPat:='PCX';

  GetPath;
  cpath :='*.PCX';
  cpath :=FExpand(cpath);
end.

