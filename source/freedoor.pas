unit freedoor;

{
        FreeDoor 1.70 for VP/BP
        Release Date: 08/15/2002
        (C)opyright 2000-2002 Mike Hodgson
        EleCom is (C)opyright Maarten Bekers

        Released under the BSD License. Please see License.txt.

        REVISION HISTORY

         -- Moved to fd_changes.txt in docs directory --

        COMMAND LINE PARAMETER EXAMPLES

        32bit (Windows / OS/2)

        doorname.exe /L                        -- for local mode
        doorname.exe /DC:\PATH\TO\DOOR32.SYS   -- for remote telnet connection

        16bit (DOS)

        doorname.exe /Dc:\path\to\door.sys     -- for normal FOSSIL mode, # = port number
        doorname.exe /Dc:\path\to\door.sys     -- Telnet mode, # = port handle

}

{NOTE : Modify COLORDEF.INC to select which sets of colour codes you
        would like to support}

interface

uses
{$IFDEF OS2}os2base,{$ENDIF}                                    {mp1.0}
{$IFDEF WIN32}windows,{$ENDIF}                                  {mp1.0}
{$IFDEF MSDOS} BPCompat, {$ENDIF}
{$IFDEF VirtualPascal}Use32, VPUtils, VpSysLow, sysutils, {$ENDIF}
crt, dos, newansi, extra, elenorm;

{$I FREEDOOR.INC}

{ define this if you want ddplus compatibility}
{ DEFINE DDPLUS}

function InitDoorDriver : boolean;
Procedure DeInitDoorDriver;
function CCarrier : boolean;
Procedure CClrScr;
Procedure CClrEol;
Procedure CursorSave;
Procedure CursorRestore;
Procedure CursorUp (Distance : Integer);
Procedure CursorDown (Distance : Integer);
Procedure CursorBack (Distance : Integer);
Procedure CursorForward (Distance : Integer);
Procedure CGotoXY (X,Y : Integer);
Procedure ErrorWriteLn (S : String); {Prints message w/o calling statbar }
Procedure CWriteLn (S : String);
Procedure CWrite (S : String);
Function CKeyPressed : boolean;
Procedure CGetChar (var Ch: Char);  { From Manning's MDoor kit! }
Procedure CReadLn (var S: String);  { From Manning's MDoor kit! }
Procedure CWriteLong (I : LongInt);
Procedure CGetByte (var B: Byte);
Procedure CWriteLnLong (I : LongInt);
Procedure CReadLnLong (var L: LongInt);
Procedure CPause;
Procedure CWriteFile (FN : String);
Function CMaskInput (mask : String; StrLength : Byte) : String;
Function CMaskInputPW (mask : String; StrLength : Byte) : String;
Procedure CCenter (S : String);
Procedure CRight (S : String);
Procedure CWindow (X1,Y1,X2,Y2 : Integer);
Procedure CSendToNode (S : String; Node : String);
Procedure CGetFromNode;
Function CGetOpSys : String;
Procedure freedoor_Exit;

{$IFDEF DDPLUS} {mp1.5 - all ddplus compatibility stuff added by MPreslar}
procedure sread(var s:string);
procedure swriteln(s:string);
procedure swrite(s:string);
procedure set_foreground(n:byte);
procedure set_background(n:byte);
procedure sgoto_xy(x,y:byte);
procedure sclrscr;
procedure sclreol;
function skeypressed:boolean;
procedure swritec(ch:char);
procedure swritexy(x,y:byte;s:string);
procedure set_color(f,b:byte);
procedure display_status;
function time_used:longint;
function time_left:longint;
procedure sread_char(var ch:char);
{$ENDIF}

(*

{ these have been converted to freedoor}
procedure sgoto_xy(x,y: integer);
procedure sclrscr;
procedure sclreol;
function  skeypressed: boolean;
procedure swrite(s: string);
procedure swritec(ch: char);
procedure swriteln(s: string);
procedure set_foreground(f: byte);
procedure set_background(b: byte);
Procedure swritexy(x,y:integer;s:string);
procedure set_color(f,b: byte);
function Time_used: integer;
function time_left: integer;
procedure sread_char(var ch: char);
procedure sread(var s: string);

{ these need to be converted to freedoor}
procedure sendtext(s: string);
procedure sread_num(var n: integer);
procedure sread_num_byte(var b: byte);
procedure sread_num_word(var n: word);
procedure sread_num_longint(var n: longint);
Procedure speedread(var ch : char);
procedure prompt(var s: string; le: integer; pc: boolean);
procedure get_stacked(var s: string);
procedure sread_char_filtered(var ch: char);
procedure display_status;
Procedure Displayfile(filen: string);
procedure InitDoorDriver(ConfigFileName: string);

{ these wont be converted }
procedure DDAssignSoutput(var f: text);
 - not used by ddplus
Procedure SelectAnsi(chflag :char;filenm: string);
 - not needed. was it ever used?
Procedure elapsed(time1_hour, time1_min, time1_sec, time2_hour, time2_min,
                  time2_sec: longint; var elap_hour, elap_min, elap_sec: word);
 - should be in a toolkit, not a doorkit
Procedure Propeller(v:byte);
 - just a fancy "readkey"
Procedure Clear_Region(x,a,b:byte);
 - a cumbersome way to clear an area, and unconfigurable too
*)


implementation

var freedoor_SaveExit: Pointer;                                 {mp1.5}
    show_status_bar:boolean;                                    {mp1.5}
    quietmode : boolean;                                        {mp1.5}

(*************************************************************)
 Procedure CheckExitKey;
(*************************************************************)
var tempch : char;
begin
{    PeekKey(tempch);
    if (tempch = #0) then
    begin
      tempch := ReadKey;
      tempch := ReadKey;
      if (tempch = chr($10)) then
      begin
        ErrorWriteLn ('');
        ErrorWriteLn ('* Sysop has ended door session *');
        ErrorWriteLn ('');
        halt(0);
      end;
    end;
    SysCtrlSleep(1); }
end;


(*************************************************************)
 Procedure LocalLogin;
(*************************************************************)
var
  tempusername : String;
begin
  clrscr;
  textcolor(7);
  textbackground(0);
  WriteLn ('Enter your name or leave blank for SYSOP');
  Write (':: ');
  TextColor(15);
  ShowCursor;                                                   {mp1.0}
  ReadLn (tempusername);
  HideCursor;                                                   {mp1.0}
  If (tempusername <> '') then fdInfo.RealName := tempusername;
  fdInfo.Handle := fdInfo.RealName;
  TextColor(7);
end;

(*************************************************************)
 function ReadDropFile (DropPath : String) : Boolean;
(*************************************************************)
var
  f : text;           { Dropfile file variable }
  s : string;         { Temporary String }
  {$IFDEF VirtualPascal}
  i : LongInt;        { Temporary Integer }
  {$ELSE}
  i : Integer;
  {$ENDIF}
  Procedure ReadDoorSys;
  begin
    readln (f,s);
    delete (s,1,3);
    delete (s,length(s),1);
    val(s,fdInfo.ComPort,i);
    if fdInfo.ComPort <> 0 then fdInfo.ConnType := 1;
    readln(f,s); { remote baud rate}
    val(s,fdInfo.Baud,i);
    readln(f,s); {dbits}
    readln(f,s); {node num}
    fdInfo.Node := s;
    readln(f,s); {actual internal bbs}
    readln(f,s); {screen on}
    readln(f,s); {printer}
    readln(f,s); {page bell}
    readln(f,s); {caller bell}
    readln(f,s); {user name}
    fdInfo.RealName := s;
    fdInfo.Handle := fdInfo.RealName;
    readln(f,s); {city,state}
    fdInfo.CityState := s;
    readln(f,s); {home phone}
    readln(f,s); {work phone}
    readln(f,s); {password}
    readln(f,s); {security}
    val(s,fdInfo.ACS,i);
    readln(f,s); {times on}
    readln(f,s); {last called}
    readln(f,s); {secs left}
    readln(f,s); {time left}
    val(s,fdInfo.TimeLeft,i);
    fdInfo.TotalTime := fdInfo.TimeLeft;
    readln(f,s); {graphics code}
    if s='GR' then fdInfo.GraphMode:=ANSI_GRAPH
    else if s='RIP' then fdInfo.GraphMode:=RIP_GRAPH
    else fdInfo.GraphMode:=ASCII_GRAPH;
    close(f);
  end;

  Procedure ReadDoor32Sys;
  begin
    readln (f,s);
    val(s,fdInfo.ConnType,i);
    readln (f,s);
    val(s,fdInfo.ComPort,i);
    readln (f,s);
    val(s,fdInfo.Baud,i);
    readln (f,s);
    fdInfo.BBSID := s;
    readln (f,s);
    val(s,fdInfo.RecPos,i);
    readln (f,s);
    fdInfo.RealName := s;
    readln (f,s);
    fdInfo.Handle := s;
    readln (f,s);
    val(s,fdInfo.ACS,i);
    readln (f,s);
    val(s,fdInfo.TimeLeft,i);
    fdInfo.TotalTime := fdInfo.TimeLeft;
    readln (f,s);
    val (s,fdInfo.GraphMode,i);
    readln (f,s);
    fdInfo.Node := s;
    close(f);
  end;

  Procedure ReadDorinfo;
  begin
    readln (f,s);
    readln (f,s);
    readln (f,s);
    readln (f,s);
    delete(s, 1, 3); {manning}
    val(s,fdInfo.ComPort,i);
    readln (f,s);
    val(s,fdInfo.Baud,i);
    readln (f,s);
    readln (f,s);
    fdInfo.RealName := s;
    readln (f,s);
    fdInfo.RealName := fdInfo.RealName + ' ' + s;
    fdInfo.Handle := fdInfo.RealName;
    readln (f,s);
    fdInfo.CityState := s;
    readln (f,s);
    if (s = '0') then fdInfo.GraphMode := ASCII_GRAPH else fdInfo.GraphMode := ANSI_GRAPH;
    readln (f,s);
    val(s,fdInfo.ACS,i);
    readln (f,s);
    val(s,fdInfo.TimeLeft,i);
    fdInfo.TotalTime := fdInfo.TimeLeft;
    readln (f,s);
    close(f);
  end;

begin
  assign (f,DropPath);
  if not (FileExists(DropPath)) then
  begin
    if not quietmode then                                       {mp1.5}
    WriteLn ('ReadDropFile :: ERROR :: DropFile not found!');
    ReadDropFile := False;
  end
  else
  begin
    reset(f);
    fdInfo.DropFile := DropPath;
    if (fdInfo.DropType = 1) then ReadDoorSys
    else if (fdInfo.DropType = 2) then ReadDoor32Sys
    else if (fdInfo.DropType = 3) then ReadDorinfo;
    ReadDropFile := True;
  end;
end;

(*************************************************************)
 function tl: word;
(*************************************************************)
begin;
  tl := (GetTimeMSec div 1000) - SavedTime;
end;

(*************************************************************)
 procedure UpdateStatusBar;
(*************************************************************)
var
  c,d: word;
  x,y: integer;
  OldTextAttr : Byte;
begin
  SysCtrlSleep(1);
  if (not show_status_bar) or (quietmode) then exit;            {mp1.5}
  OldTextAttr := TextAttr;
  x:=wherex;
  y:=wherey;
  window(1,25,80,25);
  textcolor(StatFore);
  textbackground(StatBack);
  if (FirstTime = True) then
  begin
    clreol;
    gotoxy(1,1);
    write(fdInfo.RealName);
    GotoXY (40 - (Length(ProgName) div 2),1);
    Write (ProgName);
    LastTime := 30000;
    FirstTime := False;
  end;
  c:= (fdInfo.TimeLeft-1) - (tl div 60);
  d:=60- (tl mod 60);
  if ((c -1 = -1) and (d-1 = 0)) then
    begin
      textcolor(7);
      textbackground(0);
      window(1,1,80,25-1);
      gotoxy(x,y);
      ErrorWriteLn('`0CTime limit exceeded');
      delay(1);
      halt(0);
    end;
  if ((GetTimeMSec div 1000 div 60) - (LkTime div 1000 div 60)) >= 5 then
    begin
      textcolor(7);
      textbackground(0);
      window(1,1,80,25-1);
      gotoxy(x,y);
      ErrorWriteLn(#10+'User Inactive.');
      delay(10);
      halt(0);
    end;
    if (d <= (LastTime - 5)) or (d = 55) then
    begin
      gotoxy(72,1);
      write ('     ');
      gotoxy(72,1);
      write(c,':');
      if d<10 then write('0');
      write(d);
      LastTime:=d;
    end;
    TextAttr := OldTextAttr;
    window(1,1,80,25-1);
    gotoxy(x,y);
end;

(*************************************************************)
 function InitDoorDriver : boolean;
(*************************************************************)
var
  TempInt  : LongInt;
  TempStr  : String;
{$IFDEF VirtualPascal}
  Code     : LongInt;
{$ELSE}
  Code     : Integer;
{$ENDIF}
{$IFDEF WIN32}                                                  {mp1.0}
  pp:array[0..40] of char;                                      {mp1.0}
  pc:pchar;                                                     {mp1.0}
{$ENDIF}                                                        {mp1.0}


begin
  {mp: we add this here so that we _know_ the deinit routines
   will be called}
  freedoor_SaveExit := ExitProc;                                {mp1.5}
  ExitProc := @freedoor_Exit;                                   {mp1.5}
  MouseOff;                                                     {mp1.0}

  HideCursor;
{$IFDEF WIN32}                                                  {mp1.0}
  pc:=pp;                                                       {mp1.0}
  pc:=strpcopy(pc,progname);                                    {mp1.0}
  setconsoletitle(pc);                                          {mp1.0}
{$ENDIF}                                                        {mp1.0}

  fdInfo.ConnType := 0;
  fdInfo.BBSID := 'Unknown';
  fdInfo.Handle := 'Sysop';
  fdInfo.RealName := 'Sysop';
  fdInfo.CityState := 'Somewheresville';
  fdInfo.ACS := 255;
  fdInfo.TimeLeft := 3000;
  fdInfo.TotalTime := 3000;
  fdInfo.ComPort := 0;
  fdInfo.Baud := 0;
  fdInfo.Node := '0';
  fdInfo.Graphmode := ANSI_GRAPH;
  fdInfo.DropFile := '';
  fdInfo.DropType := 0;
  show_status_bar := true;                                      {mp1.5}
  quietmode := false;                                           {mp1.5}
  if (ParamCount = 0) then
  begin
    writeln ('InitDoorDriver :: ERROR :: You didn''t tell me what to do!');
    writeln ('Exiting.');
{mp1.0}    writeln (' If you''re trying to load this program locally, you should do a');
{mp1.0}    writeln;
{mp1.0}    writeln (' '+paramstr(0)+' /l');

    InitDoorDriver := False;
    isLocal := True;
  end
  else
  begin
    for TempInt := 1 to ParamCount do
      begin
{mp1.5} if (UpperCase(ParamStr(TempInt)) = '/STATBAROFF') then          {Local Only?}
{mp1.5}   show_status_bar := false;
{mp1.6} if ((UpperCase(ParamStr(TempInt)) = '/Q') and (not isLocal)) then begin         {Local Only?}
          {$IFDEF WIN32}
          FreeConsole;
          {$ENDIF}
{mp1.5}   quietmode := true;
        end;


        if (UpperCase(ParamStr(TempInt)) = '/L') then          {Local Only?}
          begin
            isLocal := True;
{mp1.5}     quietmode := false;
          end;
        if (pos('/D',UpperCase(ParamStr(TempInt))) <> 0) then  {Read Dropfile!}
          begin
            TempStr := '';
            TempStr := ParamStr(TempInt);
            delete(TempStr,1,2);
            if (pos('DOOR.SYS',UpperCase(TempStr)) <> 0) then fdInfo.DropType := 1 else
              if (pos('DOOR32.SYS',UpperCase(TempStr)) <> 0) then fdInfo.DropType := 2 else
              if (pos('DORINFO',UpperCase(TempStr)) <> 0) then fdInfo.DropType := 3 else fdInfo.DropType := 0;
            ReadDropFile (TempStr);
          end;
        if (pos('/T',UpperCase(ParamStr(TempInt))) <> 0) then fdInfo.ConnType := 02;
        if (pos('/N',UpperCase(ParamStr(TempInt))) <> 0) then
          begin
            TempStr := '';
            TempStr := ParamStr(TempInt);
            delete (TempStr,1,2);
            fdInfo.Node := TempStr;
          end;
        if (pos('/P',UpperCase(ParamStr(TempInt))) <> 0) then
          begin
            TempStr := '';
            TempStr := ParamStr(TempInt);
            delete (TempStr,1,2);
            val(TempStr,fdInfo.ComPort,Code);
          end;
      end;
    if (fdInfo.ConnType = 0) or (fdInfo.ComPort = 0) then isLocal := True;
    if (not isLocal) then
    begin
      Com_StartUp(fdInfo.ConnType);
      Com_SetDontClose(True);
      Com_OpenQuick(fdInfo.ComPort);
      Com_SendString(#27 + '[0;37m');
    end;
    if ((isLocal) and (fdInfo.DropType = 0)) then LocalLogin;
    LkTime := GetTimeMSec;
    SavedTime := GetTimeMSec div 1000;
    UpdateStatusBar;
    CWrite(#27 + '[0;37m');
    InitDoorDriver := True;
  end;
end;

procedure Freedoor_Exit;
begin
 ExitProc := Freedoor_SaveExit;
 if ExitCode <> 0 then
  begin
   Writeln( 'An error number ',ExitCode,' occured!' );
   ExitCode := 0;
   ErrorAddr := nil;
  end;
 deinitdoordriver;
end;

(*************************************************************)
 Procedure DeInitDoorDriver;
(*************************************************************)
begin
  ShowCursor;
  if (not isLocal) then Com_Shutdown;
end;

(*************************************************************)
 Function CCarrier : Boolean;
(*************************************************************)
begin
  if ((not isLocal) and (not Com_Carrier)) then CCarrier := False else CCarrier := True;
end;

(*************************************************************)
 Procedure CClrScr;
(*************************************************************)
begin
  if (not isLocal) then
    Com_SendString(#27 + '[2J');
  if not quietmode then
  ClrScr;
end;

(*************************************************************)
 Procedure CClrEol;
(*************************************************************)
begin
  if (not isLocal) then
    Com_SendString(#27 + '[K');
  if not quietmode then
  ClrEol;
end;

(*************************************************************)
 Procedure CursorSave;
(*************************************************************)
Begin
  CWrite (#27 + '[s');
End;

(*************************************************************)
 Procedure CursorRestore;
(*************************************************************)
Begin
  CWrite (#27 + '[u');
End;

(*************************************************************)
 Procedure CursorUp (Distance : Integer);
(*************************************************************)
Var
  DummyVal : String;
Begin
  Str (Distance, DummyVal);
  CWrite (#27 + '[' + DummyVal + 'A');
End;

(*************************************************************)
 Procedure CursorDown (Distance : Integer);
(*************************************************************)
Var
  DummyVal : String;
Begin
  Str (Distance, DummyVal);
  CWrite (#27 + '[' + DummyVal + 'B');
End;

(*************************************************************)
 Procedure CursorBack (Distance : Integer);
(*************************************************************)
Var
  DummyVal : String;
Begin
  Str (Distance, DummyVal);
  CWrite (#27 + '[' + DummyVal + 'D');
End;

(*************************************************************)
 Procedure CursorForward (Distance : Integer);
(*************************************************************)
Var
  DummyVal : String;
Begin
  Str (Distance, DummyVal);
  CWrite (#27 + '[' + DummyVal + 'C');
End;

(*************************************************************)
 Procedure CGotoXY (X,Y : Integer);
(*************************************************************)
var
  TempX : String;
  TempY : String;
begin
  Str(X,TempX);
  Str(Y,TempY);
  CWrite (#27 + '[' + TempY + ';' + TempX + 'H');
end;

(*************************************************************)
 Procedure ErrorWriteLn (S : String); {Prints message w/o calling statbar }
(*************************************************************)
begin
  if not (isLocal) then
    Com_SendString(#10#13 + S + #10#13);
  if not quietmode then
  WriteLn (S);
end;

(*************************************************************)
 Procedure CWrite (S : String);
(*************************************************************)
begin
  Convert_To_ANSI(S);
  if (not isLocal) then
    Com_SendString(S);
  if not quietmode then
    AWrite (S);
  UpdateStatusBar;
  CheckExitKey;
end;

(*************************************************************)
 Procedure CWriteLn (S : String);
(*************************************************************)
begin
  CWrite(S + #10#13);
end;

(*************************************************************)
  Procedure CWriteLnLong (I : LongInt);
(*************************************************************)
var
  S : String;
begin
  str(I,S);
  CWrite (S + #10#13);
end;

(*************************************************************)
  Procedure CWriteLong (I : LongInt);
(*************************************************************)
var
  S : String;
begin
  str(I,S);
  CWrite (S);
end;

function ckeypressed:boolean;
begin
ckeypressed:=false;
if (isLocal) then
 begin
  if (keypressed) then ckeypressed:=true;
 end
else
 begin
 if (Com_CharAvail) then ckeypressed:=true;
 end;
end;

(*************************************************************)
 Procedure CGetChar (var Ch : Char);  { From Manning's MDoor kit! }
(*************************************************************)
begin
     Ch := #255;
     repeat
           if (KeyPressed) then
           begin
              CheckExitKey;
              Ch := ReadKey;
              isLocalChar := TRUE;
           end
           else
           if Not(isLocal) then
              if (Com_CharAvail) then
              begin
                 Ch := Com_GetChar;
                 isLocalChar := FALSE;
              end;
           SysCtrlSleep(1);
           CGetFromNode;
           UpdateStatusBar;
     until (Ch <> #255) or Not(CCarrier);
     LkTime := GetTimeMSec;
end;

(*************************************************************)
  Procedure CGetByte (var B : Byte);
(*************************************************************)
var
  C : Char;
{$IFDEF VirtualPascal}
  Code : LongInt;
{$ELSE}
  Code : Integer;
{$ENDIF}
begin
  CGetChar(C);
  val (C,B,Code);
end;


(*************************************************************)
 Procedure CreadLn(var S : String);
(*************************************************************)
var
   Ch: Char;
begin
     S := '';
     repeat
           CGetChar(Ch);
           CWrite(Ch);
           if (Ch <> #13) and (Ch <> #10) then
              S := S + Ch;
     until (Ch = #13) or Not(CCarrier);

     if Not(isLocal) then
        Com_SendChar(#10);
     WriteLn;
end;

(*************************************************************)
  Procedure CReadLnLong (var L : LongInt);
(*************************************************************)
var
  S : String;
{$IFDEF VirtualPascal}
  Code : LongInt;
{$ELSE}
  Code : Integer;
{$ENDIF}
begin
  CReadLn(S);
  val (S,L,Code);
end;

(*************************************************************)
 Procedure CPause;
(*************************************************************)
var
  C : Char;
begin
  CWrite (PAUSE_STRING);
  CGetChar(C);
  CwriteLn('');
end;

(*************************************************************)
 Procedure CWriteFile (FN : String);
(*************************************************************)
var
  f: file;
  s : array[1..255] of char;
  numread : integer;
  tempint : integer;
  tempint2 : integer;
  tempstr : string[255];
begin
  Fillchar (s,sizeof(s),#0);
  Assign(f,FN);
  {manning}
  if not (FileExists(FN)) then
    CWriteLn ('`0A*** FILE ' + FN + ' NOT FOUND ***')
  else
  begin
    Reset(f,1); {manning}
    repeat
      {$I-}BlockRead (f,s,sizeof(s),numread);{$I+}
      if (numread > 0) and (IOResult = 0) then
      begin
            Move(s,tempstr[1],numread);
            tempstr[0] := chr(numread);
            CWrite(tempstr);
            tempstr[0] := #0;
      end;
    until ((EOF(f)) or (numread <= 0));
    FlushAnsi;
    close (f);
    CheckExitKey;
  end;
end;

(*************************************************************)
 Function CMaskInput (mask : String; StrLength : Byte) : String;
(*************************************************************)
Var
  ch : Char;
  DummyByte : Byte;
  s : String[80];
  tempstr : String;
begin
  s:='';
//  CWrite (MASK_COLOUR);
  CursorSave;
  for DummyByte := 1 to StrLength+2 do tempstr := tempstr + ' ';
  CWrite (MASK_COLOUR + tempstr);
  CursorRestore;
  CWrite (' ');
  repeat
    CGetChar(ch);
    if (ch<>#8) and (ch<>^M) and (Pos(UpCase(Ch), mask) = 0) and (length(s) < StrLength) then
    begin
      s:=s+ch;
      CWrite(ch);
    end;
    if (ch=chr(8)) and (length(s)>0) then
    begin
      delete(s,length(s),1);
      CWrite(chr(8)+' '+chr(8));
    end;
  until (ch=^M);
  CWriteln('`07');
  CMaskInput := s;
end;

(*************************************************************)
 Function CMaskInputPW (mask : String; StrLength : Byte) : String;
(*************************************************************)
Var
  ch : Char;
  DummyByte : Byte;
  s : String[80];
  tempstr : string;
begin
  s:='';
  CursorSave;
  for DummyByte := 1 to StrLength+2 do tempstr := tempstr + ' ';
  CWrite (MASK_COLOUR+tempstr);
  CursorRestore;
  CWrite (' ');
  repeat
    CGetChar(ch);
    if (ch<>#8) and (ch<>^M) and (Pos(UpCase(Ch), mask) = 0) and (length(s) < StrLength) then
    begin
      s:=s+ch;
      CWrite(MASK_PWCHAR);
    end;
    if (ch=chr(8)) and (length(s)>0) then
    begin
      delete(s,length(s),1);
      CWrite(chr(8)+' '+chr(8));
    end;
  until (ch=^M);
  CWriteln('`07');
  CMaskInputPW := s;
end;

(*************************************************************)
 Procedure CCenter (S : String);
(*************************************************************)
begin
  CGotoXY (40 - (Length(S) div 2), WhereY);
  CWrite (S);
end;

(*************************************************************)
 Procedure CRight (S : String);
(*************************************************************)
begin
  CGotoXY (80 - Length(S), WhereY);
  CWrite (S);
end;



(*************************************************************)
 Procedure CWindow (X1,Y1,X2,Y2 : Integer);
(*************************************************************)
var
  TempInt : Integer;
  StoredX : Integer;
  StoredY : Integer;
begin
  CursorSave;
  CGotoXY (X1,Y1);
  CWrite ('Ú');
  CGotoXY (X2,Y1);
  CWrite ('¿');
  CGotoXY (X2,Y2);
  CWrite ('Ù');
  CGotoXY (X1,Y2);
  CWrite ('À');
  CGotoXY (X1+1,Y1);
  For TempInt := 1 to X2-2 do
    CWrite('Ä');
  CGotoXY (X1+1,Y2);
  For TempInt := 1 to X2-2 do
    CWrite('Ä');
  CgotoXY (X1,Y1+1);
  For TempInt := Y1+1 to Y2-1 do
  begin
    CGotoXY(X1,TempInt);
    CWrite('³');
  end;
  For TempInt := Y1+1 to Y2-1 do
  begin
    CGotoXY(X2,TempInt);
    CWrite('³');
  end;
  CursorRestore;
end;

(*************************************************************)
 Procedure CSendToNode (S: String; Node : String);
(*************************************************************)
var
  NodeFile : Text;
begin
  Assign (NodeFile, 'MSG'+Node+'.TMP');
  Repeat
    {$I-}ReWrite (NodeFile){$I+}
  Until (IOResult = 0);
  WriteLn (NodeFile, 'From ' + fdInfo.Handle + ' on Node #' + fdInfo.Node);
  if not quietmode then                                       {mp1.5}
  WriteLn (S);
  Close (NodeFile);
end;

(*************************************************************)
 Procedure CGetFromNode;
(*************************************************************)
var
  NodeFile : Text;
  S : String;
begin
  If FileExists('MSG'+fdInfo.Node+'.TMP') then
  Begin
    Assign (NodeFile, 'MSG'+fdInfo.Node+'.TMP');
    Reset (NodeFile);
    ReadLn (NodeFile, S);
    CWriteLn ('`0A' + S);
    ReadLn (NodeFile, S);
    CWriteLn ('`02' + S);
    CWriteLn ('');
    Close (NodeFile);
    Erase (NodeFile);
  end;
end;

(*************************************************************)
 Function CGetOpSys : String;
(*************************************************************)
var
  tlobyte : byte;
  thibyte : byte;
begin
  {$IFDEF VirtualPascal}
  tlobyte := lo(SysOSVersion);
  thibyte := hi(SysOSVersion);
  if (tlobyte = $05) then
  begin
    if (thibyte = $01) then
      Result := 'Windows XP'
    else if (thibyte = $00) then
      Result := 'Windows 2000';
  end
  else if (tlobyte = $04) then
  begin
    if (thibyte = $00) then
      Result := 'Windows 95'
    else if (thibyte = $01) then
      Result := 'Windows 98'
    else if (thibyte = $09) then
      Result := 'Windows ME';
  end;
  {$ENDIF}
  {$IFDEF MSDOS}
  CGetOpSys := 'MS-DOS';
  {$ENDIF}
end;

{$IFDEF DDPLUS}
{$I ddplus.inc}
{$ENDIF}


begin
end.


