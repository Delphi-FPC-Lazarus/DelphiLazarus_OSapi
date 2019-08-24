unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmTest = class(TForm)
    btnProp: TButton;
    btnOpenWith: TButton;
    btnCopyFilsToClipboard: TButton;
    Memo1: TMemo;
    btnExec: TButton;
    edpar: TEdit;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    btnCopyDirContent: TButton;
    btnShellExec: TButton;
    btnFileSizeLarge: TButton;
    OpenDialog1: TOpenDialog;
    Label1: TLabel;
    memOut: TMemo;
    memErr: TMemo;
    procedure btnPropClick(Sender: TObject);
    procedure btnOpenWithClick(Sender: TObject);
    procedure btnCopyFilsToClipboardClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnExecClick(Sender: TObject);
    procedure btnCopyDirContentClick(Sender: TObject);
    procedure btnShellExecClick(Sender: TObject);
    procedure btnFileSizeLargeClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  frmTest: TfrmTest;

implementation

{$R *.dfm}

uses syspfadutil_unit, os_api_unit;

procedure TfrmTest.btnExecClick(Sender: TObject);
var OutPutList, ErrorList: TStringStream;
    scmd, Error:string;
begin
 OutPutList := TStringStream.Create;
 ErrorList := TStringStream.Create;
 try
   //scmd:= edtExtDecoder.Text;
   //scmd:= StringReplace(scmd, '%i', IncludeTrailingPathDelimiter(extractfilepath(application.ExeName))+'Test.FLAC', [rfReplaceAll]+[rfIgnoreCase]);
   //scmd:= StringReplace(scmd, '%o', IncludeTrailingPathDelimiter(gettempdir)+'Test.Wav', [rfReplaceAll]+[rfIgnoreCase]);

   if not fileexists('..\..\ExitCodeTest\ExitCodeTest.exe') then
   begin
     showmessage('Bitte erst ExitCodeTest kompilieren!');
     exit;
   end;

   scmd:= IncludeTrailingPathDelimiter(ExtractFilePath(application.ExeName));
   scmd:= scmd + '..\..\ExitCodeTest\ExitCodeTest.exe '+edpar.Text;

   memOut.Clear;
   memErr.Clear;

   if RadioButton1.Checked then
   begin
    if GetConsoleOutput(scmd,OutPutList,ErrorList, 10*1024) then
     showmessage('ok')
    else
     showmessage('nicht ok');

    memOut.Text:= OutPutList.DataString;
    memErr.Text:= ErrorList.DataString;
   end;
   if RadioButton2.Checked then
   begin
    if ExecProcess(scmd,Error, 10*1000) then
     showmessage('ok')
    else
     showmessage('nicht ok');

    memErr.Text:= Error;
   end;

 finally
   OutPutList.Free;
   ErrorList.Free;

 end;
end;


procedure TfrmTest.btnShellExecClick(Sender: TObject);
begin
 //Shellexecute_safe('open', 'explorer', '', '', SHOW_FULLSCREEN);
 Shellexecute_safe('open', 'notepad', 'c:\temp\test.txt', '', SHOW_FULLSCREEN);
end;

procedure TfrmTest.btnPropClick(Sender: TObject);
begin
 if not ShowProperties(application.Handle, application.ExeName, pchar('')) then
  showmessage('Fehler');
end;

procedure TfrmTest.btnOpenWithClick(Sender: TObject);
begin
 if not OpenWithDialog(application.ExeName) then
  showmessage('Fehler');
end;

procedure TfrmTest.btnCopyFilsToClipboardClick(Sender: TObject);
begin
 CopyFilesToClipboard(application.ExeName);
end;

procedure TfrmTest.btnCopyDirContentClick(Sender: TObject);
begin
 CopyDirContent(IncludeTrailingPathDelimiter(extractfilepath(application.ExeName)), 'C:\temp\');
end;

procedure TfrmTest.btnFileSizeLargeClick(Sender: TObject);
var s:int64;
begin
  if not opendialog1.Execute then exit;
  s:= FileSizeLarge(opendialog1.FileName);
  //showmessage(inttostr(s)+#13#10+inttostr(s div 1024 div 1024));
  showmessage(format('%d Bytes / %d MB / %1.2f GB', [s, s div 1024 div 1024, s / 1024 / 1024 / 1024]));
end;

procedure TfrmTest.FormCreate(Sender: TObject);
var ma,mi:integer;
    vstr,istr:string;
begin
 memo1.Lines.Add(GetAppVersionStr(true));
 memo1.Lines.Add('');
 if GetUnix then
  memo1.Lines.Add('UNIX Betriebssystem');
 if GetWineAvail then
  memo1.Lines.Add('WINE erkannt');
 memo1.Lines.Add(getuserdir);
 memo1.Lines.Add(getalluserdir);
 memo1.Lines.Add(getappdatadir);
 memo1.Lines.Add(getprogDir);
 memo1.Lines.Add(GetProgDirx64);
 memo1.lines.Add('');
 memo1.Lines.Add(GetStartDir);
 memo1.Lines.Add(GetdataDir('Testanwendung', true));
 memo1.lines.Add('');
 memo1.Lines.Add(ShowDriveType('c'));
 if DiskInDrive('c') then memo1.Lines.Add('DiskInDrive=true') else memo1.Lines.Add('DiskInDrive=false');
 memo1.Lines.Add(ShowDriveType('d'));
 if DiskInDrive('d') then memo1.Lines.Add('DiskInDrive=true') else memo1.Lines.Add('DiskInDrive=false');
 memo1.lines.Add('');

 if GetOSVersion(ma,mi,vstr) then
 begin
   memo1.Lines.Add(vstr);
 end;

 memo1.Lines.Add('');
 memo1.Lines.Add(benutzername);

end;

end.
