Unit RWRaw;
 Interface
 uses dos,graph,Bits,bgiPal;

Function ReadRaw(x,y,x2,y2 : Word; pal : Boolean;FileName : String) : Word;
Function WriteRaw(x,y,x2,y2 : Word;FileName : String) : Word;

Implementation

type
 linebuftype = array[0..2047] of byte;

Function WriteRaw(x,y,x2,y2 : Word;FileName : String) : Word;
Var
 Error,i ,j : Word;
    F : File;
 Width,Height,Colors : Word;
   Tbuf : LinebufType;
  myPal : PaletteT;
begin
 Width:=x2-x+1;
 Height:=y2-y+1;
 Colors:=GetMaxColor+1;

 GrabPaletteList(myPal,Colors);

{$I-}
 Assign(F,FileName);
 Rewrite(F,1);
 BlockWrite(F,Width,2);
 BlockWrite(F,Height,2);
 BlockWrite(F,Colors,2);

 BlockWrite(F,myPal,Colors*3);

 For j:=y to y2 do
 begin
   For i:=1 to Width do
   begin
     Tbuf[i-1]:=GetPixel(x+i-1,j);
   end;
   BlockWrite(F,TBuf,Width);
   Error:=IORESULT;
   If Error<>0 then
   begin
     WriteRaw:=Error;
     Exit;
   end;
 end;

 Close(F);
 Error:=IORESULT;
 WriteRaw:=Error;
{$I+}
end;

Function ReadRaw(x,y,x2,y2 : Word; pal : Boolean;FileName : String) : Word;
Var
 Error,i ,j : Word;
    F : File;
 Width,Height,Colors : Word;
 myWidth,myHeight : Word;
 Fcol : Byte;
 Tbuf : LineBufType;
  myPal : PaletteT;
 size,fsize  : LongInt;
begin
 myWidth:=x2-x+1;
 myHeight:=y2-y+1;
{$I-}
 Assign(F,FileName);
 Reset(F,1);
 Error:=IORESULT;
 if Error <>0 then
 begin
   ReadRaw:=Error;
   Exit;
 end;

 fsize:=FileSize(F);

 BlockRead(F,Width,2);
 BlockRead(F,Height,2);
 BlockRead(F,Colors,2);

 size:=LongInt(Width)*LongInt(Height)+LongInt(Colors*3)+6;
 if size<>fsize then
 begin
  Close(f);
  ReadRaw:=1000;
  Error:=IORESULT;
  Exit;
 end;
 If Colors > 0 Then
 begin
   BlockRead(F,myPal,Colors*3);
 end;
 If myHeight > Height then myHeight:=Height;
 if myWidth >  Width then myWidth:=Width;
 For j:=1 to myHeight do
 begin
   BlockRead(F,TBuf,Width);
   Error:=IORESULT;
   If Error<>0 then
   begin
     ReadRaw:=Error;
     Exit;
   end;
   For i:=1 to myWidth do
   begin
       PutPixel(x+i-1,y+j-1,Tbuf[i-1]);
   end;
 end;
 Close(F);

 if Colors > (GetMaxColor+1) then Colors:=GetMaxColor+1;
 If Pal then
 begin
   If Colors > 0 Then SetPaletteList(myPal,Colors);
 end;
 Error:=IORESULT;
 ReadRaw:=Error;
{$I+}
end;


begin
end.