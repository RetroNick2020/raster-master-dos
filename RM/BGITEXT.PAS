Unit bgiText;
 Interface
Procedure ShadowText(x,y : Word;TextStr : String);
 Implementation
    uses Graph;

Procedure ShadowText(x,y : Word;TextStr : String);
begin
 SetColor(White);
 OutTextXY(x+1,y,TextStr);
 SetColor(Black);
 OutTextXY(x,y,TextStr);
end;

begin
end.