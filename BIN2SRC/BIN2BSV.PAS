(* Data	Meaning
  'BYTE	Magic number (always 0xFD, 253)
  'INT	Segment. Set to 0x9999 by modern versions.
  'INT	Offset is always 0
  'INT	Length, the number of bytes

Article: Q34407
Product(s): See article
Version(s): 3.00 4.00 4.00b 4.50
Operating System(s): MS-DOS
Keyword(s): ENDUSER | B_BasicCom B_GWBasicI | mspl13_basic
Last Modified: 9-JAN-1991

A file saved with the BSAVE statement has a 7-byte header with the
following hexadecimal format:

   ww xx xx yy yy zz zz

   ww:     A signature byte equal to 253, which tells DOS and other
           programs that this is a BASIC BSAVE/BLOAD format file.
   xx xx:  The segment address from the last BSAVE.
   yy yy:  The offset address from the last BSAVE.
   zz zz:  The number of bytes BSAVEd.

This information applies to Microsoft QuickBASIC versions 3.00, 4.00,
4.00b, and 4.50 for MS-DOS; to Microsoft BASIC Compiler versions 6.00
and 6.00b for MS-DOS; and to Microsoft BASIC Professional Development
System (PDS) versions 7.00 and 7.10 for MS-DOS.

This information is provided as is. The BSAVE format is not guaranteed
to be the same in a future release.

Microsoft GW-BASIC Interpreter (versions 3.20, 3.22, and 3.23) uses
the same 7-byte header string, and also repeats the 7-byte string,
appending it after the final data byte. BASICA (provided in IBM or
Compaq ROM on some computer models) does not repeat the 7-byte string
at the end. GW-BASIC and BASICA both terminate the file with ASCII 26,
also known as a CTRL+Z character (hex 1A). QuickBASIC and Microsoft
BASIC Compiler don't append CTRL+Z or repeat the 7-byte string at the
end.

To determine whether a file was BSAVEd by GW-BASIC, BASICA, or
QuickBASIC, compare the length of the memory saved against the file
length. The difference is 15 bytes in GW-BASIC, 7 bytes in QuickBASIC,
and 8 bytes in BASICA.

Despite the slight format differences, files BSAVEd under any of the
three above BASIC dialects correctly BLOAD into each other BASIC.
*)

Program BIN2BSV;

const
  ProgramName = 'Bin2Bsv 1.0';
  CopyRight   = '(c) Copyright 2022 By RetroNick. All Rights Reserved';
  GitHub1     = 'Get source and latest version from github:';
  GitHub2     = 'https://github.com/RetroNick2020';

  MaxBSaveSize = 32767;
type
  BsvRec = Record
              Magic  : Byte;
              Seg    : Word;
              Off    : Word;
              Length : Word;
           end;

Var
 InFileMemPtr : Pointer;
 InFileSize   : Word;


(* we could allocate less memory - but this just a small app - 32Kb is no big deal *)
Procedure GetTheMemory;
begin
  GetMem(InFileMemPtr,MaxBsaveSize);
  if InFileMemPtr = NIL then
  begin
    Writeln('Failed to Allocate Enough Memeory, we need ',MaxBSaveSize,' bytes!');
  end;
end;

Procedure FreeTheMemory;
begin
 if InFileMemPtr<>NIL then
 begin
   Freemem(InFileMemPtr,MaxBsaveSize);
 end;
end;


Procedure FailAndCleanUp;
begin
 FreeTheMemory;
 writeln('Looks like something went wrong - not sure what to say.');
 halt;
end;

Procedure CheckSize(filename : string);
var
 F : File;
begin
 Assign(F,filename);
{$I-}
 Reset(F,1);
 if FileSize(F) > 32767 then
 begin
   writeln('Source file too big. Must be ',MaxBSaveSize,' bytes or less!');
   Close(F);
   FreeTheMemory;
   Halt;
 end;
 Close(f);
{$I+}
 if IOResult <> 0 then
 begin
  FailAndCleanUp;
 end;
end;

Procedure ReadFile(filename : string);
var
 F : File;
 RSize : Word;
begin
 Assign(F,filename);
{$I-}
 Reset(F,1);
 BlockRead(F,InFileMemPtr^,MaxBSaveSize,RSize);
 close(F);
{$I+}
 if IOResult <> 0 then
 begin
  FailAndCleanUp;
 end;
 InFileSize:=RSize;
end;

Procedure WriteFile(filename : string);
var
 F : File;
 WSize : Word;
 Bsv   :BsvRec;
begin
 Bsv.Magic:=$FD;  (* 253 *)
 Bsv.Seg:=$9999;
 Bsv.Off:=$0;
 Bsv.Length:=InFileSize;
 Assign(F,filename);
{$I-}
 Rewrite(F,1);
 BlockWrite(F,Bsv,sizeof(Bsv));
 BlockWrite(F,InFileMemPtr^,InFileSize,WSize);
 BlockWrite(F,Bsv,sizeof(Bsv));
 close(F);
{$I+}
 if IOResult <> 0 then
 begin
  FailAndCleanUp;
 end;
end;

Procedure PrintHelp;
begin
   writeln(ProgramName);
   writeln(Copyright);
   writeln;
   writeln(GitHub1);
   writeln(GitHub2);
   writeln;

   writeln('Usage: Bin2Bsv <input file> <output file>');
   writeln;
   writeln('       eg. BIN2BSV ASMCODE.COM ASMCODE.BSV');
end;

var
 InFile,OutFile : string;
begin
 if ParamCount < 2 then
 begin
   printHelp;
   halt;
 end;

 InFile:=ParamStr(1);
 OutFile:=ParamStr(2);
 CheckSize(InFile);
 GetTheMemory;
 ReadFile(InFile);
 WriteFile(OutFile);
 FreeTheMemory;
end.