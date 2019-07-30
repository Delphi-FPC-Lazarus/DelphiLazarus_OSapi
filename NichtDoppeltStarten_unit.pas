{
  Programm nicht doppelt startbar - ACHTUNG: MUTEX NAME EINDEUTIG

  08/2012 XE2 kompatibel
  02/2016 XE10 x64 Test
  xx/xxxx FPC Ubuntu

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

{$I ..\..\share_settings.inc}
unit NichtDoppeltStarten_unit;

interface

implementation

uses
{$IFNDEF FPC}System.UITypes, {$ENDIF}
  Windows, Dialogs, Sysutils, Forms;

var
  mName: string; // Mutexname
  mHandle: THandle = INVALID_HANDLE_VALUE; // Mutexhandle

resourcestring
  rsstillrunning = 'Anwendung "%s" läuft bereits!';

Initialization

mName := extractfilename(application.ExeName);
mName := trim(mName);
if length(mName) < 1 then
  exit;

mHandle :=
{$IFDEF FPC}CreateMutexW{$ELSE}CreateMutex{$ENDIF}(nil, True, pchar(mName));
if GetLastError = ERROR_ALREADY_EXISTS then
begin
  messagedlg(format(rsstillrunning, [mName]), mtwarning, [mbok], 0);
  Halt;
end;

finalization

if (mHandle <> 0) and (mHandle <> INVALID_HANDLE_VALUE) then
  CloseHandle(mHandle)

end.
