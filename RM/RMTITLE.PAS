{$I RM.INC}

Unit rmtitle;
 Interface
   uses crt,dos,vars,xgraph,graph,bgigadge,bgimouse,bgimisc;

Procedure EndTitle;
Procedure StartMenu(x,y : word);

Implementation


Procedure Wait(Sds : Word);
Var
 nPassed : Word;
 sec,min,hour,sec100 : Word;
 lastsec : Word;
begin
 nPassed:=0;
 LastSec:=0;
 Repeat
   GetTime(hour,min,sec,sec100);
   if sec <> LastSec then
   begin
    inc(nPassed);
    Lastsec:=sec;
   end;

 Until npassed > Sds;
end;


Procedure EndTitle;
begin
  Writeln(ProgramName);
  Writeln(CopyRight1+'  '+Copyright2);
end;

Procedure StartMenu(x,y : word);
const width = 369;
      height = 169;
var
 ReqGads : GLPtr;
      gn : Word;
    size : Word;
    Img  : Pointer;

begin
 size:=xgraph.ImageSize(x,y,x+width,y+height);
 GetMem(Img,size);
 GetGadgetMem(ReqGads,1);
 DefineStringGadget(ReqGads,1,x+width-40,y+height-30,' OK ',TRUE,FALSE);
 MouseHide;
 GetImage(x,y,x+width,y+height,Img^);
 SetFillStyle(SolidFill,White);
 Bar(x+3,y+3,x+width-3,y+height-3);
 Border(x,y,x+width,y+height);
 SetColor(LightRed);
 OutTextXY(x+100,y+10,ProgramName);
 SetColor(black);
 Rectangle(x+2,y+2,x+width-2,y+height-2);
 OutTextXY(x+10,y+25,Copyright1);
 OutTextXY(x+42,y+35,Copyright2);


 DrawGadget(ReqGads,1,FALSE);
 MouseShow;
 Repeat
   MouseWaitForKeyRelease;
   MouseWaitForLKey;
   gn:=GetGadgetPressed(ReqGads,1);
 until gn > 0;
 MouseHide;
 DrawGadget(reqGads,gn,TRUE);
 MouseShow;
 MouseWaitForKeyRelease;
 MouseHide;
 DrawGadget(reqGads,gn,FALSE);
 PutImage(x,y,Img^,normalput);
 Freemem(Img,size);
 FreeGadgetMem(ReqGads,1);
 MouseShow;
end;


begin
end.
