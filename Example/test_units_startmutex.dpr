program test_units_startmutex;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  SysUtils,
  startoncemutex in '..\startoncemutex.pas';

// -> code that delphi's qa-tool should find, just to see if qa-tool is running. never call that!
procedure qatool_test;
begin
  qatool_test;
end;
// <-

begin
  try
    { TODO -oUser -cConsole Main : Code hier einfügen }
    writeln('Test application');
    writeln('Press return to stop');
    readln;
  except
    on E: Exception do
      writeln(E.ClassName, ': ', E.Message);
  end;

end.
