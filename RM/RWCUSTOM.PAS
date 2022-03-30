Unit RWCUSTOM;

Interface
  Uses Vars;

Function WriteCustom(x,y,x2,y2 : Word;wf : FormatRec; filename : String) : Word;
Function ReadCustom(x,y,x2,y2,pal : Word;wf : FormatRec; filename : String) : Word;

Implementation
  Uses Dos,Graph,RWXGF;

Function WriteCustom(x,y,x2,y2 : Word;wf : FormatRec; filename : String) : Word;
Var
 Error : Word;
    F  : File;
begin
  Error:=WriteRaw(x,y,x2,y2,'RM$$.RAW');
  if Error <> 0 then
  begin
    WriteCustom:=Error;
    Exit;
  end;
  Exec(wf.PrgName,filename+' '+wf.PrgFormat);
  Error:=DosError;
  if Error <> 0 then
  begin
    WriteCustom:=2000+Error;
    Exit;
  end;
  Error:=DosExitCode;
  if Error <> 0 then
  begin
    WriteCustom:=3000+Error;
    Exit;
  end;
  WriteCustom:=0;
{$I-}
  Assign(F,'RM$$.RAW');
  Erase(F);
  Error:=IORESULT;
{$I+}
end;


Function ReadCustom(x,y,x2,y2,pal : Word;wf : FormatRec; filename : String) : Word;
Var
 Error : Word;
 Xstr,YStr,X2Str,Y2Str,PalStr,CMode  : String[3];
 F : FIle;
begin
  Str(x,XStr);
  Str(y,YStr);
  Str(x2,X2Str);
  Str(y2,Y2Str);
  Str(GetMaxColor+1,Cmode);
  Str(Pal,PalStr);

  Exec(wf.PrgName,filename+' '+wf.PrgFormat+
       ' '+Xstr+' '+YStr+' '+x2Str+' '+Y2Str+' '+PalStr);
  Error:=DosError;
  if Error <> 0 then
  begin
    ReadCustom:=2000+Error;
    Exit;
  end;

  Error:=DosExitCode;
  if Error <> 0 then
  begin
    ReadCustom:=3000+Error;
    Exit;
  end;

  Error:=ReadRaw(x,y,x2,y2,pal,'RM$$.RAW');
{$I-}
  Assign(F,'RM$$.RAW');
  Erase(F);
  Error:=IORESULT;
{$I+}
  ReadCustom:=Error;
end;

begin
end.