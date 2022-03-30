Unit bgiEdit;
Interface

Procedure EditString(x,y,visibleColumns: Integer;Var cursorState: integer;BackColor,
                     forColor,curColor, mouseState : Integer;Var msg : String);
Implementation
 uses dos,crt,graph,bgiMouse,keys;

Procedure EditString(x,y,visibleColumns: Integer;Var cursorState: integer;BackColor,
                     forColor,curColor, mouseState : Integer;Var msg : String);

Const
 FWidth       = 8;
 FHeight      = 9;
 flash        : Boolean = True;
var
 myKey        : Word;
 tempString   : String;
 offset       : Integer;
 Pos          : Integer;
 originalString : String;

Procedure ShowCursor;
begin
 SetFillStyle(SolidFill,curColor);
 Case cursorState of 0:begin
                        Bar(x+(pos*FWidth)-FWidth,y,x+(pos*FWidth)-2,y+FHeight);
                        if length(msg) >0 then
                        begin
                         Setcolor(backColor);
                         OutTextXY(x+(pos*FWidth)-FWidth,y,msg[Pos+offset]);
                        end;

                       end;
                     1:begin
                        Bar(x+(pos*FWidth)-FWidth,y+FHeight-1,
                            x+(pos*FWidth)-2,y+FHeight);
                     (*
                         if length(msg) >0 then
                         begin
                           Setcolor(backColor);
                           OutTextXY(x+(pos*FWidth)-FWidth,y,msg[Pos+offset]);
                        end;
                       *)
                       end;
 end;

end;

Procedure HideCursor;
begin
 SetFillStyle(SolidFill,backColor);
 Case cursorState of 0:begin
                        Bar(x+(pos*FWidth)-FWidth,
                        y,x+(pos*FWidth)-2,
                        y+FHeight);
                        Setcolor(forColor);
                        OuttextXY(x+(pos*FWidth)-FWidth,y,
                        msg[Pos+offset]);
                      end;
                    1:begin
                        Bar(x+(pos*FWidth)-FWidth,
                        y+FHeight-1,
                        x+(pos*FWidth)-2,
                        y+FHeight);
                      end;
 end;
end;

Procedure ClearEditBox;
begin
 SetFillStyle(SolidFill,BackColor);
 Bar(x,y,x+(visibleColumns*FWidth)-2,y+FHeight);
end;

Procedure HomeKeyAction;
begin
 if (pos+offset)<>1 then
 begin
  pos:=1;
  offset:=0;
  tempstring:=copy(msg,offset+1,visiblecolumns);

  if mouseState=1 then MouseHide;
  clearEditBox;
  Setcolor(forColor);
  OuttextXY(x,y,tempstring);
  showcursor;
  if mouseState=1 then MouseShow;

 end;
end;

Procedure EndKeyAction;
begin
 if (pos+offset) <> length(msg) then
 begin
  if length(msg) > visibleColumns then
  begin
   pos:=visibleColumns;
   offset:=length(msg)-pos;
  end
  else
  begin
   pos:=length(msg);
   offset:=0;
  end;
  tempstring:=copy(msg,offset+1,visiblecolumns);

  if mouseState=1 then MouseHide;
  clearEditBox;
  Setcolor(forColor);
  OuttextXY(x,y,tempstring);
  showcursor;
  if mouseState=1 then MouseShow;
 end;
end;

Procedure LeftKeyAction;
begin
 if (pos > 1) then
 begin
  if mouseState=1 then MouseHide;
  hidecursor;
  dec(pos);
  showcursor;
  if mouseState=1 then MouseShow;
 end
 else if ((pos=1) AND (offset>0)) then
 begin
  dec(offset);
  tempstring:=copy(msg,pos+offset,visibleColumns);
  if mouseState=1 then MouseHide;
  cleareditbox;
  Setcolor(forColor);
  OuttextXY(x,y,tempstring);
  showcursor;
  if mouseState=1 then MouseShow;
 end;
end;

Procedure RightKeyAction;
begin
 if Length(msg)<>0 then
 begin
  if (pos < visibleColumns) then
  begin
   if length(msg) > (pos+offset) then
   begin
    if mouseState=1 then MouseHide;
    hidecursor;
    inc(pos);
    showcursor;
    if mouseState=1 then MouseShow;
   end;
  end
  else if ((pos+offset)< Length(msg)) then
  begin
   inc(offset);
   tempstring:=copy(msg,offset+1,visiblecolumns);
   if mouseState=1 then MouseHide;
   clearEditBox;
   Setcolor(forColor);
   OutTextXY(x,y,tempstring);
   showcursor;
   if mouseState=1 then MouseShow;
  end;
 end;
end;

Procedure DelKeyAction;
begin
 if length(msg)<>0 then
 begin
  delete(msg,pos+offset,1);
  if (pos+offset) > length(msg) then
  begin
   if offset > 0 then
   begin
    dec(offset);
   end
   else if pos > 1 then
   begin
    dec(pos);
   end;
  end;
  if mouseState=1 then MouseHide;
  clearEditBox;
  if length(msg)<>0 then
  begin
   tempstring:=copy(msg,offset+1,visiblecolumns);
   Setcolor(forColor);
   OuttextXY(x,y,tempstring);
   showcursor;
  end;
  if mouseState=1 then MouseShow;
 end;
end;

Procedure BackKeyAction;
begin
 if length(msg)>1 then
 begin
  delete(msg,pos+offset-1,1);
  if pos > 1 then
  begin
   dec(pos);
  end
  else if offset>0 then
  begin
   dec(offset);
  end;
  tempstring:=copy(msg,offset+1,visiblecolumns);
  if mouseState=1 then MouseHide;
  clearEditBox;
  Setcolor(forColor);
  OuttextXY(x,y,tempstring);
  showcursor;
  if mouseState=1 then MouseShow;
 end;
end;

Procedure CharKeyAction;
begin
 if length(msg)<>0 then
 begin
 if ((pos+offset)<>length(msg)) AND (cursorState=0) then
 begin
  msg[pos+offset]:=chr(mykey);
 end
 else
 begin
  insert(chr(mykey),msg,pos+offset);
 end;
 end
 else
 begin
  insert(chr(mykey)+#32,msg,pos+offset);
 end;
 if (pos <visiblecolumns) then
 begin
  inc(pos);
 end
 Else
 begin
  inc(offset);
 end;
 tempstring:=copy(msg,offset+1,visiblecolumns);
 if mouseState=1 then MouseHide;
 clearEditBox;
 Setcolor(forColor);
 OuttextXY(x,y,tempstring);
 showcursor;
 if mouseState=1 then MouseShow;
end;

Procedure FlashCursor;
Var
 h,m,s,sec100 : Word;
begin
 gettime(h,m,s,sec100);
 if (sec100<50) then
 begin
  if not Flash then
  begin
   if mouseState=1 then MouseHide;
   ShowCursor;
   if mouseState=1 then MouseShow;
   Flash:=True;
  end;
 end
 else
 begin
  if Flash then
  begin
   if mouseState=1 then MouseHide;
   hidecursor;
   if mouseState=1 then MouseShow;
   flash:=false;
  end;
 end;
end;


Function LKey : Boolean;
Var
 my,mx,st : Integer;
begin
 LKey:=false;
 MouseGetStatus(st,my,mx);
 if st=1 then LKey:=True;
end;

Procedure LKeyAction;
Var
 my,mx,st : Integer;
 ppos     : Word;
begin
 MouseGetStatus(st,my,mx);
   ppos:=((mx-x) div FWidth)+1;
   if ((pos+offset)<>ppos) then
   begin
    if (ppos > visiblecolumns) or (ppos<0) then exit;
    if ppos>length(msg) then ppos:=length(msg);
    MouseHide;
    hidecursor;
    pos:=ppos;
    showcursor;
    MouseShow;
   end;
   Repeat  Until LKey=False;
end;

Function IsInEditBox : Boolean;
Var
 my,mx,st : Integer;
begin
 IsInEditBox:=False;
   MouseGetStatus(st,my,mx);
 if (mx>x-2) and (my>y-2) and (mx <x+(visibleColumns*FWidth+2)) and
    (my < y+FHeight+1) then
 begin
  IsInEditBox:=true;
 end;
end;




begin
 if length(msg) = 0 then msg:=#32;
 originalstring:=msg;
 if mouseState=1 then MouseHide;
 ClearEditBox;
 if mouseState=1 then MouseShow;

 offset:=0;
 Pos:=0;
 HomeKeyAction;

 Repeat
  While not keypressed do
  begin
   If mouseState = 1 then
   begin
   If LKey then
   begin
    if isInEditBox=true then
    begin
     LKeyAction;
      (*Repeat until not LKey;*)
    end
    else
    begin
     HomeKeyAction;
     MouseHide;
     hidecursor;
     MouseShow;
     Exit;
    end;
   end;
   end;
   FlashCursor;
  end;

  myKey:=getkey;
  Case myKey of HomeKey:begin  (* home key *)
                    HomeKeyAction;
                   end;
                LeftKey:begin   (* left key *)
                    LeftKeyAction;
                   end;
                RightKey:begin  (* right arrow *)
                    RightKeyAction;
                   end;
                EndKey:begin (*end key *)
                    EndKeyAction;
                   end;
                InsKey:begin (*ins key *)
                    if mouseState=1 then MouseHide;
                    hidecursor;
                    CursorState:=abs(1-CursorState);
                    showcursor;
                    if mouseState=1 then MouseShow;
                   end;
                DeleteKey:begin (* del key *)
                    DelKeyAction;
                   end;

  end;

  Case mykey of  BackSpace:begin  (* backspace *)
                    BackKeyAction;
                   end;
                EnterKey:begin  (* Enter Key *)
                    HomeKeyAction;
                    if mouseState=1 then MouseHide;
                    hidecursor;
                    if mouseState=1 then MouseShow;
                    Exit;
                   end;
                EscKey:begin (* Esc Key *)
                    msg:=originalString;
                    pos:=0;
                    offset:=0;
                    HomeKeyAction;
                    if mouseState=1 then MouseHide;
                    hidecursor;
                    if mouseState=1 then MouseShow;
                    exit;
                   end;
           32..255:begin (* all the other key *)
                     CharKeyAction;
                   end;
   end;
 until (1=0); (* Enter key *)
end;


begin
end.