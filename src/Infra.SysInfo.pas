unit Infra.SysInfo;

{$i Infra.inc}

interface

{$IFDEF FPC}
{$MODESWITCH advancedRecords}
{$ENDIF}


uses
  SysUtils,
  Classes,
  Types,
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF}
  {$IFNDEF FPC}
  {$IFDEF NEXTGEN}
  IOUtils,
  {$IFDEF ANDROID}
  Androidapi.Helpers,
  {$ENDIF}
  {$IFDEF IOS}
  Macapi.CoreFoundation,
  iOSApi.Foundation,
  {$ENDIF}
  {$ENDIF}
  {$ENDIF}
  Infra.Files;

type

  TSystemInfo = record
  private
    fAppName: string;
    fAppVersion: string;
    fAppPath: string;
    fHostName: string;
    fUserName: string;
    fOSVersion: string;
    fCPUCores: Integer;
    fProcessId: DWORD;
    function GetOSVersion: string;
  public
    procedure GetInfo;
    property AppName: string read fAppName;
    property AppVersion: string read fAppVersion;
    property AppPath: string read fAppPath;
    property HostName: string read fHostName;
    property UserName: string read fUserName;
    property OsVersion: string read fOSVersion;
    property CPUCores: Integer read fCPUCores;
    property ProcessId: DWORD read fProcessId;
  end;

var
  SystemInfo: TSystemInfo;

implementation

{ TSystemInfo }

function GetComputerName: string;
{$IFDEF MSWINDOWS}
var
  dwLength: DWORD;
begin
  dwLength := 253;
  SetLength(Result, dwLength + 1);
  if not Windows.GetComputerName(pchar(Result), dwLength) then
    Result := 'Not detected!';
  Result := pchar(Result);
end;
{$ELSE}
{$IF DEFINED(FPC) AND DEFINED(LINUX)}


begin
  Result := GetEnvironmentVariable('COMPUTERNAME');
end;
{$ELSE} // Android gets model name
{$IFDEF NEXTGEN}


begin
  {$IFDEF ANDROID}
  Result := JStringToString(TJBuild.JavaClass.MODEL);
  {$ELSE} // IOS
  Result := GetDeviceModel;
  {$ENDIF}
end;
{$ELSE}
{$IFDEF DELPHILINUX}


var
  phost: PAnsiChar;
begin
  try
    phost := AllocMem(256);
    try
      if gethostname(phost, _SC_HOST_NAME_MAX) = 0 then
      begin
        {$IFDEF DEBUG}
        Result := Copy(Trim(phost), 1, Length(Trim(phost)));
        {$ELSE}
        Result := Copy(phost, 1, Length(phost));
        {$ENDIF}
      end
      else
        Result := 'N/A.';
    finally
      FreeMem(phost);
    end;
  except
    Result := 'N/A';
  end;
end;
{$ELSE}

// OSX
begin
  Result := NSStrToStr(TNSHost.Wrap(TNSHost.OCClass.currentHost).localizedName);
end;
{$ENDIF}
{$ENDIF}
{$IFEND}
{$ENDIF}


function GetLoggedUserName: string;
{$IFDEF MSWINDOWS}
const
  cnMaxUserNameLen = 254;
var
  sUserName: string;
  dwUserNameLen: DWORD;
begin
  dwUserNameLen := cnMaxUserNameLen - 1;
  SetLength(sUserName, cnMaxUserNameLen);
  GetUserName(pchar(sUserName), dwUserNameLen);
  SetLength(sUserName, dwUserNameLen);
  Result := sUserName;
end;
{$ELSE}
{$IF DEFINED(FPC) AND DEFINED(LINUX)}


begin
  Result := GetEnvironmentVariable('USERNAME');
end;
{$ELSE}


var
  {$IFNDEF NEXTGEN}
  plogin: PAnsiChar;
  {$ELSE}
  plogin: MarshaledAString;
  {$ENDIF}
begin
  {$IFDEF POSIX}
  try
    plogin := getlogin;
    Result := Copy(plogin, 1, Length(Trim(plogin)));
  except
    Result := 'N/A';
  end;
  {$ELSE}
  Result := 'N/A';
  {$ENDIF}
  // raise ENotImplemented.Create('Not Android GetLoggedUserName implemented!');
end;
{$IFEND}
{$ENDIF}


function GetAppVersionFullStr: string;
{$IFDEF MSWINDOWS}
var
  Exe: string;
  Size, Handle: DWORD;
  Buffer: TBytes;
  FixedPtr: PVSFixedFileInfo;
begin
  Result := '';
  Exe := ParamStr(0);
  Size := GetFileVersionInfoSize(pchar(Exe), Handle);
  if Size = 0 then
  begin
    // RaiseLastOSError;
    // no version info in file
    Exit;
  end;
  SetLength(Buffer, Size);
  if not GetFileVersionInfo(pchar(Exe), Handle, Size, Buffer) then
    RaiseLastOSError;
  if not VerQueryValue(Buffer, '\', Pointer(FixedPtr), Size) then
    RaiseLastOSError;
  if (LongRec(FixedPtr.dwFileVersionLS).Hi = 0) and (LongRec(FixedPtr.dwFileVersionLS).Lo = 0) then
  begin
    Result := Format('%d.%d',
      [LongRec(FixedPtr.dwFileVersionMS).Hi, // major
      LongRec(FixedPtr.dwFileVersionMS).Lo]); // minor
  end
  else if (LongRec(FixedPtr.dwFileVersionLS).Lo = 0) then
  begin
    Result := Format('%d.%d.%d',
      [LongRec(FixedPtr.dwFileVersionMS).Hi, // major
      LongRec(FixedPtr.dwFileVersionMS).Lo, // minor
      LongRec(FixedPtr.dwFileVersionLS).Hi]); // release
  end
  else
  begin
    Result := Format('%d.%d.%d.%d',
      [LongRec(FixedPtr.dwFileVersionMS).Hi, // major
      LongRec(FixedPtr.dwFileVersionMS).Lo, // minor
      LongRec(FixedPtr.dwFileVersionLS).Hi, // release
      LongRec(FixedPtr.dwFileVersionLS).Lo]); // build
  end;
end;
{$ELSE}
{$IF DEFINED(FPC) AND DEFINED(LINUX)}


var
  version: TProgramVersion;
begin
  if GetProgramVersion(version) then
    Result := Format('%d.%d.%d.%d', [version.Major, version.Minor, version.Revision, version.Build])
  else
    Result := '';
end;
{$ELSE}
{$IFDEF NEXTGEN}
{$IFDEF ANDROID}


var
  PkgInfo: JPackageInfo;
begin
  PkgInfo := SharedActivity.getPackageManager.getPackageInfo(SharedActivity.getPackageName, 0);
  Result := JStringToString(PkgInfo.versionName);
end;
{$ELSE}

// IOS
var
  AppKey: Pointer;
  AppBundle: NSBundle;
  BuildStr: NSString;
begin
  AppKey := (StrToNSStr('CFBundleVersion') as ILocalObject).GetObjectID;
  AppBundle := TNSBundle.Wrap(TNSBundle.OCClass.mainBundle);
  BuildStr := TNSString.Wrap(AppBundle.infoDictionary.objectForKey(AppKey));
  Result := UTF8ToString(BuildStr.UTF8String);
end;
{$ENDIF}
{$ELSE}
{$IFDEF OSX}


var
  AppKey: Pointer;
  AppBundle: NSBundle;
  BuildStr: NSString;
begin
  AppKey := (StrToNSStr('CFBundleVersion') as ILocalObject).GetObjectID;
  AppBundle := TNSBundle.Wrap(TNSBundle.OCClass.mainBundle);
  BuildStr := TNSString.Wrap(AppBundle.infoDictionary.objectForKey(AppKey));
  Result := UTF8ToString(BuildStr.UTF8String);
end;
{$ELSE}


begin
  Result := '';
end;
{$ENDIF}
{$ENDIF}
{$IFEND}
{$ENDIF}


procedure TSystemInfo.GetInfo;
begin
  {$IFNDEF NEXTGEN}
  if IsLibrary then
    fAppName := ExtractFileNameWithoutExt(GetModuleName(0))
  else
    fAppName := ExtractFileNameWithoutExt(ParamStr(0));
  {$ELSE}
  {$IFDEF ANDROID}
  fAppName := JStringToString(SharedActivityContext.getPackageName);
  {$ELSE}
  fAppName := TNSString.Wrap(CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle, kCFBundleIdentifierKey)).UTF8String;
  {$ENDIF}
  {$ENDIF}
  fAppVersion := GetAppVersionFullStr;
  {$IFNDEF NEXTGEN}
  if IsLibrary then
    fAppPath := ExtractFilePath(GetModuleName(0))
  else
    fAppPath := ExtractFilePath(ParamStr(0));
  {$ELSE}
  fAppPath := TPath.GetDocumentsPath;
  {$ENDIF}
  {$IFDEF DELPHILINUX}
  fUserName := GetLoggedUserName;
  {$ELSE}
  fUserName := Trim(GetLoggedUserName);
  {$ENDIF}
  fHostName := GetComputerName;
  fOSVersion := GetOSVersion;
  fCPUCores := CPUCount;
  {$IFDEF MSWINDOWS}
  fProcessId := GetCurrentProcessID;
  {$ELSE}
  {$ENDIF}
end;

function TSystemInfo.GetOSVersion: string;
begin
  Result := {$IFDEF FPC}
  {$I %FPCTARGETOS%}+'-' + {$I %FPCTARGETCPU%}
  {$ELSE}
  {$IFDEF DELPHIXE_UP}
    TOSVersion.ToString
  {$ELSE}
    ''
  {$ENDIF}
  {$ENDIF};
end;

initialization

try
  SystemInfo.GetInfo;
except
  {$IFDEF MSWINDOWS}
  on E: Exception do
  begin
    raise Exception.CreateFmt('Error getting SystemInfo: %s', [E.Message]);
  end;
  {$ENDIF}
end;

end.
