Unit Raw2XGF;

Interface
     Uses Dos,PCX2RAW;

Function RawToXgf(RawFileName,XgfFileName : String;MaxColors,CompLan: Word) : Word;

Implementation
Type
 LineBufType = Array[0..1023] Of Byte;
 ColorMap    = Array[0..15] of Byte;

Const
   TPLan   = 1;
   TCLan   = 2;
   QCLan   = 3;
   QBLan   = 4;
   PBLan   = 5;
   GWLan   = 6;

   BColorMap : ColorMap = (0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15);
   MSColorMap: ColorMap = (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);

Var
  DefaultColorMap : ColorMap;

 Function BitOn(Position,Testbyte : Byte) : Boolean;
 Var
  Bt : Byte;
 Begin
  Bt :=$01;
  Bt :=Bt Shl Position;
  Biton :=(Bt And Testbyte) > 0;
 End;

 Procedure SetBit(Position, Value : Byte; Var Changebyte : Byte);
 Var
  Bt : Byte;
 Begin
  Bt :=$01;
  Bt :=Bt Shl Position;
  If Value = 1 then
     Changebyte :=Changebyte Or Bt
  Else
   Begin
     Bt :=Bt Xor $FF;
     Changebyte :=Changebyte And Bt;
  End;
 End;

Function StackLine16(Width : Word;Var LineBuf    : LineBufType;
                                  Var StackedLine: LineBufType) : Word;
var
 nb    : Word;
 x     : Word;
 np    : Word;
 cl    : Byte;
 cb    : Byte;
 cp    : Word;
 lof   : Word;
 lof2  : Word;
 lof3  : Word;
 lof4  : Word;
 J     : Word;
 xp    : Word;
begin
 nb :=(Width+7) div 8;
 FillChar(StackedLine,nb*4,0);
 lof :=0;
 lof2:=nb;
 lof3:=nb*2;
 lof4:=nb*3;
 xp:=0;
 cp:=0;
  for x:=0 to nb-1 do
    begin
      for j:=0 to 7 do
      begin
          cl:=DefaultColorMap[LineBuf[xp+j]];
          Case biton(3,cl) Of True: Setbit((7-j),1,Stackedline[lof4+cp]) End;
          Case biton(2,cl) Of True: Setbit((7-j),1,StackedLine[lof3+cp]) End;
          Case biton(1,cl) Of True: Setbit((7-j),1,StackedLine[lof2+cp]) End;
          Case biton(0,cl) Of True: Setbit((7-j),1,StackedLine[lof+cp])  End;
      end;
      inc(cp);
      inc(xp,8);
    end;
StackLine16:=nb*4;
end;

Procedure Pack4(Col1,Col2,Col3,Col4 : byte;Var PCol:byte);
begin
 col1:=col1 shl 6;
 col2:=col2 shl 6;
 col2:=col2 shr 2;
 col3:=col3 shl 6;
 col3:=col3 shr 4;
 col4:=col4 shl 6;
 col4:=col4 shr 6;
 Pcol:=col1+col2+col3+col4;
end;

Function PackLine4(Width : Word;Var LineBuf    : LineBufType;
                                Var PackedLine : LineBufType) : Word;
Var
 Count  : Word;
 I      : Word;
 C2     : Word;
Begin
 Count  :=0;
 I      :=0;
 For I:=0 To ((Width+3) Div 4)-1 Do
 Begin
   Pack4(LineBuf[Count],LineBuf[Count+1],LineBuf[Count+2],LineBuf[Count+3],
         PackedLine[I]);
   Inc(Count,4);
 End;
 PackLine4:=(Width+3) Div 4;
End;


Function StackLine2(Width : Word;Var LineBuf    : LineBufType;
                                 Var StackedLine: LineBufType) : Word;
var
 nb    : Word;
 x     : Word;
 np    : Word;
 cl    : Byte;
 cb    : Byte;
 cp    : Word;
 lof   : Word;
 J     : Word;
 xp    : Word;
begin
 nb :=(Width+7) div 8;
 FillChar(StackedLine,nb,0);
 lof :=0;
 xp:=0;
 cp:=0;
  for x:=0 to nb-1 do
    begin
      for j:=0 to 7 do
      begin
          cl:=LineBuf[xp+j];
          Case biton(0,cl) Of True: Setbit((7-j),1,StackedLine[lof+cp])  End;
      end;
      inc(cp);
      inc(xp,8);
    end;
StackLine2:=nb;
end;


Function ShouldPad(Width,Height,Ncolors : Word) : Boolean;
Var
 Temp : Word;
begin
 ShouldPad:=False;
 Case Ncolors of 2,16 : Temp:=((Width+7) div 8)*Height;
                 4    : Temp:=((Width+3) div 4)*Height;
                256   : Temp:=Width*Height;
 End;
 If Odd(Temp) then ShouldPad:=True;
end;



Function RawToXgf(RawFileName,XgfFileName : String;MaxColors,CompLan: Word) : Word;
Const
 Dummy : Word = 0;
Var
 RawFile,XgfFile : File;
 MyWidth,MyHeight: Word;
 Error           : Word;
 MyCol           : Word;
 RawLine         : LineBufType;
 FormatedLine    : LineBufType;
 J               : Word;
 Nb              : Word;
 t               : Word;
 myPal           : Array[1..768] of byte;
begin
 DefaultColorMap:=MSColorMap;
 Assign(RawFile,RawFileName);
 Reset(RawFile,1);

 BlockRead(RawFile,MyWidth,2);
 BlockRead(RawFile,MyHeight,2);
 BlockRead(RawFile,MyCol,2);
 Blockread(RawFile,myPal,myCol*3);

 Assign(XgfFile,XgfFilename);
 Rewrite(XgfFile,1);

 Case CompLan of
    TPLan,TCLan:begin
                Dec(MyWidth);
                Dec(MyHeight);

                BlockWrite(XgfFile,MyWidth,2);
                BlockWrite(XgfFile,MyHeight,2);

                Inc(MyWidth);
                Inc(MyHeight);

                case MaxColors of 16 : DefaultColorMap:=BColorMAp; End;
               end;
   GWLan,QCLan,QBLan,PBLan:begin
                If MaxColors=256 then
                begin
                  T:=MyWidth SHL 3;
                  BlockWrite(XgfFile,T,2);
                end
                else
                begin
                  BlockWrite(XgfFile,MyWidth,2);
                end;

                BlockWrite(XgfFile,MyHeight,2);
                If (MaxColors=16) then DefaultColorMap:=MSColorMap;
                If (MaxColors=16) And (CompLan=PBLan) then DefaultColorMap:=BColorMAp;

               end;
 end;

 Write('            RAW To XGF. Processing Line:     ');

 For J:=1 to MyHeight Do
 begin
   Write(#8,#8,#8,#8);
   Write(J:4);
   Case MaxColors of 256:begin
                          BlockRead(RawFile,RawLine,MyWidth);
                          BlockWrite(XgfFile,RawLine,MyWidth);
                         end;
                      16:begin
                          BlockRead(RawFile,RawLine,MyWidth);
                          Nb:=StackLine16(MyWidth,RawLine,FormatedLine);
                          BlockWrite(XgfFile,FormatedLine,Nb);
                         end;
                       4:begin
                          BlockRead(RawFile,RawLine,MyWidth);
                          Nb:=PackLine4(MyWidth,RawLine,FormatedLine);
                          BlockWrite(XgfFile,FormatedLine,Nb);
                         end;
                       2:begin
                          BlockRead(RawFile,RawLine,MyWidth);
                          Nb:=StackLine2(MyWidth,RawLine,FormatedLine);
                          BlockWrite(XgfFile,FormatedLine,Nb);
                         end;

   end;
   Error:=IOResult;
   If Error<>0 then
   begin
     RawToXgf:=Error;
     Close(RawFile);
     Close(XgfFile);
     Exit;
   End;

 end;
 WriteLn;

 Case CompLan of TPLan,TCLan: BlockWrite(XgfFile,Dummy,2);
                 GWLan,QBLan,PBLan:
                   If ShouldPad(MyWidth,MyHeight,MaxColors) then
                   begin
                     BlockWrite(XgfFile,Dummy,1);
                   end;
 End;

 Close(RawFile);
 Close(XgfFile);
end;

begin
end.
