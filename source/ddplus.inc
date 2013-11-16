{Notes..

Im sure there are places this could be better. I didnt/dont intend on
this to be a "end all, be all" for ddplus -> freedoor migration. This
is just meant as an easy way to get stuff compiled without having to
change every sread to cread and the like..

With that being said.. If you have something thatd work better than whats
here, let me know. Send it my way, Ill take a look, and will consider
adding it :)

- MP

}

procedure set_foreground(n:byte);
var s:string;
begin
  case n of
  0 : s:=#27+'[0;30m';
  1 : s:=#27+'[0;34m';
  2 : s:=#27+'[0;32m';
  3 : s:=#27+'[0;36m';
  4 : s:=#27+'[0;31m';
  5 : s:=#27+'[0;35m';
  6 : s:=#27+'[0;33m';
  7 : s:=#27+'[0;37m';
  8 : s:=#27+'[1;30m';
  9 : s:=#27+'[1;34m';
  10: s:=#27+'[1;32m';
  11: s:=#27+'[1;36m';
  12: s:=#27+'[1;31m';
  13: s:=#27+'[1;35m';
  14: s:=#27+'[1;33m';
  15: s:=#27+'[1;37m';
  end; {case}
  if (not isLocal) then Com_SendString(S);
  AWrite (S);
end;

procedure set_background(n:byte);
var s:string;
begin
  case n of
  0 : s:=#27+'[0;40m';
  1 : s:=#27+'[0;44m';
  2 : s:=#27+'[0;42m';
  3 : s:=#27+'[0;46m';
  4 : s:=#27+'[0;41m';
  5 : s:=#27+'[0;45m';
  6 : s:=#27+'[0;43m';
  7 : s:=#27+'[0;47m';
  end; {case}
  if (not isLocal) then Com_SendString(S);
  AWrite (S);
end;

procedure swrite(s:string);
begin
 cwrite(s);
end;

procedure swriteln(s:string);
begin
 cwriteln(s);
end;

procedure sgoto_xy(x,y:byte);
begin
 cgotoxy(x,y);
end;

procedure sclrscr;
begin
 cclrscr;
end;

procedure sclreol;
begin
 cclreol;
end;

function skeypressed:boolean;
begin
 skeypressed:=ckeypressed;
end;

procedure swritec(ch:char);
begin
 cwrite(ch);
end;

procedure swritexy(x,y:byte;s:string);
begin
 cgotoxy(x,y);
 cwrite(s);
end;

procedure set_color(f,b:byte);
begin
 set_foreground(f);
 set_background(b);
end;

procedure display_status;
begin
 updatestatusbar;
end;

function time_left:integer;
begin
 time_left := (fdinfo.timeleft div 60);
end;

function time_used:longint;
begin
 time_used := (fdinfo.totaltime - fdinfo.timeleft) div 60;
end;

procedure sread_char(var ch:char);
begin
 cgetchar(ch);
end;

procedure sread(var s:string);
begin
 creadln(s);
end;

procedure sendtext(s:string);
var a:longint;
begin
{ this could use some error checking.}
 com_sendblock(s,sizeof(s),a);
end;
