unit bgiMouse;

{ This unit defines an object type mouse_object that provides mouse     }
{ support for Turbo Pascal 5.5 programs.  The routines have been tested }
{ with a MicroSoft serial mouse.  I created this as an educational      }
{ experience for myself in object oriented programming.  If you have    }
{ suggestions or enhancements feel free to contact me.                  }
{                                                                       }
{       Benjamin R Peart                                                }
{       735 N 400 E #29                                                 }
{       Provo, UT  84606                                                }
{       CIS 76645,1041.                                                 }
{                                                                       }
{ If there is any interest in a joystick object and a keyboard object   }
{ that would provide routines similar to those available in the mouse   }
{ object let me know.                                                   }

interface

uses Dos;

        function  MouseExists : boolean;
        { check if a mouse driver is currently loaded           }

        function  MouseNumberOfButtons : integer;
        { returns the number of available buttons on the mouse  }

        procedure MouseReset;
        { reset the mouse driver to its defaults                }

        procedure MouseShow;
        { Makes the mouse cursor visible.                       }

        procedure MouseHide;
        { Makes mouse cursor invisible. Movement and button activity are        }
        { still tracked.                                                        }

        procedure MouseGetStatus(var status, row, column : integer);
        { Get mouse position and status.  Gives button status and       }
        { current position.  status:    1 = left button pressed,        }
        {                               2 = right,                      }
        {                               3 = both.                       }

        procedure MouseMoveTo(new_row, new_column : integer);
        { Position the mouse on the screen.  It wants the pixel         }
        { coordinates, not just character positions.                    }

        procedure MousePressed(button : integer; var result : boolean; var count, row, column : integer);
        { Gets pressed info about named button: current status          }
        { (up/down), times pressed since last call, position at most    }
        { recent press.  Resets count and position info. Button 0 is    }
        { left, 1 is right on Microsoft mouse.                          }

        procedure MouseReleased(button : integer; var result : boolean; var count, row, column : integer);
        { Gets released info about named button: current status         }
        { (up/down), times released since last call, position at most   }
        { recent press.  Resets count and position info. Button 0 is    }
        { left, 1 is right on Microsoft mouse.                          }

        procedure MouseColRange(horizontal_min, horizontal_max : integer);
        { Sets min and max horizontal range for mouse cursor. Moves     }
        { cursor inside range if outside when called. Swaps values if   }
        { min and max are reversed.                                     }

        procedure MouseRowRange(vertical_min, vertical_max : integer);
        { Sets min and max vertical range for mouse cursor. Moves       }
        { cursor inside range if outside when called. Swaps values if   }
        { min and max are reversed.                                     }

        procedure MouseGraphCursor(hHot, vHot : integer; mask_segment, mask_offset : word);
        { Sets the graphics cursor's hot spot and mask which defines    }
        { what the graphics cursor will look like.  The cursor hot spot }
        { must be within the range -16 to +16 pixels relative to the    }
        { cursor.  The mask values could be something like:             }
        { xmask : array[1..33] :=                                       }
        {       $07e0, $0000, $0180, $700e, $0000, $1c38, $c003, $0660, }
        {       $f00f, $03c0, $c003, $0660, $0000, $1c38, $0180, $700e, }
        {       $07e0, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000, }
        {       $ffff, $0000, $ffff, $0000, $ffff, $0000, $ffff, $0000  }
        { defines a graphics cursor like an x.  See the reference       }
        { earlier in this file for the table of the mask values effects }
        { on the screen.                                                }

        procedure MouseTextCursor(cursor_type : integer; arg1, arg2 : word);
        { Sets text cursor type, where 0 = software and 1 = hardware)   }
        { For software cursor, arg1 and arg2 are the screen and cursor  }
        { masks.  For hardware cursor, arg1 and arg2 specify scan line  }
        { start/stop i.e. cursor shape.                                 }

        procedure MouseMotion(var horizontal_count, vertical_count : integer);
        { Reports net motion of cursor since last call to this function.}
        { Returns the motion in "mickeys", always within the range of   }
        { -32768 to +32767.                                             }

        procedure MouseInstallTask(mask, task_segment, task_offset : word);
        { This function sets a subroutine to be conditionally called by }
        { the mouse software.  The condition of execution is defined by }
        { the mask.                                                     }
        {       Bit 0          cursor position changes                  }
        {           1          left button pressed                      }
        {           2          left button released                     }
        {           3          right button pressed                     }
        {           4          right button released                    }
        {           5-15       unused                                   }
        { To disable an interrupt for a specified condition, call       }
        { function again with the corresponding bit set to zero.        }
        { Calling mouse function Reset also resets everything.  The     }
        { subroutine to be called must be a far procedure, must save    }
        { any modified registers, and must not do any dos or bios calls.}

        procedure MouseLightPenOn;
        { Turns on light pen emulation. This is the default condition.  }

        procedure MouseLightPenOff;
        { Turns off light pen emulation.                                }

        procedure MouseRatio(horizontal, vertical : integer);
        { Sets the mickey / pixel ratio vertically and horizontally.    }
        { Default values are horizontal 8 mickeys to 8 pixels,          }
        { vertically 16 to 8.                                           }

        procedure MouseConditionOff(x1, y1, x2, y2 : integer);
        { This function is similar to hide_cursor(), but only turns off }
        { the cursor if it is in the area defined when this function is }
        { called.  If this function hides the cursor, Show must be      }
        { called later on to show the cursor again.                     }

        procedure MouseSetThreshold(x : integer);
        { This function sets how fast the mouse must move before its    }
        { relative cursor movements on the screen are doubled.  Default }
        { value is 64 mickeys per second.                               }

        Procedure MouseMode(mMode : integer);

        Procedure MouseWaitForLKey;
        Procedure MouseWaitForRKey;
        Procedure MouseWaitForAnyKey;
        Procedure MouseWaitForKeyRelease;

        Function MouseIsLKey : Boolean;
        Function MouseIsRKey : Boolean;


const
SlickArrow : Array[1..32] Of Word = (

     $3FFF,$1FFF,$0FFF,$07FF,$03FF,$01FF,$00FF,$007F,
     $007F,$E0FF,$F07F,$F87F,$FC7F,$FFFF,$FFFF,$FFFF,
     $0000,$4000,$6000,$7000,$7800,$7C00,$7E00,$7F00,
     $1C00,$0E00,$0700,$0300,$0000,$0000,$0000,$0000);

implementation
  uses Graph;

const
        MOUSE_DRIVER_INTERRUPT = $33;
                  Mouse_Width  = 9;
                  Mouse_Height = 13;



var
        mouse_exists    : Boolean;
        mouse_visible   : Boolean;
        mouse_buttons   : Integer;
        Registers       : DOS.Registers;

        MouseImg256     : Array[1..16,1..16] of Byte;
        UnderMouseImg256: Array[1..16,1..16] of Byte;
        Mouse_Mode      : Integer; (* 1=standard 2=svga *)
        OldmouseX       : Integer;
        OldmouseY       : Integer;

{ --------------------------------------------------------------------- }

Procedure CallMouse(MouseFunction : integer);
begin
        Registers.AX := MouseFunction;
        intr (MOUSE_DRIVER_INTERRUPT, Registers);
end; { CallMouse }

{ --------------------------------------------------------------------- }

Function MouseExists : boolean;
{ check if a mouse driver is currently loaded                           }
begin
        MouseExists := mouse_exists;
end;

{ --------------------------------------------------------------------- }

Function MouseNumberOfButtons : integer;
{ returns the number of available buttons on the mouse                  }
begin
        MouseNumberOfButtons := mouse_buttons;
end;

{ --------------------------------------------------------------------- }

Procedure MouseReset;
{ reset the mouse driver to its defaults                                }
begin
        CallMouse(3);
        Mouse_Exists := Registers.AX <> 0;
end; { Reset }

{ --------------------------------------------------------------------- }

procedure MouseShow;
{ Makes the mouse cursor visible.                                       }
Var
 i,j : Integer;
begin
        if mouse_visible then exit;
        If Mouse_Mode = 2 then
        begin
          CallMouse(3);
          with Registers do begin
                 OldMouseX := CX;
                 OldMouseY := DX;
          end;
          For i:=1 to Mouse_Width do
          begin
            For j:=1 to Mouse_Height do
            begin
              UnderMouseImg256[i,j]:=GetPixel(OldMouseX+i-1,OldMouseY+j-1);
            end;
          end;
          For i:=1 to Mouse_Width do
          begin
            For j:=1 to Mouse_Height do
            begin
              If (MouseImg256[i,j]<>UnderMouseImg256[i,j]) AND (MouseImg256[i,j]<>1) Then
              begin
                PutPixel(i+OldMouseX-1,j+OldMouseY-1,MouseImg256[i,j]);
              end;
            end;
          end;

        end
        else
        begin
          CallMouse(1);
        end;
        mouse_visible := true;
end;

{ --------------------------------------------------------------------- }

procedure MouseHide;
{ Makes mouse cursor invisible. Movement and button activity are        }
{ still tracked.                                                        }
Var
 i,j : Integer;
begin
        if not mouse_visible then exit;
        If Mouse_Mode=2 then
        begin
          For i:=1 to Mouse_Width do
            begin
              For j:=1 to Mouse_Height do
              begin
                If (MouseImg256[i,j]<>UnderMouseImg256[i,j]) AND (MouseImg256[i,j]<>1) Then
                begin
                  PutPixel(i+OldMouseX-1,j+OldMouseY-1,UnderMouseImg256[i,j]);
                end;
              end;
            end;
        end
        else
        begin
          CallMouse(2);
        end;
        mouse_visible := false;
end;

{ --------------------------------------------------------------------- }

procedure MouseGetStatus(var status, row, column : integer);
{ Gets mouse cursor position and button status.                         }
begin
        CallMouse (3);
        with Registers do begin
                row := DX;
                status := BX;
                Case Mouse_Mode of 3:column:=CX SHR 1;
                 ELSE
                  column:=CX;
                END;
        end;
        If Mouse_Mode=2 then
        begin
          If (Column<>OldMouseX) OR (Row<>OldMouseY) Then
          begin
            if mouse_visible then
            begin
              MouseHide;
              MouseShow;
            end;
          end;
        end;
end; { GetPosition }

{ --------------------------------------------------------------------- }

procedure MouseMoveTo(new_row, new_column : integer);
{ Move mouse cursor to new position                                     }
begin
        with Registers do begin
                CX := new_column;
                DX := new_row;
        end;
        CallMouse(4);
        If Mouse_Mode = 2 then
        begin
          If mouse_visible then
          begin
            MouseHide;
            MouseShow;
          end;
        end;
end;

{ --------------------------------------------------------------------- }

procedure MousePressed(button : integer; var result : boolean; var count, row, column : integer);
{ Gets pressed info about named button: current status (up/down),       }
{ times pressed since last call, position at most recent press.         }
{ Resets count and position info. Button 0 is left, 1 is right on       }
{ Microsoft mouse.                                                      }
begin
        with Registers do begin
                BX := button - 1;
                CallMouse(5);
                case button of
                        1 : result := AX and $01 <> 0;
                        2 : result := AX and $02 <> 0;
                        3 : result := AX and $04 <> 0;
                end; { case }
                count := BX;
                column := CX;
                row := DX;
        end; { with }
end;

{ --------------------------------------------------------------------- }

procedure MouseReleased(button : integer; var result : boolean; var count, row, column : integer);
{ Gets released info about named button: current status (up/down),      }
{ times released since last call, position at most recent press.        }
{ Resets count and position info. Button 0 is left, 1 is right on       }
{ Microsoft mouse.                                                      }
begin
        with Registers do begin
                BX := button - 1;
                CallMouse(6);
                case button of
                        1 : result := AX and $01 <> 0;
                        2 : result := AX and $02 <> 0;
                        3 : result := AX and $04 <> 0;
                end; { case }
                count := BX;
                column := CX;
                row := DX;
        end; { with }
end;

{ --------------------------------------------------------------------- }

procedure MouseColRange(horizontal_min, horizontal_max : integer);
{ Sets min and max horizontal range for mouse cursor. Moves             }
{ cursor inside range if outside when called. Swaps values if           }
{ min and max are reversed.                                             }
begin
        with Registers do begin
                CX := horizontal_min;
                DX := horizontal_max;
        end; { with }
        CallMouse(7);
end;

{ --------------------------------------------------------------------- }

procedure MouseRowRange(vertical_min, vertical_max : integer);
{ Sets min and max vertical range for mouse cursor. Moves               }
{ cursor inside range if outside when called. Swaps values if           }
{ min and max are reversed.                                             }
begin
        with Registers do begin
                CX := vertical_min;
                DX := vertical_max;
        end; { with }
        CallMouse(8);
end;

{ --------------------------------------------------------------------- }

procedure MouseGraphCursor(hHot, vHot : integer; mask_segment, mask_offset : word);
{ Sets graphic cursor shape                                             }
begin
        with Registers do begin
                BX := hHot;
                CX := vHot;
                DX := mask_offset;
                ES := mask_segment;
        end;
        CallMouse(9);
end;

{ --------------------------------------------------------------------- }

procedure MouseTextCursor(cursor_type : integer; arg1, arg2 : word);
{ Sets text cursor type, where 0 = software and 1 = hardware)           }
{ For software cursor, arg1 and arg2 are the screen and cursor          }
{ masks.  For hardware cursor, arg1 and arg2 specify scan line          }
{ start/stop i.e. cursor shape.                                         }
begin
        with Registers do begin
                BX := cursor_type;
                CX := arg1;
                DX := arg2;
        end;
        CallMouse(10);
end;

{ --------------------------------------------------------------------- }

procedure MouseMotion(var horizontal_count, vertical_count : integer);
{ Reports net motion of cursor since last call to this function         }
begin
        CallMouse(11);
        with Registers do begin
                horizontal_count := CX;
                vertical_count := DX;
        end;
end;

{ --------------------------------------------------------------------- }

procedure MouseInstallTask(mask, task_segment, task_offset : word);
{ Installs a user-defined task to be executed upon one or more          }
{   mouse events specified by mask.                                     }
begin
        with Registers do begin
                CX := mask;
                DX := task_offset;
                ES := task_segment;
        end;
        CallMouse(12);
end;

{ --------------------------------------------------------------------- }

procedure MouseLightPenOn;
{ Turns on light pen emulation. This is the default condition.          }
begin
        CallMouse(13);
end;

{ --------------------------------------------------------------------- }

procedure MouseLightPenOff;
{ Turns off light pen emulation.                                        }
begin
        CallMouse(14);
end;

{ --------------------------------------------------------------------- }

procedure MouseRatio(horizontal, vertical : integer);
{ Sets mickey-to-pixel ratio, where ratio is R/8. Default is 16         }
{   for vertical, 8 for horizontal                                      }
begin
        with Registers do begin
                CX := horizontal;
                DX := vertical;
        end;
        CallMouse(15);
end;

{ --------------------------------------------------------------------- }

procedure MouseConditionOff(x1, y1, x2, y2 : integer);
{ This function hides the mouse if it is in the region when this        }
{ function is called.  Afterwards your program must call Show to show   }
{ the cursor again.                                                     }
begin
        if not mouse_visible then exit;
        with Registers do begin
                SI := x2;               { lower x screen coordinates    }
                DI := y2;               { lower y screen coordinates    }
                CX := x1;               { upper x screen coordinates    }
                DX := y1;               { upper y screen coordinates    }
        end;
        CallMouse(16);
        mouse_visible := false;
end;

{ --------------------------------------------------------------------- }

procedure MouseSetThreshold(x : integer);
{ Set the threshold speed for doubling the cursor's movements           }
begin
        Registers.DX := x;
        CallMouse(19);
end;


{ --------------------------------------------------------------------- }

var     ExitSave: pointer;              { Previous exit procedure       }

{$F+} procedure ExitHandler; {$F-}
begin
        ExitProc := ExitSave;   { Chain to other exit procedures        }
        CallMouse(0);
end;

Procedure MouseWaitForLKey;
Var
 status,row,col : Integer;
begin
 Repeat
   MouseGetStatus(Status,row,col);
 Until Status=1;
end;

Procedure MouseWaitForRKey;
Var
 status,row,col : Integer;
begin
 Repeat
   MouseGetStatus(Status,row,col);
 Until Status=2;
end;

Procedure MouseWaitForAnyKey;
Var
 status,row,col : Integer;
begin
 Repeat
   MouseGetStatus(Status,row,col);
 Until (Status=1) or (Status=2);
end;

Procedure MouseWaitForKeyRelease;
Var
 status,row,col : Integer;
begin
 Repeat
   MouseGetStatus(Status,row,col);
 Until Status=0;
end;


Function MouseIsRKey : Boolean;
Var
 status,row,col : Integer;
begin
 MouseIsRKey:=TRUE;
 MouseGetStatus(Status,row,col);
 if Status<>2 then MouseIsRKey:=FALSE;
end;

Function MouseIsLKey : Boolean;
Var
 status,row,col : Integer;
begin
 MouseIsLKey:=False;
 MouseGetStatus(Status,row,col);
 if Status=1 then MouseIsLKey:=TRUE;
end;

Procedure CreateMouse256;
Const
 MouseImg : array[1..117] of Byte =
               (0,0,1,1,1,1,1,1,1,
                0,$F,0,1,1,1,1,1,1,
                0,$F,$F,0,1,1,1,1,1,
                0,$F,$F,$F,0,1,1,1,1,
                0,$F,$F,$F,$F,0,1,1,1,
                0,$F,$F,$F,$F,$F,0,1,1,
                0,$F,$F,$F,$F,$F,$F,0,1,
                0,$F,$F,$F,$F,$F,$F,$F,0,
                0,0,0,$F,$F,$F,0,0,0,
                1,1,1,0,$F,$F,$F,0,1,
                1,1,1,1,0,$F,$F,$F,0,
                1,1,1,1,1,0,$F,$F,0,
                1,1,1,1,1,1,0,0,0);
Var
 i,j,c : Word;
begin
 c:=1;
 For j:=1 to Mouse_Height do
 begin
   For i:=1 to Mouse_Width do
   begin
     MouseImg256[i,j]:=MouseImg[c];
     Inc(c);
   end;
 end;
end;


Procedure MouseMode(mMode : integer);
begin
If mMode = 2 then
begin
 CreateMouse256;
 Mouse_Mode:=2;
end
else if mMode =1 then
begin
 Mouse_Mode:=1;
 MouseGraphCursor(0,0,Seg(SlickArrow), Ofs(SlickArrow));
end
else if mMode = 3 then        (* 320X256X256 *)
begin
 Mouse_Mode:=3;
 MouseGraphCursor(0,0,Seg(SlickArrow), Ofs(SlickArrow));
end;

end;



{ --------------------------------------------------------------------- }

begin

        ExitSave := ExitProc;
        ExitProc := @ExitHandler;       { Install our exit procedure    }
        CallMouse(0);
        mouse_exists := Registers.AX <> 0;
        mouse_visible := false;
        mouse_buttons := Registers.BX;
end.
