{
  Start- und Datenpfad-Verwaltung

  Dieses Modul stellt Startpfad und
  Datenpfad ensprechend dem verwendeten Betriebssystem zur Verfügung
  und legt den Datenpfad auch an falls dieser nicht existiert.
  Das Übergeordnete Programm braucht sich um nichts mehr kümmern.

  Achtung: Alle Pfade werden ohne Delimiter (\ bzw. /) am Ende zurückgegeben!
  Nicht ändern!
  (falls anders benötigt, übergeordnet im Programm anpassen)

  10/2012 portiert auf XE2 (Zugriff über Appdata kompatibel mit Win8 und Wine 1.5.6)
  02/2016 XE10 x64 Test
  xx/xxxx FPC Ubuntu

  --------------------------------------------------------------------
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.

  THE SOFTWARE IS PROVIDED "AS IS" AND WITHOUT WARRANTY

  Author: Peter Lorenz
  Is that code useful for you? Donate!
  Paypal webmaster@peter-ebe.de
  --------------------------------------------------------------------


}

{$I ..\share_settings.inc}
unit syspfadutil_unit;

interface

uses
{$IFNDEF UNIX}Windows, {$ENDIF}
{$IFNDEF FPC}System.UITypes, {$ENDIF}
  classes,
  forms,
  SysUtils,
  dialogs,
  stdctrls,
  graphics;

{ Startpfad für laufendes Programmes herausfinden -> startpfad_read }
function GetStartDir: string;
function IsStartDirUWP: Boolean;

{ Datenpfad für laufendes Programmes herausfinden -> startpfad_write }
function GetdataDir(anwendungsname: string;
  erzeugenwennnichtvorhanden: Boolean): string;

{ Hilfsfunktionen, freigegeben da auch anderweitig verwendbar }
function CreateDirFull(verz: string): Boolean;

function GetTempDir: string;

function GetUserDir: string;
function GetAlluserDir: string;
function GetAppdataDir: string;
function GetProgDir: string;
function GetProgDirx64: string;

resourcestring
  rscreateerror = 'Fehler: Verzeichnisstuktur konnte nicht angelegt werden!';

implementation

uses os_api_unit;

// =============================================================================

{$IFDEF UNIX}
{$IFDEF LINUX}

const
  pfad_tmp = '/tmp';

const
  pfad_prog = '/usr/bin';

const
  varname_home = 'HOME';
{$ENDIF}
{$IFDEF DARWIN}

const
  pfad_tmp = '/tmp';

const
  pfad_prog = '/Applications';

const
  varname_home = 'HOME';
{$ENDIF}
{$ELSE}

const
  pfad_progfilesdef = 'c:\Programme\';
  {
    Vorgabe (falls alles andere nicht funktioniert)
  }

const
  varname_progfiles = 'PROGRAMFILES';
  {
    %PROGRAMFILES%
    Immer vorhanden
  }

const
  varname_progfilesx86 = 'PROGRAMFILES(X86)';
  {
    %PROGRAMFILES(x86)%
    Unter 64 Bit Betriebssystemen vorhanden
  }

const
  varname_progfilesW6432 = 'PROGRAMW6432';
  {
    %PROGRAMFILES6432%
    Unter 64 Bit Betriebssystemen vorhanden
  }

const
  varname_alluserprofile: string = 'ALLUSERSPROFILE';
  {
    %ALLUSERSPROFILE%
    \Dokumente und Einstellungen\All Users\    (W2K-XP)
    \ProgramData\                              (Vista/7/8)
    \users\public\                             (Wine 1.5.6)
    Achtung: Zugriff auf Unterordner "Anwendungsdaten" wird unter Vista/7 umgelenkt (Userprofil) oder ignoriert (Programdata)
  }

const
  varname_userprofile: string = 'USERPROFILE';
  {
    %USERPROFILE%
    \Dokumente und Einstellungen\<Benutzer>    (W2K-XP)
    \users\<Benutzer>\                         (Vista/7/8)
    \users\<Benutzer>\                         (Wine 1.5.6)
    Achtung: Zugriff auf Unterordner "Anwendungsdaten" wird unter Vista/7 umgelenkt (Userprofil) oder ignoriert (Programdata)
  }

const
  varname_appdata: string = 'APPDATA';
  {
    <privater Anwendungsspeicher, beim deinstalliern gelöscht>  (UWP APPX)
    %APPDATA%
    \Dokumente und Einstellungen\<Benutzer>\Anwendungsdaten\    (W2K-XP)
    \users\<Benutzer>\AppData\Roaming\                          (Vista/7/8)
    \users\<Benutzer>\Application Data\                         (Wine 1.5.6)

    Gibt direkt den Pfad zum Datenpfad unter dem Benutzerprofil des eingeloggtem Benutzer zurück
  }

const
  identifier_uwp: string = 'WindowsApps';

{$ENDIF}
  // =============================================================================

function CreateDirFull(verz: string): Boolean;
begin
  Result := false;

  if length(verz) < 1 then
    exit;

  { falls nicht vorhanden, Struktur anlegen }
  verz := IncludeTrailingPathDelimiter(verz);
  if directoryexists(verz) = false then
  begin
    if not ForceDirectories(verz) then
      exit;
  end; { of Verzeichnis existiert nicht }

  { wenn das Zielverzeichnis jetzt existiert hat's geklappt }
  if directoryexists(verz) then
    Result := true;
end;

// =============================================================================

function GetTempDir: string;
{$IFDEF UNIX}
begin
  Result := pfad_tmp;
end;
{$ELSE}

var
  Dir: string;
  Len: DWord;
begin
  Result := '';

  SetLength(Dir, MAX_PATH);
  Len := {$IFDEF FPC}GetTempPathW{$ELSE}GetTempPath{$ENDIF}(MAX_PATH,
    PChar(Dir));
  if Len > 0 then
  begin
    SetLength(Dir, Len);
    Dir := ExcludeTrailingPathDelimiter(Dir);
    Result := Dir;
  end
  else
    RaiseLastOSError;
end;
{$ENDIF}
// =============================================================================

function GetUserDir: string;
var
  verzeichnis: string;
begin
  Result := '';

{$IFDEF UNIX}
  verzeichnis := GetEnvironmentVariable(varname_home);
{$ELSE}
  verzeichnis := GetEnvironmentVariable(varname_userprofile);
{$ENDIF}
  if not directoryexists(verzeichnis) then
    exit;

  { ggf. delimiter am ende ENTFERNEN }
  verzeichnis := ExcludeTrailingPathDelimiter(verzeichnis);

  { übergeben }
  Result := verzeichnis;
end;

function GetAlluserDir: string;
var
  verzeichnis: string;
begin
  Result := '';

{$IFDEF UNIX}
  exit; { so etwas gibt es unter UNIX nicht }
{$ELSE}
  verzeichnis := GetEnvironmentVariable(varname_alluserprofile);

  if not directoryexists(verzeichnis) then
    exit;

  { ggf. delimiter am ende ENTFERNEN }
  verzeichnis := ExcludeTrailingPathDelimiter(verzeichnis);

  { übergeben }
  Result := verzeichnis;
{$ENDIF}
end;

function GetAppdataDir: string;
var
  verzeichnis: string;
begin
  Result := '';

{$IFDEF UNIX}
  verzeichnis := GetEnvironmentVariable(varname_home);
{$ELSE}
  verzeichnis := GetEnvironmentVariable(varname_appdata);
{$ENDIF}
  if not directoryexists(verzeichnis) then
    exit;

  { ggf. delimiter am ende ENTFERNEN }
  verzeichnis := ExcludeTrailingPathDelimiter(verzeichnis);

  { übergeben }
  Result := verzeichnis;
end;

function GetProgDir: string;
var
  tmpstr: string;
  verzeichnis: string;
begin
  Result := '';

{$IFDEF UNIX}
  Result := pfad_prog;
{$ELSE}
  verzeichnis := pfad_progfilesdef;
  { vordefiniert für ganz alte systeme, rückgabe niemals leer }

  { Umgebungsvariablen abfragen:
    %programfiles%
    Immer vorhanden

    %programfiles(x86)%
    Unter 64 Bit Betriebssystemen vorhanden,
    falls dies so ist, dieses verwenden
  }

  tmpstr := GetEnvironmentVariable(varname_progfiles);
  if directoryexists(tmpstr) then
    verzeichnis := tmpstr;

  { folgendes überschreibt das vorherige - so gewollt! }
  tmpstr := GetEnvironmentVariable(varname_progfilesx86);
  if directoryexists(tmpstr) then
    verzeichnis := tmpstr;

  { ggf. delimiter am ende ENTFERNEN }
  verzeichnis := ExcludeTrailingPathDelimiter(verzeichnis);

  { übergeben }
  Result := verzeichnis;
{$ENDIF}
end;

function GetProgDirx64: string;
var
  tmpstr: string;
  verzeichnis: string;
begin
  Result := '';

{$IFDEF UNIX}
  Result := pfad_prog;
{$ELSE}
  verzeichnis := pfad_progfilesdef;
  { vordefiniert für ganz alte systeme, rückgabe niemals leer }

  { Umgebungsvariablen abfragen:
    %programfiles%
    Diese zeigt bei 64 Bit Systemen auf den 64 Bit Programmpfad,
    leider wird mit beim Aufruf von 32 Bit Prozessen der Programmpfad für 32 Bit zurückgeben.
    %programw6432%
    Liefert immer den Pfad für 64 Bit Programme
  }

  tmpstr := GetEnvironmentVariable(varname_progfilesW6432);
  if directoryexists(tmpstr) then
    verzeichnis := tmpstr;

  { ggf. delimiter am ende ENTFERNEN }
  verzeichnis := ExcludeTrailingPathDelimiter(verzeichnis);

  { übergeben }
  Result := verzeichnis;
{$ENDIF}
end;

function GetStartDir: string;
var
  verzeichnis: string;
begin
  Result := '';

  verzeichnis := extractfilepath(application.exename);

  { ggf. delimiter am ende ENTFERNEN }
  verzeichnis := ExcludeTrailingPathDelimiter(verzeichnis);

  { übergeben }
  Result := verzeichnis;
end;

function IsStartDirUWP: Boolean;
var
  sPfad, sTest: String;
begin
  Result := false;
{$IFNDEF UNIX}
  sPfad := lowercase(GetStartDir);
  sTest := lowercase(identifier_uwp);
  if strpos(PChar(sPfad), PChar(sTest)) <> nil then
    Result := true;
{$ENDIF}
end;

// =============================================================================

function GetdataDir(anwendungsname: string;
  erzeugenwennnichtvorhanden: Boolean): string;
{$IFDEF UNIX}
var
  datenverzeichnis: string;
begin
  Result := '';

  datenverzeichnis := GetUserDir + '/' + '.' + anwendungsname;

  if directoryexists(datenverzeichnis) then
  begin
    Result := datenverzeichnis;
  end
  else
  begin
    if erzeugenwennnichtvorhanden then
    begin
      if CreateDirFull(datenverzeichnis) then
      begin
        Result := datenverzeichnis;
      end
      else
      begin
        messagedlg(datenverzeichnis + #10#13 + rscreateerror, mtwarning,
          [mbok], 0);
        { Result bleibt leer }
      end;
    end;
  end;

end;
{$ELSE}
  function checkpfadschreibrecht(pfad: string): Boolean;
  var
    f: TFileStream;
    fbuf: array [0 .. 15] of byte;
  begin
    Result := false;

    f := nil;
    try
      { prüfe ob ein Pfad übergeben wurde }
      if length(pfad) < 1 then
        exit;
      { prüfe ob er existiert }
      if not directoryexists(pfad) then
        exit;
      { prüfe ob er schreibbar ist }
      f := TFileStream.create(IncludeTrailingPathDelimiter(pfad) +
        'schreibtest.debug', fmOpenReadWrite or fmCreate);
      FillChar(fbuf, sizeof(fbuf), 0); // ZeroMemory
      f.WriteBuffer(fbuf[0], sizeof(fbuf));
      FreeAndNil(f);

      Result := true;
    except
      on e: exception do
      begin
        FreeAndNil(f);
        exit;
      end;
    end;

    if fileexists(IncludeTrailingPathDelimiter(pfad) + 'schreibtest.debug') then
    begin
      if not deletefile(IncludeTrailingPathDelimiter(pfad) + 'schreibtest.debug')
      then
      begin
        //
      end;
    end;

  end;

var
  grundverzeichnis, datenverzeichnis: string;
  i: integer;
begin
  Result := '';

  datenverzeichnis := '';

  { Die Möglichkeiten durchprobieren, bei Treffer (Pfad bereits vorhanden)
    Rückgabe dieses Verzeichnisses und Ende.
    - Userpfad bevorzugt, sonst für alle User gültiges Verzeichnis
    - Programmpfad wird nicht mehr unterstützt (bei W2K/XP nur als Administrator schreibbar, bei Win7 umgelenkt)
  }

  { -> prüfe auf existierenden Datenpfad
    Durchlauf 1,2 : nur prüfen und ggf. übernehmen
    Durchlauf 11, 12: ggf. erzeugen, dann prüfen und ggf. übernehmen
  }
  i := 1;
  repeat
    ;

    case i of
      1, 11:
        begin
          datenverzeichnis := GetAppdataDir + Delimiter + anwendungsname;
          grundverzeichnis := GetAppdataDir;
        end;
      2, 12:
        begin // abwärtskompatibel zu alten Installationen oder manuell verschobenen Pfad
          datenverzeichnis := GetAlluserDir + Delimiter + 'Anwendungsdaten' +
            Delimiter + anwendungsname;
          grundverzeichnis := GetAlluserDir;
        end;
    end;

    { -> erzeugen }
    { ggf. datenpfad erzeugen wenn grundverzeichnis vorhanden und erstellbar }
    if (i > 10) and (erzeugenwennnichtvorhanden = true) then
    begin
      if directoryexists(grundverzeichnis + Delimiter) = true
      then { prüfung immer mit delmiter am Ende }
      begin
        if checkpfadschreibrecht(grundverzeichnis + Delimiter) = true then
        begin
          { Grundverzeichnis ist vorhanden und schreibbar
            -> Datenpfad erzeugen (wird dann unten nochmal geprüft und ggf. verwendet)
          }

          { Verzeichnisbaum bis Startpfad anlegen }
          if not directoryexists(datenverzeichnis) then
            if not CreateDirFull(datenverzeichnis) then
            begin
              messagedlg(datenverzeichnis + #10#13 + rscreateerror, mtwarning,
                [mbok], 0);
              { kein exit, einfach weiter laufen }
            end;

        end
      end;
    end;
    { <- erzeugen }

    { -> prüfen und verwenden }
    if directoryexists(datenverzeichnis + Delimiter) = true
    then { prüfung immer mit delimiter am Ende }
    begin
      if checkpfadschreibrecht(datenverzeichnis + Delimiter) = true then
      begin
        { Datenpfad gefunden -> Ende }

        { ggf. delimiter am ende ENTFERNEN }
        datenverzeichnis := ExcludeTrailingPathDelimiter(datenverzeichnis);

        Result := datenverzeichnis;
        exit;
      end;
    end;
    { <- prüfen und verwenden }

    inc(i);
    if i = 3 then
      i := 11;
    if i = 13 then
      i := 999; { sofortiges ende }

  until i >= 50; { next i }
  { <- prüfe auf existierenden Datenpfad }

  { Der Datenpfad konnte nicht ermittelt werden,
    existiert also nicht und konnte ggf. auch nicht erzeugt werden
  }

  { Fehler, Rückgabe leer }
  Result := '';
end;
{$ENDIF}
// =============================================================================

end.
