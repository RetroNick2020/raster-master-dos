Unit rKey;
 Interface
Type
 keyRec = Record
            UserName  : String[25];
            Address   : String[25];
            City      : String[25];
            State     : String[25];
            Country   : String[25];
            Zip       : String[25];
            Phone     : String[25];
            UserNum   : String[4];
            C1        : LongInt;
            C2        : LongInt;
            C3        : LongInt;
            C4        : LongInt;
            C5        : LongInt;
            C6        : LongInt;
            C7        : LongInt;
            C8        : LongInt;
            FC        : LongInt;
            Extra     : String[10];
          End;

Procedure CreateKey(Var zKey : KeyRec);
Procedure ReadKey(Var zKey : KeyRec;KeyFileName : String);
Procedure WriteKey(Var zKey : KeyRec;KeyFileName : String);
Function ValidKey(zKey : KeyRec) : Boolean;

Implementation
  uses dos;

Procedure CreateKey(Var zKey : KeyRec);
Var
 i : Word;
begin
  Write('Enter User Name: ');
  ReadLn(zKey.UserName);
  Write('Enter Adress: ');
  ReadLn(zKey.Address);
  Write('Enter City: ');
  ReadLn(zKey.City);
  Write('Enter State: ');
  ReadLn(zKey.State);
  Write('Enter Country: ');
  ReadLn(zKey.Country);
  Write('Enter Zip: ');
  ReadLn(zKey.Zip);
  Write('Enter Phone: ');
  ReadLn(zKey.Phone);

  Write('User Number: ');
  ReadLn(zKey.UserNum);

  zKey.C1:=2465;

  For i:=0 to 25 do
  begin
   zKey.C1:=zKey.C1+((((ORD(zKey.UserName[i])*43257)+69387)*3478)+34302);
  end;
  WriteLn(zKey.C1);

  zKey.C2:=12236;
  For i:=0 to 25 do
  begin
   zKey.C2:=zKey.C2+((((ORD(zKey.Address[i])*83952)+99307)*3546)+41322);
  end;
  WriteLn(zKey.C2);

  zKey.C3:=24465;
  For i:=0 to 25 do
  begin
   zKey.C3:=zKey.C3+((((ORD(zKey.City[i])*83257)+28387)*1428)+14301);
  end;
  WriteLn(zKey.C3);

  zKey.C4:=2465;
  For i:=0 to 25 do
  begin
   zKey.C4:=zKey.C4+((((ORD(zKey.State[i])*23437)+99457)*433)+74312);
  end;
  WriteLn(zKey.C4);

  zKey.C5:=32465;
  For i:=0 to 25 do
  begin
   zKey.C5:=zKey.C5+((((ORD(zKey.Zip[i])*83467)+48367)*21488)+4312);
  end;
  WriteLn(zKey.C5);

  zKey.C6:=23465;
  For i:=0 to 25 do
  begin
   zKey.C6:=zKey.C6+((((ORD(zKey.Phone[i])*267)+92979)*4183)+33121);
  end;
  WriteLn(zKey.C6);

  zKey.C7:=23;
  For i:=0 to 4 do
  begin
   zKey.C7:=zKey.C7+((((ORD(zKey.UserNum[i])*7)+379)*43)+321);
  end;
  WriteLn(zKey.C7);

  zKey.C8:=2265;
  For i:=0 to 25 do
  begin
   zKey.C8:=zKey.C8+((((ORD(zKey.Country[i])*23447)+99497)*433)+74312);
  end;
  WriteLn(zKey.C8);

end;

Procedure WriteKey(Var zKey : KeyRec;KeyFileName : String);
Var
 F : File;
 tempBuf : Array[1..256] of Byte;
 i : WOrd;
 Error : Word;
begin
 Move(zKey,tempBuf,SizeOf(KeyRec));
 For i:=1 to 256 do
 begin
   tempBuf[i]:=256-tempBuf[i];
 end;
{$I-}
 Assign(F,KeyFileName);
 Rewrite(F,1);
 BlockWrite(F,tempBuf,256);
 Close(F);
 Error:=IORESULT;
{$I+}
End;

Procedure ReadKey(Var zKey : KeyRec;KeyFileName : String);
Var
 F : File;
 tempBuf : Array[1..256] of Byte;
 i : Word;
 Error : Word;
begin
{$I-}
 Assign(F,KeyFileName);
 Reset(F,1);
 BlockRead(F,tempbuf,256);
 Close(F);
 Error:=IORESULT;
{$I+}
 For i:=1 to 256 do
 begin
   tempBuf[i]:=256-tempBuf[i];
 end;
 Move(tempBuf,zKey,SizeOf(KeyRec));
End;

Function ValidKey(zKey : KeyRec) : Boolean;
Var
 C1,C2,C3,
 C4,C5,C6,
 C7,C8        : LongInt;
 i         : Word;
begin
  ValidKey:=False;

  C1:=2465;
  For i:=0 to 25 do
  begin
   C1:=C1+((((ORD(zKey.UserName[i])*43257)+69387)*3478)+34302);
  end;

  C2:=12236;
  For i:=0 to 25 do
  begin
   C2:=C2+((((ORD(zKey.Address[i])*83952)+99307)*3546)+41322);
  end;

  C3:=24465;
  For i:=0 to 25 do
  begin
   C3:=C3+((((ORD(zKey.City[i])*83257)+28387)*1428)+14301);
  end;

  C4:=2465;
  For i:=0 to 25 do
  begin
   C4:=C4+((((ORD(zKey.State[i])*23437)+99457)*433)+74312);
  end;

  C5:=32465;
  For i:=0 to 25 do
  begin
   C5:=C5+((((ORD(zKey.Zip[i])*83467)+48367)*21488)+4312);
  end;

  C6:=23465;
  For i:=0 to 25 do
  begin
   C6:=C6+((((ORD(zKey.Phone[i])*267)+92979)*4183)+33121);
  end;

  C7:=23;
  For i:=0 to 4 do
  begin
   C7:=C7+((((ORD(zKey.UserNum[i])*7)+379)*43)+321);
  end;

  C8:=2265;
  For i:=0 to 25 do
  begin
   C8:=C8+((((ORD(zKey.Country[i])*23447)+99497)*433)+74312);
  end;

  If (zKey.C1 = C1) AND (zKey.C2 = C2) AND (zKey.C3 = C3) AND (zKey.C4 = C4)
  AND (zKey.C5 = C5) AND (zKey.C6 = C6) AND (zKey.C7 = C7) AND (zKey.C8 = C8)  then
  begin
    ValidKey:=True;
    exit;
  end;
  ValidKey:=False;
End;

begin
end.