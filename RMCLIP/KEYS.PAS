Unit Keys;

Interface
   Uses Crt;

const
 EscKey    = 27;
 TabKey    = 9;
 Leftkey   = 19200;
 Rightkey  = 19712;
 UpKey     = 18432;
 DownKey   = 20480;
 DeleteKey = 21248;
 InsKey    = 20992;
 BackSpace = 8;
 HomeKey   = 18176;
 Endkey    = 20224;
 EnterKey  = 13;
 PgUpKey   = 18688;
 PgDownKey = 20736;
 F1Key     = 15104;
 F2Key     = 15360;
 F3Key     = 15616;
 F4Key     = 15872;

Function GetKey : Word;

Implementation

Function GetKey : Word;
var
 key  :char;
 key2 :word;
begin
 Repeat until keypressed = true;
 key:=readkey;
 case key of #0:begin
                 key    := readkey;
                 Key2   := ord(key);
                 getkey := (key2 shl 8);
                 exit;
                end;
 else
   getkey:=ord(key);
   exit;
 end;
end;

end.