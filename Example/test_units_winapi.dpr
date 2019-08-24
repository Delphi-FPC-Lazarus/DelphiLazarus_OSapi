program test_units_winapi;

//FastMM4 in '..\..\_ShareExtern\FastMM\FastMM4.pas',
//FastMM4Messages in '..\..\_ShareExtern\FastMM\FastMM4Messages.pas',

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {frmTest},
  os_api_unit in '..\os_api_unit.pas',
  syspfadutil_unit in '..\syspfadutil_unit.pas';

{$R *.res}

begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown:= true;
  {$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmTest, frmTest);
  Application.Run;
end.
