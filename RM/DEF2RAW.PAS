{$M 1024,0,0}
Program DEF2RAW;
Var
 FT      : Text;
 FB      : File;
 DefFile : String;
 RawFile : String;
 Image   : Array[1..100] of String[100];
 Count   : Word;
 Width,Height : Word;
 T : Byte;
 i,j : Word;
 tempStr : String;
 Error : Word;
begin
 FillChar(Image,SizeOf(Image),'2');
 RawFile:='RM$$.RAW';
 DefFile:=ParamStr(1);
{$I-}
 writeln(deffile);
 Assign(FT,DEFFile);
 Reset(FT);
 Error:=IORESULT;
 If Error<>0 then
 begin
   HALT(Error);
 end;
 Count:=0;
 While Not EOF(FT) AND (Count <100) Do
 begin
  Inc(Count);
  Readln(FT,Image[Count]);
 end;
 Close(FT);
 Height:=Count;
 Width:=0;
 For i:=1 to Height do
 begin
  if Length(Image[i]) > Width then Width:=Length(image[i]);
 end;
 Count:=0;

 if Height > 100 then Height:=100;
 if Width > 100 then Width:=100;
 Assign(FB,RawFile);
 Rewrite(FB,1);
 BlockWrite(FB,Width,2);
 BlockWrite(FB,Height,2);
 BlockWrite(FB,Count,2);
 t:=0;
 For j:=1 to Height do
 begin
  TempStr:=Image[j];
  For i:=1 to Width do
  begin
   t:=ORD(UPCASE(TempStr[i]));
   Case t of     48: t:=0;
             49..57: Dec(t,48);
             65..70: Dec(t,55);
   end;
   TempStr[i]:=CHR(t);
  end;
  BlockWrite(FB,TempStr[1],Width);
 end;
 Close(FB);
 Error:=IORESULT;
{$I+}
end.