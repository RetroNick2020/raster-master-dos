Program bin2src;

const
  GitHub1     = 'Get source and latest version from github:';
  GitHub2     = 'https://github.com/RetroNick2020';

  maxBlock=5000;
  basicLan  =3;
  pascalLan =2;
  clan      =1;



type
   BlockArray = Array [0..MaxBlock]  of Byte;

var
   BlockData      : BlockArray;
   NextByte       : Integer;
   infile,outfile : String;
   lanStr,formStr : String;
   varname        : String;
   LineNumber     : Word;
   LineSteps      : Word;
   BasicLineMode  : Boolean;

Function ValidFormat : Boolean;
begin
  ValidFormat:=FALSE;
  if ((formStr='/B') or (formStr='/W')) AND ((lanStr='/C') or (lanStr='/BAS') or (lanStr='/BAS2') or (lanStr='/PAS')) then
  begin
    ValidFormat:=TRUE;
  end;
end;

Procedure StrToUp(Var S : String);
var
 i : Word;
begin
 For i:=1 to length(s) do
 begin
    s[i]:=UpCase(s[i]);
 end;
end;

Function byte2Hex(v : byte) : String;
const
 hex : array[0..15] of String[1] =('0','1','2','3','4','5','6','7','8','9',
                                    'A','B','C','D','E','F');
var
 temp1 : Byte;
 temp2 : Byte;
begin
   temp1:=v SHR 4;
   temp2:=v SHL 4;
   temp2:=temp2 SHR 4;
   byte2hex:=hex[temp1]+hex[temp2];
end;

Procedure  ExitWithDisplayError(Error : Word);
begin
  Case  Error of 2:Writeln('File Not Found.');
   else WriteLn('Error: ',Error);
  END;
  HALT;
end;

Function Word2Hex(v : Word) : String;
begin
  word2Hex:=byte2hex(lo(v))+byte2hex(hi(v));
end;

Function ReadByte(Var F : File) : Byte;
var
 NumBlocksRead : Integer;
 Error : Word;
begin
 if NextByte = MaxBlock then
 begin
{$I-}
   BlockRead (F, BlockData,MaxBlock,NumBlocksRead);
   Error:=IORESULT;
{$I+}
   NextByte:=0;
 end;
 ReadByte:=BlockData[NextByte];
 Inc(NextByte);
End;

Function GetNextLineNumberStr : string;
var
 TStr  : String;
begin
 TStr:='';
 If BasicLineMode then
 begin
   Str(LineNumber,TStr);
   TStr:=TStr+' ';
   inc(LineNumber,LineSteps);
 end;
 GetNextLineNumberStr:=TStr;
end;


Procedure BinToSrc(Format,Lantype,DataOrVariable : Word); (* DataOrVariable for basic only as option*)
Var
 F        : file;
 FT       : Text;
 nb       : LongInt; (* number of bytes *)
 count,i  : LongInt;
 temp     : Word;
 vpL      : Word;
 cpL      : Word;
 tempStr  : String;
 error    : Word;
 DataStr  : String;
 HexFormat : String;
begin
 DataStr:='DATA ';
 if DataOrVariable = 1 then DataStr:='';
 Case LanType of BasicLan :HexFormat:='&H';
                 Clan     :HexFormat:='0x';
                 PascalLan:HexFormat:='$';
 End;


{$I-}
   Assign(F,infile);
   Reset(F,1);
   Error:=IORESULT;
   if Error<>0 then
   begin
     ExitWithDisplayError(Error);
   end;
   Assign(FT,outfile);
   Rewrite(FT);
   Error:=IORESULT;
   if Error<>0 then
   begin
     ExitWithDisplayError(Error);
   end;

   nextByte:=MaxBlock;
   nb:=FileSize(F);
   Case Format of 1:begin
                      Count:=nb; (* dump file in byte array *)
                      vpl:=14;
                      if DataOrVariable = 1 then vpl:=3;
                    end;
    else             (* dump file in word format *)
    begin
      Count:=(nb+1) DIV 2;
      vpl:=10;
      if DataOrVariable = 1 then vpl:=5;
    end;
   end;

   if format = 1 then
   begin
   Case LanType of pascallan:WriteLn(FT,varname,' : Array[1..',Count,'] of Byte = (');
                        clan:writeln(FT,'char ',varname,'[',count,'] = {');
                   basiclan :Writeln(FT,GetNextLineNumberStr,'REM   ',varname,', Data Count = ',count);
   end;
   end
   else
   begin
     Case LanType of pascallan:WriteLn(FT,varname,' : Array[1..',Count,'] of Word = (');
                          clan:writeln(FT,'int ',varname,'[',count,'] = {');
                     basiclan :Writeln(FT,GetNextLineNumberStr,'REM   ',varname,', Data Count = ',count);
     end;
   end;
   Cpl:=1;
   if LanType <> BasicLan then
   begin
     write(FT,' ':4);
   end
   else
   begin
     write(FT,GetNextLineNumberStr,DataStr);
     if (format=1) and (DataOrVariable = 1) then Write(FT,varname,'$="":');

   end;
   For i:=1 to Count-1 do
   begin
      if Format = 1 then
      begin
         Temp:=ReadByte(F);
         if DataOrVariable = 1 then
         begin
           Write(FT,varname,'$=',varname,'$+CHR$(');
           Write(FT,HexFormat);
           Write(FT,byte2hex(temp));
           Write(FT,')');
         end
         else
         begin
           Write(FT,HexFormat);
           Write(FT,byte2hex(temp));
         end;
      end
      else
      begin
        Temp:=ReadByte(f) SHL 8;
        Inc(Temp,ReadByte(f));

       if DataOrVariable = 1 then
       begin
         Write(FT,varname,'%(',i-1,')=');
         Write(FT,HexFormat);
         Write(FT,word2hex(temp));
       end
       else
       begin
        Write(FT,HexFormat);
        write(FT,word2hex(temp));
       end;
      end;

      if cpl = vpl then
      begin
        cpl:=0;
        if LanType <> BasicLan then
        begin
          writeln(FT,',');
          write(FT,' ':4);
        end
        else
        begin
          writeln(FT);
          write(FT,GetNextLineNumberStr,DataStr);
        end;
      end
      else
      begin
          if DataOrVariable = 1 then
          begin
            write(FT,':');
           end
          else
          begin
            write(FT,',');
          end;
      end;
      inc(cpl);
   end;

   if Format = 1 then
   begin
       if DataOrVariable = 1 then
       begin
         Write(FT,varname,'$=',varname,'$+CHR$(');
         Write(FT,HexFormat);
         Write(FT,byte2hex(temp));
         Write(FT,')');
       end
       else
       begin
        Temp:=ReadByte(F);
        Write(FT,HexFormat);
        Write(FT,byte2hex(temp));
      end;
   end
   else
   begin
     Temp:=ReadByte(f) SHL 8;
     Inc(Temp,ReadByte(f));
     if DataOrVariable = 1 then
     begin
       Write(FT,varname,'%(',i,')=');
       Write(FT,HexFormat);
       Write(FT,word2hex(temp));
     end
     else
     begin
        Write(FT,HexFormat);
        Write(FT,word2hex(temp));
     end;
   end;
   case LanType of pascalLan: Write(FT,');');
                        clan: Write(FT,'};');
   end;
  writeln(FT);
  CLOSE(FT);
  Close(F);
end;

Procedure CheckForLineNumbers;
var
 LineSwitch : string;
 TempStr    : string;
 Error      : integer;
 SPos       : integer;
 TLine,TSteps : word;
 StepStr   : String;
 LineStr   : String;
begin
 BasicLineMode:=False;
 LineNumber:=1000;
 LineSteps:=10;
 LineSwitch:=ParamStr(5);
 StrToUp(LineSwitch);
 if Copy(LineSwitch,1,6)='/LINES' then
 begin
   BasicLineMode:=True;
   Delete(LineSwitch,1,6);
   if (Length(LineSwitch) > 0) and (LineSwitch[1]=':') then
   begin
      Delete(LineSwitch,1,1); (* get rid of first ':' *)
   end;

   StepStr:='10';
   LineStr:='1000';
   SPos:=POS(':',LineSwitch);
   if SPos > 0 then  (* we have lines and steps*)
   begin
     LineStr:=Copy(LineSwitch,1,SPos-1);
     Delete(LineSwitch,1,SPos);
     StepStr:=LineSwitch;
   end
   else
   begin   (* we only lines *)
     LineStr:=LineSwitch;
   end;

   Val(LineStr,TLine,Error);
   if (TLine > 0)  then
   begin
     LineNumber:=TLine;
   end;

   Val(StepStr,TSteps,Error);
   if (TSteps > 0) then
   begin
     LineSteps:=TSteps;
   end;

 end;
end;


Procedure PrintHelp;
begin
   writeln('BIN2SRC v1.4');
   writeln('(c) Copyright 1993-2022 By RetroNick. All Rights Reserved.');
   writeln;
   writeln(GitHub1);
   writeln(GitHub2);
   writeln;

   writeln('Usage: Bin2Src <input file> <output file> /format /language /lines:start:steps');
   writeln;
   writeln('  format /b = byte format  language /c    = c');
   writeln('         /w = word format  language /bas  = basic DATA Statetents');
   writeln('                           language /bas2 = basic Variable assignment');
   writeln('                           language /pas  = pascal language');
   writeln;
   writeln('       eg. BIN2SRC TGCAR.XGF TGCAR.C /b /c');
   writeln('       eg. BIN2SRC TGCAR.XGF TGCAR.C /b /bas /lines:1000:20');
   writeln('       eg. BIN2SRC TGCAR.XGF TGCAR.C /b /bas2');
   writeln('       eg. BIN2SRC TGCAR.XGF TGCAR.C /b /pas');

end;

var
 DataOrVairable : word;


begin
 if ParamCount < 4 then
 begin
   printHelp;
   halt;
 end;
 infile:=ParamStr(1);
 StrToUp(infile);
 outfile:=ParamStr(2);
 StrToUp(outfile);
 lanStr:=ParamStr(4);
 StrToUp(lanStr);
 FormStr:=ParamStr(3);
 StrToUp(FormStr);
 varname:=ParamStr(2);
 if pos('.',varname) > 0 then
 begin
  varname:=copy(varname,1,pos('.',varname)-1);
 end;
 if validFormat = False then
 begin
  printHelp;
  halt;
 end;

 DataOrVairable:=0;
 if lanStr='/C' then
 begin
    if formStr='/B' then
    begin
      binTosrc(1,Clan,0);
    end
    else
    begin
      binTosrc(2,Clan,0);
    end;
  end
  else  if (lanStr='/BAS') OR (lanStr='/BAS2') then
 begin
    CheckForLineNumbers;
    if LanStr='/BAS2' then DataOrVairable:=1;
    if formStr='/B' then
    begin
      binTosrc(1,BasicLan,DataOrVairable);
    end
    else
    begin
      binTosrc(2,BasicLan,DataOrVairable);
    end;
  end
  else  if lanStr='/PAS' then
 begin
    if formStr='/B' then
    begin
      binTosrc(1,PascalLan,0);
    end
    else
    begin
      binTosrc(2,PascalLan,0);
    end;
  end;

end.
