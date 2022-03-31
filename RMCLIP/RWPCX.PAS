Unit RWPcx;
Interface
uses
  Dos,XGraph,bgipal,Graph,Bits;
Type

   PImageRec = Record
                 Img       : Pointer;
                 Colors    : Word;
                 memAmount : LongInt;
               End;

   PcxPalette = Array[0..255,0..2] of Byte;

   PCXHeaderRec = Record
        Manufacturer: byte;     (* Always 10 for PCX file *)

        Version: byte;          (* 2 - old PCX - no palette (not used anymore),
                                   3 - no palette,
                                   4 - Microsoft Windows - no palette (only in
                                      old files, new Windows version uses 3),
                                   5 - with palette *)

        Encoding: byte;         (* 1 is PCX, it is possible that we may add
                                  additional encoding methods in the future *)

        Bits_per_pixel: byte;   (* Number of bits to represent a pixel
                                  (per plane) - 1, 2, 4, or 8 *)

        Xmin: integer;          (* Image window dimensions (inclusive) *)
        Ymin: integer;          (* Xmin, Ymin are usually zero (not always) *)
        Xmax: integer;
        Ymax: integer;

        Hdpi: integer;          (* Resolution of image (dots per inch) *)
        Vdpi: integer;          (* Set to scanner resolution - 300 is default *)

        ColorMap: array [0..15, 0..2] of byte;
                                (* RGB palette data (16 colors or less)
                                   256 color palette is appended to end of file *)

        Reserved: byte;         (* (used to contain video mode)
                                   now it is ignored - just set to zero *)

        Nplanes: byte;          (* Number of planes *)

        Bytes_per_line_per_plane: integer;   (* Number of bytes to allocate
                                                for a scanline plane.
                                                MUST be an an EVEN number!
                                                Do NOT calculate from Xmax-Xmin! *)

        PaletteInfo: integer;   (* 1 = black & white or color image,
                                   2 = grayscale image - ignored in PB4, PB4+
                                   palette must also be set to shades of gray! *)

        HscreenSize: Integer;   (* added for PC Paintbrush IV Plus ver 1.0,  *)
        VscreenSize: Integer;   (* PC Paintbrush IV ver 1.02 (and later)     *)
                                (* I know it is tempting to use these fields
                                   to determine what video mode should be used
                                   to display the image - but it is NOT
                                   recommended since the fields will probably
                                   just contain garbage. It is better to have
                                   the user install for the graphics mode he
                                   wants to use... *)

        Filler: array [74..127] of Byte;
    end;

Function  ValidPcxFile(Filename : string) : Boolean;
Function  GetPcxWidth(Var PcxH : PcxHeaderRec) : Word;
Function  GetPcxHeight(Var PcxH : PcxHeaderRec) : Word;
Function DisPcxImg(x,y,x2,y2 : Word;IPal : Boolean;Filename : string): word;
Function  SavePcxImg(x,y,x2,y2 : Word;Filename : String): Word;


Procedure GetPcxInfo(Filename : string; Var PcxH : PcxHeaderRec;Var Pal : PaletteT);
Function  GetNPcxColors(Var PcxH : PcxHeaderRec) : Word;

Implementation

Const
   MaxWidth    = 2048;    (* arbitrary - maximum width (in bytes) of a PCX image *)
   CompressNum = $C0;  (* this is the upper two bits that indicate a count *)
   MaxBlock    = 4096;




type
   BlockArray     = Array [0..MaxBlock]  of Byte;
   UncpLine       = Array [0..MaxWidth]  of Byte;
   CompressedLine = Array [0..MaxWidth*2] of Byte;

var
   BlockData: ^BlockArray;             (* 4k data buffer                     *)
   NextByte : Integer;                 (* index into file buffer in ReadByte *)
   Index    : Integer;                 (* PCXline index - where to put Data  *)
   Data     : byte;                    (* PCX compressed data byte           *)


Function BytesPerRow(width : word) : Word;
begin
 BytesPerRow :=(width+7) div 8;
end;

(*
Procedure SetRGBColorX(ColorN,R,G,B : Word);
Var
  reg : registers;
Begin

if colorn < 16 then
begin
 Reg.ah := $10;
 Reg.al := $0;
 Reg.bl := ColorN;
 Reg.bh := ColorN;
 intr ($10, Reg);
end;

 Reg.ah := $10;
 Reg.al := $10;
 Reg.bx := ColorN;
 Reg.dh := R;
 Reg.ch := G;
 Reg.cl := B;
 intr ($10, Reg);
end;


Procedure GetRgbColorX(NColor : Word;Var R,G,B : Word);
var
  Reg : registers;
begin
  Reg.ah:=$10;
  Reg.al:=$15;
  Reg.bx:=NColor;
  intr($10,reg);
  R:=reg.dh;
  G:=reg.ch;
  B:=reg.cl;
end;


Procedure SetPcxPalette(Var Pal : PcxPalette; NColors : Word);
Var
 PN,R,G,B : byte;
 I : Word;
Begin
For i:=0 to NColors-1 do
Begin
 R := Pal[i,0] shr 2;
 G := pal[i,1] shr 2;
 B := pal[i,2] shr 2;
 SetRGBColorX(i,R,G,B);
end;
end;


Procedure GrabPalette(Var Pal : PcxPalette;NColors : Word);
var
i : word;
r,g,b : word;
begin
 For i:=0 to NColors-1 do
 begin
  GetRGBColorX(i,R,G,B);
  Pal[i,0]:=(R shl 2);
  Pal[i,1]:=(G shl 2);
  pal[i,2]:=(B shl 2);
 end;
end;
*)

Procedure GetPcxInfo(Filename : string; Var PcxH : PcxHeaderRec;Var Pal : PaletteT);
Var
 F     :  File;
 Error : Word;
Begin
{$I-}
 Assign(F,Filename);
 Reset(F,1);
 Error:=IORESULT;
 if Error<>0 then exit;
 BlockRead(F,PcxH,sizeof(PcxH));
 If (PcxH.Bits_Per_Pixel = 8) and (PcxH.Version=5) then
 begin
   Seek(F,FileSize(F)-768);
   BlockRead(F,Pal,SizeOf(Pal));
 end
 else
 begin
   Move(PcxH.ColorMap,Pal,48);
 end;
 Close(F);
 Error:=IORESULT;
{I+}
end;


Function ValidPcxFile(Filename : string) : Boolean;
Var
  MyPcxHeader : PcxHeaderRec;
  F           : File;
 Error        : Word;
Begin
{$I-}
 Assign(F,Filename);
 Reset(F,1);
 BlockRead(F,MyPcxHeader,sizeof(MyPcxHeader));
 Close(F);
 Error:=IORESULT;
{$I+}
 ValidPcxFile:=false;
 If (MyPcxHeader.Manufacturer = 10) AND (Error=0) then
 begin
   ValidPcxFile:=true;
 end;
end;

Function GetNPcxColors(Var PcxH : PcxHeaderRec) : Word;
begin
 GetNPcxColors:=0;
 if (PcxH.Bits_Per_Pixel=1)      And (pcxH.nplanes=1) then
 begin
    GetNPcxColors:=2;
 end
 Else if (PcxH.Bits_Per_Pixel=2) And (pcxH.nplanes=1) then
 begin
    GetNPcxColors:=4;
 end
 Else if (PcxH.Bits_Per_Pixel=1) And (pcxH.nplanes=3) then
 begin
    GetNPcxColors:=8;
 end
 Else if (PcxH.Bits_Per_Pixel=1) And (pcxH.nplanes=4) then
 begin
    GetNPcxColors:=16;
 end
 Else if (PcxH.Bits_Per_Pixel=8) And (pcxH.nplanes=1) then
 begin
    GetNPcxColors:=256;
 end;
end;


Function GetPcxWidth(Var PcxH : PcxHeaderRec) : Word;
begin
 GetPcxWidth:=PcxH.Xmax-PcxH.Xmin+1;
end;

Function GetPcxHeight(Var PcxH : PcxHeaderRec) : Word;
begin
 GetPcxHeight:=PcxH.Ymax-PcxH.Ymin+1;
end;

Function PcxPaletteExists(Var PcxH : PcxHeaderRec) : Boolean;
begin
  PcxPaletteExists:=false;
  if PcxH.Version > 4 then
  begin
     PcxPaletteExists:=true;
  end;
end;


Function Compressline(Var Uline:UncpLine;Var CLine : CompressedLine;BytesPerLine : Word) : Word;
Var
 cp        : Word;
 count     : Word;
 repeatNum : Word;
begin
 Cp:=0;
 Count:=0;
 Repeat
   repeatNum:=0;
   repeat
     inc(repeatNum);
   until (repeatNum+count=BytesPerLine) OR
         (uline[count+repeatNum-1] <> uline[count+repeatNum]) OR (repeatNum>62);

   if (repeatNum > 1) then
   begin
     Cline[Cp]:=repeatNum;
     inc(cline[Cp],192);
     inc(Cp);
     Cline[Cp]:=Uline[count];
     inc(count,repeatNum);
     inc(Cp);
   end
   else if (uline[count] > 127) then
   begin
     Cline[Cp]:=repeatNum;
     inc(cline[Cp],192);
     inc(Cp);
     Cline[Cp]:=uline[count];
     inc(count,repeatNum);
     inc(Cp);
   end
   else
   begin
     Cline[Cp]:=uline[count];
     inc(Cp);
     inc(count,repeatNum);
   end;
 Until (count=BytesPerLine) OR (count=BytesPerLine-1);

 if count=BytesPerLine-1 then
 begin
   repeatNum:=1;
   if uline[count] > 127  then
   begin
     Cline[Cp]:=repeatNum;
     inc(Cline[Cp],192);
     inc(Cp);
     Cline[Cp]:=uline[count];
     inc(count,repeatNum);
     inc(Cp);
   end
   else
   begin
     Cline[Cp]:=uline[count];
     inc(Cp);
     inc(count,repeatNum);
   end;
 end;
 compressline:=Cp;
end;


Procedure ReadByte(Var F : File);
var
 NumBlocksRead : Integer;
begin
 if NextByte = MaxBlock then
 begin
{$I-}
   BlockRead (F, BlockData^,MaxBlock,NumBlocksRead);
{$I+}
   NextByte:=0;
 end;
 Data:=BlockData^[NextByte];
 Inc(NextByte);
End;

Procedure ReadPCXLine(Var F : File;Var Uline : Uncpline;BytesPerLine : Word);
Var
 Count : Word;
begin
 If Index <> 0 then
 begin
   FillChar(Uline [0], Index, data);
 end;
 While (Index < BytesPerLine) do
 begin
   ReadByte(F);
   If (Data and $C0) = CompressNum then
   begin
     Count:=(Data AND $3F);
     ReadByte(F);
     FillChar(Uline [Index],Count,Data);
     Inc(Index,Count);
     end
   else
   begin
     Uline[Index]:=Data;
     Inc(Index);
   end;
 end;
 Dec(Index,BytesPerLine);
end;

Procedure mpTOsp(Var mPlane : UncpLine;Var splane : uncpLine;
                 ImgOff2,ImgOff3,ImgOff4 : Word);
Var
 i,j    : Word;
 xpos : Word;
 Col  : Word;
begin
 xpos:=0;
 FillChar(splane,SizeOf(sPlane),0);
 For i:=0 to ImgOff2-1 do
 begin
   For j:=7 downto 0 do
   begin
     Col:=0;
     if biton(j,mPlane[i]) then
     begin
       Inc(Col,1);
     end;

     if biton(j,mPlane[i+ImgOff2]) then
     begin
       Inc(Col,2);
     end;

     if biton(j,mPlane[i+ImgOff3]) then
     begin
       Inc(Col,4);
     end;

     if biton(j,mPlane[i+ImgOff4]) then
     begin
       Inc(Col,8);
     end;

     Splane[xpos]:=Col;
     Inc(xpos);
   end;
 end;
end;


Procedure DisLine(x,y : Word;Var Splane : UncpLine;width : Word);
Var
 i : Word;
 cl  : array[0..255] of Word;
 mc,oc : Word;
begin
 Fillchar(cl,sizeof(cl),0);
 For i:=0 to width-1 do
 begin
    Inc(cL[Splane[i]]);
 end;
 mc:=0;
 oc:=0;
 for i:=0 to 255 do
 begin
   if cL[i]>mc then
   begin
    mc:=cL[i];
    oc:=i;
   end;
 end;
 SetColor(oc);
 Line(x,y,x+width-1,y);

 For i:=0 to width-1 do
 begin
   if Splane[i]<>oc then
   begin
     PutPixel(x+i,y,Splane[i]);
   end;
 end;
end;


Function DisPcxImg(x,y,x2,y2 : Word;IPal : Boolean;Filename : string): word;
Type
 ImgRec = Array[1..$FFFF] of Byte;
var
 PcxFile        : File;
 Header         : PcxHeaderRec;
 PcxPal         : PaletteT;
 Uline          : UncpLine;
 SPlane         : UncpLine;
 ImgBuf         : ^ImgRec;
 ImgOff         : Word;
 BitPlane2      : Word;
 BitPlane3      : Word;
 BitPlane4      : Word;
 BytesPerLine   : Word;
 memAmount      : LongInt;
 i,j,Ln         : Word;
 myWidth        : Word;
 myHeight       : Word;
 Error          : Word;
 NColors        : Word;
 Temp           : Byte;
 DisFlag        : Word;
Begin
 DisPcxImg:=0;
 DisFlag:=0;
{$I-}

 Assign(PcxFile, Filename);
 Reset(PcxFile, 1);
 Error:=IORESULT;

 If Error <> 0 Then
 begin
   DisPcxImg:=Error;
   Exit;
 end;

 BlockRead(PcxFile, Header, 128);
 Error:=IORESULT;

 If Error <> 0 Then
 begin
   DisPcxImg:=Error;
   Exit;
 end;

 Index:=0;
 NextByte:=MaxBlock;

 myHeight:=(Header.Ymax-Header.Ymin+1);

 NColors:=GetNPcxColors(Header);
 If (NColors<>16) AND (NColors<>256) then
 begin
   DisPcxImg:=1001;
   Close(PcxFile);
   Exit;
 end
 Else if (Header.Manufacturer<>10) then
 begin
   DisPcxImg:=1001;
   Close(PcxFile);
   Exit;
 end;

 If NColors=16 then
 begin
   BytesPerLine:=(Header.Bytes_per_line_per_plane SHL 2);
   memAmount:=BytesPerLine + 6;
   myWidth:=BytesPerLine SHL 1;
   BitPlane2:=(BytesPerLine SHR 2);
   BitPlane3:=(BytesPerLine SHR 1);
   BitPlane4:=(BytesPerLine SHR 2) * 3;
 end
 else
 begin
   BytesPerLine:=Header.Bytes_per_line_per_plane;
   memAmount:=BytesPerLine + 6;
   myWidth:=BytesPerLine;
 end;

 GetMem(ImgBuf,memAmount);
 GetMem(BlockData,SizeOf(BlockArray));

 ImgBuf^[1]:=Lo(myWidth-1);
 ImgBuf^[2]:=Hi(myWidth-1);
 ImgBuf^[3]:=0;
 ImgBuf^[4]:=0;

 ImgOff:=4;

 if (y+myHeight-1) > y2 then
 begin
   myHeight:=y2-y+1;
 end;

 If NColors = 16 then
 begin
   if (GetMaxColor <> 15) then DisFlag:=1;
   if (x+myWidth-1) > x2 then
   begin
     DisFlag:=1;
     myWidth:=x2-x+1;
   end;

   For Ln:=1 to myHeight do
   begin
     ReadPCXLine(PcxFile,Uline,BytesPerLine);
     Error:=IORESULT;
     If Error <> 0 then
     begin
       DisPcxImg:=Error;
       Close(PcxFile);
       FreeMem(ImgBuf,memAmount);
       FreeMem(BlockData,SizeOf(BlockArray));
       Exit;
     end;
     For I:=0 to BitPlane2-1 do
     begin
       Temp:=Uline[I];
       Uline[I]:=Uline[I+BitPlane4];
       Uline[I+BitPlane4]:=Temp;
       Temp:=Uline[I+BitPlane2];
       Uline[I+BitPlane2]:=Uline[I+BitPlane3];
       Uline[I+BitPlane3]:=Temp;
     end;
     if DisFlag = 1 then
     begin
        mpToSp(Uline,Splane,BitPlane2,BitPlane3,BitPlane4);
        DisLine(x,y+ln-1,Splane,myWidth);
     end
     else
     begin
        Move(Uline,ImgBuf^[ImgOff+1],BytesPerLine);
        PutImage(x,y+Ln-1,ImgBuf^,NormalPut);
     end
   end;
 end
 else  (* must be 256 *)
 begin
   if (GetMaxColor <> 255) then DisFlag:=1;
   if (x+myWidth-1) > x2 then
   begin
     myWidth:=x2-x+1;
     ImgBuf^[1]:=Lo(myWidth-1);
     ImgBuf^[2]:=Hi(myWidth-1);
   end;

   For Ln:=1 to myHeight do
   begin
     ReadPCXLine(PcxFile,Uline,BytesPerLine);
     Error:=IORESULT;
     If Error <> 0 then
     begin
       DisPcxImg:=Error;
       Close(PcxFile);
       FreeMem(ImgBuf,memAmount);
       FreeMem(BlockData,SizeOf(BlockArray));
       Exit;
     end;
     if DisFlag = 1 then
     begin
        DisLine(x,y+ln-1,ULine,myWidth);
     end
     else
     begin
       Move(Uline,ImgBuf^[ImgOff+1],BytesPerLine);
       PutImage(x,y+Ln-1,ImgBuf^,NormalPut);
     end;
   end;
 end;
 FreeMem(BlockData,SizeOf(BlockArray));
 FreeMem(ImgBuf,memAmount);
 Close(PcxFile);
 Error:=IORESULT;
{$I+}

 If Error <> 0 Then
 begin
   DisPcxImg:=Error;
   Exit;
 end;

 if IPal then
 begin
   GetPcxInfo(Filename,Header,PcxPal);
   if GetNPcxColors(Header) > (GetMaxColor+1) then
   begin
     For i:=0 to GetMaxColor do
     begin
       PcxPal[i,0]:=PcxPal[i,0] SHR 2;
       PcxPal[i,1]:=PcxPal[i,1] SHR 2;
       PcxPal[i,2]:=PcxPal[i,2] SHR 2;
     end;
     SetPaletteList(PcxPal,GetMaxColor+1);
   end
   else
   begin
     For i:=0 to GetNPcxColors(Header) do
     begin
       PcxPal[i,0]:=PcxPal[i,0] SHR 2;
       PcxPal[i,1]:=PcxPal[i,1] SHR 2;
       PcxPal[i,2]:=PcxPal[i,2] SHR 2;
     end;
     SetPaletteList(PcxPal,GetMaxColor+1);
   end;
 end;
end;

Function ReadPcxImg(Var Img : PImageRec;filename : string): word;
Type
 ImgRec = Array[1..$FFFF] of Byte;
var
 PcxFile        : File;
 Header         : PcxHeaderRec;
 Uline          : UncpLine;
 SPlane         : UncpLine;
 ImgBuf         : ^ImgRec;
 ImgOff         : Word;
 BitPlane2      : Word;
 BitPlane3      : Word;
 BitPlane4      : Word;
 BytesPerLine   : Word;
 memAmount      : LongInt;
 i,j,Ln         : Word;
 myWidth        : Word;
 myHeight       : Word;
 Error          : Word;
 Temp           : Byte;
Begin
 ReadPcxImg:=0;
{$I-}
 Assign(PcxFile, Filename);
 Reset(PcxFile, 1);
 Error:=IORESULT;

 If Error <> 0 Then
 begin
   ReadPcxImg:=Error;
   Exit;
 end;

 BlockRead(PcxFile, Header, 128);

 Index:=0;
 NextByte:=MaxBlock;

 myHeight:=(Header.Ymax-Header.Ymin+1);

 Img.Colors:=GetNPcxColors(Header);
 If (Img.Colors<>16) AND (Img.Colors<>256) then
 begin
   ReadPcxImg:=3;
   Close(PcxFile);
   Exit;
 end
 Else if (Header.Manufacturer<>10) then
 begin
   ReadPcxImg:=2;
   Close(PcxFile);
   Exit;
 end;

 If Img.Colors=16 then
 begin
   BytesPerLine:=(Header.Bytes_per_line_per_plane SHL 2);
   memAmount:=BytesPerLine * myHeight + 6;
   myWidth:=BytesPerLine SHL 1;

   BitPlane2:=(BytesPerLine SHR 2);
   BitPlane3:=(BytesPerLine SHR 1);
   BitPlane4:=(BytesPerLine SHR 2) * 3;
 end
 else
 begin
   BytesPerLine:=Header.Bytes_per_line_per_plane;
   memAmount:=BytesPerLine * myHeight + 6;
   myWidth:=BytesPerLine;
 end;

 Img.memAmount:=memAmount;
 If Img.memAmount > $FFFF then
 begin
   ReadPcxImg:=4;
   Close(PcxFile);
   Exit;
 end;

 GetMem(ImgBuf,memAmount);
 GetMem(BlockData,SizeOf(BlockArray));

 ImgBuf^[1]:=Lo(myWidth-1);
 ImgBuf^[2]:=Hi(myWidth-1);
 ImgBuf^[3]:=Lo(myHeight-1);
 ImgBuf^[4]:=Hi(myHeight-1);

 ImgOff:=4;

 If Img.Colors = 16 then
 begin
   For Ln:=1 to myHeight do
   begin
     ReadPCXLine(PcxFile,Uline,BytesPerLine);
     Error:=IORESULT;
     If Error <> 0 then
     begin
       ReadPcxImg:=1;
       Close(PcxFile);
       FreeMem(ImgBuf,memAmount);
       FreeMem(BlockData,SizeOf(BlockArray));
       Exit;
     end;
     For I:=0 to BitPlane2-1 do
     begin
       Temp:=Uline[I];
       Uline[I]:=Uline[I+BitPlane4];
       Uline[I+BitPlane4]:=Temp;
       Temp:=Uline[I+BitPlane2];
       Uline[I+BitPlane2]:=Uline[I+BitPlane3];
       Uline[I+BitPlane3]:=Temp;
     end;

     Move(Uline,ImgBuf^[ImgOff+1],BytesPerLine);
     Inc(ImgOff,BytesPerLine);
   end;
 end
 else  (* must be 256 *)
 begin
   For Ln:=1 to myHeight do
   begin
     ReadPCXLine(PcxFile,Uline,BytesPerLine);
     Error:=IORESULT;
     If Error <> 0 then
     begin
       ReadPcxImg:=1;
       Close(PcxFile);
       FreeMem(ImgBuf,memAmount);
       FreeMem(BlockData,SizeOf(BlockArray));
       Exit;
     end;
     Move(Uline,ImgBuf^[ImgOff+1],BytesPerLine);
     Inc(ImgOff,BytesPerLine);
   end;
 end;
 Close(PcxFile);
 FreeMem(BlockData,SizeOf(BlockArray));
 Img.Img:=ImgBuf;
{$I+}
end;


Function SavePcxImg(x,y,x2,y2 : Word;Filename : String): Word;
Type
 ImgRec = Array[1..$FFFF] of Byte;
var
 PcxPal         : PaletteT;
 PcxFile        : File;
 Header         : PcxHeaderRec;
 ULine          : UncpLine;
 CLine          : CompressedLine;
 Cbytes         : Word;
 ImgBuf         : ^ImgRec;
 ImgOff         : Word;
 BitPlane2      : Word;
 BitPlane3      : Word;
 BitPlane4      : Word;
 BytesPerLine   : Word;
 memAmount      : LongInt;
 i,j,Ln         : Word;
 myWidth        : Word;
 myHeight       : Word;
 Error          : Word;
 NColors        : Word;
 Temp           : Byte;
Begin
 SavePcxImg:=0;
 NColors:=GetMaxColor+1;
 If (Ncolors<>16) AND (Ncolors<>256) Then
 begin
   SavePcxImg:=3;
   Exit;
 end;

 myWidth:=x2-x+1;
 myHeight:=y2-y+1;
 BytesPerLine:=xgraph.imagesize(1,1,myWidth,1)-6;
 memAmount:=xgraph.imagesize(1,1,myWidth,1);

 FillChar(Header,SizeOf(Header),0);
 Header.Manufacturer:=10;
 Header.Version:=5;
 Header.Encoding:=1;
 Header.PaletteInfo:=1;
 Header.Xmax:=myWidth-1;
 Header.Ymax:=myHeight-1;

 If NColors=16 Then
 begin
   Header.Bits_per_pixel:=1;
   Header.Nplanes:=4;
   Header.Bytes_per_line_per_plane:=BytesPerLine SHR 2;
 end
 else
 begin
   Header.Bits_per_pixel:=8;
   Header.Nplanes:=1;
   Header.Bytes_per_line_per_plane:=BytesPerLine;
 end;

 GrabPaletteList(PcxPal,GetMaxColor+1);
 For i:=0 to GetMaxColor do
 begin
   PcxPal[i,0]:=PcxPal[i,0] SHL 2;
   PcxPal[i,1]:=PcxPal[i,1] SHL 2;
   PcxPal[i,2]:=PcxPal[i,2] SHL 2;
 end;

 Move(PcxPal,header.colormap,16*3);


{$I-}
 Assign(PcxFile, Filename);
 Rewrite(PcxFile, 1);
 BlockWrite(PcxFile, Header, 128);
 Error:=IORESULT;

 If Error <> 0 Then
 begin
   SavePcxImg:=Error;
   Exit;
 end;

 If NColors=16 then
 begin
   BitPlane2:=(BytesPerLine SHR 2);
   BitPlane3:=(BytesPerLine SHR 1);
   BitPlane4:=(BytesPerLine SHR 2) * 3;
 end;

 GetMem(ImgBuf,memAmount);
 ImgOff:=4;

 If NColors=16 then
 begin
   For Ln:=y to y2 do
   begin
     GetImage(x,Ln,x2,Ln,ImgBuf^);
     Move(ImgBuf^[ImgOff+1],ULine[0],BytesPerLine);
     Error:=IORESULT;
     If Error <> 0 then
     begin
       SavePcxImg:=Error;
       Close(PcxFile);
       FreeMem(ImgBuf,memAmount);
       FreeMem(BlockData,SizeOf(BlockArray));
       Exit;
     end;
     For I:=0 to BitPlane2-1 do
     begin
       Temp:=Uline[I];
       Uline[I]:=Uline[I+BitPlane4];
       Uline[I+BitPlane4]:=Temp;
       Temp:=Uline[I+BitPlane2];
       Uline[I+BitPlane2]:=Uline[I+BitPlane3];
       Uline[I+BitPlane3]:=Temp;
     end;
     Cbytes:=CompressLine(Uline,Cline,BytesPerLine);
     BlockWrite(PcxFile,Cline,Cbytes);
   end;
 end
 else  (* must be 256 *)
 begin
   For Ln:=y to y2 do
   begin
     GetImage(x,Ln,x2,Ln,ImgBuf^);
     Move(ImgBuf^[ImgOff+1],ULine[0],BytesPerLine);
     Error:=IORESULT;
     If Error<>0 then
     begin
       SavePcxImg:=Error;
       Close(PcxFile);
       FreeMem(ImgBuf,memAmount);
       FreeMem(BlockData,SizeOf(BlockArray));
       Exit;
     end;
     Cbytes:=CompressLine(Uline,Cline,BytesPerLine);
     BlockWrite(PcxFile,Cline,Cbytes);
   end;
   Temp:=$C;
   BlockWrite(PcxFile,Temp,1);
   BlockWrite(PcxFile,PcxPal,Sizeof(PcxPal));
 end;
 Close(PcxFile);
 FreeMem(ImgBuf,memAmount);
{$I+}
end;


begin
end.
