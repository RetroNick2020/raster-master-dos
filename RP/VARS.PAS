Unit Vars;

Interface
   uses RKey,DOS;
const
 ProgramName = 'RastPort v2.1';
 Copyright   = '(c) Copyright 1993-2022 By RetroNick. All Rights Reserved.';
 GitHub1     = 'Get source and latest version from github:';
 GitHub2     = 'https://github.com/RetroNick2020';


Var
 RPKey : KeyRec;
 CPath : String;
 Implementation

Procedure GetPath;
var
   n     : nameStr;
   d     : dirStr;
   e     : extStr;
BEGIN
 fsplit(ParamStr(0),d,n,e);
 Cpath:=d;
end;

begin
 GetPath;
 ReadKey(RPKey,Cpath+'\RM.KEY');
end.
