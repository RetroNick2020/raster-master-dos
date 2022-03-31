Unit RAW2DEF;
 Interface
   uses Dos;
Function RawToDef(rawFile,defFile : string) : Word;
 Implementation

Procedure Byte2str(mybyte : byte;Var mystring :string);
const
 hexa : array[0..15] of char=('0','1','2','3','4','5','6','7','8','9',
 'A','B','C','D','E','F');
var
 h1,h2 : byte;
begin
 h2:=mybyte shl 4;
 h2:=h2 shr 4;
 mystring:=hexa[h2];
end;

Function RawToDef(rawFile,defFile : string) : Word;
Var
 F : Text;
 F2: File;
 Width : Word;
 Height: Word;
 Col : Word;
 I,J : WOrd;
 myCol : byte;
 mySCol: String;
 myBuf : Array[1..1024] of char;
 myPal : array[1..768] of byte;
begin
 Assign(F,defFile);
 Rewrite(F);
 SetTextBuf(F,myBuf);

 Assign(F2,rawFile);
 Reset(F2,1);

 Blockread(F2,Width,2);
 Blockread(F2,Height,2);
 Blockread(F2,Col,2);
 Blockread(F2,myPal,Col*3);

 Write('Converting RAW To DEF. Processing Line:     ');

 For J:=1 to Height Do
 begin
   Write(#8,#8,#8,#8);
   Write(J:4);
   For I:=1 to Width Do
   begin
     BlockRead(F2,myCol,1);
     Byte2Str(myCol,mySCol);
     Write(F,mySCol);
   end;
   WriteLN(F);
 End;

 Close(F);
 Close(F2);

 RawToDef:=IOResult;
End;

begin
end.
