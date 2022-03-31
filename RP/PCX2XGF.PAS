Program pcx2xgf;
 uses DOS,PCX2RAW,RAW2XGF,RAW2DEF,RAW2PRF,Keys;

Const
   TPLan   = 1;
   TCLan   = 2;
   QCLan   = 3;
   QBLan   = 4;
   PBLan   = 5;
   GWLan   = 6;

   Binary2   = 1;
   Binary4   = 2;
   Binary16  = 3;
   Binary256 = 4;

   Source2   = 5;
   Source4   = 6;
   Source16  = 7;
   Source256 = 8;

   SPRBinary = 9;
   SPRSource = 10;

   PPRBinary = 11;
   PPRSource = 12;

   TEGLText  = 13;

Const
 Compilers : array[1..6] of String = ('Turbo Pascal','Turbo C','QuickC',
             'QuickBASIC','Power Basic','GW BASIC');

 myNumColors : array[1..4] of Word = (2,4,16,256);
Var

 myPcxPalette : PcxPalette;
 myPcxHeader  : PcxHeader;
 myWidth      : Word;
 myHeight     : Word;
 myNColors    : Word;
 myMemAmount  : LongInt;
 myReply      : String[1];
 myPcxFile    : String;
 myXgfFile    : String;
 myFormat     : Word;
 myCompiler   : Word;
 Error        : Word;
 F            : File;



Function FileExists(filename:string) : Boolean;
var f : file;
begin
{$I-}
Assign(f,FileName);
Reset(f);
Close(f);

FileExists:=(IOResult=0) and (Filename<>'');
{$I+}
end;

Function MemRequired(Width,Height,Comp,Format : Longint) : Longint;
Var
 myMem : longint;
begin
  Case Format of Binary2,Source2:begin
                                  myMem:=((Width+7) div 8) * Height+4;
                                 end;
                 Binary4,Source4:begin
                                  myMem:=((Width+7) div 8) * 2 * Height+4;
                                 end;
                 Binary16,Source16:begin
                                     myMem:=((Width+7) div 8) * 4 * Height+4;
                                   end;
                 Binary256,Source256:begin
                                      myMem:=Width * Height+4;
                                     end;

  end;

  Case Comp of TPLan,TCLan:begin
                             inc(myMem,2);
                            end;
               GWLan,PBLan,QBLan:begin
                             if Odd(myMem) then
                             begin
                               inc(myMem);
                             end;
                           end;
  end;
  MemRequired:=myMem;
end;

Function GetFormType(FormStr : String;Var myFormat,myCompiler : Word) : Boolean;
Var
 i : Word;
 lanStr : String;
 ColStr : String;
begin
  GetFormType:=True;
  if FormStr[1]='-' then
  begin
   Delete(FormStr,1,1);
  End;
  For i:=1 to Length(FormStr) do
  begin
    FormStr[i]:=UpCase(FormStr[i]);

  End;

  If FormStr='PPR' then
  begin
     myFormat:=PPRBinary;
  end
  Else if FormStr='SPR' then
  begin
     myFormat:=SPRBinary;
  end
  Else if FormStr='DEF' then
  begin
     myFormat:=TeglText;
  end
  Else
  begin
    LanStr:=FormStr[1]+FormStr[2];
    Delete(FormStr,1,2);
    Colstr:=FormStr;

    IF LanStr='TP' then
    begin
      myCompiler:=TPLan;
    end
    Else If LanStr='TC' then
    begin
      myCompiler:=TCLan;
    end
    Else If LanStr='QC' then
    begin
      myCompiler:=QCLan;
    end
    Else If LanStr='QB' then
    begin
      myCompiler:=QBLan;
    end
    Else IF LanStr='PB' then
    begin
      myCompiler:=PBLan;
    end
    Else If LanStr='GW' then
    begin
      myCompiler:=GWLan;
    end
    Else
     begin
      GetFormType:=False;
      Exit;
    End;

    If ColStr='2' then
    begin
       myFormat:=Binary2;
    end
    Else if ColStr='4' then
    begin
       myFormat:=Binary4;
    end
    Else if ColStr='16' then
    begin
       myFormat:=Binary16;
    end
    Else if ColStr='256' then
    begin
       myFormat:=Binary256;
    end
    else
    begin
      GetFormType:=False;
      exit;
    end;
  End;

End;


begin
If ParamCount<>3 then
begin
  WriteLn('RastPort V1.0');
  WriteLn('Usage: RastPort <In_File> <Out_File> -format');
  WriteLn;
  WriteLn('   In_File = PCX File to read');
  WriteLn('  Out_FIle = XGF File to create');
  WriteLn('    Format = TPx,TCx,QCx,QBx,PBx,SPR,PPR');
  WriteLn('             x can be 2,4,16, or 256');
  WriteLn;

  Halt(1);
End;



myPcxFile:=ParamStr(1);
myXgfFile:=ParamStr(2);


if FileExists(myPcxFile)=false then
begin
 WriteLn(myPcxFile,' does not exist!');
 Halt;
end;

if FileExists(myXgfFile) then
begin
     Repeat
       Write('File Already Exists. Overwrite? [y/n]');
       Readln(myReply);
       myReply:=UpCase(myReply[1]);
       if myReply='N' then
       begin
          Halt;
       end;
     Until (myReply='Y');
end;



If ValidPcxFile(myPcxFile) = False then
begin
  WriteLn('Invalid PCX file!');
  Halt(1);
end;


If GetFormType(ParamStr(3),myFormat,myCompiler) = False then
begin
   WriteLn('Invalid output format!');
   Halt;
End;



 GetPcxInfo(myPcxFile,myPcxHeader,myPcxPalette);
 myWidth :=GetPcxWidth(myPcxHeader);
 myHeight:=GetPcxHeight(myPcxHeader);
 myNColors:=GetNPcxColors(myPcxHeader);
 WriteLn('Width= ',myWidth,' Height= ',myHeight,' Colors= ',myNColors);


Case myFormat Of Binary2..Binary256:
 begin
    If (myNColors>myNumColors[myFormat])  then
    begin
     Repeat
       Write('Color values will be truncated. Continue Anyway? [y/n]');
       Readln(myReply);
       myReply:=UpCase(myReply[1]);
       if myReply='N' then
       begin
          Halt;
       end;
       Until (myReply='Y')
    end;

   Writeln('PCX --> ',myNumColors[myFormat],' Color Bitmap for ',Compilers[myCompiler],'.');
   myMemAmount:=MemRequired(myWidth,myHeight,myCompiler,myFormat);
   If myMemAmount > $FFFF then
   begin
        Repeat
         Write('File will exceed 64K. Continue Anyway? [y/n]');
         Readln(myReply);
         myReply:=UpCase(myReply[1]);
         if myReply='N' then
         begin
          Halt;
         end;
        Until (myReply='Y')
        end;
   Error:=PcxToRaw(myPcxfile,'$$$$.Raw');
   Error:=RawToXgf('$$$$.Raw',myXgfFile,myNumColors[myFormat],myCompiler);
 End;
SPRBinary:
  begin
    Writeln('PCX --> SPR');
    Error:=PcxToRaw(myPcxfile,'$$$$.Raw');
    error:=RawToSpr('$$$$.raw',myXgfFile);
  end;
PPRBinary:
  begin
    If myNColors>16 then
    begin
     Repeat
       Write('Color values will be truncated. Continue Anyway? [y/n]');
       Readln(myReply);
       myReply:=UpCase(myReply[1]);
       if myReply='N' then
       begin
          Halt;
       end;
       Until (myReply='Y')
    end;
    Writeln('PCX --> PPR');
    Error:=PcxToRaw(myPcxfile,'$$$$.Raw');
    error:=RawToPpr('$$$$.raw',myXgfFile);
  end;
TeglText:
  begin
    If myNColors>16 then
    begin
     Repeat
       Write('Color values will be truncated. Continue Anyway? [y/n]');
       Readln(myReply);
       myReply:=UpCase(myReply[1]);
       if myReply='N' then
       begin
          Halt;
       end;
       Until (myReply='Y')
    end;
    Writeln('PCX --> DEF');
    Error:=PcxToRaw(myPcxfile,'$$$$.Raw');
    error:=RawToDEF('$$$$.raw',myXgfFile);
  end;
End;

Assign(F,'$$$$.raw');
Erase(F);

End.
