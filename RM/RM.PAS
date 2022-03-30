{$I RM.INC}


{$IFDEF RMP}
  {$M 51000,0,140000}
{$ELSE}
  {$M 52000,0,140000}
{$ENDIF}

{$S+}
Program RM;
 uses  crt,
      graph,
      keys,
      vars,
     panel,
     tools,
  bgimouse,
       dos,
    bgiReq,
  Messages,
    Format,
    Screen,
    rmTitle;

Var
 n : Word;
 RKey : Boolean;


Procedure DrawScreen;
begin
 GetGadgetMemory;
 SetMainToolGadget(2,110);
 SetMainGridGadget(115,5);
 SetMainColorGadget(111,431);
 SetHorizScrollers(110,411);
 SetVirtScrollers(620,0);
 SetToolGadgets(2,110);
 SetClipGadgets(2,110);
 SetColorGadgets(111,431);
 Setfillstyle(SolidFill,Black);

 Bar(0,0,639,469);
 MouseColrange(0,629);
 MouseRowrange(0,464);

 DrawActualBox(5,4);
 DrawColorGadgets;
 DrawGridBox(115,5);
 DrawToolGadgets;
 DrawRMBox(2,350);
 DrawScrollGadgets;
end;

Procedure Init;
begin
 If MouseExists then
 begin
   if SetSVGA16(3) then
   begin
     DrawScreen;
   end
   else
    begin
      Writeln('This Program requires a Mouse and a VGA card.');
      write(#7);
      halt(1);
   end;
 end
 else
 begin
   Writeln('This Program requires a Mouse and VGA card.');
   halt(1);
 end;

end;

begin
 Init;
 MouseMode(1);
 MouseShow;

 repeat
  MouseWaitForAnyKey;
  Rkey:=MouseIsRKey;
  n:=GetMainGadget;
  If n=1 then
  begin
    n:=GetToolGadget;
    if n = 1 then
    begin
      If RKey then
      begin
        OpenFormatP;
      end
      else
      begin
        SaveUndoImg;
        OpenP;
      end;
    end
    else if n = 2 then
    begin
      If RKey then
      begin
        SaveFormatp;
      end
      else
      begin
        SaveP;
      end;
    end
    Else if n = 3 then
    begin
      SaveUndoImg;
      CLRP;
    end
    else if n = 4 then
    begin
      UndoP;
    end
    else if n = 5 then
    begin
      GridP;
    end
    else if n = 6 then
    begin
      GridAdjustP;
    end
    else if n = 7 then
    begin
      ViewP;
    end
    else if n = 8 then
    begin
      FreeGadgetMemory;
      TogleMode;
      DrawScreen;
      ReDrawImage;
      MouseShow;
    end
    else if n = 9 then
    begin
      if DoExit(80,221) then
      begin
        FreeGadgetMemory;
        MouseHide;
        ClearDevice;
        Closegraph;
        EndTitle;
        halt;
      end;
    end;
  end
  else if n=2 then
  begin
    n:=GetColorGadget;
    if n=1 then
    begin
      SelectColor;
    end
    else if n= 2then
    begin
      Pal;
    end
    else if n= 3 then
    begin
     UpColors;
    end
    else if n=4 then
    begin
     DownColors;
    end;
    MouseWaitForKeyRelease;
  end
  else if n=3 then
  begin
    SaveUndoImg;
    case tool of
                 1:ClipP;
                 2:FillP;
                 3:CircleP;
                 4:FCircleP;
                 5:SprayP;
                 6:DotP;
                 7:RectangleP;
                 8:FRectangleP;
                 9:LineP;
    end;
  end
  else
  begin
    n:=GetScrollGadget;
    case n of   1:SweepLeft;
                2:SweepRight;
                3:SweepH;
                4:SweepUp;
                5:SweepDown;
                6:SweepV;
    end;
  end;

Until 1=0;

end.