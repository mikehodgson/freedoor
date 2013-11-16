{
        extra.pas, part of the freedoor doorkit
}

unit extra;
{$I COLORDEF.INC}

interface
Uses
  {$IFDEF OS2}os2base,{$ENDIF}                                    {mp}
  {$IFDEF WIN32}windows,{$ENDIF}                                  {mp}

  {$IFDEF VirtualPascal}Use32,VPUtils,{$ENDIF}dos;

Procedure Convert_To_ANSI (var MyStr : String);
procedure mouseoff;            (* Turns the mouse cursor off *) {mp}

implementation

(*************************************************************)
 Procedure Convert_To_ANSI (var MyStr : String);
(*************************************************************)
Var
  DummyInt : Integer;
  AnsiStr : String;
{$IFDEF COLOR_TG}
   Procedure CvtTelegard;
   Begin
    AnsiStr := '';
    DummyInt := 0;
    Repeat
      if Pos ('`', MyStr) <> 0 then
      begin
        DummyInt := Pos('`', MyStr) + 2;
          Case MyStr[DummyInt] of
            '0': AnsiStr := #27 + '[0;30;';
            '1': AnsiStr := #27 + '[0;34;';
            '2': AnsiStr := #27 + '[0;32;';
            '3': AnsiStr := #27 + '[0;36;';
            '4': AnsiStr := #27 + '[0;31;';
            '5': AnsiStr := #27 + '[0;35;';
            '6': AnsiStr := #27 + '[0;33;';
            '7': AnsiStr := #27 + '[0;37;';
            '8': AnsiStr := #27 + '[1;30;';
            '9': AnsiStr := #27 + '[1;34;';
            'A': AnsiStr := #27 + '[1;32;';
            'B': AnsiStr := #27 + '[1;36;';
            'C': AnsiStr := #27 + '[1;31;';
            'D': AnsiStr := #27 + '[1;35;';
            'E': AnsiStr := #27 + '[1;33;';
            'F': AnsiStr := #27 + '[1;37;';
          end;
        DummyInt := DummyInt - 1;
          Case MyStr[DummyInt] of
            '0': AnsiStr := AnsiStr + '40m';
            '1': AnsiStr := AnsiStr + '44m';
            '2': AnsiStr := AnsiStr + '42m';
            '3': AnsiStr := AnsiStr + '46m';
            '4': AnsiStr := AnsiStr + '41m';
            '5': AnsiStr := AnsiStr + '45m';
            '6': AnsiStr := AnsiStr + '43m';
            '7': AnsiStr := AnsiStr + '47m';
          end;
        Delete (MyStr, DummyInt - 1, 3);
        Insert (AnsiStr, MyStr, DummyInt - 1);
      End;
    Until Pos ('`', MyStr) = 0;
  End;
{$ENDIF}

{$IFDEF COLOR_SYNC}
   Procedure CvtSync;
   Begin
    AnsiStr := '';
    DummyInt := 0;
    Repeat
      if Pos (#01, MyStr) <> 0 then
      begin
        DummyInt := Pos(#01, MyStr) + 1;
          Case MyStr[DummyInt] of
            'L': AnsiStr := #27 + '[2J';
            '>': AnsiStr := #27 + '[K';
            'H': AnsiStr := #27 + '[1m';
            'I': AnsiStr := #27 + '[5m';
            'N': AnsiStr := #27 + '[0m';
            'K': AnsiStr := #27 + '[30m';
            'R': AnsiStr := #27 + '[34m';
            'G': AnsiStr := #27 + '[32m';
            'Y': AnsiStr := #27 + '[36m';
            'B': AnsiStr := #27 + '[31m';
            'M': AnsiStr := #27 + '[35m';
            'C': AnsiStr := #27 + '[33m';
            'W': AnsiStr := #27 + '[37m';
            '0': AnsiStr := #27 + '[40m';
            '1': AnsiStr := #27 + '[44m';
            '2': AnsiStr := #27 + '[42m';
            '3': AnsiStr := #27 + '[46m';
            '4': AnsiStr := #27 + '[41m';
            '5': AnsiStr := #27 + '[45m';
            '6': AnsiStr := #27 + '[43m';
            '7': AnsiStr := #27 + '[47m';
          end;
        Delete (MyStr, DummyInt-1, 2);
        Insert (AnsiStr, MyStr, DummyInt-1);
      End;
    Until Pos (#01, MyStr) = 0;
  End;
{$ENDIF}

{$IFDEF COLOR_WWIV}
   Procedure CvtWWIV;
   Begin
    AnsiStr := '';
    DummyInt := 0;
    Repeat
      if Pos (#03, MyStr) <> 0 then
      begin
        DummyInt := Pos(#03, MyStr) + 1;
          Case MyStr[DummyInt] of
            '0': AnsiStr := #27 + '[0;37;40m';
            '1': AnsiStr := #27 + '[1;36;40m';
            '2': AnsiStr := #27 + '[1;33;40m';
            '3': AnsiStr := #27 + '[0;35;40m';
            '4': AnsiStr := #27 + '[1;37;44m';
            '5': AnsiStr := #27 + '[0;32;40m';
            '6': AnsiStr := #27 + '[1;5;31m';
            '7': AnsiStr := #27 + '[1;34;40m';
            '8': AnsiStr := #27 + '[0;34;40m';
            '9': AnsiStr := #27 + '[0;36;40m';
          end;
        Delete (MyStr, DummyInt - 1, 2);
        Insert (AnsiStr, MyStr, DummyInt - 1);
      End;
    Until Pos (#01, MyStr) = 0;
  End;
{$ENDIF}

{$IFDEF COLOR_LORD}
   Procedure CvtLord;
   Begin
    AnsiStr := '';
    DummyInt := 0;
    Repeat
      if Pos ('`', MyStr) <> 0 then
      begin
        DummyInt := Pos('`', MyStr) + 1;
          Case MyStr[DummyInt] of
            '1': AnsiStr := #27 + '[0;34m';
            '2': AnsiStr := #27 + '[0;32m';
            '3': AnsiStr := #27 + '[0;36m';
            '4': AnsiStr := #27 + '[0;31m';
            '5': AnsiStr := #27 + '[0;35m';
            '6': AnsiStr := #27 + '[0;33m';
            '7': AnsiStr := #27 + '[0;37m';
            '8': AnsiStr := #27 + '[1;30m';
            '9': AnsiStr := #27 + '[1;34m';
            '0': AnsiStr := #27 + '[1;32m';
            '!': AnsiStr := #27 + '[1;36m';
            '@': AnsiStr := #27 + '[1;31m';
            '#': AnsiStr := #27 + '[1;35m';
            '$': AnsiStr := #27 + '[1;33m';
            '%': AnsiStr := #27 + '[1;37m';
            'r': begin
                  inc(DummyInt);
                  Case MyStr[DummyInt] of
                   '0': AnsiStr := AnsiStr + #27 + '[40m';
                   '1': AnsiStr := AnsiStr + #27 + '[44m';
                   '2': AnsiStr := AnsiStr + #27 + '[42m';
                   '3': AnsiStr := AnsiStr + #27 + '[46m';
                   '4': AnsiStr := AnsiStr + #27 + '[41m';
                   '5': AnsiStr := AnsiStr + #27 + '[45m';
                   '6': AnsiStr := AnsiStr + #27 + '[43m';
                   '7': AnsiStr := AnsiStr + #27 + '[47m';
                  end;
                  dec(DummyInt);
                 end;
          end;

        Delete (MyStr, DummyInt - 1, 2);
        Insert (AnsiStr, MyStr, DummyInt - 1);
      End;
    Until Pos ('`', MyStr) = 0;
  End;
{$ENDIF}

Begin
  {$IFDEF COLOR_TG} CvtTelegard; {$ENDIF}
  {$IFDEF COLOR_SYNC} CvtSync; {$ENDIF}
  {$IFDEF COLOR_WWIV} CvtWWIV; {$ENDIF}
  {$IFDEF COLOR_LORD} CvtLord; {$ENDIF}
End;

(*************************************************************) {mp}
procedure mouseoff;            (* Turns the mouse cursor off *)
(*************************************************************)
{$IFDEF VirtualPascal}
{$IFDEF OS2}
var
  kbd: kbdinfo;
begin
  kbd.cb:=sizeof(kbd);
  kbdgetstatus(kbd, 0);
  kbd.fsMask:=KEYBOARD_MODIFY_STATE or KEYBOARD_BINARY_MODE;
  KbdSetStatus(kbd, 0);
end;
{$ELSE}
var
  Mode: Longint;
begin
  if GetConsoleMode(SysFileStdIn, Mode) then
    SetConsoleMode(SysFileStdIn, Mode and not enable_processed_input
                                 and not enable_mouse_input);
end;
{$ENDIF}
{$ELSE}
begin
end;
{$ENDIF}

begin
end.
