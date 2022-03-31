{$M 16000,0,200000}

Program RmClip;
 uses crt,vars,rkey,xgraph,graph,screen,bgimouse,panel,rwpcx,rwbmp,
      wxgf,wprf,rwpal,rwraw,rlist;

const
 SFormat : Word =1;
 OFormat : Word =1;
 CordsON = TRUE;
Var
 Option : Word;

Var
 CAreaImg  : Pointer;
 CAreaSize : Word;
 CAreaX    : Word;
 CAreaY    : Word;
 CAreaW    : Word;
 CAreaH    : Word;

Procedure GetCAreaImg;
begin
 CAreaSize:=xgraph.Imagesize(1,1,CAreaW,CAreaH);
 GetMem(CareaImg,CareaSize);
 GetImage(Careax,CAreay,CareaX+CAreaW-1,Careay+CAreaH-1,CAreaImg^);
end;

Procedure FreeCAreaImg;
begin
 PutImage(Careax,CAreay,CAreaImg^,NormalPut);
 FreeMem(CareaImg,CareaSize);
end;

Procedure GetCAreaCords;
Var
 mx,my,st : integer;
begin
 MouseGetStatus(st,my,mx);
 CAreaW:=300;
 CAreaX:=GetMaxX-CareaW;
 CAreaH:=10;
 if my > CareaH then
 begin
  CAreaY:=0;
 end
 else
 begin
  CareaY:=GetMaxY-CareaH+1;
 end;
end;

Procedure MoveCArea;
begin
  FreeCAreaImg;
  GetCAreaCords;
  GetCareaImg;
end;

Procedure DrawCrossH(x,y : Integer);
begin
 SetWriteMode(XorPut);
 SetColor(Red);
 Line(0,y,GetMaxX,y);
 Line(x,0,x,GetMaxY);
 SetWriteMode(NormalPut);
end;

Procedure PrintCordsxy(Var x,y : Integer);
Const
 Lastx : Word=$FFFF;
 Lasty : Word=$FFFF;
Var
 ocolor : Integer;
 sx,sy  : String[4];
begin
 If (x=lastx) and (y=lasty) then exit;
 If (y >= CAreaY) and (y<=CareaY+CareaH) then
 begin
   MoveCarea;
 end;

 SetFillStyle(SolidFill,White);
 ocolor:=GetColor;
 SetColor(Black);
 Str(x:4,sx);
 Str(y:4,sy);
 Bar(CAreaX,CareaY,careax+careaw-1,careay+careah-1);
 outtextxy(Careax+1,careay+1,'X:'+sx+' Y:'+sy);

 lastx:=x;
 lasty:=y;
 SetColor(ocolor);
end;

Procedure PrintCords(Var x,y,x2,y2 : Integer);
Var
 ocolor : Integer;
 sx,sy,sx2,sy2,sw,sh  : String[4];
begin
 If (y2 >= CAreaY) and (y2<=CareaY+CareaH) then MoveCarea;
 If (y2 >= CAreaY) and (y2<=CareaY+CareaH) then
 begin
   MoveCarea;
 end;
 SetFillStyle(SolidFill,White);
 ocolor:=GetColor;
 SetColor(Black);
 Bar(CAreaX,CareaY,careax+careaw-1,careay+careah-1);

 Str(x,sx);
 Str(y,sy);
 Str(x2,sx2);
 Str(y2,sy2);
 If (x2>x) then
 begin
   Str((x2-x+1),sw);
 end
 else
 begin
   Str((x-x2+1),sw);
 end;
 if (y2>y) then
 begin
   Str((y2-y+1),sh);
 end
 else
 begin
   Str((y-y2+1),sh);
 end;
 outtextxy(Careax+1,careay+1,'X:'+sx+' Y:'+sy+' X2:'+sx2+' Y2:'+sy2+' W:'+SW+' H:'+SH);
 SetColor(ocolor);
end;

Procedure RBox(x,y,x2,y2 : Integer);
begin
 SetWriteMode(XorPut);
 SetColor(White);
 Rectangle(x,y,x2,y2);
 SetWriteMode(NormalPut);
end;

Procedure GetClipCords(Var x,y,x2,y2 : Integer);
var
 st : integer;
 lastx,lasty : Integer;
begin
 MouseWaitForKeyRelease;
 Mousehide;
 if CordsON then
 begin
  GetCareaCords;
  GetCareaImg;
 end;
 MouseGetStatus(st,y,x);
 Lastx:=x;
 Lasty:=y;
 DrawCrossH(Lastx,LastY);
 Repeat
   MouseGetStatus(st,y,x);
   If (Lastx<>x) or (lasty<>y) then
   begin
     DrawCrossH(Lastx,LastY);
     if CordsON then
     begin
       printcordsxy(x,y);
     end;
     DrawCrossH(x,Y);
     Lastx:=x;
     Lasty:=y;
   end;
 Until st<>0;
 DrawCrossH(Lastx,LastY);
 x2:=x;
 y2:=y;
 lastx:=x;
 lasty:=y;

 RBox(x,y,x2,y2);
 DrawCrossH(lastx,lastY);
 Repeat
  MouseGetStatus(st,y2,x2);
  if (Lastx<>x2) or (lasty<>y2) then
  begin
    RBox(x,y,lastx,lasty);
    DrawCrossH(lastx,lasty);
    if CordsON then PrintCords(x,y,x2,y2);
    RBox(x,y,x2,y2);
    DrawCrossH(x2,y2);
    lastx:=x2;
    lasty:=y2;
  end;
 Until st = 0;
 RBox(x,y,x2,y2);
 DrawCrossH(x2,y2);

 if CordsON then FreeCareaImg;
 MouseShow;
end;


Function MoveClipRect(x,y,x2,y2 : Integer;var nx,ny,nx2,ny2 : Integer) : Word;
var
 st : integer;
 width,height : integer;
 oldx,oldy : integer;
begin
 width:=x2-x+1;
 height:=y2-y+1;

 MouseGetStatus(st,y,x);
 oldx:=x;
 oldy:=y;
 SetColor(White);
 SetWriteMode(XorPut);
 Rectangle(x,y,x+width-1,y+height-1);
 Repeat
  MouseGetStatus(st,y,x);
  if (oldx<>x) or (oldy<>y) then
  begin
    Rectangle(oldx,oldy,oldx+width-1,oldy+height-1);
    Rectangle(x,y,x+width-1,y+height-1);
    oldx:=x;
    oldy:=y;
  end;
 Until (st = 1) or (st=2);
 nx:=x;
 ny:=y;
 nx2:=nx+width-1;
 ny2:=ny+height-1;
 Rectangle(oldx,oldy,oldx+width-1,oldy+height-1);
 SetWriteMode(NormalPut);
 MoveClipRect:=st;
end;

Procedure DoOpenFormat;
begin
 OFormat:=SetFormat(10,10,1);
end;

Procedure DoSaveFormat;
begin
 Sformat:=SetFormat(10,10,2);
end;

Procedure DoOpen(x,y,x2,y2 : Word;IPAl : Boolean);
var
 Filename : String;
 Error    : Word;
begin
 FileName:='';
 if GetFileName(10,10,'Open File',FileName) then
 begin
    MouseHide;
    if OFormat = 1 then
    begin
       Error:=DisPcxImg(x,y,x2,y2,IPAL,Filename);
    end
    else if OFormat = 2 then
    begin
       Error:=ReadBMP(x,y,x2,y2,IPAL,FileName);
    end
    else if OFormat = 3 then
    begin
       Error:=ReadICN(x,y,x2,y2,FileName);
    end
    else if OFormat = 4 then
    begin
       Error:=ReadRaw(x,y,x2,y2,IPAL,FileName);
    end
    else if OFormat = 5 then
    begin
       Error:=ReadPal(Filename);
    end;
    MouseShow;
    if Error <>0 then
    begin
      ErrorMessage(10,10,Error);
    end;
 end;
end;

Procedure DoSave(x,y,x2,y2,format : Word);
var
 Filename : String;
 Error    : Word;
begin
 FileName:='';
 if GetFileName(10,10,'Save File',FileName) then
 begin
    MouseHide;
    if format=1 then
    begin
       error:=SavePcxImg(x,y,x2,y2,Filename);
    end
    else if format=2 then
    begin
       error:=WriteBMP(x,y,x2,y2,Filename);
    end
    else if format=3 then
    begin
       error:=WriteXGF(x,y,x2,y2,1,Filename);
    end
    else if format=4 then
    begin
       error:=WriteRAW(x,y,x2,y2,Filename);
    end
    else if format=5 then
    begin
       error:=WritePal(Filename);
    end
    else if format=6 then
    begin
       error:=WritePPR(x,y,x2,y2,Filename);
    end
    else if format=7 then
    begin
       error:=WriteSPR(x,y,x2,y2,Filename);
    end
    else if format=8 then
    begin
       error:=WriteXGF(x,y,x2,y2,1,Filename);
    end
    else if format=9 then
    begin
       Error:=WriteXgf(x,y,x2,y2,2,Filename);
    End;
    MouseShow;
    if Error <>0 then
    begin
      ErrorMessage(10,10,Error);
    end;
 end;
end;


Procedure DoCopy(x,y,x2,y2 : Integer);
var
 nx,ny,nx2,ny2 : integer;
 option : Word;
 size   : LongInt;
 img    : Pointer;
begin
  size:=xgraph.imagesize(x,y,x2,y2);
  if size > $FFFF then
  begin
   InfoMessage(10,10,'','Image Must be 64K or Less.','');
   exit;
  end;
  GetMem(img,size);
  getimage(x,y,x2,y2,img^);
  MouseHide;
  Repeat;
   option:=MoveClipRect(x,y,x2,y2,nx,ny,nx2,ny2);
   if option = 1 then
   begin
     PutImage(nx,ny,Img^,NormalPut);
   end;
  Until option=2;
  MouseShow;
  FreeMem(Img,Size);
end;


Procedure DoClip;
Var
 Option : word;
 x,y,x2,y2,temp : integer;
 sx,sy,sx2,sy2,sw,sh : String[4];

begin
 GetClipCords(x,y,x2,y2);
 if x > x2 then
 begin
  temp:=x;
  x:=x2;
  x2:=temp;
 end;

 if y > y2 then
 begin
  temp:=y;
  y:=y2;
  y2:=temp;
 end;

 Str(x,sx);
 Str(y,sy);
 Str(x2,sx2);
 Str(y2,sy2);
 Str((x2-x+1),sw);
 Str((y2-y+1),sh);

 Repeat
   Option:=ClipMenu(5,5,'X:'+sx+' Y:'+sy+' X2:'+sx2+' Y2:'+sy2+' W:'+sw+' H:'+SH);
   MouseHide;

   Case Option of 1:DoOpen(x,y,x2,y2,FALSE);
                  2:DoSave(x,y,x2,y2,Sformat);
                  3:DoCopy(x,y,x2,y2);
                  6:DoOpenFormat;
                  7:DoSaveFormat;

   end;

  MouseShow;
 Until option=5;
end;

procedure DoMode;
Var
 Mode : Word;
begin
 Mode := GetScreenMode(10,10);
 if Mode = 0 then exit;
 Mousehide;
 CloseGraph;
 if Mode < 5 then
 begin
   if SetSVGA16(Mode-1) = False then
   begin
     writeln('Cannot set this mode on your VGA card!');
     halt;
   end;
 end
 else if Mode > 4 then
 begin
   if SetVGA256(Mode-5) = False then
   begin
     writeln('Cannot set this mode on your VGA card!');
     halt;
   end;
 end;

 If (Mode=1) or (Mode=5) then
 begin
   MouseMode(3);
 end
 else if Mode > 4 then
 begin
  MouseMode(2);
 end
 else
 begin
  MouseMode(1);
 end;
 If GetMaxX=319 then
 begin
  MouseColRange(0,639);
 end
 else
 begin
  MouseColRange(0,GetMaxX);
 end;
  MouseRowRange(0,GetMaxY);
 MouseShow;
end;


Procedure DoBegScreen;
begin
 writeln(ProgramName);
 WriteLn(Copyright);
 writeln;
 writeln(Github1);
 WriteLn(Github2);
 writeln;
end;


Var
 Title : String;
begin
 Title:=ProgramName;

 If ParamCount = 1 then
 begin
   ReadList(ParamStr(1));
   DoBegScreen;
   halt;
 end
 else if MouseExists=False then
 begin
   writeln('Can'#39't find mouse!');
   halt;
 end;

 if SetSVGA16(0) then
 begin
   MouseMode(3);
   MouseColRange(0,639);
   MouseRowRange(0,199);
   MouseShow;
   Repeat
     Option:=MainMenu(5,5,Title);
     Case Option of 1:DoOpen(0,0,GetMaxX,GetMaxY,TRUE);
                    2:DoSave(0,0,GetMAxX,GetMaxY,Sformat);
                    3:DoClip;
                    4:doMode;
                    6:DoOpenFormat;
                    7:DoSaveFormat;
     End;
   Until Option=5;
   CloseGraph;
 end;
 DoBegScreen;
end.
