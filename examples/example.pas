{
        This isn't an 'example' per-se, this is just a program I use
        to test different functionality. You can see some basic usage
        of freedoor here though.
}

uses freedoor;

var
  TempStr : String;
  Ch : Char;
begin
  progname:='FreeDoor Example Program';
  InitDoorDriver;
  CClrScr;
  CWriteLn ('`70 FreeDoor Example Program `07');
  CWriteLn ('');
  CWriteLn ('`09Enter a sentence below: ');
  TempStr := CMaskInputPW (MASK_ALL, 72);
  CWriteLn ('');
  CWriteLn ('`0FYou entered: `07' + TempStr);
  CPause;
  CClrScr;
  CWriteLn ('`07Your Name:        `0F ' + fdInfo.RealName);
  CWriteLn ('`07Your Handle:      `0F ' + fdInfo.Handle);
  CWriteLn ('`07Your City/State:  `0F ' + fdInfo.CityState);
  CWriteLn ('`07Node Number:      `0F ' + fdInfo.Node);
  CWriteLn ('`07Path to DropFile: `0F ' + fdInfo.DropFile);
  CWrite ('`07DropFile Type:     `0D');
  CWriteLong (fdInfo.DropType);
  case fdInfo.droptype of
   0:cwriteln('  (no dropfile)');
   1:cwriteln('  (door.sys)');
   2:cwriteln('  (door32.sys)');
   3:cwriteln('  (dorinfo)');
  end;{case}

  CWrite ('`07Port Number:       `0D');
  CWriteLnLong (fdInfo.ComPort);
  CWrite ('`07Port Type:         `0D');
  CWriteLnLong (fdInfo.ConnType);
  CWriteLn ('`07BBSID:            `0D ' + fdInfo.BBSID);
  CWriteLn ('');
  CWindow(1,1,10,10);
  CPause;
end.
