(*
        NewAnsi ANSI Emulation Units (C)opyright 2000, Mike Hodgson
        This source code can be freely used.

        Tested Environments: Borland Pascal 7.01
                             Virtual Pascal 2.10

        Revisions:
                    1.02:    Fixed CRLF sequence.

*)
unit newansi;

interface

Procedure FlushAnsi;
Procedure AWrite (S : String);
Procedure AWriteLn (S : String);

var
  Ans_Fore         : Byte;        { saved ansi foreground colour }
  Ans_Back         : Byte;        { saved ansi background colour }
  Ans_SX           : Byte;        { saved X position }
  Ans_SY           : Byte;        { saved Y position }
  Ans_High         : Boolean;     { are colours high intensity? }
  Ans_Blink        : Boolean;     { are colours blinking? }
  FoundEscape      : Boolean;     { have we found #27 yet? }
  FoundBracket     : Boolean;     { have we found [ yet? }
  AnsiBuffer       : String;      { buffer to store escape sequence }
  BufPos           : LongInt;     { where's the end of the buffer?? }
  Temp_X           : Byte;        { temporary X position storage }
  Temp_Y           : Byte;        { temporary Y position storage }

implementation

uses {$IFDEF VirtualPascal} Use32,SysUtils,{$ENDIF} crt;

const
  { array of ansi colours }
  clIndex : Array[1..16] of byte = ($00,$04,$02,$06,$01,$05,$03,$07,$00,$04,$02,$06,$01,$05,$03,$07);

{$IFNDEF VirtualPascal}
Function StrToInt (S : String) : LongInt;
Var
 Code : Integer;
 TempInt : LongInt;
Begin
  Val(S,TempInt,Code);
  StrToInt := TempInt;
End;
{$ENDIF}

Procedure FlushAnsi;
Begin
  AnsiBuffer[0] := #0;
  Ans_Fore := 7;
  Ans_Back := 0;
  Ans_SX := 1;
  Ans_SY := 1;
  Ans_High := False;
  Ans_Blink := False;
  FoundEscape := False;
  FoundBracket := False;
  BufPos := 0;
  Temp_X := 0;
  Temp_Y := 0;
End;

Procedure ParseAnsi;
{ this does the actual parsing of a valid escape sequence
  #27 and [ are already stripped here. }
var
  TempInt : LongInt;
  TempStr : String;
  Done    : Boolean;

begin
  AnsiBuffer[0] := Chr(BufPos);
  done := false;
  Case AnsiBuffer[BufPos] of
    'J' : ClrScr;
    'K' : ClrEol;
    'm' :
        begin
          delete(ANSIBuffer,BufPos,1);
          Repeat
            if (pos(';',ANSIBuffer) <> 0) then
            begin
              TempStr := copy (ANSIBuffer,1,pos(';',ANSIBuffer)-1);
              delete (ANSIBuffer, 1, pos(';',ANSIBuffer));
            end
            else
              begin
                TempStr := ANSIBuffer;
                done := true;
              end;
            Case StrToInt(TempStr) of
              0 :
                begin
                  Ans_High := False;
                  Ans_Fore := 7;
                  Ans_Back := 0;
                end;
              1 : Ans_High := True;
              2 : Ans_High := False;
              5 : Ans_Blink := True;
             30..47 :
                    begin
                      if ((StrToInt(TempStr) >29) and (StrToInt(TempStr) <38)) then
                        Ans_Fore := clIndex[StrToInt(TempStr)-29]
                      else if ((StrToInt(TempStr) >39) and (StrToInt(TempStr) <48)) then
                        Ans_Back := clIndex[StrToInt(TempStr)-31];
                    end;
            end;
            if (Ans_High) then TextColor(Ans_Fore+8) else TextColor(Ans_Fore);
            TextBackground(Ans_Back);
            if (Ans_Blink) then TextAttr := TextAttr or 128;
          Until (Done = true)
        end;
    'A' :
          if (Length(ANSIBuffer) = 1) then GotoXY(WhereX,WhereY+1)
          else
          begin
            delete(ANSIBuffer,BufPos,1);
            GotoXY(WhereX,WhereY - StrToInt(ANSIBuffer));
          end;
    'B' :
          if (Length(ANSIBuffer) = 1) then GotoXY(WhereX,WhereY-1)
          else
          begin
            delete(ANSIBuffer,BufPos,1);
            GotoXY(WhereX,WhereY + StrToInt(ANSIBuffer));
          end;
    'C' :
          if (Length(ANSIBuffer) = 1) then GotoXY(WhereX + 1,WhereY)
          else
          begin
            delete(ANSIBuffer,BufPos,1);
            GotoXY(WhereX + StrToInt(ANSIBuffer),WhereY);
          end;
    'D' :
          if (Length(ANSIBuffer) = 1) then GotoXY(WhereX - 1,WhereY)
          else
          begin
            delete(ANSIBuffer,BufPos,1);
            GotoXY(WhereX - StrToInt(ANSIBuffer),WhereY);
          end;
    's' :
          begin
            Ans_SX := WhereX;
            Ans_SY := WhereY;
          end;
    'u' : GotoXY(Ans_SX,Ans_SY);
'H','F','f' :
{ not sure wether F or f is the correct code, different references
  show one or the other. It shouldn't hurt to support both. }
          begin                                                         {rp}
            if (Length(ANSIBuffer) = 1) then GotoXY(1,1) else           {rp}
            begin                                                       {rp}
              delete(ANSIBuffer,BufPos,1);                              {rp}
              Temp_X := 255;                                            {rp}
              Temp_Y := 255;                                            {rp}
              TempStr := Copy(ANSIBuffer, 1, Pos(';', ANSIBuffer) - 1); {rp}
              if (TempStr <> '') then                                   {rp}
              Temp_Y := StrToInt(TempStr);                              {rp}
              Delete(ANSIBuffer,1,pos(';', ANSIBuffer));                {rp}
              if (ANSIBuffer <> '') then                                {rp}
              Temp_X := StrToInt(ANSIBuffer);                           {rp}
              if (Temp_X <> 255) and (Temp_Y <> 255) then               {rp}
              GotoXY(Temp_X, Temp_Y);                                   {rp}
            end;                                                        {rp}
          end;                                                          {rp}
    end;                                                                {rp}
end;                                                                    {rp}

Procedure FindAnsi (S : Char);
{ This pieces together a valid sequence and sends it to the parser! }
var
  TempInt : LongInt;
begin
  if (s = #27) then FoundEscape := True;
  if ((s = '[') and FoundEscape) then FoundBracket := True;
  if ((s <> '[') and (FoundBracket = True)) then
  begin
    BufPos := BufPos + 1;
    AnsiBuffer[BufPos] := s;
    if (pos(AnsiBuffer[BufPos],'HfFABCDnsuJKmh') <> 0) then
      begin
        ParseAnsi;              { part of escape sequence, save it! }
        FoundEscape := False;
        FoundBracket := False;
        BufPos := 0;
        AnsiBuffer := '';
      end;
   end
    else if ((s = '[') and (FoundEscape = False)) or ((s <>'[') and (s<>#27)) then
      Write (S);
end;


Procedure AWrite(s : string);
var TempInt : LongInt;
begin
  For TempInt := 1 to Length(s) do
    FindAnsi (s[TempInt]);
end;

Procedure AWriteLn (s : string);
begin
  AWrite(s + #13+#10);
end;


begin
  FoundEscape := False;
  FoundBracket := False;

  BufPos := 0;
end.
