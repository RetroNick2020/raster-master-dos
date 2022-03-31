
Unit Panel;
Interface
  uses vars,xgraph,graph,bgiMouse,bgiMisc,bgiGadge,bgiedit,bgiimage;

Function  OverWriteFile(x,y : word) : Boolean;
Function  DoExit(x,y : word) : Boolean;
Procedure ErrorMessage(x,y,ErrorNum : Word);
Procedure InfoMessage(x,y : Word;msg1,msg2,msg3 : String);
Function  GetFileName(x,y : Word;title : String;Var IStr : String) : Boolean;
Function MainMenu(x,y : Word;ISTR : String) : Word;
Function ClipMenu(x,y : Word;Title : String) : Word;
Function  SetFormat(xp,yp,ftype : Word) : Word;
Function  GetScreenMode(x,y : word) : word;

Implementation

Function GetFileName(x,y : Word;title : String;Var IStr : String) : Boolean;
const
 cs : Integer = 1;
var
 ReqGads : GLPtr;
      gn : Word;
    size : Word;
    Img  : Pointer;
    TStr : String[22];
Procedure GetInput;
begin
 MouseHide;
 SetfillStyle(SolidFill,Green);
 Bar(x+9,y+29,x+(8*23)+1,y+40);
 MouseShow;
 EditString(x+10,y+30,22,cs,Green,Black,red,1,ISTR);
 MouseHide;
 SetfillStyle(SolidFill,White);
 Bar(x+9,y+29,x+(8*23)+1,y+40);
 SetColor(Black);
 TStr:=IStr;
 OutTextXy(x+10,y+30,TSTR);
 MouseShow;
end;

begin
 size:=xgraph.ImageSize(x,y,x+200,y+80);
 GetMem(Img,size);
 GetGadgetMem(ReqGads,3);
 DefineBlankGadget(ReqGads,1,x+9,y+29,(22*8),10,TRUE,FALSE);
 DefineStringGadget(ReqGads,2,x+90,y+50,' CANCEL ',TRUE,FALSE);
 DefineStringGadget(ReqGads,3,x+160,y+50,' OK ',TRUE,FALSE);
 Mousehide;
 GetImage(x,y,x+200,y+80,Img^);
 DrawFrame(x,y,x+200,y+80,Title);
 DrawAllGadgets(ReqGads,3);
 SetColor(Black);
 Rectangle(x+8,y+28,x+(8*23)+2,y+41);
 MouseShow;
 MouseWaitForKeyRelease;
 GetInput;
 Repeat
   MouseWaitForKeyRelease;
   MouseWaitForLKey;
   gn:=GetGadgetPressed(ReqGads,3);
   if gn=1 then GetInput;
 until gn > 1;
 MouseHide;
 DrawGadget(reqGads,gn,TRUE);
 MouseShow;
 MouseWaitForKeyRelease;
 MouseHide;
 DrawGadget(reqGads,gn,FALSE);
 PutImage(x,y,Img^,normalput);
 MouseShow;
 Freemem(Img,size);
 FreeGadgetMem(ReqGads,3);
 GetFileName:=TRUE;
 if gn=2 then
 begin
   GetFileName:=False;
 end
end;


Function MainMenu(x,y : Word;ISTR : String) : Word;
var
 ReqGads : GLPtr;
      gn : Word;
    size : Word;
    Img  : Pointer;
 st,mx,my : integer;

begin
 size:=xgraph.ImageSize(x,y,x+308,y+60);
 GetMem(Img,size);
 GetGadgetMem(ReqGads,5);
 DefineStringGadget(ReqGads,1,x+10,y+30,' OPEN ',TRUE,FALSE);
 DefineStringGadget(ReqGads,2,x+65,y+30,' SAVE ',TRUE,FALSE);
 DefineStringGadget(ReqGads,3,x+120,y+30,' CLIP ',TRUE,FALSE);
 DefineStringGadget(ReqGads,4,x+175,y+30,' MODE ',TRUE,FALSE);
 DefineStringGadget(ReqGads,5,x+230,y+30,' EXIT ',TRUE,FALSE);
 Mousehide;
 GetImage(x,y,x+308,y+60,Img^);
 DrawFrame(x,y,x+308,y+60,ISTR);
 DrawAllGadgets(ReqGads,5);

 MouseShow;
 Repeat
   MouseWaitForKeyRelease;
   MouseWaitForAnyKey;
   MouseGetStatus(st,my,mx);
   gn:=GetGadgetPressed(ReqGads,5);
 until gn > 0;
 MouseHide;
 DrawGadget(reqGads,gn,TRUE);
 MouseShow;
 MouseWaitForKeyRelease;
 MouseHide;
 DrawGadget(reqGads,gn,FALSE);
 PutImage(x,y,Img^,normalput);
 MouseShow;
 Freemem(Img,size);
 FreeGadgetMem(ReqGads,5);
 MainMenu:=gn;
 if (st=2) and (gn<3) then
 begin
   MainMenu:=gn+5;
 end;

end;

Function ClipMenu(x,y : Word;Title : String) : Word;
var
 ReqGads : GLPtr;
      gn : Word;
    size : Word;
    Img  : Pointer;
 st,mx,my : integer;

begin
 size:=xgraph.ImageSize(x,y,x+308,y+60);
 GetMem(Img,size);
 GetGadgetMem(ReqGads,5);
 DefineStringGadget(ReqGads,1,x+10,y+30,' OPEN ',TRUE,FALSE);
 DefineStringGadget(ReqGads,2,x+65,y+30,' SAVE ',TRUE,FALSE);
 DefineStringGadget(ReqGads,3,x+120,y+30,' COPY ',TRUE,FALSE);
 DefineBlankGadget(ReqGads,4,x+4000,y+30,0,0,TRUE,FALSE);
 DefineStringGadget(ReqGads,5,x+230,y+30,' MAIN ',TRUE,FALSE);
 Mousehide;
 GetImage(x,y,x+308,y+60,Img^);
 DrawFrame(x,y,x+308,y+60,Title);
 DrawAllGadgets(ReqGads,5);

 MouseShow;
 Repeat
   MouseWaitForKeyRelease;
   MouseWaitForAnyKey;
   MouseGetStatus(st,my,mx);
   gn:=GetGadgetPressed(ReqGads,5);
 until gn > 0;
 MouseHide;
 DrawGadget(reqGads,gn,TRUE);
 MouseShow;
 MouseWaitForKeyRelease;
 MouseHide;
 DrawGadget(reqGads,gn,FALSE);
 PutImage(x,y,Img^,normalput);
 MouseShow;
 Freemem(Img,size);
 FreeGadgetMem(ReqGads,5);
 ClipMenu:=gn;
 if (st=2) and (gn<3) then
 begin
   ClipMenu:=gn+5;
 end;
end;


Function GetScreenMode(x,y : word) : word;
var
 gn     : word;
 size   : word;
 Img    : Pointer;
 ReqGads: GLPtr;
begin
 size:=xgraph.ImageSize(x,y,x+300,y+140);
 GetMem(Img,size);

 GetGadgetMem(ReqGads,8);
 DefineStringGadget(ReqGads,1,x+10,y+25, ' 320 X 200 X 16 ',TRUE,FALSE);
 DefineStringGadget(ReqGads,2,x+10,y+50, ' 640 X 200 X 16 ',TRUE,FALSE);
 DefineStringGadget(ReqGads,3,x+10,y+75, ' 640 X 350 X 16 ',TRUE,FALSE);
 DefineStringGadget(ReqGads,4,x+10,y+100,' 640 X 480 X 16 ',TRUE,FALSE);
 DefineStringGadget(ReqGads,5,x+150,y+25, ' 320 X 200 X 256 ',TRUE,FALSE);
 DefineStringGadget(ReqGads,6,x+150,y+50, ' 640 X 400 X 256 ',TRUE,FALSE);
 DefineStringGadget(ReqGads,7,x+150,y+75, ' 640 X 480 X 256 ',TRUE,FALSE);
 DefineStringGadget(ReqGads,8,x+220,y+110,' CANCEL ',TRUE,FALSE);

 MouseHide;
 GetImage(x,y,x+300,y+140,Img^);
 DrawFrame(x,y,x+300,y+140,'Select Screen Mode');
 DrawAllGadgets(ReqGads,8);
 MouseShow;
 Repeat
   MouseWaitForKeyRelease;
   MouseWaitForLKey;
   gn:=GetGadgetPressed(ReqGads,8);
 until gn > 0;
 MouseHide;
 DrawGadget(reqGads,gn,TRUE);
 MouseShow;
 MouseWaitForKeyRelease;
 MouseHide;
 DrawGadget(reqGads,gn,FALSE);

 PutImage(x,y,Img^,normalput);
 MouseShow;

 Freemem(Img,size);
 FreeGadgetMem(ReqGads,8);
 if (gn <> 8) then
 begin
   GetScreenMode:=gn
 end
 else
 begin
   GetScreenMode:=0;
 end;
end;

Function SetFormat(xp,yp,ftype : Word) : Word;
const
 Sformat: Word = 1;
 OFormat: Word = 1;

Var
 Cformat : Word;
 FGads      : GLPtr;
 x,y,x2,y2  : Word;
 offset,pos : Word;
 i          : Word;
 img,P,P2   : Pointer;
 size,nGad  : Word;
 fileList   : Array[1..10] of String[20];
 nformats   : Word;

Procedure PrintList(xx,yy : Word);
Var
i : Word;
begin
 For i:=1 to 5 do
 begin
   if (i+offset) = Cformat then
   begin
     SetFillStyle(SolidFill,RED);
   end
   else
   begin
     SetFillStyle(SolidFill,Green);
   end;
   Bar(xx,yy+(i-1)*14,xx+170,yy+(i)*14);
   SetColor(Black);
   If nFormats >=(i+offset) then
   begin
     OutTextXY(xx+2,yy+(i-1)*14+3,FileList[i+offset]);
   end;
 end;
end;

begin

 FileList[1]:='PCX  (PC Paintbrush)';
 FileList[2]:='BMP  Windows 3 BMP';
 FileList[3]:='ICN  RIP Icon';
 FileList[4]:='RAW  RAW Format';
 FileList[5]:='PAL  Palette';
 FileList[6]:='PPR  Fastgraph PPR';
 FileList[7]:='SPR  Fastgraph SPR';
 FileList[8]:='XGF  Turbo C/Pascal';
 FileList[9]:='XGF  Quick C/BASIC';
 {$IFDEF MEGACLIP}
 nformats:=4;
 {$ELSE}
 nformats:=9;
 {$ENDIF}
 Cformat:=Sformat;
 if ftype=1 then
 begin
 {$IFDEF MEGACLIP}
 nformats:=4;
 {$ELSE}
 nformats:=5;
 {$ENDIF}
  cformat:=Oformat;
 end;

 size:=xgraph.ImageSize(xp,yp,xp+220,yp+140);
 GetMem(img,size);
 MouseHide;
 GetImage(xp,yp,xp+220,yp+140,Img^);
 if Ftype = 1 then
 begin
   DrawFrame(xp,yp,xp+220,yp+140,'Select Open Format');
 end
 else
 begin
   DrawFrame(xp,yp,xp+220,yp+140,'Select Save Format');
 end;
 GetGadgetMem(FGads,5);
 DefineBlankGadget(FGads,1,xp+15,yp+30,175,75,FALSE,TRUE);
 GetGadgetCords(FGads,1,x,y,x2,y2);

 If GetMaxColor=15 then
 begin
   P:=@Up16a;
   P2:=@Up16b;
 end
 else
 begin
   P:=@Up256a;
   P2:=@Up256b;
 end;
 DefineImageGadget(FGads,2,x2+2,y,17,17,P,P2,TRUE,FALSE);

 If GetMaxColor=15 then
 begin
   P:=@Down16a;
   P2:=@Down16b;
 end
 else
 begin
   P:=@Down256a;
   P2:=@Down256b;

 end;
 DefineImageGadget(FGads,3,x2+2,y+17,17,17,P,P2,TRUE,FALSE);

 DefineStringGadget(FGads,4,xp+140,y+82,'   OK   ',TRUE,FALSE);

 SetColor(Black);
 Rectangle(x,y,x2,y2);

 DrawAllGadgets(FGads,4);
 if cFormat < 6 then
 begin
   offset:=0;
   pos:=cformat;
 end
 else
 begin
   offset:=cformat-5;
   pos:=cformat-offset;
 end;
 PrintList(x+2,y+2);
 MouseShow;
 Repeat
   MouseWaitForKeyRelease;
   MouseWaitForAnyKey;
   Ngad:=GetGadgetPressed(FGads,4);
   If NGad > 1 then
   begin
   Repeat

   if NGad = 2 then
   begin
     if Pos+offset > 1 then
     begin
      if pos > 1 then
      begin
       Dec(pos);
      end
      else if offset > 0 then
      begin
       Dec(Offset);
      end;

      CFormat:=Pos+Offset;
      MouseHide;
      PrintList(x+2,y+2);
      MouseShow;
     end;
   end
   else if NGad = 3 then
   begin
     if (Pos+Offset) < NFormats then
     begin
       if Pos < 5 then
       begin
         inc(Pos);
       end
       else
       begin
         inc(offset);
       end;
       cFormat:=Pos+offset;
       MouseHide;
       PrintList(x+2,y+2);
       MouseShow;
     end;
  end;
  Until MouseIsRKey=False;

  MouseHide;
  DrawGadget(FGads,Ngad,TRUE);
  MouseShow;
  MouseWaitForKeyRelease;
  MouseHide;
  DrawGadget(FGads,Ngad,FALSE);
  MouseShow;

  end;
 Until nGad = 4;

 FreeGadgetMem(Fgads,4);
 Mousehide;
 PutImage(xp,yp,Img^,NormalPut);
 MouseShow;
 FreeMem(img,size);
 SetFormat:=Cformat;
 if Ftype=1 then
 begin
   Oformat:=Cformat;
 end
 else
 begin
   Sformat:=Cformat;
 end;
end;

Function OverWriteFile(x,y : word) : Boolean;
var
 Size    : Word;
 Img     : Pointer;
 ReqGads : GLPtr;
      gn : Word;
begin
  MouseHide;
  Size:=xgraph.ImageSize(x,y,x+220,y+110);
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
  Size:=xgraph.ImageSize(x,y,x+220,y+110);
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
  Size:=xgraph.ImageSize(x,y,x+220,y+110);
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
  Size:=xgraph.ImageSize(x,y,x+220,y+110);
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
                    103: OutTextXY(x+10,y+35,'    Can'#39't Open File');
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