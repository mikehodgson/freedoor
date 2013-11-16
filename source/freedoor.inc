const
  isLocal : Boolean = False;         { Are we running Local Only? }
  isStats : Boolean = True;          { Is the status bar dislplayed? }
  FirstTime : Boolean = True;        { Has the status bar been drawn yet? }

  isExtended : Boolean = False;      { Is the current input char Extended }

  StatFore  : Byte = $0F;
  StatBack  : Byte = $04;
  PAUSE_STRING  : String = '<PAUSE>'; {Modify this!}
  ProgName  : String = 'Another FreeDoor Program';

  ASCII_GRAPH   : Integer = 0;
  ANSI_GRAPH    : Integer = 1;
  AVT_GRAPH     : Integer = 2;
  RIP_GRAPH     : Integer = 3;
  MAX_GRAPH     : Integer = 4;

{ Masks for use in CMaskInput }
{
        MASK_ALPHA allows only letters to be entered
        MASK_NUM allows only numbers
        MASK_ALPHANUM allows only numbers and letters
        MASK_NOSPACE requires the string entered to contain no spaces
        MASK_SPECIAL allows only non-alphanumeric characters
}

  MASK_ALL      : String = '';
  MASK_ALPHA    : String = '1234567890!@#$%^&*()-=_+`~[]{}\|;:''",<.>/?';
  MASK_NUM      : String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()-=_+`~[]{}\|;:''",<.>/?';
  MASK_ALPHANUM : String = '!@#$%^&*()-=_+`~[]{}\|;:''",<.>/?';
  MASK_NOSPACE  : String = ' ';
  MASK_SPECIAL  : String = '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  MASK_COLOUR   : String = #27+'[1;37;44m';

  MASK_PWCHAR   : String = '*';

{ User record, this is where info from dropfiles is stored }

Type TfdUserInfo = Record
  RealName  : String;
  Handle    : String;
  CityState : String;
  ACS       : LongInt;
  TimeLeft  : LongInt;
  TotalTime : LongInt;
  ComPort   : LongInt;
  ConnType  : Byte;                {0 = local, 1 = modem, 2 = telnet}
  Baud      : LongInt;
  Node      : String[3];
  GraphMode : Byte;
  DropFile  : String;
  DropType  : Byte;                {0 = local, 1 = door.sys, 2 = door32.sys, 3 = dorinfox.def}
  {Available only when DOOR32.SYS is used}
  BBSID     : String;              {BBS name and version, ie: "Mystic 1.07"}
  RecPos    : LongInt;             {User record position in BBS data file}
end;

(* Not used yet! *)
Type TMenu = Record
  Title     : String[20];                 { Title of menu }
  HiFore    : Byte;                       { Highlight Colours }
  HiBack    : Byte;
  MnuFore   : Byte;                       { Menu Colours }
  MnuBack   : Byte;
  NumOpts   : Integer;
  DfltOpt   : Integer;                    { Number of Default Option }
  Options   : Array[1..20] of String[20]; { Max 20 Options }
end;

(* Not Used Yet! *)
Type TMessageQueue = Record
  FromUser    : String[30];
  FromNode    : String[3];
  FromMessage : String;
  Next        : Integer;
end;

Var
  { Messaging }
  MsgQueue      : Array[1..10] of TMessageQueue; { Message Queue }
  MsgLast       : Integer;           { Total number of messages in Queue }
  MsgNext       : Integer;           { Next message to be read }
  { Timing }
  LastTime      : LongInt;           { Used for UpdateStatBar }
  SavedTime     : LongInt;
  LkTime        : LongInt;
  { User Data }
  fdInfo        : TfdUserInfo;       { User info variable }
  isLocalChar   : boolean;           { set to 1 if last char entered was local }
