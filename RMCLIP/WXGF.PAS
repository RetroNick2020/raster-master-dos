Unit wXgf;
Interface
     uses xgraph,graph,bits;

Function WriteXgf(x,y,x2,y2,LanType :Word;Filename : String) : Word;
Function ReadICN(x,y,x2,y2 : Word;Filename : String) : Word;


Implementation

type
 linebuftype = array[0..1023] of byte;


Function WriteXgf(x,y,x2,y2,LanType :Word;Filename : String) : Word;
Type
 ImgRec = Array[1..$FFFF] of Byte;

Var
 myWidth,myHeight : Word;
 F : File;
 Error : Word;
 BytesPerLine : Word;
 size  : LongInt;
 ImgBuf         : ^ImgRec;
 i,j      : Word;
 BitPlane2,bitPlane3,BitPlane4 : Word;
 temp  : byte;
 Uline : array[0..2047] of byte;
 sig   : array[1..2] of char;
begin
 Error:=0;
 Size:=xgraph.imagesize(x,0,x2,0);
 BytesPerLine:=Size-6;

 myWidth:=x2-x+1;
 myHeight:=y2-y+1;


 If (GetMaxColor=15) and (lantype=2) then
 begin
   BitPlane2:=(BytesPerLine SHR 2);
   BitPlane3:=(BytesPerLine SHR 1);
   BitPlane4:=(BytesPerLine SHR 2) * 3;
 end;


 If (LanType=1) then
 begin
   Dec(mywidth,1);
   Dec(myheight,1);
 end
 else if (GetMaxColor=255) and (LanType=2) then
 begin
     myWidth:=mywidth*8;
 end;

{$I-}
 Assign(F,FileName);
 Rewrite(F,1);
 Error:=IOResult;
 If Error <> 0 then
 begin
   WriteXgf:=Error;
   exit;
 end;
 BlockWrite(F,myWidth,2);
 BlockWrite(F,myHeight,2);
 GetMem(imgBuf,size);
 For i:=y to y2 do
 begin
    GetImage(x,i,x2,i,ImgBuf^);
    Move(ImgBuf^[5],ULine[0],BytesPerLine);

    if (LanType=2) AND (GetMaxColor=15) then
    begin
     For j:=0 to BitPlane2-1 do
     begin
       Temp:=Uline[j];
       Uline[j]:=Uline[j+BitPlane4];
       Uline[j+BitPlane4]:=Temp;
       Temp:=Uline[j+BitPlane2];
       Uline[j+BitPlane2]:=Uline[j+BitPlane3];
       Uline[j+BitPlane3]:=Temp;
     end;
    end;
    BlockWrite(F,uline,BytesPerLine);
    Error:=IOResult;
    If Error <> 0 then
    begin
      WriteXgf:=Error;
      FreeMem(ImgBuf,size);
      exit;
    end;
 end;
 if Lantype=1 then
 begin
   Sig:='RM';
   BlockWrite(F,sig,sizeof(sig));
 end;
 Close(F);
 Error:=IOResult;
{$I+}
 If Error <> 0 then
 begin
   WriteXgf:=Error;
   FreeMem(ImgBuf,size);
   exit;
 end;
 WriteXgf:=Error;
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
       PutPixel(x+i-1,y+j-1,sline[i-1]);
    end;

  end;

  Close(F);
  Error:=IORESULT;
  ReadICN:=Error;
{$I+}
end;



begin
end.