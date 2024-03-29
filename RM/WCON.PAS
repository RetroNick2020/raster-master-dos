Unit Wcon;
 Interface
     uses vars,dos,Graph,rwXGF,WPRF,Xgf2src;
 Function WriteDat(x,y,x2,y2,myFormat,LanType : word; filename : string) : word;

 Implementation

Function WriteDat(x,y,x2,y2,myFormat,LanType : word;filename:string):word;
Var
 mywidth : word;
 myheight: word;
 F       : File;
 Error   : Word;
begin
{$I+}
 myWidth:=x2-x+1;
 myHeight:=y2-y+1;

 If myFormat=SPRSource then
 begin
   error:=WriteSPR(x,y,x2,y2,'$$$$.tmp');
 end
 else if myFormat=PPRSource then
 begin
   error:=WritePPR(x,y,x2,y2,'$$$$.tmp');
 end
 else if myFormat=PALSource then
 begin
   error:=WritePAL('$$$$.tmp');
 end
 else
 begin
   error:=writeXgf(x,y,x2,y2,LanType,'$$$$.tmp');
 end;

 if Error<>0 then
 begin
   WriteDat:=Error;
   exit;
 end;

 error:=XgfToSrc('$$$$.tmp',filename,myWidth,myHeight,GetMaxColor+1,myFormat,Lantype);
 Assign(f,'$$$$.tmp');
 Erase(F);

 WriteDAT:=error;
 Error:=IORESULT;

{$I+}
end;



begin
end.