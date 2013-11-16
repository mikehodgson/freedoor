Uses Freedoor;
var
  MyChar : Char;

begin
  progname:='FreeDoor Example Program';
  InitDoorDriver;
  CClrScr;
  CGotoXY (15,3);
  CWrite ('15,3 Press a key!');
  CGotoXY (20,20);
  CWrite ('20,20');
  CGotoXY (1,10);
  CWrite ('1,10');
  CGetChar(MyChar);
end.
