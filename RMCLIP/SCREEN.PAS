Unit Screen;
Interface
Function SetSVGA16(Mode : Word) : Boolean;
Function SetVGA256(Mode :Word) : Boolean;
Implementation
  uses graph;


procedure Svga16; external;
{$L SVGA16.OBJ }

Procedure Svga256 ;external;
{$L svga256.obj}


{$F+}
Function DetectVGA256 : integer;
begin
    DetectVGA256 :=0;
end;
{$F-}

{$F+}
Function DetectVGA16 : integer;
begin
    DetectVGA16 :=0;
end;
{$F-}


Function SetVGA256(Mode : Word) : Boolean;
Var
 Error : Word;
 gd,gm : Integer;
begin
 SetVga256:=TRUE;

 GD :=InstallUserDriver('svga256',@detectvga256);
 gM :=Mode;

 IF RegisterBGIDriver(@svga256) < 0 then
 begin
   SetVGA256:=FALSE;
 end
 else
 begin
   Initgraph(gd,gm,'');
   If GraphResult <> 0 then
   begin
     SetVGA256:=FALSE;
   end;
 end;

end;

Function SetSVGA16(Mode : Word) : Boolean;
Var
 gd,gm : Integer;
begin
 GD :=InstallUserDriver('svga16',@detectvga16);
 gm:=Mode;

 IF RegisterBGIDriver(@svga16) < 0 then
 begin
   SetSVGA16:=FALSE;
 end
 else
 begin
   Initgraph(gd,gm,'');
   If GraphResult <> 0 then
   begin
     SetSVGA16:=FALSE;
   end;
 end;
end;


begin
end.
