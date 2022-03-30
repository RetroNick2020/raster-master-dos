Unit RWXgf;
 Interface
 uses dos,xgraph,graph,vars,core,Bits,bgiPal;
Function WriteXgf(x,y,x2,y2,LanType : word;filename:string):word;
Function ReadRaw(x,y,x2,y2,pal : Word;FileName : String) : Word;
Function WriteRaw(x,y,x2,y2 : Word;FileName : String) : Word;
Function ReadPAL(Filename : String) : Word;
Function WritePAL(Filename : String) : Word;
Function ReadICN(x,y,x2,y2 : Word;Filename : String) : Word;
Implementation


type
 linebuftype = array[0..1023] of byte;

Procedure WriteXgfLine(Var F: File;xp,ln,width,bytesPerLine,LanType : word);
var
 BitPlane1 : Word;
 BitPlane2 : Word;
 BitPlane3 : Word;
 BitPlane4 : Word;
 cp,cl,x,
 xoff,j    : Word;
 mylinebuf : Linebuftype;
 Temp      : Word;
begin
{$I-}
 Fillchar(mylinebuf,sizeof(mylinebuf),0);

 BitPlane1:=0;
 BitPlane2:=bytesPerLine;
 BitPlane3:=BytesPerLine*2;
 BitPlane4:=BytesPerLine*3;
 xoff:=xp;
 cp:=0;
 for x:=0 to bytesPerLine-1 do
 begin
   for j:=0 to 7 do
   begin
      cl:=IconImage[xoff+j,ln];
      if biton(3,cl) then setbit((7-j),1,mylinebuf[BitPlane4+cp]);
      if biton(2,cl) then setbit((7-j),1,mylinebuf[BitPlane3+cp]);
      if biton(1,cl) then setbit((7-j),1,mylinebuf[BitPlane2+cp]);
      if biton(0,cl) then setbit((7-j),1,mylinebuf[BitPlane1+cp]);
   end;
   inc(cp);
   inc(xoff,8);
 end;

 If (LanType=TPLan) OR (LanType=TCLan) OR (LanType=PBLan) then
 begin
   For x:=0 to BitPlane2-1 do
   begin
     Temp:=myLineBuf[x];
     mylineBuf[x]:=mylineBuf[x+BitPlane4];
     mylineBuf[x+BitPlane4]:=Temp;
     Temp:=mylineBuf[x+BitPlane2];
     mylineBuf[x+BitPlane2]:=mylineBuf[x+BitPlane3];
     mylineBuf[x+BitPlane3]:=Temp;
   end;
 end;
 BlockWrite(F,mylinebuf,BytesPerLine*4);
{$I+}
end;


Function WriteXgf(x,y,x2,y2,LanType : word;filename:string):word;
Type
 XgfHead = Record
             Width  : Word;
             Height : Word;
           End;
Var
 mylinebuf : Linebuftype;
 myHead    : XgfHead;
 mywidth   : word;
 myheight  : word;
 BPL       : Word;
 F         : File;
 Error     : Word;
 J,I       : Word;
 Temp      : array[1..2] of char;
begin
{$I-}
 myWidth:=x2-x+1;
 myHeight:=y2-y+1;

 If (LanType=TPLan) OR (LanType=TCLan) then
 begin
   myhead.Width:=mywidth-1;
   myhead.Height:=myheight-1;
 end
 else
 begin
   If GetMaxColor=255 then
   begin
     myhead.Width:=mywidth SHL 3;
   end
   else
   begin
     myhead.Width:=mywidth;
   end;
   myhead.Height:=myheight;
 end;

 Assign(F,filename);
 Rewrite(F,1);
 BlockWrite(F,myhead,4);

 Error:=IOResult;
 if Error <> 0 then
 begin
   close(F);
   WriteXgf:=Error;
   exit;
 end;

 if GetMaxColor=15 then
 begin
   BPL:=(mywidth+7) div 8;
   For j:=0 to myheight-1 do
   begin
     WriteXgfline(F,x,y+j,mywidth,BPL,LanType);
     Error:=IOResult;
     if Error <> 0 then
     begin
       close(F);
       WriteXgf:=Error;
       exit;
     end;
    end;
 end
 else
 begin
   For j:=y to y2 do
   begin
     For i:=1 to myWidth do
     begin
       MyLineBuf[i-1]:=IconImage[i+x-1,j];
     end;
     BlockWrite(F,MyLineBuf,myWidth);
   end;
 end;

 If (LanType = TPLan) OR (LanType=TCLan)  then
 begin
   Temp:='RM';
   BlockWrite(F,Temp,2);
 end;

 Close(F);
 WriteXgf:=IOResult;
{$I+}
end;

Procedure mpTOsp(Var mPlane : Linebuftype;Var splane : Linebuftype;
                 ImgOff2,ImgOff3,ImgOff4 : Word);
Var
 i,j    : Word;
 xpos : Word;
 Col  : Word;
begin
 xpos:=0;
 FillChar(splane,SizeOf(sPlane),0);
 For i:=0 to ImgOff2-1 do
 begin
   For j:=7 downto 0 do
   begin
     Col:=0;
     if biton(j,mPlane[i]) then
     begin
       Inc(Col,1);
     end;

     if biton(j,mPlane[i+ImgOff2]) then
     begin
       Inc(Col,2);
     end;

     if biton(j,mPlane[i+ImgOff3]) then
     begin
       Inc(Col,4);
     end;

     if biton(j,mPlane[i+ImgOff4]) then
     begin
       Inc(Col,8);
     end;

     Splane[xpos]:=Col;
     Inc(xpos);
   end;
 end;
end;

Function ReadICN(x,y,x2,y2 : Word;Filename : String) : Word;
Type
 XgfHead = Record
             Width  : Word;
             Height : Word;
           End;

Var
 uline,sline     : Linebuftype;
 myHead    : XgfHead;
 mywidth   : word;
 myheight  : word;
 myFSize,
 FSize16,
 Fsize256  : Longint;
 BPL,BitPlane2,BitPlane3,BitPlane4       : Word;
 F         : File;
 Error     : Word;
 Temp      : Word;
 J,I       : Word;
 ICN16     : Boolean;

begin
{$I-}
  Assign(F,Filename);
  Reset(F,1);
  myFSize:=FileSize(F);
  Error:=IORESULT;
  If Error<>0 then
  begin
    ReadICN:=Error;
    exit;
  end;


  BlockRead(F,myHead,sizeof(myHead));
  inc(myHead.width);
  inc(myHead.Height);

  myWidth:=x2-x+1;
  myheight:=y2-y+1;

  if myWidth > myHead.width then myWidth:=myHead.width;
  if myHeight > myHead.Height then myHeight:=myHead.Height;

  FSize16:=((myHead.width+7) div 8) * 4  * myhead.height+6;
  FSize256:=myHead.width * myhead.height+6;

  If myFSize=Fsize16 then
  begin
   ICN16:=TRUE;
   BPL:=((myHead.width+7) div 8) * 4;
   BitPlane2:=(BPL SHR 2);
   BitPlane3:=(BPL SHR 1);
   BitPlane4:=(BPL SHR 2) * 3;
  end
  else if myFSize=Fsize256 then
  begin
   ICN16:=FALSE;
   BPL:=LongInt(myHead.width)
  end
  else
  begin
   ReadICN:=1000;
   Close(F);
   Error:=IORESULT;
   exit;
  end;

  For j:=1 to myheight do
  begin
     If ICN16 then
     begin
       BlockRead(F,uline,BPL);
       For I:=0 to BitPlane2-1 do
       begin
         Temp:=Uline[I];
         Uline[I]:=Uline[I+BitPlane4];
         Uline[I+BitPlane4]:=Temp;
         Temp:=Uline[I+BitPlane2];
         Uline[I+BitPlane2]:=Uline[I+BitPlane3];
         Uline[I+BitPlane3]:=Temp;
       end;
       mpToSp(uline,sline,BitPlane2,BitPlane3,BitPlane4);
    end
    else
    begin
       BlockRead(F,sline,BPL);
    end;

    For i:=1 to myWidth do
    begin
       IconImage[x+i-1,y+j-1]:=sline[i-1];
    end;

  end;

  if (ICN16=FALSE) AND (GetMAxColor=15) then
  begin
    ReduceTo16;
  end;
  Close(F);
  Error:=IORESULT;
  ReadICN:=Error;
{$I+}
end;




Function WriteRaw(x,y,x2,y2 : Word;FileName : String) : Word;
Var
 Error,i ,j : Word;
    F : File;
 Width,Height,Colors : Word;
 Tbuf : array[1..100] of Byte;
  myPal : PaletteT;
begin
 Width:=x2-x+1;
 Height:=y2-y+1;
 Colors:=GetMaxColor+1;

 GrabPaletteList(myPal,Colors);

{$I-}
 Assign(F,FileName);
 Rewrite(F,1);
 BlockWrite(F,Width,2);
 BlockWrite(F,Height,2);
 BlockWrite(F,Colors,2);

 BlockWrite(F,myPal,Colors*3);

 For j:=y to y2 do
 begin
   For i:=1 to Width do
   begin
     Tbuf[i]:=IconImage[x+i-1,j];
   end;
   BlockWrite(F,TBuf,Width);
   Error:=IORESULT;
   If Error<>0 then
   begin
     WriteRaw:=Error;
     Exit;
   end;
 end;

 Close(F);
 Error:=IORESULT;
 WriteRaw:=Error;
{$I+}
end;

Function ReadRaw(x,y,x2,y2,pal : Word;FileName : String) : Word;
Var
 Error,i ,j : Word;
    F : File;
 Width,Height,Colors : Word;
 myWidth,myHeight : Word;
 Fcol : Byte;
 Tbuf : LineBufType;
  myPal : PaletteT;
 size,fsize  : LongInt;
begin
 myWidth:=x2-x+1;
 myHeight:=y2-y+1;
{$I-}
 Assign(F,FileName);
 Reset(F,1);
 Error:=IORESULT;
 if Error <>0 then
 begin
   ReadRaw:=Error;
   Exit;
 end;

 fsize:=FileSize(F);

 BlockRead(F,Width,2);
 BlockRead(F,Height,2);
 BlockRead(F,Colors,2);

 size:=LongInt(Width)*LongInt(Height)+LongInt(Colors*3)+6;
 if size<>fsize then
 begin
  Close(f);
  ReadRaw:=1000;
  Error:=IORESULT;
  Exit;
 end;
 If Colors > 0 Then
 begin
   BlockRead(F,myPal,Colors*3);
 end;
 If myHeight > Height then myHeight:=Height;
 if myWidth >  Width then myWidth:=Width;
 For j:=1 to myHeight do
 begin
   BlockRead(F,TBuf,Width);
   Error:=IORESULT;
   If Error<>0 then
   begin
     ReadRaw:=Error;
     Exit;
   end;
   For i:=1 to myWidth do
   begin
       IconImage[x+i-1,y+j-1]:=Tbuf[i-1];
   end;
 end;
 Close(F);
 If (GetMaxColor=15) AND (Colors>16) then
 begin
   ReduceTo16;
 end;
 if Colors > (GetMaxColor+1) then Colors:=GetMaxColor+1;
 If Pal=1 then
 begin
   If Colors > 0 Then SetPaletteList(myPal,Colors);
 end;
 Error:=IORESULT;
 ReadRaw:=Error;
{$I+}
end;


Function WritePAL(FileName : String): Word;
Var
 F : File;
  myPal : PaletteT;
 Colors : Word;
 Error : Word;
begin
{$I-}
 Colors:=GetMaxColor+1;
 GrabPaletteList(myPal,Colors);
 Assign(F,FileName);
 Rewrite(F,1);
 BlockWrite(F,myPAL,Colors*3);
 Close(F);
 Error:=IORESULT;
 WritePAL:=Error;
{$I+}
end;

Function ReadPAL(Filename : String) : Word;
Var
 F      : File;
 Fsize  : LongInt;
 Colors : word;
 Error  : Word;
  myPal : PaletteT;
begin
 Colors:=GetMaxCOlor+1;
 Assign(F,FileName);
 Reset(F,1);
 Fsize:=FIleSize(F);
 If (Fsize<>48) AND (Fsize<>768) then
 begin
  ReadPAL:=1000;
  Exit;
 end;
 BlockRead(F,myPAL,Fsize);
 Close(F);
 Error:=IORESULT;
 ReadPAl:=Error;
 If Error = 0 then
 begin
  If Colors > (Fsize div 3) then
  begin
    Colors:=(Fsize div 3);
  end;
  SetPaletteList(myPal,Colors);
 end;
end;

begin
end.