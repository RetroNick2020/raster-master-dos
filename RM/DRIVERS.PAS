Unit Drivers;

Interface

  Procedure EgaVgaDriverProc;

 procedure SVga256Proc;

Implementation

 procedure EgaVgaDriverProc; external;
 {$L C:\TP\EGAVGA.OBJ }

 procedure SVga256Proc; external;
 {$L C:\TP\SVGA256.OBJ }

begin
end.
