Unit WMask;
Interface
 uses Dos,rmStrg,Vars,Bits,xgf2src;
Function WriteMouseMask(x,y,x2,y2,LanType: Word;Filename : String) : Word;

Implementation

Function WriteMouseMask(x,y,x2,y2,LanType: Word;Filename : String) : Word;
Var
 i,j : Word;
 Width,Height        : Word;
 Solid,Holow,TImage  : String[16];
 Count,Error         : Word;
 F : Text;
 MouseName : String;
 Mpos      : Word;
 MouseImage : Array[1..32] of String[16];
 TextImage  : Array[1..16] of String[16];
 Temp : Word;
 Code : Integer;

begin
 FileNameToImageName(FileName,MouseName);
 Width:=x2-x+1;
 Height:=y2-y+1;
 If Width > 16 then Width:=16;
 if Height > 16 then Height:=16;
 Count:=0;


 For j:=y to y+15 do
 begin
   Solid :='1111111111111111';
   Holow :='0000000000000000';
   TImage:='                ';
   If (j <= y2) then
   begin
     For i:=1 to Width do
     begin
       If IconImage[i+x-1,j] = 0 then
       begin
         Solid[i]:='0';
         Holow[i]:='0';
         TImage[i]:='*';
       end
       else if IconImage[i+x-1,j]=15 then
       begin
         Solid[i]:='0';
         Holow[i]:='1';
         TImage[i]:='#';
       end
       else if IconImage[i+x-1,j]=1 then
       begin
         Solid[i]:='1';
         Holow[i]:='0';
         Timage[i]:=' ';
       end
       else
       begin
         Solid[i]:='1';
         Holow[i]:='1';
         TImage[i]:='X';
       end;
     end;
   end;
   Inc(Count);
   Temp:=ValBin(Solid,Code);
   MouseImage[Count]:=StrHex(Temp,4);
   Temp:=ValBin(Holow,Code);
   MouseImage[Count+16]:=StrHex(Temp,4);
   TextImage[Count]:=TImage;
 end;


{$I-}
 Assign(F,FileName);
 Rewrite(F);

 Case LanType Of TPLan:WriteLn(F,'(*');
                 TCLan:WriteLn(F,'/*');
 end;

 For i:=1 to 16 do
 begin
  if LanType=QBLan then Write(F,#39#32);
  WriteLn(F,TextImage[i]);
 end;


 Case LanType Of TPLan:begin
                        WriteLn(F,'Mouse Cursor Image *)');
                        WriteLn(F);
                        WriteLn(F,MouseName,' : Array[1..32] Of Word = (');
                        Write(F,' ':5);
                       End;
                 TCLan:begin
                        WriteLn(F,'Mouse Cursor Image */');
                        WriteLn(F);
                        WriteLn(F,'int ',MouseName,'[] = {');
                        Write(F,' ':5);
                       End;

                 QBLan:begin
                        WriteLn(F,#39,' Mouse Cursor Image');
                        WriteLn(F,#39,' ',MouseName);
                        WriteLn(F);
                        Write(F,'DATA ');
                       End;


 End;

 Count:=0;
 For i:=1 to 31 do
 begin
  Case LanType of TPLan: Write(F,'$',MouseImage[i],',');
                  TCLan: Write(F,'0x',MouseImage[i],',');
                  QBLan:begin
                          Write(F,'&H',MouseImage[i]);
                          if (i mod 8) <> 0 then write(F,',');
                        End;
  end;
  Inc(Count);
  If Count=8 then
  begin
   WriteLn(F);
   if LanType=QBLan then
   begin
    Write(F,'DATA ');
   end
   else
   begin
    Write(F,' ':5);
   end;
   Count:=0;
  end;
 End;
 Case Lantype of TPLan: WriteLn(F,'$',MouseImage[32],');');
                 TCLan: WriteLn(F,'0x',MouseImage[32],'};');
                 QBLan: WriteLn(F,'&H',MouseImage[32]);
 End;
 WriteLn(F);
 Close(F);
 Error:=IORESULT;
 WriteMouseMask:=Error;

end;


begin
end.