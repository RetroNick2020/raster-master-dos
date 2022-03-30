Unit RWico;
 Interface
Function ReadIco(x,y,x2,y2 : word;filename : String) : Word;
Function WriteIco(x,y,x2,y2 : word;Filename : String) : Word;

 Implementation
  uses Vars,dos;

type
   IcoBuf   = Array[1..32,1..32] of byte;

 const
  IcoColors : array[0..15] of word= (0,4,2,6,1,5,3,8,7,12,10,14,9,13,11,15);
  Unknown   : array[1..104] of byte=(
               40,  0,  0,  0, 32,  0,  0,  0, 64,  0,  0,  0,  1,  0,
                4,  0,  0,  0,  0,  0,128,  2,  0,  0,  0,  0,  0,  0,
                0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
                0,  0,  0,  0,128,  0,  0,128,  0,  0,  0,128,128,  0,
              128,  0,  0,  0,128,  0,128,  0,128,128,  0,  0,128,128,
              128,  0,192,192,192,  0,  0,  0,255,  0,  0,255,  0,  0,
                0,255,255,  0,255,  0,  0,  0,255,  0,255,  0,255,255,
                0,  0,255,255,255,  0);

 Type
   tagICOHDR = Record
                icoReserved : Word;
                icoResourceType : word;
                icoResourceCount : word;
               end;

   tagICODSC = Record
                Width : byte;
                Height: byte;
                ColorCount : byte;
                Reserved1 : byte;
                reserved2 : word;
                Reserved3 : word;
                icoDIBSize: Longint;
                icoDIBOffset: Longint;
               end;

var
   Ihead     : tagICOHDR;
   Idesc     : tagICODSC;
   IcoImgBuf : array [1..512] of byte;
   MSIcon : IcoBuf;
   f         : file;

Function ValidIco(fname : pathstr) : boolean;
var
 mf : file;
 mhead : tagicohdr;
 mdesc : tagicodsc;
 Error : Word;
begin
{$I-}
  ValidIco:=true;
  Assign(mf,fname);
  Reset(mf,1);
  if filesize(mf)<>766 then
  begin
    ValidIco:=False;
    close(mf);
    exit;
  end;
  BlockRead(mf,mhead,sizeof(mhead));
  BlockRead(mf,mdesc,sizeof(mdesc));

  if (mdesc.Width <> 32) or (mdesc.Height <> 32) or (mdesc.ColorCount <>16) then
  begin
    ValidIco:=false;
  end;
  Close(mf);
  Error:=IORESULT;
{$I+}
end;

Procedure ReadHead;
begin
{$I-}
 Blockread(f,ihead,sizeof(ihead));
{$I+}
end;


Procedure ReadDesc;
begin
{$I-}
 Blockread(f,idesc,sizeof(idesc));
{$I+}
end;

Procedure ReadImage;
begin
{$I-}
  seek(f,(filesize(f)-640));
  BlockRead(f,IcoImgBuf,SizeOf(IcoImgBuf));
{$I+}
end;

Procedure WriteHead;
begin
 Ihead.icoReserved :=0;
 Ihead.icoResourceType:=1;
 Ihead.icoResourceCount:=1;
 BlockWrite(f,ihead,sizeof(ihead));
end;

Procedure WriteDesc;
begin
 Idesc.Width:=32;
 Idesc.Height:=32;
 Idesc.ColorCount:=16;
 Idesc.Reserved1:=0;
 Idesc.Reserved2:=0;
 Idesc.Reserved3:=0;
 Idesc.icoDIBSize:=744;
 Idesc.icoDIBOffset:=22;
 BlockWrite(f,idesc,sizeof(idesc));
end;

Procedure WriteUnknown;
begin
{$I-}
 BlockWrite(f,unknown,Sizeof(unknown));
{$I+}
end;

Procedure WriteImage;
begin
{$I-}
  BlockWrite(f,IcoImgBuf,SizeOf(icoImgBuf));
{$I+}
end;

Procedure WriteTail;
Var
 empty : array[1..128] of byte;
begin
 FillChar(empty,sizeof(empty),0);
{$I-}
 BlockWrite(f,empty,sizeof(empty));
{$I+}
end;



Procedure UnpackColor(color:byte;Var c1,c2 : byte);
begin
 c1:=color shr 4;
 c2:=color shl 4;
 c2:=c2    shr 4;
end;

Procedure PackToArray;
Var
w : word;
h : word;
i : word;
PColors : byte;
Color1  : byte;
Color2  : byte;

begin

 w:=1;
 h:=32;

 for i:=1 to 512 do
 begin
   Pcolors:=IcoImgBuf[i];
   if w>31 then
   begin
    w:=1;
    dec(h);
   end;

   UnpackColor(Pcolors,Color1,Color2);
   MSIcon[w,h]   :=IcoColors[Color1];
   MSIcon[w+1,h] :=IcoColors[Color2];
   inc(w,2);
 end;

end;

Function PackColors(c1,c2 : byte) : Byte;
begin
 PackColors:=c1 shl 4 + c2;
end;

Procedure ArrayToPack;
Var
w : word;
h : word;
i : word;
Color1  : byte;
Color2  : byte;

begin

 w:=1;
 h:=32;

 for i:=1 to 512 do
 begin
   if w>31 then
   begin
    w:=1;
    dec(h);
   end;

   Color1:=IcoColors[MSIcon[w,h]];
   Color2:=IcoColors[MSIcon[w+1,h]];
   IcoImgBuf[i] :=PackColors(Color1,Color2);
   inc(w,2);
 end;

end;


Function ReadIco(x,y,x2,y2 : word;filename : string) : Word;
var
 Error : Word;
 i,j : word;
 width,height : word;
begin
{$I-}
  if ValidIco(filename) = false then
  begin
    readIco:=1000;
    exit;
  end;
  width:=x2-x+1;
  height:=y2-y+1;
  if width > 32 then width:=32;
  if height > 32 then height:=32;
  FillChar(msicon,sizeof(msicon),0);
  FillChar(Idesc,sizeof(idesc),0);
  Assign(f,filename);
  Reset(f,1);
  Error:=IOResult;
  if Error <>0 then
  begin
     ReadIco:=Error;
     exit;
  end;

   ReadHead;
   ReadDesc;
   ReadImage;
  Close(f);
  Error:=IOResult;
  if Error <>0 then
  begin
     ReadIco:=Error;
     exit;
  end;
  PackToArray;
  for i:=1 to width do
  begin
  for j:=1 to height do
  begin
    if (x+i-1 < 101) and (y+j-1 < 101) then
    begin
      IconImage[x+i-1,y+j-1]:=MSIcon[i,j];
    end;
  end;
  end;

  ReadIco := IOResult;
{$I+}
end;


Function WriteIco(x,y,x2,y2 : word;Filename : string) : Word;
var
 i,j : word;
 width,height : word;
begin
{$I-}
  width:=x2-x+1;
  height:=y2-y+1;
  if width > 32 then width:=32;
  if height > 32 then height:=32;
  FillChar(MSicon,sizeof(msicon),1);
  for i:=1 to width do
  begin
  for j:=1 to height do
  begin
    if (i+x-1 < 101) and (j+y-1 < 101) then
    begin
      MSIcon[i,j]:=IconImage[x+i-1,y+j-1];
    end;
  end;
  end;
  ArrayToPack;
  Assign(f,Filename);
  Rewrite(f,1);
  WriteHead;
  WriteDesc;
  WriteUnknown;
  WriteImage;
  WriteTail;
  Close(f);
  WriteIco :=IOResult;
{$I+}
end;

begin
end.