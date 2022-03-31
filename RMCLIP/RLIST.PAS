Unit RList;

Interface
   uses dos,vars,rkey,graph,screen,wxgf,rwpcx,rwbmp,wprf,rwraw,rwpal;

Procedure ReadLIST(ListFile : String);

Implementation


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

Procedure ExitWithReminder;
begin
 closegraph;
 Writeln('Saving in the 256 color modes requires registration!');
 Writeln('Try saving in 16 color modes.');
 writeln;
 halt;
end;

Procedure Run(ListText : String);
Var
 Filename : String;
 Error    : Word;
begin
 GetNextWord(ListText,Filename);
 SwapVectors;
 Exec(filename,ListText);
 SwapVectors;
 Error:=DosError;
 if  (Error<>0) then
 begin
   Closegraph;
   Writeln(Error);
   halt;
 end;
end;



Procedure ProcessLine(ListText: String);
Var
 x,y,x2,y2 : Word;
 Filename  : String;
 Error     : Word;
 PAL,MFail : Boolean;
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
 if Ctext = #39 then
 begin

 end
 else If CText = 'SM' then
 begin
   CloseGraph;
   GetNextWord(listText,CText);
   If Ctext='320X200X16' then
   begin
     MFail:=SetSVGA16(0);
   end
   else if Ctext='640X200X16' then
   begin
     MFail:=SetSVGA16(1);
   end
   else if Ctext='640X200X16' then
   begin
     MFail:=SetSVGA16(2);
   end
   else if Ctext='640X350X16' then
   begin
     MFail:=SetSVGA16(3);
   end
   else if Ctext='640X480X16' then
   begin
     MFail:=SetSVGA16(4);
   end
   else if Ctext='800X600X16' then
   begin
     MFail:=SetSVGA16(5);
   end
   else if Ctext='1024X768X16' then
   begin
     MFail:=SetSVGA16(6);
   end
   else if Ctext='320X200X256' then
   begin
     MFail:=SetVGA256(0);
   end
   else if Ctext='640X400X256' then
   begin
     MFail:=SetVGA256(1);
   end
   else if Ctext='640X480X256' then
   begin
     MFail:=SetVGA256(2);
   end
   else if Ctext='800X600X256' then
   begin
     MFail:=SetVGA256(3);
   end
   else if Ctext='1024X768X256' then
   begin
     MFail:=SetVGA256(4);
   end
   else
   begin
     writeln('invalid mode ',Ctext);
   end;
 end
 else if CText = 'RUN' then
 begin
    Run(ListText);
 end
 else if CText = 'RPCX' then
 begin
   GetNextWord(ListText,filename);
   if GetCords then
   begin
     if DisPcxImg(x,y,x2,y2,PAL,filename) <> 0 then
     begin
     end;
   end;
 end
 else if CText = 'WPCX' then
 begin
   GetNextWord(ListText,filename);
   if GetCords then
   begin
     if SavePcxImg(x,y,x2,y2,filename) <> 0 then
     begin
     end;
   end;
 end
 else if CText = 'RBMP' then
 begin
   GetNextWord(ListText,filename);
   if GetCords then
   begin
     if ReadBMP(x,y,x2,y2,PAL,Filename) <> 0 then
     begin
     end;
   end;
 end
 else if CText = 'WBMP' then
 begin
   GetNextWord(ListText,filename);
   if GetCords then
   begin
     if WriteBMP(x,y,x2,y2,Filename) <> 0 then
     begin
     end;
   end;
 end
 else if CText = 'RRAW' then
 begin
   GetNextWord(ListText,filename);
   if GetCords then
   begin
     if ReadRaw(x,y,x2,y2,PAL,Filename) <> 0 then
     begin
     end;
   end;
 end
 else if CText = 'WRAW' then
 begin
   GetNextWord(ListText,filename);
   if GetCords then
   begin
     if WriteRAW(x,y,x2,y2,Filename) <> 0 then
     begin
     end;
   end;
 end
 else if CText = 'RPAL' then
 begin
   GetNextWord(ListText,filename);
   if ReadPAL(Filename) <> 0 then
   begin
   end;
 end
 else if CText = 'WPAL' then
 begin
   GetNextWord(ListText,filename);
   if WritePAL(Filename) <> 0 then
   begin
   end;
 end
 else if CText = 'WSPR' then
 begin
   GetNextWord(ListText,filename);
   if GetCords then
   begin
     if WriteSPR(x,y,x2,y2,Filename)  <> 0 then
     begin
     end;
   end;
 end
 else if CText = 'WPPR' then
 begin
   GetNextWord(ListText,filename);
   if GetCords then
   begin
     if WritePPR(x,y,x2,y2,Filename) <> 0 then
     begin
     end;
   end;
 end
 else if (CText = 'WXGF') then
 begin
   GetNextWord(ListText,CText);
   if (CText = 'TP') or (Ctext='TC') then
   begin
     GetNextWord(ListText,filename);
     if GetCords then
     begin
       if WriteXGF(x,y,x2,y2,1,Filename)  <> 0 then
       begin
       end;
     end;
   end
   else if (CText = 'QC') or (Ctext='QB') then
   begin
     GetNextWord(ListText,filename);
     if GetCords then
     begin
       if WriteSPR(x,y,x2,y2,Filename)  <> 0 then
       begin
       end;
     end;
   end;
 end;

end;

Procedure ReadLIST(ListFile : String);
Var
 F : Text;
 ListText : String;
 Error : Word;
begin
 if POS('@',ListFile) = 1 then
 begin
   Delete(ListFile,1,1);
 end;
{$I-}
 Assign(F,ListFile);
 Reset(F);
 Error:=IORESULT;
 if Error <> 0 then
 begin
   WriteLn('Error: ',Error);
   halt;
 end;
 if SetSVGA16(0) then
 begin
 end;

 While (Not Eof(F)) AND (Error=0) do
 begin
   ReadLn(F,ListText);
   Error:=IORESULT;
   ProcessLine(ListText);
 end;
 Close(F);
{$I-}
 Closegraph;
end;

begin
end.
