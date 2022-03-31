(*
*************************************************
*                                               *
* Name:     PCX2RAW.PAS                         *
*                                               *
* Purpose:  A unit for reading PCX files and    *
*           and creating RAW files.             *
*                                               *
*************************************************
*)

{$I-}
Unit PCX2RAW;

Interface
Type

   PcxPalette = array[0..255,0..2] of byte;

   PCXHeaderRec = record
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

        HscreenSize: integer;   (* added for PC Paintbrush IV Plus ver 1.0,  *)
        VscreenSize: integer;   (* PC Paintbrush IV ver 1.02 (and later)     *)
                                (* I know it is tempting to use these fields
                                   to determine what video mode should be used
                                   to display the image - but it is NOT
                                   recommended since the fields will probably
                                   just contain garbage. It is better to have
                                   the user install for the graphics mode he
                                   wants to use... *)

        Filler: array [74..127] of byte;
    end;

Function  ValidPcxFile(Filename : string) : Boolean;
Function  GetPcxWidth(Var PcxH : PcxHeaderRec) : Word;
Function  GetPcxHeight(Var PcxH : PcxHeaderRec) : Word;
Function  PcxToRaw(PcxFilename,RawFilename : string) : word;

Procedure GetPcxInfo(Filename : string; Var PcxH : PcxHeaderRec;Var Pal : PcxPalette);
Function  GetNPcxColors(Var PcxH : PcxHeaderRec) : Word;

Implementation
uses
  Dos;
const
   MAX_WIDTH = 4000;    (* arbitrary - maximum width (in bytes) of a PCX image *)
   COMPRESS_NUM = $C0;  (* this is the upper two bits that indicate a count *)
   MaxBlock = 4096;


type
   block_array = array [0..MaxBlock] of byte;
   UncpLine    = array [0..MAX_WIDTH] of byte;
   CompressedLine = array[0..Max_Width*2] of Byte;

var
   BlockData: block_array;             (* 4k data buffer                     *)
   NextByte : integer;                 (* index into file buffer in ReadByte *)
   Index    : integer;                 (* PCXline index - where to put Data  *)
   Data     : byte;                    (* PCX compressed data byte           *)



Function BytesPerRow(width : word) : Word;
begin
 BytesPerRow :=(width+7) div 8;
end;


Procedure SetBit(Position, Value : byte; Var Changebyte:byte);
var
  bt : byte;
begin
  bt :=$01;
  bt :=bt shl position;
  if value = 1 then
     changebyte :=changebyte or bt
  else
     begin
       bt :=bt xor $FF;
       changebyte :=changebyte and bt;
  end;
end;


Function BitOn(Position,Testbyte : byte) : boolean;
var
 bt : byte;
begin
  bt :=$01;
  bt :=bt shl position;
  biton :=(bt and testbyte) > 0;
end;


Procedure Unpack4Colors(Pcolor:byte;Var c1,c2,c3,c4 : byte);
begin
 c1:=Pcolor shr 6;
 c2:=Pcolor shl 2;
 c2:=c2 shr 6;
 c3:=Pcolor  shl 4;
 c3:=c3 shr 6;
 c4:=Pcolor  shl 6;
 c4:=c4 shr 6;
end;


Procedure UnPackMonoColors(PColors:byte;Var c1,c2,c3,c4,c5,c6,c7,c8 : byte);
begin
 c1:=Pcolors shr 7;
 c2:=Pcolors shl 1;
 c2:=c2 shr 7;
 c3:=Pcolors shl 2;
 c3:=c3 shr 7;
 c4:=Pcolors shl 3;
 c4:=c4 shr 7;
 c5:=Pcolors shl 4;
 c5:=c5 shr 7;
 c6:=Pcolors shl 5;
 c6:=c6 shr 7;
 c7:=Pcolors shl 6;
 c7:=c7 shr 7;
 c8:=Pcolors shl 7;
 c8:=c8 shr 7;
end;


Procedure GetPcxInfo(Filename : string; Var PcxH : PcxHeaderRec;Var Pal : PcxPalette);
Var
 F     :  File;
 Error : Word;
Begin
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
end;


Function ValidPcxFile(Filename : string) : Boolean;
Var
  MyPcxHeader : PcxHeaderRec;
  F           : File;
Begin
 Assign(F,Filename);
 Reset(F,1);
 BlockRead(F,MyPcxHeader,sizeof(MyPcxHeader));
 Close(F);
 ValidPcxFile:=false;
 If MyPcxHeader.Manufacturer = 10 then
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


Procedure WriteRAWLine256(Var RF:File;Var Uline : UncpLine;Width:word);
Begin
 BlockWrite(RF,Uline,Width);
end;


Procedure WriteRAWLine16(Var RF : file;Var Uline : UncpLine;Width,BPL : Word);
Var
 X     : Word;
 Xp    : Word;
 I     : Word;
 J     : Word;
 COL   : Word;
 OFPL2 : Word;
 OFPL3 : Word;
 OFPL4 : Word;
 RawLine : Array[0..1023] of byte;
Begin
  Fillchar(RawLine,sizeof(RawLine),0);
  OFPL2:=(BPL div 4) ;
  OFPL3:=(BPL div 4) * 2;
  OFPL4:=(BPL div 4) * 3;
  Xp:=0;
  for I:=0 to OFPL2-1 do
  begin
        for J:=7 downto 0  do
        begin
          COL:=0;
          case  biton(j,Uline[i])       of true:  inc(COL,1) end;
          case  biton(j,Uline[i+OFPL2]) of true:  inc(COL,2) end;
          case  biton(j,Uline[i+OFPL3]) of true:  inc(COL,4) end;
          case  biton(j,Uline[i+OFPL4]) of true:  inc(COL,8) end;
          RawLine[Xp+(7-j)]:=COL;
        end;
        Inc(Xp,8);
   end;
   BlockWrite(RF,RawLine,Width);
end;

Procedure WriteRawLine4(Var RF:File;Var Uline : UncpLine;Width,BPL : Word);
Var
 Col : Array[0..3] of byte;
 Xp  : Word;
  I  : Word;
  J  : Word;
RawLine : Array[0..1023] of byte;
Begin
  Fillchar(RawLine,sizeof(RawLine),0);
  xp:=0;
  for i:=0 to BPL-1 do
  begin
     FillChar(Col,Sizeof(Col),0);
     Unpack4Colors(Uline[i],Col[0],Col[1],Col[2],Col[3]);
     For j:=0 to 3 do
     begin
      RawLine[xp+j]:=Col[j];
     end;
     inc(Xp,4);
  end;
  BlockWrite(RF,RawLine,Width);
end;


Procedure WriteRawLine2(Var RF:file;Var Uline : UncpLine;Width,BPL : Word);
Var
 Xp  : Word;
  I  : Word;
  J  : Word;
Col  : array[0..7] of byte;
RawLine : Array[0..1023] of byte;
begin
  Fillchar(RawLine,sizeof(RawLine),0);
  xp:=0;
  for i:=0 to BPL-1 do
  begin
     UnPackMonoColors(Uline[i],col[0],col[1],col[2],col[3],col[4],col[5],col[6],col[7]);
     For j:=0 to 7 do
     begin
        RawLine[xp+j]:=Col[j];
     end;
    inc(xp,8);
  end;
  BlockWrite(RF,RawLine,Width);
end;

Procedure ReadHeader(Var F : File;Var Header : PcxHeaderRec);
begin
 BlockRead (F, Header, 128);
 Index := 0;
 NextByte := MaxBlock;
end;


Procedure ReadByte(Var F : File);
var
   NumBlocksRead: integer;
begin
 if NextByte = MaxBlock then
 begin
   BlockRead (F, BlockData, MaxBlock, NumBlocksRead);
   NextByte := 0;
 end;
 Data := BlockData[NextByte];
 Inc(NextByte);
End;


Procedure ReadPCXLine(Var F : File;Var Uline : Uncpline;BPL : Word);
var
  Count : Word;
begin
If Index <> 0 then
   FillChar(Uline [0], Index, data);
While (Index < BPL) do
   begin
   ReadByte(F);

   if (data and $C0) = compress_num then
      begin
      count := data and $3F;
      ReadByte(F);
      FillChar (Uline [Index], count, data);
      inc (Index, count);
      end
   else
      begin
       Uline[Index] := data;
       Inc(Index);
      end;
   end;
Index:=Index - BPL;
end;


Function PcxToRaw(PcxFilename,RawFilename : string): word;
var
   Ln     : Word;
   ypos   : word;
   error  : word;
   BPL    : word;
   XWidth : word;
   XHeight: word;
   mypal  : PcxPalette;
   i,j    : word;
   Header : PcxHeaderRec;
   Uline  : UncpLine;
   PcxFile: File;
   RawFile: File;
   NumCol : Word;

Begin
  GetPcxInfo(PcxFileName,Header,mypal);

  Assign(PcxFile, PcxFilename);
  Reset(PcxFile, 1);

  Assign(RawFile, RawFilename);
  ReWrite(RawFile,1);
  ReadHeader(PcxFile,Header);


  XHeight:=GetPcxHeight(Header);
  XWidth:=GetPcxWidth(Header);
  NumCol:=GetNPcxColors(Header);


  BlockWrite(RawFile,XWidth,2);
  BlockWrite(RawFile,XHeight,2);
  BlockWrite(RawFile,NumCol,2);
  BlockWrite(RawFile,myPal,NumCol*3);

  Case NumCol of 2,4,256:BPL:=Header.Bytes_per_line_per_plane;
                       8:BPL:=Header.Bytes_per_line_per_plane*3;
                      16:BPL:=Header.Bytes_per_line_per_plane*4;
  end;
  Write('            PCX To RAW. Processing Line:     ');

  For Ln :=1 to Xheight do
  begin
     Write(#8,#8,#8,#8);
     Write(Ln:4);
     ReadPCXLine(PcxFile,Uline,BPL);
     Case NumCol of 256: WriteRawLine256(RawFile,Uline,XWidth);
                     16: WriteRawline16(RawFile,ULine,XWidth,BPL);
                      8: WriteRawline16(RawFile,ULine,XWidth,BPL);
                      4: WriteRawline4(RawFile,ULine,XWidth,BPL);
                      2: WriteRawline2(RawFile,ULine,XWidth,BPL);
     end;

     Error:=IOResult;
     if Error <> 0 then
     begin
       PcxToRaw:=Error;
       Close(PcxFile);
       Exit;
     end;
  end;
  WriteLn;

  Close(PcxFile);
  Close(RawFile);

  PcxToRaw:=IOResult;
end;


begin
end.