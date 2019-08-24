program ExitCodeTest;

{$APPTYPE CONSOLE}

{$R *.res}

uses sysutils;

var i:integer;
begin
  Writeln('ExitCodeTest Console output');
  Writeln(inttostr(paramcount)+' Param');
  for i:= 0 to paramcount do
   writeln(ParamStr(i));

  if paramcount < 1 then halt(0);

  halt(StrToIntDef(paramstr(1), 255));
end.
