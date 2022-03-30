Unit Messages;
Interface
  uses bgiMouse,bgiMisc,bgiGadge,Graph;

Function  OverWriteFile(x,y : word) : Boolean;
Function  DoExit(x,y : word) : Boolean;
Procedure ErrorMessage(x,y,ErrorNum : Word);
Procedure InfoMessage(x,y : Word;msg1,msg2,msg3 : String);

Implementation


Function OverWriteFile(x,y : word) : Boolean;
var
 Size    : Word;
 Img     : Pointer;
 ReqGads : GLPtr;
      gn : Word;
begin
  MouseHide;
  Size:=ImageSize(x,y,x+220,y+110);
  GetMem(Img,Size);
  GetImage(x,y,x+220,y+110,Img^);

  DrawFrame(x,y,x+220,y+110,'        WARNING!!!');

  SetColor(Black);
  OutTextXY(x+14,y+30,'  File already exists!');
  OutTextXY(x+14,y+40,'Overwrite existing File?');

  GetGadgetMem(ReqGads,2);
  DefineStringGadget(ReqGads,1,x+120,y+70,' YES ',TRUE,FALSE);
  DefineStringGadget(ReqGads,2,x+60, y+70,' NO  ',TRUE,FALSE);
  DrawAllGadgets(ReqGads,2);
  MouseShow;

Repeat
 MouseWaitForKeyRelease;
 MouseWaitForLKey;
 gn:=GetGadgetPressed(ReqGads,2);

 if gn=1  then
 begin
   OverWriteFile:=true;
 end
 else if gn=2  then
 begin
   OverWriteFile :=false;
 end;

Until gn > 0;
 MouseHide;
 DrawGadget(ReqGads,gn,TRUE);
 MouseShow;
 MouseWaitForKeyRelease;
 MouseHide;
 DrawGadget(ReqGads,gn,FALSE);

PutImage(x,y,Img^,NormalPut);
FreeGadgetMem(ReqGads,2);
Freemem(Img,size);
MouseShow;

end;

Function DoExit(x,y : word) : Boolean;
var
 Size    : Word;
 Img     : Pointer;
 ReqGads : GLPtr;
      gn : Word;
begin
  Mousehide;
  Size:=ImageSize(x,y,x+220,y+110);
  GetMem(Img,Size);
  GetImage(x,y,x+220,y+110,Img^);
  DrawFrame(x,y,x+220,y+110,'       ATTENTION!!!');
  SetColor(Black);
  OutTextXY(x+25,y+30,'Do you really want to');
  OutTextXY(x+25,y+40,'Exit ?');


  GetGadgetMem(ReqGads,2);
  DefineStringGadget(ReqGads,1,x+120,y+70,' YES ',TRUE,FALSE);
  DefineStringGadget(ReqGads,2,x+60, y+70,' NO  ',TRUE,FALSE);
  DrawAllGadgets(ReqGads,2);
  MouseShow;


Repeat
 MouseWaitForKeyRelease;
 MouseWaitForLKey;
 gn:=GetGadgetPressed(ReqGads,2);

 if gn=1  then
 begin
   DoExit:=true;
 end
 else if gn=2  then
 begin
   DoExit:=false;
 end;

Until gn > 0;
   MouseHide;
   DrawGadget(ReqGads,gn,TRUE);
   MouseShow;
   MouseWaitForKeyRelease;
   MouseHide;
   DrawGadget(ReqGads,gn,FALSE);

PutImage(x,y,Img^,NormalPut);
FreeGadgetMem(ReqGads,2);
Freemem(Img,size);
MouseShow;
end;

Procedure InfoMessage(x,y : Word;msg1,msg2,msg3 : String);
var
 Size    : Word;
 Img     : Pointer;
 ReqGads : GLPtr;
      gn : Word;
begin
  MouseHide;
  Size:=ImageSize(x,y,x+220,y+110);
  GetMem(Img,Size);
  GetImage(x,y,x+220,y+110,Img^);

  GetGadgetMem(ReqGads,1);
  DefineStringGadget(ReqGads,1,x+160,y+85,'  OK  ',TRUE,FALSE);


  DrawFrame(x,y,x+220,y+110,'       ATTENTION!!!');
  SetColor(Black);
  OutTextXY(x+10,y+35,msg1);
  OutTextXY(x+10,y+45,msg2);
  OutTextXY(x+10,y+55,msg3);
  DrawGadget(ReqGads,1,FALSE);

  MouseShow;
  Repeat
   MouseWaitForLKey;
   gn:=GetGadgetPressed(ReqGads,1);
  Until gn > 0;
  MouseHide;
  DrawGadget(ReqGads,1,TRUE);
  MouseShow;
  MouseWaitForKeyRelease;
  MouseHide;
  DrawGadget(ReqGads,1,FALSE);

  PutImage(x,y,Img^,NormalPut);
  FreeGadgetMem(ReqGads,1);
  Freemem(Img,size);
MouseShow;

end;



Procedure ErrorMessage(x,y,ErrorNum : Word);
var
 ENum    : String[4];
 Size    : Word;
 Img     : Pointer;
 ReqGads : GLPtr;
      gn : Word;
begin
  MouseHide;
  Size:=ImageSize(x,y,x+220,y+110);
  GetMem(Img,Size);
  GetImage(x,y,x+220,y+110,Img^);

  Str(ErrorNum,Enum);

  DrawFrame(x,y,x+220,y+110,'        WARNING!!!');
  SetColor(Black);

  Case ErrorNum of 1000: OutTextXY(x+10,y+35,'    Invalid File Type');
                   1001: OutTextXY(x+10,y+35,'     Too many colors');
                 2,3002: OutTextXY(x+10,y+35,'     File Not Found!');
                      3: OutTextXY(x+10,y+35,'     Path Not Found!');
                      5: OutTextXY(x+10,y+35,'    File Access Denied');
                    100: OutTextXY(x+10,y+35,'     Disk Read Error');
                    101: OutTextXY(x+10,y+35,'    Disk Write Error');
                    150: OutTextXY(x+10,y+35,' Disk Is Write-Protected');
                    152: OutTextXY(x+10,y+35,'     Drive Not Ready');
                    156: OutTextXY(x+10,y+35,'      Disk Seek Error');
                    162: OutTextXY(x+10,y+35,'     Hardware Failure');
      else
      begin
        OutTextXY(x+10,y+30,'   I/O error #'+Enum+' has');
        OutTextXY(x+10,y+40,'        Occured!');
      end;
  END;
  GetGadgetMem(ReqGads,1);
  DefineStringGadget(ReqGads,1,x+85,y+70,'  OK  ',TRUE,FALSE);
  DrawGadget(ReqGads,1,FALSE);
  MouseShow;

Repeat
 MouseWaitForKeyRelease;
 MouseWaitForLKey;
 gn:=GetGadgetPressed(ReqGads,1);
until gn > 0;
 MouseHide;
 DrawGadget(ReqGads,1,TRUE);
 MouseShow;
 MouseWaitForKeyRelease;
 MouseHide;
 DrawGadget(ReqGads,1,FALSE);
 PutImage(x,y,Img^,NormalPut);
 MouseShow;
 Freemem(Img,size);
 FreeGadgetMem(ReqGads,1);
end;


begin
end.