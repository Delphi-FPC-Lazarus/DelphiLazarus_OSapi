{
  Unit to ensure program starting only one time
  Add as first unit (or first unit after memorymanager) in project

  --------------------------------------------------------------------
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.

  THE SOFTWARE IS PROVIDED "AS IS" AND WITHOUT WARRANTY

  Last Maintainer: Peter Lorenz
  Is that code useful for you? Donate!
  Paypal webmaster@peter-ebe.de
  --------------------------------------------------------------------

}

{$I ..\share_settings.inc}
unit startoncemutex_unit;

interface

resourcestring
  rsstillrunning = 'Anwendung "%s" läuft bereits!';

implementation

{$IFNDEF UNIX}
// This is Code for Windows only.
// If you nee both, Windows and Unix, use UniqueInstance

uses
{$IFNDEF FPC}System.UITypes,{$ENDIF}
  Windows, Dialogs, Sysutils, Forms;

var
  mutexName: string;
  mutexHandle: THandle;

procedure mutex_init;
begin
  mutexName := extractfilename(application.ExeName);
  mutexName := trim(mutexName);
  if length(mutexName) < 1 then
    exit;

  mutexHandle :=
{$IFDEF FPC}CreateMutexW{$ELSE}CreateMutex{$ENDIF}(nil, True, pchar(mutexName));
  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
    if IsConsole then
    begin
      writeln(format(rsstillrunning, [mutexName]));
      readln;
    end
    else
    begin
      messagedlg(format(rsstillrunning, [mutexName]), mtwarning, [mbok], 0);
    end;
    Halt;
  end;
end;

procedure mutex_done;
begin
  if (mutexHandle <> INVALID_HANDLE_VALUE) and (mutexHandle <> 0) then
  begin
    CloseHandle(mutexHandle);
  end;
end;

initialization

mutex_init;

finalization

mutex_done;

{$ENDIF}

end.
