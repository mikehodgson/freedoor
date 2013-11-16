{
  bpcompat.pas
  This unit adds necessary VP2.1 compatable functions to Borland Pascal
}

Unit BPCompat;

interface

function GetTimeMSec : LongInt;
procedure SysCtrlSleep (Seconds : Integer);
procedure ShowCursor;
procedure HideCursor;
function FileExists (FN : String) : Boolean;
function UpperCase (S : String) : String;
function PeekKey (var C : Char) : Boolean;

implementation

uses dos;

function GetTimeMSec : Longint;
var
  H,M,S,T : Word;
begin
  GetTime(H,M,S,T);
  GetTimeMSec := (S * 1000) + (M * 60 * 1000) + (H * 60 * 60 * 1000);
end;

procedure SysCtrlSleep(Seconds: Integer);  { Stolen from SWAG :> }
{ This is a stripped down timeslice procedure, should work fine under
 Windows and OS/2 }

  procedure TimerSlice;
  begin
    asm
      MOV AX,$1680
      INT $2F
    end;
  end;

begin
      TimerSlice;
end;

procedure ShowCursor;
begin
end;

procedure HideCursor;
begin
end;

function FileExists (FN : String) : Boolean;
var
  TempFile : Text;
begin
  Assign (TempFile, FN);
  {$I-}Reset (TempFile);{$I+}
  if (IOResult <> 0) then
    FileExists := False
  else
  begin
    FileExists := True;
    close (TempFile);
  end;
end;

function UpperCase (S : String) : String;
var
  TempInt : Integer;
begin
  if (Length(S) > 0) then
    For TempInt := 1 to Length(S) do S[TempInt] := UpCase(S[TempInt]);
end;

function PeekKey (var C : Char) : Boolean;
var
  HTregs : registers;

begin { PeekKey }
  HTregs.AH := $01;
  Intr($16,HTregs);
  if not (HTregs.Flags and FZero <> 0) then
    begin
      PeekKey := True;
      C := Chr(HTregs.AX);
    end
  else
    PeekKey := False;
    C := #00;
end; { PeekKey }
end.
