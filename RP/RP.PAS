{$M 50000,0,0}

Program RP;
 uses vars,rkey,PCX2RAW,RAW2XGF,RAW2DEF,RAW2PRF;


Const
  PCX_FILE  = 1;
  RES_FILE  = 2;
  LIST_FILE = 3;

  TPLan   = 1;
  TCLan   = 2;
  QCLan   = 3;
  QBLan   = 4;

CONST
 NumOfFormats= 21;
 FormatList : Array[1..NumOfFormats] of String[5] =

   ('ADD','RAW','TP2','TP4','TP16','TP256','TC2','TC4',
    'TC16','TC256','QC2','QC4','QC16','QC256',
    'QB2','QB4','QB16','QB256','SPR','PPR','DEF');


Var

 ResFile       : String;
 ListFile      : String;
 Format        : String;
 in_File        : String;
 out_File       : String;

 Error         : Word;
 FileToProcess : Word;
 OverWriteFile     : Boolean;


Procedure StrToUp(Var ISTR : String);
Var
 i : Word;
begin
 For i:=1 to length(ISTR) do
 begin
   ISTR[i]:=UpCase(ISTR[i]);
 end;
end;

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

Procedure EraseFile(filename : String);
Var
 F : File;
 Error : Word;
begin
{$I-}
 Assign(F,FileName);
 Erase(F);
 Error:=IORESULT;
{$I+}
end;

Function GetFileSize(filename : String) : LongInt;
Var
 f     : File;
 size  : LongInt;
 error : Word;
begin
{$I-}
 Assign(F,filename);
 Reset(F,1);
 size:=FileSize(F);
 GetFileSize:=Size;
 Close(F);
 Error:=IORESULT;
{$I+}
end;

Function CopyToFile(VAR ToF : File;filename : String) : Word;

var
  FromF : file;
  NumRead, NumWritten: Word;
  buf: array[1..15000] of Char;
  Error : Word;
begin
{$I-}
  Assign(FromF, filename);
  Reset(FromF, 1);
  Error:=IORESULT;
  if error<>0 then
  begin
    CopyToFile:=error;
    exit;
  end;
  repeat
    BlockRead(FromF,buf,
              SizeOf(buf),NumRead);
    BlockWrite(ToF,buf,NumRead,NumWritten);
  until (NumRead = 0) or (NumWritten <> NumRead);
  Close(FromF);
  Error:=IORESULT;
  CopyToFile:=error;
{$I+}
end;


Procedure SetCmdArg;
Var
 List : array[1..5] of String;
    i : Word;
begin
 For i:=1 to 5 do
 begin
  List[i]:=ParamStr(i);
  StrToUp(List[i]);
 end;
 If (Pos('@',List[1]) = 1) AND ((List[3]='/RES') OR (List[3]='RES')) then
 begin
   FileToProcess:=RES_FILE;
   ResFile:=List[1];
   Delete(ResFile,1,1);
   out_file:=List[2];
 end
 else if (Pos('@',List[1]) = 1) AND ((List[2]='/O') OR (List[2]='O') OR (List[2]='')) then
 begin
   FileToProcess:=LIST_FILE;
   ListFile:=List[1];
   Delete(ListFile,1,1);
 end
 else
 begin
   FileToProcess:=PCX_FILE;
   in_File:=List[1];
   out_File:=List[2];
   Format:=List[3];
   if (POS(Format,'/') = 1) then
   begin
     Delete(Format,1,1);
   end;
 end;

 OverWriteFile:=False;
 For i:=2 to 5 do
 begin
  if (List[i]='/O') OR (List[i]='O') then
  begin
    OverwriteFile:=TRUE;
  end;
 end;
end;


Function FileExists(filename:string) : Boolean;
var
 f : file;
begin
{$I-}
 Assign(f,FileName);
 Reset(f);
 Close(f);
 FileExists:=(IOResult=0) and (Filename<>'');
{$I+}
end;

Function OverWrite(ISTR : String) : Boolean;
Var
 myReply : String;
begin
  OverWrite:=TRUE;

  if FileExists(ISTR) AND (OverWriteFile=False) then
  begin
    Repeat
      Write('File '#39+ISTR+#39' Already Exists. Overwrite? [y/n]');
      Readln(myReply);
      StrToUp(myReply);
      if myReply='N' then
      begin
        OverWrite:=FALSE;
      end;
    Until (myReply='Y') OR (myReply='N');
  end;
end;

Procedure Title;
begin
  WriteLn(ProgramName);
  writeln(Copyright);
  writeln;
  writeln(Github1);
  writeln(Github2);
  writeln;
end;

Procedure HelpScreen;
begin
  Title;
  WriteLn('Usage       : RASTPORT infile outfile format');
  Writeln('              RASTPORT @filelist');
  Writeln('              RASTPORT @reslist outfile res');
  Writeln;
  WriteLn;
  WriteLn('   infile = PCX FILE / FILE LIST / RESOURCE LIST to read');
  WriteLn('  outfile = File to create');
  WriteLn('    format = TPx,TCx,QCx,QBx,RAW,SPR,PPR,RES');
  WriteLn('             x can be 2,4,16, or 256');
  WriteLn;
  WriteLn('  eg. RASTPORT CAR.PCX CAR.XGF TC16');
  Writeln('      RASTPORT @FILELIST.TXT');
  Writeln('      RASTPORT @RESLIST.TXT RESFILE.RES RES');
  Halt;
end;

Procedure CheckRegistrationKey(format : String;Ncolors : Word);
begin
  IF ValidKey(RPKey)=FALSE then
  begin
    If (POS('256',Format)>0) OR ((Format='SPR') and (NColors=256))
       OR ((Format='RAW') AND (NColors=256)) THEN
    begin
      Writeln('Converting images to 256 color format requires registration!');
      writeln('Try converting some 16 color images.');
      halt;
    end;
  end;
end;


Function ValidFormat(Format : String) : Word;
Var
 i : Word;
BEGIN
 ValidFormat:=0;
 For i:=1 to NumOfFormats do
 begin
   if Format = FormatList[i] then
   begin
     ValidFormat:=i;
     exit;
   end;
 end;
END;

Procedure GetFormatName(Var FormatName : String;FN : Word);
BEGIN
   FormatName:=FormatList[FN];
END;

Procedure ConvertFile(infile,outfile,format : String);
var
 pcxpal     : PcxPalette;
 PcxHeader  : PcxHeaderRec;

 myWidth      : Word;
 myHeight     : Word;
 myNColors    : Word;

begin

  GetPcxInfo(inFile,PcxHeader,pcxpal);
  myWidth :=GetPcxWidth(PcxHeader);
  myHeight:=GetPcxHeight(PcxHeader);
  myNColors:=GetNPcxColors(PcxHeader);

  CheckRegistrationKey(format,myNColors);
  If OverWrite(OutFile) = FALSE then exit;

  Writeln('Converting: ',inFile,'  [Width= ',myWidth,' Height= ',myHeight,' Colors= ',myNColors,']',' To ',format);

  if (Format='RAW') then
  begin
    Error:=PcxToRaw(infile,outfile);
  end
  else if (Format='TP2') OR (Format='TC2') then
  begin
    Error:=PcxToRaw(infile,'$$$$.Raw');
    Error:=RawToXgf('$$$$.Raw',outFile,2,TPLan);
  end
  else if (Format='TP4') OR (Format='TC4') then
  begin
    Error:=PcxToRaw(infile,'$$$$.Raw');
    Error:=RawToXgf('$$$$.Raw',OutFile,4,TPLan);
  end
  else if (Format='TP16') OR (Format='TC16') then
  begin
    Error:=PcxToRaw(infile,'$$$$.Raw');
    Error:=RawToXgf('$$$$.Raw',OutFile,16,TPLan);
  end
  else if (Format='TP256') OR (Format='TC256') then
  begin
    Error:=PcxToRaw(infile,'$$$$.Raw');
    Error:=RawToXgf('$$$$.Raw',OutFile,256,TPLan);
  end
  else if (Format='QB2') OR (Format='QC2') then
  begin
    Error:=PcxToRaw(infile,'$$$$.Raw');
    Error:=RawToXgf('$$$$.Raw',OutFile,2,QBLan);
  end
  else if (Format='QB4') OR (Format='QC4') then
  begin
    Error:=PcxToRaw(infile,'$$$$.Raw');
    Error:=RawToXgf('$$$$.Raw',OutFile,4,QBLan);
  end
  else if (Format='QB16') OR (Format='QC16') then
  begin
    Error:=PcxToRaw(infile,'$$$$.Raw');
    Error:=RawToXgf('$$$$.Raw',OutFile,16,QBLan);
  end
  else if (Format='QB256') OR (Format='QC256') then
  begin
    Error:=PcxToRaw(infile,'$$$$.Raw');
    Error:=RawToXgf('$$$$.Raw',OutFile,256,QBLan);
  end
  else if (Format='SPR') then
  begin
    Error:=PcxToRaw(infile,'$$$$.Raw');
    Error:=RawToSpr('$$$$.Raw',outfile);
  end
  else if (Format='PPR') then
  begin
    Error:=PcxToRaw(infile,'$$$$.Raw');
    Error:=RawToPpr('$$$$.Raw',outfile);
  end
  else if (Format='DEF') then
  begin
    Error:=PcxToRaw(infile,'$$$$.Raw');
    error:=RawToDEF('$$$$.raw',OutFile);
  end
  else
  begin
    writeln('Invalid format!');
    halt;
  end;
  EraseFile('$$$$.RAW');
end;


Procedure ProcessList(ListFile : String);
Var
 F : Text;
 CmdLine : String;
 infile,outfile,format : String;
 Error : Word;
 T     : Word;
 Temp  : String;

Function GetValidFiles : Boolean;
begin
  GetValidFiles:=TRUE;
  StrToUp(CmdLine);
  StripE(CmdLine);
  StripS(CmdLine);
  T:=Pos(#32,CmdLine);
  if T > 0 then
  begin
    infile:=Copy(CmdLine,1,T-1);
    Delete(CmdLine,1,T);
  end
  else
  begin
    GetValidFiles:=FALSE;
  end;

  StripS(CmdLine);
  T:=Pos(#32,CmdLine);
  if T > 0 then
  begin
    outfile:=Copy(CmdLine,1,T-1);
    Delete(CmdLine,1,T);
  end
  else
  begin
    GetValidFiles:=FALSE;
  end;

  StripS(CmdLine);
  T:= POS('/',CmdLine);
  If T > 0 then
  begin
    Delete(CmdLine,T,1);
  end;

  if ValidFormat(CmdLine) > 0 then
  begin
    format:=CmdLine;
  end
  else
  begin
    GetValidFiles:=FALSE;
  end;

end;

begin
{$I-}
 Assign(F,ListFile);
 Reset(F);
 Error:=IORESULT;
 if Error<>0 then
 begin
   writeln('Error reading ',ListFile,'!');
   halt;
 end;
 While Not Eof(F) do
 begin
   readln(f,CmdLine);
   if GetValidFiles = True then
   begin
     ConvertFile(infile,outfile,format);
   end
   else if CmdLine='' then
   begin
   end
   else
   begin
     Writeln('Invalid command in ',ListFile);
     writeln(CmdLine, ' ',infile,' ',outfile,' ',format);
     halt;
   end;
 end;
 Close(F);
{$I+}
end;


Procedure ProcessRES(ResFile,OutFile : String);
Type
 ResRec = Record
            ResName : String[80];
            Added   : Boolean;
            FN      : Word;
            Size    : LongInt;
            Offset  : LongInt;
            Desc    : Array[1..12] of Char;
          end;


Var
 F       : Text;
 FRes    : File;
 I,T     : Word;
 FC      : Word;
 FN      : Word;
 ADF     : Word;
 Line    : Word;
 Temp    : String;
 CmdLine, infile, format : String;
 ResList : Array[1..300] of ResRec;
 c : integer;
 offset,size : Longint;
 resSig : array[1..3] of char;
 desc   : String[12];
Function GetValidFiles : Boolean;
begin
  GetValidFiles:=TRUE;
  StrToUp(CmdLine);
  StripE(CmdLine);
  StripS(CmdLine);
  T:=Pos(#32,CmdLine);
  if T > 0 then
  begin
    infile:=Copy(CmdLine,1,T-1);
    Delete(CmdLine,1,T);
  end
  else
  begin
    GetValidFiles:=FALSE;
  end;

  StripS(CmdLine);
  T:=Pos(#32,CmdLine);
  if T > 0 then
  begin
    desc:=Copy(CmdLine,1,T-1);
    Delete(CmdLine,1,T);
  end
  else
  begin
    GetValidFiles:=FALSE;
  end;

  StripS(CmdLine);
  T:=Pos(#32,CmdLine);
  if T > 0 then
  begin
    format:=Copy(CmdLine,1,T-1);
    Delete(CmdLine,1,T);
  end
  else if CmdLine<>'' then
  begin
    format:=CmdLine;
  end
  else if CmdLine='' then
  begin
    GetValidFiles:=FALSE;
  end;

  ADF:=0;
  If Format='ADD' then
  begin
    StripS(CmdLine);
    if CmdLine<>'' then
    begin
      VAL(CmdLine,ADF,c);
    end;
  end;
end;

begin
 OverWriteFile:=TRUE;
{$I-}
 Assign(F,ResFile);
 Reset(F);
 Error:=IORESULT;
 if Error<>0 then
 begin
   writeln('Error reading ',ListFile,'!');
   halt;
 end;
 FC:=0;
 Line:=0;
 While (Not Eof(F)) AND (FC < 300) do
 begin
   readln(f,CmdLine);
   Inc(Line);
   if GetValidFiles = True then
   begin
     If ValidFormat(Format) > 0 then
     begin
       If FileExists(infile) then
       begin
         Inc(FC);
         ResList[FC].ResName:=infile;
         FillChar(ResList[FC].desc,12,32);
         if Format='ADD' then
         begin
           ResList[FC].FN :=ADF;
           ResList[FC].Added:=TRUE;
           Move(desc[1],ResList[FC].Desc,length(desc));
         end
         else
         begin
           ResList[FC].FN :=ValidFormat(Format);
           ResList[FC].Added:=FALSE;
           Move(desc[1],ResList[FC].Desc,length(desc));
         end;
       end
       else
       begin
         writeln('Cannot find ',infile,'!');
         halt;
       end;
     end
     else
     begin
       Writeln('Invalid format in line ',line,'!');
       halt;
     end;
   end
   else if CmdLine='' then
   begin
   end
   else
   begin
     Writeln('Invalid command in line',line,'!');
     halt;
   end;
 end;
 Close(F);
 Error:=IORESULT;

 Assign(Fres,outfile);
 Rewrite(Fres,1);
 seek(Fres,longint(FC)*22+5);
 Error:=IORESULT;
 if error <>0 then
 begin
   writeln('Error creating ',outfile,'!');
   Close(Fres);
   EraseFile(outfile);
   halt;
 end;
 Offset:=Longint(FC)*22+5;
 For i:=1 to FC do
 begin
   If ResList[i].Added=TRUE then
   begin
     Size:=GetFileSize(ResList[i].ResName);
     ResList[i].Size:=Size;
     ResList[i].Offset:=Offset;
     if CopyToFile(Fres,ResList[i].ResName) <> 0 then
     begin
        Close(Fres);
        EraseFile(outfile);
        halt;
     end;
     Inc(offset,Size);
   end
   else
   begin
     GetFormatName(Format,ResList[i].FN);
     ConvertFile(ResList[i].ResName,'$$RES.TMP',Format);
     if CopyToFile(Fres,'$$RES.TMP') <> 0 then
     begin
        Close(Fres);
        EraseFile(outfile);
        EraseFile('$$RES.TMP');
        halt;
     end;
     Size:=GetFileSize('$$RES.TMP');
     EraseFile('$$RES.TMP');
     ResList[i].Size:=Size;
     ResList[i].Offset:=Offset;
     Inc(offset,Size);
   end;
   Error:=IORESULT;
   if error <>0 then
   begin
     writeln('Error creating ',outfile,'!');
     Close(Fres);
     EraseFile(outfile);
     halt;
   end;
   writeln('    Adding: ',ResList[i].Desc);
 end;

 Seek(Fres,0);
 resSig:='RES';
 Blockwrite(Fres,resSig,sizeof(resSig));
 Blockwrite(Fres,FC,Sizeof(FC));
 offset:=6;

 For i:=1 to FC do
 begin
  Blockwrite(Fres,ResList[i].FN,2);
  Blockwrite(Fres,ResList[i].desc,12);
  Blockwrite(Fres,ResList[i].offset,4);
  Blockwrite(Fres,ResList[i].size,4);
 end;
 Seek(Fres,FileSize(Fres));
 Close(Fres);
 Error:=IORESULT;
 if error <>0 then
 begin
   writeln('Error creating ',outfile,'!');
   EraseFile(outfile);
   halt;
 end;
{$I+}
end;






begin
  If ParamCount < 1 then
  begin
    HelpScreen;
    halt;
  End;

  SetCmdArg;

  If FileToProcess = PCX_FILE then
  begin
    if FileExists(in_File)=false then
    begin
      WriteLn(in_File,' does not exist!');
      Halt;
    end;
    ConvertFile(in_file,out_file,format);
  end
  else if FileToProcess = LIST_FILE then
  begin
    if FileExists(listFile)=false then
    begin
      WriteLn(listFile,' does not exist!');
      Halt;
    end;
    ProcessList(Listfile);
  end
  else if FileToProcess = RES_FILE then
  begin
    if FileExists(ResFile)=false then
    begin
      WriteLn(ResFile,' does not exist!');
      Halt;
    end;
    If FileExists(out_file) then
    begin
      If OverWrite(out_file) then
      begin
        OverWriteFile:=TRUE;
      end
      else
      begin
        Halt;
      end;
    end;
    ProcessRES(ResFile,out_file);
  end;

  WriteLn;
  Title;
End.
