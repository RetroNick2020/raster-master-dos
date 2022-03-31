Program Parse;
   uses graph;
Const
 list : array[1..5] of string = ('sm 320x200x16',
                                  'rpcx 1 1 319 199 ',
                                  '  rpcx 1 1 319 199  NoPal',
                                  ' wpcx  1 1 200  100',
                                  'wxgf 1  1 20 20   qb');


Procedure StripE(VAR ISTR : STRING);
begin
 While (Length(ISTR) > 1) AND (ISTR[Length(ISTR)]=#32) do
 begin
   Delete(ISTR,Length(ISTR),1);
 end;
end;

Procedure StripS(VAR ISTR : STRING);
begin
 While (Length(ISTR) > 1) AND (ISTR[1]=#32) do
 begin
   Delete(ISTR,1,1);
 end;
end;

Procedure StrToUp(Var ISTR : String);
Var
 i : Word;
begin
 For i:=1 to length(ISTR) do
 begin
   ISTR[i]:=UpCase(ISTR[i]);
 end;
end;

Procedure GetNextWord(Var IStr, OStr : String);
var
 T : Word;

begin
 StripS(ISTR);
 T:=POS(#32,ISTR);
 if T > 0 then
 begin
   OStr:=Copy(ISTR,1,T-1);
   StrToUp(OSTR);
   Delete(ISTR,1,T);
 end
 else if ISTR<>'' then
 begin
   OStr:=ISTR;
   ISTR:='';
 end
 else
 begin
   OStr:='';
 end;
 StrToUp(OSTR);
end;

Procedure ProcessLine(ListText: String);
Var
 x,y,x2,y2 : Word;
 Error     : Word;
 PAL       : Boolean;
 CText     : String;
 C         : integer;

Function GetCords : Boolean;
begin
   GetCords:=FALSE;
   GetNextWord(listText,CText);
   VAL(CText,x,c);
   if c<>0 then exit;
   GetNextWord(listText,CText);
   VAL(CText,y,c);
   if c<>0 then exit;
   GetNextWord(listText,CText);
   VAL(CText,x2,c);
   if c<>0 then exit;
   GetNextWord(listText,CText);
   VAL(CText,y2,c);
   if c<>0 then exit;
   GetNextWord(listText,CText);
   PAL:=TRUE;
   If CText='NOPAL' then
   begin
     PAL:=FALSE;
   end;
   GetCords:=TRUE;
end;

begin
 GetNextWord(listText,CText);
 If CText = 'SM' then
 begin
   GetNextWord(listText,CText);
   If Ctext='320X200X16' then
   begin
   end
   else if Ctext='640X200X16' then
   begin
   end
   else if Ctext='640X200X16' then
   begin
   end
   else if Ctext='640X350X16' then
   begin
   end
   else if Ctext='640X480X16' then
   begin
   end;
 end
 else if CText = 'RPCX' then
 begin
   if GetCords then
   begin

   end;
 end;
end;

Procedure RLIST(ListFile : String);
Var
 F : Text;
 ListText : String;
begin
 Assign(F,ListFile);
 Reset(F);
 While Not Eof(F) do
 begin
   ReadLn(F,ListText);
   ProcessLine(ListText);
 end;
 Close(F);
end;

begin
end.