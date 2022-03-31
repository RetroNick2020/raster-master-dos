Unit wXgf;
Interface
     uses xgraph,graph;

Function WriteXgf(x,y,x2,y2,LanType :Word;Filename : String) : Word;


Implementation
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
 temp : byte;
 Uline : array[0..2047] of byte;
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
 else
 begin
   If GetMaxColor=255 then
   begin
     myWidth:=mywidth*8;
   end;
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


begin
end.