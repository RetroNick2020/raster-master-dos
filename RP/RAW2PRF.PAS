Unit RAW2PRF;
 Interface
     uses Dos;
Function RawToSpr(RawFile, SprFile : string) : word;
Function RawToPPR(RawFile,PPRfile:string):word;

 Implementation
Function RawToSpr(RawFile, SprFile : string) : word;
Var
 f: file;
 f2: file;
 rc:byte;
 i,j : word;
 col : byte;
 lastcol:byte;
 myWidth:word;
 myHeight:word;

 error       : word;
 myRawWidth  : Word;
 myRawheight : Word;
 myRawCol    : byte;
 myDumWord   : Word;
 myFsize     : longint;
 myBuf       : Array[1..1024] of byte;
 mySprHeader : Array[1..16] of byte;
 myPal       : Array[1..768] of byte;
begin
{$I-}

 Assign(F2,RawFile);
 Reset(F2,1);

 Blockread(F2,myRawWidth,2);
 Blockread(F2,myRawHeight,2);
 Blockread(F2,myDumWord,2);
 Blockread(F2,myPal,myDumWord*3);

 FillChar(mySprHeader,16,0);

 mySprHeader[1]:=ORD('S');
 mySprHeader[3]:=ORD('P');
 mySprHeader[5]:=ORD('R');

 mySprHeader[7]:=HI(myRawWidth);
 mySprHeader[9]:=LO(myRawWidth);

 mySprHeader[11]:=HI(myRawHeight);
 mySprHeader[13]:=LO(myRawHeight);

 mySprHeader[15]:=8;

 assign(F,SprFile);
 rewrite(f,1);
 BlockWrite(F,mySprHeader,16);
 rc:=0;

 Write('            RAW To SPR. Processing Line:     ');


 for j:=myrawHeight downto 1 do
 begin
   Write(#8,#8,#8,#8);
   Write((myrawHeight-J+1):4);

   myFsize:=6+(mydumword*3)+(LongInt(J)-1)*LongInt(myRawWidth);
   Seek(F2,myFsize);
   BlockRead(F2,myBuf,myRawWidth);

   for i:=1 to myRawWidth do
   begin
                              (*  BlockRead(F2,col,1);*)
     Col:=myBuf[i];
     inc(rc);
     if rc=1 then
     begin
       Lastcol:=col;
     end
     else if col<>lastcol then
     begin
       Blockwrite(f,lastcol,1);
       dec(rc);
       Blockwrite(f,rc,1);
       rc:=1;
       lastcol:=col;
     end
     else if rc=255 then
     begin
      blockwrite(f,col,1);
      blockwrite(f,rc,1);
      rc:=0;
     end;
   end;
   Error:=IORESULT;
   If Error<>0 then
   begin
     RawToSPr:=Error;
     Exit;
   end;
  end;

  if rc>0 then
  begin
    blockwrite(f,col,1);
    blockwrite(f,rc,1);
  end;
 WriteLn;
 Close(F);
 Close(F2);
 error:=ioresult;
 RawToSpr:=error;
{$I+}
end;

Function RawToPPR(RawFile,PPRfile:string):word;
Var
 f: file;
 F2 : File;
 rc:byte;
 i,j : word;
 col : byte;
 lastcol:byte;
 myWidth:word;
 myHeight:word;
 nc : byte;
 cl      : array[1..3] of byte;
 myRawWidth : Word;
 myRawheight: Word;
 myRawCol   : byte;
 myDumWord  : Word;
 myFsize    : longint;
 myBuf      : Array[1..1024] of byte;
 myPprHeader : Array[1..24] of byte;
 myColors : Word;
 error : word;
 myPal       : Array[1..768] of byte;
begin
{$I-}
 Assign(F2,RawFile);
 Reset(F2,1);

 Blockread(F2,myRawWidth,2);
 Blockread(F2,myRawHeight,2);
 Blockread(F2,myDumWord,2);
 Blockread(F2,myPal,myDumWord*3);

 FillChar(myPprHeader,24,0);

 myPprHeader[1]:=ORD('P');
 myPprHeader[4]:=ORD('P');
 myPprHeader[7]:=ORD('R');

 myPprHeader[10]:=HI(myRawWidth);
 myPprHeader[13]:=LO(myRawWidth);

 myPprHeader[16]:=HI(myRawHeight);
 myPprHeader[19]:=LO(myRawHeight);

 myPprHeader[22]:=4;


 assign(F,PPRfile);
 rewrite(f,1);
 BlockWrite(F,myPprHeader,24);

 nc:=0;
 rc:=0;
 fillchar(cl,3,0);


 Write('            RAW To PPR. Processing Line:     ');

 for j:=myrawHeight downto 1 do
 begin
   Write(#8,#8,#8,#8);
   Write((myrawHeight-J+1):4);

   myFsize:=6+(mydumword*3)+(LongInt(J)-1)*LongInt(myRawWidth);
   Seek(F2,myFsize);
   BlockRead(F2,myBuf,myRawWidth);

   for i:=1 to myRawWidth do
   begin
     Col:=myBuf[i];
     inc(rc);
     if rc=1 then
     begin
       Lastcol:=col;
     end
     else if col<>lastcol then
     begin
       inc(nc);
       if nc=1 then
       begin
        cl[1]:=(lastcol shl 4);
        cl[2]:=rc-1;
       end
       else if nc=2 then
       begin
        inc(cl[1],lastcol);
        cl[3]:=rc-1;
        nc:=0;
        Blockwrite(f,cl[1],3);
        fillchar(cl,3,0);
       end;
       rc:=1;
       lastcol:=col;
     end
     else if rc=255 then
     begin
      inc(nc);
      if nc=1 then
      begin
       cl[1]:=(col shl 4);
       cl[2]:=rc;
      end
      else if nc=2 then
      begin
       inc(cl[1],col);
       cl[3]:=rc;
       nc:=0;
       blockwrite(f,cl[1],3);
       fillchar(cl,3,0);
      end;
      rc:=0;
     end;
   end;
   Error:=IORESULT;
   If Error<>0 then
   begin
     RawToPPr:=Error;
     Exit;
   end;

  end;
  if rc>0 then
  begin
      if nc=0 then
      begin
       cl[1]:=(col shl 4);
       cl[2]:=rc;
       cl[3]:=0;
      end
      else
       begin
        inc(cl[1],col);
        cl[3]:=rc;
      end;
    blockwrite(f,cl,3);
  end;
 WriteLn;
 close(F);
 Close(F2);
 error:=IOresult;
 RawToPPR:=error;
{$I+}
end;

begin
end.
