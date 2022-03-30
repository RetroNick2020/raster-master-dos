Unit bgiReq;
 Interface
Function GetFile(xp,yp : Integer;Msg:String; Var mydirpath:string;var filename : string; SaveBack : Boolean) : Boolean;

 Implementation
   uses dos,graph,bgiMouse,bgiText,bgiEdit,bgigadge,bgiImage,bgiMisc;
Function GetFile(xp,yp : Integer;Msg:String; Var mydirpath:string;var filename : string; SaveBack : Boolean) : Boolean;


Type
 FileRec = array[1..150] of string[12];
 DirRec  = array[1..100] of string[12];

Const
 ngads = 12;

 cursorState:integer=0;

var
 fileoffset :integer;
 filepos    :Integer;
 filenum    :integer; (* total number of files *)
 filelist   : ^FileRec;
 dirlist    : ^dirRec;
 diroffset  : Integer;
 dirpos     : Integer;
 dirnum     : integer; (* total number of files *)
    size    : Word;
 UnderPanel : Pointer;
 myGadget   : Word;
 reqGads    : GLPtr;



Function ValidPath(path : string): Boolean;
var
 dirInfo : SearchRec;
begin
 ValidPath:=False;
 Findfirst(path,archive,dirinfo);
 if (DosError=0) or (DosError=18) then
 begin
  ValidPath:=True;
 end;
end;

Function GetNumberofLogicalDrives : Word;
 VAR DOS_Reg : Registers;
BEGIN
   with DOS_reg DO
    AX := $1900;	{get current disk}
    intr($21,dos_reg);
    with DOS_reg DO
     GetNumberofLogicalDrives := succ(al);
END;

Procedure SortFileNames;
var
i,j,size : integer;
switch:integer;
temp : string[12];

begin
 size:=filenum;
 Repeat
  switch:=0;
  for i:=1 to (size-1) do
  begin
   j:=i+1;
   if filelist^[i]>filelist^[j] then
   begin
    temp:=filelist^[i];
    filelist^[i]:=filelist^[j];
    filelist^[j]:=temp;
    inc(switch);
   end;
  end;
 Until (switch=0);
end;

Procedure GetFilenames;
var
 dirInfo : SearchRec;
begin
 filenum:=0;
 Findfirst(mydirpath,archive,dirinfo);
 While (DosError=0) AND (Filenum<150) do
 begin
  inc(filenum);
  filelist^[filenum]:=dirinfo.name+#32;
  findnext(dirinfo);
 end;

 filepos:=1;
 fileoffset:=0;
 sortfilenames;
end;

Procedure printfileList;
var
 count : integer;
 i     : integer;
 x,y,x2 : Word;
begin
 count:=filenum;
 x:=ReqGads^[3].x;
 y:=ReqGads^[3].y;
 x2:=ReqGads^[3].x+ReqGads^[3].Width-1;

 if filenum>10 then count:=10;
 for i:=1 to count do
 begin
 SetFillStyle(SolidFill,White);
 Bar(x+1,y+i*12-12+1,x2-1,y+i*12+1);
 Setcolor(Black);

 OutTextXY(x+4,y+i*12-12+3,filelist^[i+fileoffset]);
 end;
end;


Procedure SortDirNames;
var
i,j,size : integer;
switch:integer;
temp : string[12];

begin
 size:=dirnum;
 Repeat
  switch:=0;
  for i:=1 to (size-1) do
  begin
   j:=i+1;
   if dirlist^[i]>dirlist^[j] then
   begin
    temp:=dirlist^[i];
    dirlist^[i]:=dirlist^[j];
    dirlist^[j]:=temp;
    inc(switch);
   end;
  end;
 Until (switch=0);
end;


Procedure GetDirnames;
var
 dirInfo : SearchRec;
 ourpath : string;
       dir:dirstr;
      name:namestr;
       ext:extstr;
   i:integer;
begin
 dirnum:=GetNumberofLogicalDrives;
 for i:=1 to dirnum do
 begin
   dirlist^[i]:=+'<'+chr(64+i)+':\>';
 end;
 fsplit(mydirpath,dir,name,ext);
 ourpath:=dir+'*.*';
 Findfirst(ourpath,directory,dirinfo);
 While (DosError=0) AND (dirnum<101) do
 begin
  if (dirinfo.attr=$10) then
  begin
   inc(dirnum);
   if dirinfo.name='.' then
   begin
    dirlist^[dirnum]:='<'+dirinfo.name+'>';
   end
   else if dirinfo.name='..' then
   begin
    dirlist^[dirnum]:='<'+dirinfo.name+'>';
   end
   else
   begin
    dirlist^[dirnum]:=dirinfo.name+#32;
   end;
  end;
  findnext(dirinfo);
 end;

 Dirpos:=1;
 Diroffset:=0;
 SortDirNames;
end;

Procedure printDirList;
var
 count : integer;
 i     : integer;
 x,y,x2 : Word;
begin
 count:=filenum;
 x:=ReqGads^[4].x;
 y:=ReqGads^[4].y;
 x2:=ReqGads^[4].x+ReqGads^[4].Width-1;
 count:=dirnum;
 if dirnum>10 then count:=10;
 for i:=1 to count do
 begin
 SetFillStyle(SolidFill,White);
 Bar(x+1,y+i*12-12+1,x2-1,y+i*12+1);
 Setcolor(Black);
 OuTtextXY(x+4,y+i*12-12+3,Dirlist^[i+diroffset]);
 end;
end;



Function rGadget : Word;
Var
        gp : Word;
begin
 rGadget:=0;
 MouseWaitForKeyRelease;
 Repeat
   MouseWaitForLKey;
   gp:=GetGadgetPressed(ReqGads,ngads);
 Until gp > 0;
 rgadget:=gp;
end;


Procedure DirSliderAction;
var
 num    : Word;
 x,y,Width,Height : Word;
begin
 x:=ReqGads^[11].x;
 y:=ReqGads^[11].y;
 Width:=ReqGads^[11].Width;
 Height:=ReqGads^[11].Height;
 if dirnum > 10 then
 begin
   num:=GetVSliderPos(x,y,Width,Height,dirnum-10);
   diroffset:=num;
   MouseHide;
   DrawVSlider(x,y,Width,Height,diroffset,dirnum-10);
   printdirlist;
   MouseShow;
end;
end;

Procedure FileSliderAction;
var
 num : word;
 x,y,Width,Height : Word;
begin
 x:=ReqGads^[12].x;
 y:=ReqGads^[12].y;
 Width:=ReqGads^[12].Width;
 Height:=ReqGads^[12].Height;
 if filenum > 10 then
 begin
  num:=GetVSliderPos(x,y,Width,Height,filenum-10);
  fileoffset:=num;
  MouseHide;
  DrawVSlider(x,y,Width,Height,fileoffset,filenum-10);

  printfilelist;
  MouseShow;
 end;
end;


Procedure DirUpAction;
var
 st,mx,my : Integer;
 x,y,Width,Height : Word;
begin
 x:=ReqGads^[11].x;
 y:=ReqGads^[11].y;
 Width:=ReqGads^[11].Width;
 Height:=ReqGads^[11].Height-1;
 MouseHide; (* mouse hide *)
 DrawGadget(ReqGads,6,TRUE);
 MouseShow; (* mouse show *)
 Repeat
  if diroffset > 0 then
  begin
   dec(diroffset);
   MouseHide; (* mouse hide *)
   printdirlist;
   DrawVSlider(x,y,Width,Height,diroffset,dirnum-10);
   MouseShow; (* mouse show *)
  end;
  MouseGetStatus(st,my,mx)
 Until st=0;
 MouseHide; (* mouse hide *)
 DrawGadget(ReqGads,6,FALSE);
 MouseShow; (* mouse show *)

end;

procedure DirDownAction;
var
 st,mx,my : Integer;
 x,y,Width,Height : Word;
begin
 x:=ReqGads^[11].x;
 y:=ReqGads^[11].y;
 Width:=ReqGads^[11].Width;
 Height:=ReqGads^[11].Height;
 MouseHide; (* mouse hide *)
 DrawGadget(ReqGads,8,TRUE);
 MouseShow; (* mouse show *)
 Repeat
  if (diroffset+10) < dirnum then
  begin
   inc(diroffset);
   MouseHide; (* mouse hide *)
   printdirlist;
   DrawVSlider(x,y,Width,Height,diroffset,dirnum-10);
   MouseShow; (* mouse show *)
  end;
  MouseGetStatus(st,my,mx);
 Until st=0;
 MouseHide; (* mouse hide *)
 DrawGadget(ReqGads,8,FALSE);
 MouseShow; (* mouse show *)

end;

procedure fileupaction;
var
 st,mx,my : Integer;
 x,y,Width,Height : Word;
begin
 x:=ReqGads^[12].x;
 y:=ReqGads^[12].y;
 Width:=ReqGads^[12].Width;
 Height:=ReqGads^[12].Height;
 MouseHide; (* mouse hide *)
 DrawGadget(ReqGads,5,TRUE);
 MouseShow; (* mouse show *)
 Repeat
  if fileoffset > 0 then
  begin
   dec(fileoffset);
   MouseHide; (* mouse hide *)
   printfilelist;
   DrawVSlider(x,y,Width,Height,fileoffset,filenum-10);
   MouseShow; (* mouse show *)
  end;
  mouseGetStatus(st,my,mx)
 Until st=0;
 MouseHide; (* mouse hide *)
 DrawGadget(ReqGads,5,FALSE);
 MouseShow; (* mouse show *)

end;

procedure filedownaction;
var
 st,mx,my : Integer;
 x,y,Width,Height : Word;
begin
 x:=ReqGads^[12].x;
 y:=ReqGads^[12].y;
 Width:=ReqGads^[12].Width;
 Height:=ReqGads^[12].Height;
 MouseHide; (* mouse hide *)
 DrawGadget(ReqGads,7,TRUE);
 MouseShow; (* mouse show *)
 Repeat
  if (fileoffset+10) < filenum then
  begin
   inc(fileoffset);
   MouseHide; (* mouse hide *)
   printfilelist;
   DrawVSlider(x,y,Width,Height,fileoffset,filenum-10);
   MouseShow; (* mouse show *)
  end;
  MouseGetStatus(st,my,mx)
 Until st=0;
 MouseHide; (* mouse hide *)
 DrawGadget(ReqGads,7,FALSE);
 MouseShow; (* mouse show *)

end;

Procedure FixFilename;
var
 i : integer;
begin
   i:=1;
  Repeat
   filename[i]:=upcase(filename[i]);
   if filename[i]=#32 then
   begin
    delete(filename,i,1);
   end
   else
   begin
    inc(i);
   end;
  Until i>length(filename);
end;

procedure editfilenameAction;
Var
 x,y,x2,y2 : Word;
begin
 x:=ReqGads^[1].x;
 y:=ReqGads^[1].y;
 x2:=ReqGads^[1].x+ReqGads^[1].Width-1;
 y2:=ReqGads^[1].y+ReqGads^[1].Height-1;
MouseHide; (* hide mouse *)
SetFillStyle(SolidFill,Green);
Bar(x+1,y+1,x2-1,y2-1);
MouseShow; (* show mouse *);

EditString(x+2,y+2,12,cursorState,Green,Black,LightRed,1,filename);
FixFilename;
if length(filename)>12 then filename[0]:=#12;
MouseHide; (* hide mouse *)
setFillStyle(SolidFill,White);
Bar(x+1,y+1,x2-1,y2-1);
Setcolor(Black);
OutTextXY(x+2,y+2,filename);

MouseShow; (* show mouse *);
end;


Procedure Fixpath;
var
       dir:dirstr;
      name:namestr;
       ext:extstr;
        i:integer;
begin
  i:=1;
  Repeat
   if mydirpath[i]=#32 then
   begin
    delete(mydirpath,i,1);
   end
   else
   begin
    inc(i);
   end;
  Until i>=length(mydirpath);


 fsplit(mydirpath,dir,name,ext);
 mydirpath:=dir+name+ext;
 mydirpath:=FExpand(mydirpath);
end;

procedure editpathaction;
var
 opath : string; (* original path *)
 temppath: string;
 x,y,x2,y2 : Word;
begin
 GetGadgetCords(ReqGads,2,x,y,x2,y2);
opath:=mydirpath;
MouseHide; (* hide mouse *)
SetFillStyle(SolidFill,Green);
Bar(x+1,y+1,x2-1,y2-1);
MouseShow; (* show mouse *);
EditString(x+2,y+2,28,cursorState,Green,Black,LightRed,1,mydirpath);
if mydirpath<>opath then
begin
 if ValidPath(mydirpath) then
 begin
  Fixpath;
  getdirnames;
  getfilenames;
  MouseHide; (* mouse hide *)

  SetFillStyle(SolidFill,White);
  GetGadgetCords(ReqGads,3,x,y,x2,y2);

  Bar(x+1,y+1,x2-1,y2-1);
  GetGadgetCords(ReqGads,4,x,y,x2,y2);

  Bar(x+1,y+1,x2-1,y2-1);
  printfilelist;
  printdirlist;
  GetGadgetCords(ReqGads,11,x,y,x2,y2);

  DrawVSlider(x,y,x2-x+1,y2-y+1,1,100);
  GetGadgetCords(ReqGads,12,x,y,x2,y2);

  DrawVSlider(x,y,x2-x+1,y2-y+1,1,100);

  MouseShow; (* mouse show *)
 end
 else
 begin
  mydirpath:=opath;
 end;
end;
MouseHide; (* hide mouse *)

setFillStyle(SolidFill,white);
  GetGadgetCords(ReqGads,2,x,y,x2,y2);

Bar(x+1,y+1,x2-1,y2-1);
setcolor(Black);
temppath:=mydirpath;
if Length(temppath)>28 then
begin
  temppath[0]:=#28;
end;
OuTtextXY(x+2,y+2,temppath);

MouseShow; (* show mouse *);
end;





procedure fileboxaction;
var
 st,mx,my : Integer;
 FilePicked : word;
 x,y,x2,y2 : Word;
begin
mouseGetStatus(st,my,mx);
GetGadgetCords(ReqGads,3,x,y,x2,y2);

FilePicked:= (my-(y)) DIV 12 + 1;
if (filePicked > 10) or (filepicked>filenum) then exit;
filename:=FileList^[FilePicked+fileoffset];
MouseHide; (* hide mouse *)
SetFillStyle(SolidFill,white);
GetGadgetCords(ReqGads,1,x,y,x2,y2);

Bar(x+1,y+1,x2-1,y2-1);
Setcolor(Black);
OutTextXY(x+2,y+2,filename);
MouseShow; (* show mouse *);

end;

Procedure SetRootDir;
var
       dir:dirstr;
      name:namestr;
       ext:extstr;
begin
 fsplit(mydirpath,dir,name,ext);
 dir[0]:=#3;
 mydirpath:=dir+name+ext;
end;




Procedure SetParentDir;
var
       dir:dirstr;
      name:namestr;
       ext:extstr;
begin
 fsplit(mydirpath,dir,name,ext);
 if (dir[length(dir)]='\') AND (length(dir)>3) then
 begin
  delete(dir,length(dir),1);
  While (dir[length(dir)]<>'\') AND (length(dir)>1) do
  begin
   delete(dir,length(dir),1);
  end;
  mydirpath:=dir+name+ext;
 end;
end;


Procedure setchilddir(child : string);
var
       dir:dirstr;
      name:namestr;
       ext:extstr;
begin
 fsplit(mydirpath,dir,name,ext);
 mydirpath:=dir+child+'\'+name+ext;
end;

Procedure SetNewDrive(drive:string);
var
       dir:dirstr;
      name:namestr;
       ext:extstr;
begin
 fsplit(mydirpath,dir,name,ext);
 mydirpath:=drive[2]+':\'+name+ext;
end;

procedure dirboxaction;
var
 st,mx,my : Integer;
 DirPicked : word;
 tempdir  : string;
 x,y,x2,y2 : Word;
begin
mouseGetStatus(st,my,mx);
GetGadgetCords(ReqGads,4,x,y,x2,y2);
dirPicked:=(my-(y)) DIV 12 + 1;

if (DirPicked > 10) or (dirPicked>dirnum) then
begin
 exit;
end;
tempdir:=DirList^[dirpicked+diroffset];

if tempdir='<..>' then
begin
 SetParentDir;
 getdirnames;
 getfilenames;
 filename:='';
end
else if tempdir='<.>' then
begin
 SetRootDir;
 getdirnames;
 getfilenames;
 filename:='';
end
else if (tempdir[3]=':') then
begin
 if (tempdir[2]=mydirpath[1]) then exit;
 if validpath(tempdir[2]+':\') then
 begin
  SetNewDrive(tempdir);
  getdirnames;
  getfilenames;
  filename:='';
 end;
end
else
begin
 SetChildDir(tempdir);
 getdirnames;
 getfilenames;
 filename:='';
end;


  MouseHide; (* mouse hide *)
  setFillStyle(SolidFill,white);
  Bar(x+1,y+1,x2-1,y2-1);     (* directory box *)

  GetGadgetCords(ReqGads,3,x,y,x2,y2);
  Bar(x+1,y+1,x2-1,y2-1);     (* file box *)
  printfilelist;
  printdirlist;
  GetGadgetCords(ReqGads,11,x,y,x2,y2);

  DrawVSlider(x,y,x2-x+1,y2-y+1,1,100);
  GetGadgetCords(ReqGads,12,x,y,x2,y2);

  DrawVSlider(x,y,x2-x+1,y2-y+1,1,100);

  setFillStyle(SolidFill,White);
  GetGadgetCords(ReqGads,2,x,y,x2,y2);

  Bar(x+1,y+1,x2-1,y2-1);
  GetGadgetCords(ReqGads,1,x,y,x2,y2);

  Bar(x+1,y+1,x2-1,y2-1);
  setcolor(Black);
  fixpath;
  OuttextXY(x+2,y+2,filename);
  GetGadgetCords(ReqGads,2,x,y,x2,y2);

  OuttextXY(x+2,y+2,mydirpath);
  MouseShow; (* show mouse *);

end;

Procedure DefGads;
Var
 P,P2 : Pointer;

begin
  DefineBlankGadget(ReqGads,1,xp+88,yp+26,99,13,TRUE,FALSE);
  DefineBlankGadget(ReqGads,2,xp+88,yp+46,227,13,TRUE,FALSE);
  DefineBlankGadget(ReqGads,3,xp+6,yp+71,103,123,TRUE,FALSE);
  DefineBlankGadget(ReqGads,4,xp+126,yp+71,103,123,TRUE,FALSE);

  If GetMaxColor=15 then
  begin
    P:=@Up16a;
    P2:=@Up16b;
  end
  else
  begin
    P:=@Up256a;
    P2:=@Up256b;
  end;

  DefineImageGadget(ReqGads,5,xp+108,yp+71,17,16,P,P2,TRUE,FALSE);
  DefineImageGadget(ReqGads,6,xp+228,yp+71,17,16,P,P2,TRUE,FALSE);

  If GetMaxColor=15 then
  begin
    P:=@Down16a;
    P2:=@Down16b;
  end
  else
  begin
    P:=@Down256a;
    P2:=@Down256b;
  end;

  DefineImageGadget(ReqGads,7,xp+108,yp+87,17,16,P,P2,TRUE,FALSE);
  DefineImageGadget(ReqGads,8,xp+228,yp+87,17,16,P,P2,TRUE,FALSE);

  DefineStringGadget(ReqGads,9,xp+250,yp+135, ' CANCEL ',TRUE,FALSE);
  DefineStringGadget(ReqGads,10,xp+250,yp+164,'   OK   ',TRUE,FALSE);

  DefineBlankGadget(ReqGads,11,xp+228,yp+103,17,91,TRUE,FALSE);
  DefineBlankGadget(ReqGads,12,xp+108,yp+103,17,91,TRUE,FALSE);

end;


Procedure DrawFileRequester;
Var
 temppath : string;
 cent     : integer;
 x,y,x2,y2 : Word;
begin
 DefGads;

 cent:=160-(length(msg)*8) DIV 2;
 MouseHide; (* hide mouse *)
 SetFillStyle(SolidFill,Black);
 Bar(xp,yp,xp+319,yp+199);
 Border(xp,yp,xp+319,yp+199);
 SetFillStyle(SolidFill,LightGray);
 Bar(xp+3,yp+3,xp+316,yp+20);
 SetFillStyle(SolidFill,White);
 Bar(xp+3,yp+22,xp+316,yp+196);
 setcolor(Black);
 OuttextXY(xp+8,yp+28,' Filename:');
 OuttextXY(xp+8,yp+47,'Directory:');

 setcolor(White);

 OutTextXY(xp+cent,yp+8,msg);
 setcolor(Black);

 OutTextXY(xp+cent-1,yp+8,msg);

 GetGadgetCords(ReqGads,1,x,y,x2,y2);

 Rectangle(x,y,x2,y2);     (* file name box *)
 GetGadgetCords(ReqGads,2,x,y,x2,y2);

 Rectangle(x,y,x2,y2);     (* directory name box *)
 GetGadgetCords(ReqGads,3,x,y,x2,y2);

 Rectangle(x,y,x2,y2);     (* file box *)
 GetGadgetCords(ReqGads,4,x,y,x2,y2);

 Rectangle(x,y,x2,y2);     (* directory box *)


 DrawAllGadgets(ReqGads,ngads);

 temppath:=mydirpath;
 if Length(temppath)>28 then
 begin
   temppath[0]:=#28;
 end;
 GetGadgetCords(ReqGads,2,x,y,x2,y2);
 OuttextXY(x+2,y+2,temppath);

 GetGadgetCords(ReqGads,1,x,y,x2,y2);
 OuttextXY(x+2,y+2,filename);

 GetGadgetCords(ReqGads,11,x,y,x2,y2);

 DrawVSlider(x,y,x2-x+1,y2-y+1,1,100);
  GetGadgetCords(ReqGads,12,x,y,x2,y2);

 DrawVSlider(x,y,x2-x+1,y2-y+1,1,100);
 MouseShow; (* show mouse *)
end;


Procedure CleanUP;
begin
   if saveback=true then
   begin
    if underpanel<>nil then
    begin
     MouseHide;
     PutImage(xp,yp,UnderPanel^,CopyPut);
     MouseShow;
     FreeMem(UnderPanel,size);
    end;
   end;
   if dirList<>Nil then
   begin
    FreeMem(dirlist,sizeof(dirlist^));
   end;
   if filelist<>Nil then
   begin
    FreeMem(filelist,sizeof(filelist^));
   end;
   if ReqGads<>Nil then
   begin
    FreeGadgetMem(ReqGads,Ngads);
   end;
end;

Procedure OKAction;
Var
 st,mx,my : Integer;
        i : Integer;
 d        : DirStr;
 n        : NameStr;
 e        : ExtStr;
begin
  MouseHide;
  DrawGadget(ReqGads,10,TRUE);
  MouseShow;
  MouseWaitForKeyRelease;
  MouseHide;
  DrawGadget(ReqGads,10,FALSE);
  MouseShow;
  fsplit(mydirPath,d,n,e);
  if filename<>'' then
  begin
    Filename:=d+filename;
  end
  else
  begin
   GetFile:=False;
  end;
  Cleanup;
end;

Procedure CancelAction;
Var
 st,mx,my : Integer;
begin
  MouseHide;
  DrawGadget(ReqGads,9,TRUE);
  MouseShow;
  MouseWaitForKeyRelease;
  MouseHide;
  DrawGadget(ReqGads,9,FALSE);
  MouseShow;
  Cleanup;
end;





begin
 GetMem(FileList,sizeof(filelist^));
 GetMem(dirList,sizeof(dirList^));
 GetGadgetMem(ReqGads,ngads);

 if (dirlist=nil) OR (filelist=nil) OR (ReqGads=NIL) then
 begin
  GetFile:=false;
  CleanUp;
  exit;
 end;

 if SaveBack=true then
 begin
  size:=imageSize(0,0,319,199);
  GetMem(UnderPanel,size);
  if (underPanel=Nil) then
  begin
   GetFile:=False;
   CleanUP;
   exit;
  end;
  MouseHide;
  GetImage(xp,yp,xp+319,yp+199,UnderPanel^);
  MouseShow;
 end;

 drawFileRequester;
 getdirnames;
 getfilenames;
 MouseHide; (* hide mouse *)
 printfilelist;
 printdirlist;
 MouseShow; (* show mouse *)

 repeat
  myGadget:=rGadget;
  case mygadget of 1: editfilenameaction;
            2: editpathaction;
            3: fileboxaction;
            4: dirboxaction;
            5: fileUpaction;
            7: fileDownaction;
            6: dirUpaction;
            8: dirDownaction;
            9: begin
                CancelAction;
                GetFile:=False;
                exit;
               end;
           10: begin
                OKAction;
                exit;
               end;
           12: begin
                FileSliderAction;
               end;
           11: begin
                 DirSliderAction;
               end;
   end;
 until 1=0;
end;







begin
(* fg_setmode(16);
 fg_setcolor(blue);
 fg_rect(0,359,0,299);

 if fg_mouseini<>-1 then
 begin
 end;
 fg_mousevis(1);

 mydir:='C:\TP\*.PAS';
 myfile:='';
  if GetFile(0,0,'Select QWK Packet',mydir,myfile,false) then
 begin
 end;
*)
end.
