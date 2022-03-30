Unit RMSTRG;

Interface

Function StrHex(Num : longint;Field : byte) : String;
Function ValBin(S:String;VAR code : integer) : Longint;
function UpperCase(S : String) : string;


(*function _WrdPosL(S:string;Nth : byte) : byte;
  *)
Function Hex(i:LongInt; Lgt:Byte):String;
function Trim(S: string; DelChar : char): string;
function TrimL(S : String; DelChar : char) : string;
function TrimR(S : String; DelChar : char) : string;



function NextWord(S : String; Sep : string) : string;
function DeleteNextWord(S : String; Sep : string) : string;

Implementation

Function Hex(i:LongInt; Lgt:Byte):String;
  { Return i in hex with at least Lgt chars.
    Lgt is byte so I don't have to check for values > 255. If another
    type was used, and a value > 255 was passed in, the routine would
    loop indefinitely.
  }
Const
  HexDigs:Array[0..15] of Char = '0123456789ABCDEF';
Var
  s : String;
Begin
  s := '';
  Repeat
    s := HexDigs[i and $F] + s;
    i := i shr 4;
  until (i = 0) and (length(s) >= Lgt);
  Hex := s;
End;

Function StrHex(Num : longint;Field : byte) : String;
begin
 StrHex:=Hex(Num,Field);
end;

function bin2dec (s : string) : longint;
var
  tmp : longint;
  p : byte;
begin
  tmp := 0;
  for p := 1 to length(s) do
  begin
    inc(tmp,longint(ord(s[length(s)])-48) shl pred(p));
    dec(s[0]);
  end;
  bin2dec := tmp;
end;

Function ValBin(S:String;VAR code : integer) : Longint;
begin
 code:=0;
 ValBin:=Bin2Dec(S);
end;

function UpperCase(S : String) : string;
var
 i : byte;
begin
 for i:=1 to Length(S) do
 begin
  s[i] := UpCase(s[i]);
 end;
 UpperCase:=S;
end;

function TrimL(S : String; DelChar : char) : string;
begin
 while (Length(s) > 0) and (Pos(DelChar,S) = 1) Do
 begin
   Delete(S,1,1);
 end;
 TrimL:=S;
end;

function TrimR(S : String; DelChar : char) : string;
begin
 while (Length(s) > 0) and (S[Length(S)] = DelChar) Do
 begin
   Delete(S,Length(S),1);
 end;
 TrimR:=S;
end;


function Trim(S: string; DelChar : char): string;
begin
  S:=TrimL(S,DelChar);
  S:=TrimR(S,DelChar);
  Trim:=S;
end;

function NextWord(S : String; Sep : string) : string;
var
 npos : integer;
begin
 npos:=POS(sep,S);
 if npos = 0 then NextWord:=S else NextWord:=Copy(S,1,npos-1);
end;

function DeleteNextWord(S : String; Sep : string) : string;
var
 npos : integer;
begin
 npos:=POS(sep,S);
 if npos = 0 then
 begin
   DeleteNextWord:='';
 end
 else
 begin
  Delete(S,1,npos);
  DeleteNextWord:=S;
 end;
end;


(* finds position of word delimited by spaces *)
function _WrdPosL(S:string;Nth : byte) : byte;
begin
end;



begin
end.