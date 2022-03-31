Unit RWPal;
 Interface
 uses dos,graph,bgiPal;
Function ReadPAL(Filename : String) : Word;
Function WritePAL(Filename : String) : Word;
Implementation


Function WritePAL(FileName : String): Word;
Var
 F : File;
 myPal : PaletteT;
 Colors : Word;
 Error : Word;
begin
{$I-}
 Colors:=GetMaxColor+1;
 GrabPaletteList(myPal,Colors);
 Assign(F,FileName);
 Rewrite(F,1);
 BlockWrite(F,myPAL,Colors*3);
 Close(F);
 Error:=IORESULT;
 WritePAL:=Error;
{$I+}
end;

Function ReadPAL(Filename : String) : Word;
Var
 F      : File;
 Fsize  : LongInt;
 Colors : word;
 Error  : Word;
  myPal : PaletteT;
begin
 Colors:=GetMaxCOlor+1;
{$I-}
 Assign(F,FileName);
 Reset(F,1);
 Fsize:=FIleSize(F);
 If (Fsize<>48) AND (Fsize<>768) then
 begin
  ReadPAL:=1000;
  Exit;
 end;
 BlockRead(F,myPAL,Fsize);
 Close(F);
 Error:=IORESULT;
{$I+}
 ReadPAl:=Error;
 If Error = 0 then
 begin
  If Colors > (Fsize div 3) then
  begin
    Colors:=(Fsize div 3);
  end;
  SetPaletteList(myPal,Colors);
 end;
end;

begin
end.
