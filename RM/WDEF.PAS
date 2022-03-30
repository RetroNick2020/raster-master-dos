Unit WDEF;
 Interface
     uses dos,graph,vars,rmstrg;
Function WriteDef(x,y,x2,y2 : word;filename : String) : word;
 Implementation



Function WriteDef(x,y,x2,y2 : word;Filename : String) : word;
var
f     : text;
error : word;
i,j   : word;
HexStr : String;
HexP   : Word;
begin
If GetMaxColor= 15 then
begin
 HexP:=1;
end
else
begin
 HexP:=2;
end;

{$I-}
 Assign(f,filename);
 Rewrite(f);
 error:=IOResult;
 if error <>0 then
 begin
   WriteDef:=Error;
   exit;
 end;
 for j:=y to y2 do
 begin
   for i:=x to x2 do
   begin
     HexStr:=StrHex(IconImage[i,j],HexP);
     Write(f,HexStr);
     Error:=IORESULT;
     If Error <> 0 THen
     begin
       WriteDef:=Error;
       Exit;
     end;
   end;
   Writeln(f);
 end;
 close(f);
 Error:=IORESULT;
 WriteDef:=Error;
{$I+}
end;

begin
end.