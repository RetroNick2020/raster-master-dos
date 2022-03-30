{$I RM.INC}

Unit Format;
 Interface
    uses vars,rmstrg;

Procedure SetFormat(xp,yp,Ftype : Word;Var cFormat : Word;Var Frec : FormatRec);

 Implementation
   uses graph,bgigadge,bgimouse,bgiMisc,bgiImage;


Type
 FlistT = array[1..50] of FormatRec;

Var
  FlistPtr : ^FlistT;
  nFormats : Word;



Procedure FstrToFrec(Fstr : String;Var Frec : FormatRec);
Var
 TempStr : String;
       n : Word;
begin

 Fstr:=Trim(UpperCase(FStr),' ');
 tempStr:=NextWord(Fstr,' ');
 Frec.PrgName:=TempStr;
 Fstr:=DeleteNextWord(Fstr,' ');
 FStr:=Trim(FStr,' ');

 tempStr:=NextWord(Fstr,' ');
 Frec.PrgPat:=TempStr;
 Fstr:=DeleteNextWord(Fstr,' ');
 FStr:=TrimL(FStr,' ');

 tempStr:=NextWord(Fstr,' ');
 Frec.PrgFormat:=TempStr;
 Fstr:=DeleteNextWord(Fstr,' ');
 FStr:=TrimL(FStr,' ');

 tempStr:=NextWord(Fstr,' ');
 Frec.PrgRW:=TempStr;
 Fstr:=DeleteNextWord(Fstr,' ');
 FStr:=TrimL(FStr,' ');

 Frec.PrgDis:=FStr;
end;


Procedure ReadExFormats(FT : Word);
Var
 F       : Text;
 Error   : Word;
 FormStr : String;
 Frec    : FormatRec;
begin
{$I-}
  {$IFDEF RMP}
  Assign(F,'RM.FIL');
  {$ELSE}
  Assign(F,'MP.FIL');
  {$ENDIF}
  Reset(F);
  Error:=IORESULT;
  If Error <>0 then Exit;
  While (not EOF(F)) AND (ERROR=0) AND (nFormats<50) do
  begin
    Readln(F,FormStr);
    FStrToFRec(FormStr,Frec);
    if (FT=1) AND (Frec.PrgRW='R') then
    begin
      Inc(nFormats);
      FlistPtr^[NFormats]:=Frec;
    end
    else if (FT=2) AND (Frec.PrgRW='W') then
    begin
      Inc(nFormats);
      FlistPtr^[NFormats]:=Frec;
    end;
    Error:=IORESULT;
  End;
  Close(F);
  Error:=IORESULT;
{$I+}
end;


Procedure CreateFList(Ftype: Word); (* 1 = open 2=save *)
begin
  FlistPtr^[1].PrgDis:='PCX  PC Paintbrush';
  FlistPTr^[1].PrgPat:='PCX';
  FlistPtr^[2].PrgDis:='BMP  Windows BMP';
  FlistPtr^[2].PrgPat:='BMP';
  FlistPtr^[3].PrgDis:='ICO  Windows Icon';
  FlistPtr^[3].PrgPat:='ICO';
  FlistPtr^[4].PrgDis:='ICN  RIP Icon';
  FlistPtr^[4].PrgPat:='ICN';

  {$IFDEF RMP}
    FlistPtr^[4].PrgDis:='CEL  Autodesk Anim';
    FlistPtr^[4].PrgPat:='CEL';
    FlistPtr^[5].PrgDis:='RAW  RM RAW';
    FlistPTr^[5].PrgPat:='RAW';
    FlistPtr^[6].PrgDis:='PAL  Palette';
    FlistPTr^[6].PrgPat:='PAL';
  {$ENDIF}

  if Ftype = 2 then
  begin
    {$IFDEF RMP}

      FlistPtr^[7].PrgDis:='CHA  Palette (C)';
      FlistPtr^[7].PrgPat:='CHA';

      FlistPtr^[8].PrgDis:='CON  Palette (PAS)';
      FlistPtr^[8].PrgPat:='CON';

      FlistPtr^[9].PrgDis:='DAT  Palette (BAS)';
      FlistPtr^[9].PrgPat:='DAT';

      FlistPtr^[10].PrgDis:='XGF  TP/TC (Binary)';
      FlistPTr^[10].PrgPat:='XGF';

      FlistPtr^[11].PrgDis:='CON  TP Constants';
      FlistPtr^[11].PrgPat:='CON';

      FlistPtr^[12].PrgDis:='CHA  TC Constants';
      FlistPtr^[12].PrgPat:='CHA';

      FlistPtr^[13].PrgPat:='XGF';
      FlistPtr^[13].PrgDis:='XGF  QC/QB (Binary)';

      FlistPtr^[14].PrgDis:='CHA  QC Constants';
      FlistPtr^[14].PrgPat:='CHA';

      FlistPtr^[15].PrgDis:='DAT  BASIC DATA';
      FlistPtr^[15].PrgPat:='DAT';

      FlistPtr^[16].PrgDis:='DEF  TEGL DEF';
      FlistPtr^[16].PrgPat:='DEF';

      FlistPtr^[17].PrgDis:='PPR  Fastgraph';
      FlistPtr^[17].PrgPat:='PPR';

      FlistPtr^[18].PrgDis:='SPR  Fastgraph';
      FlistPtr^[18].PrgPat:='SPR';

      FlistPtr^[19].PrgDis:='CHA  FG PPR (C)';
      FlistPtr^[19].PrgPat:='CHA';

      FlistPtr^[20].PrgDis:='CHA  FG SPR (C)';
      FlistPtr^[20].PrgPat:='CHA';

      FlistPtr^[21].PrgDis:='CON  FG PPR (PAS)';
      FlistPtr^[21].PrgPat:='CON';

      FlistPtr^[22].PrgDis:='CON  FG SPR (PAS)';
      FlistPtr^[22].PrgPat:='CON';

      FlistPtr^[23].PrgDis:='DAT  FG PPR (BAS)';
      FlistPtr^[23].PrgPat:='DAT';

      FlistPtr^[24].PrgDis:='DAT  FG SPR (BAS)';
      FlistPtr^[24].PrgPat:='DAT';

      FlistPtr^[25].PrgDis:='CHA  Mouse (C)';
      FlistPtr^[25].PrgPat:='CHA';

      FlistPtr^[26].PrgDis:='CON  Mouse (PAS)';
      FlistPtr^[26].PrgPat:='CON';


      FlistPtr^[27].PrgDis:='DAT  Mouse (BAS)';
      FlistPtr^[27].PrgPat:='DAT';
      nFormats:=27;
     {$ELSE}
       nFormats:=4;
     {$ENDIF}
      ReadExFormats(Ftype);
  end
  else
  begin
    {$IFDEF RMP}
    nFormats:=6;
    {$ELSE}
    nFormats:=4;
    {$ENDIF}
    ReadExFormats(1);
  end;
end;



Procedure SetFormat(xp,yp,Ftype : Word;Var cFormat : Word;Var Frec : FormatRec);
Var
 FGads      : GLPtr;
 x,y,x2,y2  : Word;
 offset,pos : Word;
 i          : Word;
 img,P,P2   : Pointer;
 size,nGad  : Word;


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
     OutTextXY(xx+2,yy+(i-1)*14+3,FListPtr^[i+offset].PrgDis);
   end;
 end;
end;

begin
 GetMem(FlistPtr,SizeOf(FlistT));

 CreateFList(Ftype);

 size:=ImageSize(xp,yp,xp+220,yp+140);
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
 Frec:=FlistPtr^[cFormat];
 FreeMem(FlistPtr,SizeOf(FlistT));
 FreeGadgetMem(Fgads,4);
 Mousehide;
 PutImage(xp,yp,Img^,NormalPut);
 MouseShow;
 FreeMem(img,size);
end;


begin
end.