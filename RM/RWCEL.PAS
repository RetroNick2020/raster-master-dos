Unit RWCEL;
Interface
Function WriteCEL(x,y,x2,y2 : Word;FileName : String) : Word;
Function ReadCEL(x,y,x2,y2,pal : Word;FileName : String) : Word;
Implementation
  uses vars,graph,bgipal,core;

Type
 CELRec = Record
            mgNum   : Word;
            Width   : Word;
            Height  : Word;
            x       : Word;
            y       : Word;
            Bits    : Byte;
            Comp    : Byte;
            ImgSize : LongInt;
            Filler  : Array[1..16] of Byte;
          End;

Function WriteCEL(x,y,x2,y2 : Word;FileName : String) : Word;
Var
 Error  : Word;
 i,j    : Word;
    F   : File;
 Width  : Word;
 Height : Word;
 Colors : Word;
 Tbuf   : Array[1..100] of Byte;
  myPal : PaletteT;
  myCEL : CELRec;
begin
 Width:=x2-x+1;
 Height:=y2-y+1;
 Colors:=GetMaxColor+1;

 FillChar(myCEL,SizeOf(myCEL),0);
 myCel.mgNum:=$9119;
 myCel.Width:=Width;
 myCel.Height:=Height;
 myCel.Bits:=8;
 myCel.ImgSize:=(Width*Height);

 GrabPaletteList(myPal,256);

{$I-}
 Assign(F,FileName);
 Rewrite(F,1);
 BlockWrite(F,myCEL,SizeOf(myCEL));

 BlockWrite(F,myPal,768);

 For j:=y to y2 do
 begin
   For i:=1 to Width do
   begin
     Tbuf[i]:=IconImage[x+i-1,j];
   end;
   BlockWrite(F,TBuf,Width);
   Error:=IORESULT;
   If Error<>0 then
   begin
     WriteCEL:=Error;
     Exit;
   end;
 end;

 Close(F);
 Error:=IORESULT;
 WriteCEL:=Error;
{$I+}
end;

Function ReadCEL(x,y,x2,y2,pal : Word;FileName : String) : Word;
Var
 Error: Word;
 i ,j : Word;
    F : File;
 Colors : Word;
 myWidth,myHeight : Word;
 Fcol : Byte;
 Tbuf : array[0..1023] of byte;
  myPal : PaletteT;
 size,fsize  : LongInt;
 myCel : CELRec;
begin
 myWidth:=x2-x+1;
 myHeight:=y2-y+1;
 Colors:=256;
{$I-}
 Assign(F,FileName);
 Reset(F,1);
 Error:=IORESULT;
 if Error <>0 then
 begin
   ReadCEL:=Error;
   Exit;
 end;

 fsize:=FileSize(F);

 BlockRead(F,myCEL,SizeOf(myCEL));
 BlockRead(F,myPal,768);
 Error:=IORESULT;

 Size:=myCEL.Width*myCEL.Height+32+768;

 if (size<>fsize) OR (myCEL.mgNum<>$9119) OR (Error<>0)then
 begin
  Close(f);
  ReadCEL:=1000;
  Error:=IORESULT;
  Exit;
 end;

 If myHeight > myCel.Height then myHeight:=myCel.Height;
 if myWidth >  myCel.Width then myWidth:=myCel.Width;
 For j:=1 to myHeight do
 begin
   BlockRead(F,TBuf,myCel.Width);
   Error:=IORESULT;
   If Error<>0 then
   begin
     ReadCEL:=Error;
     Exit;
   end;
   For i:=1 to myWidth do
   begin
       IconImage[x+i-1,y+j-1]:=Tbuf[i-1];
   end;
 end;
 Close(F);
 If (GetMaxColor=15) then
 begin
   ReduceTo16;
 end;
 if Colors > (GetMaxColor+1) then Colors:=GetMaxColor+1;
 If Pal=1 then
 begin
   If Colors > 0 Then SetPaletteList(myPal,Colors);
 end;
 Error:=IORESULT;
 ReadCEL:=Error;
{$I+}
end;

begin
end.