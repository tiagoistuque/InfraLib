unit Infra.DBConfig.EnvironmentVar;

interface

uses
  Classes,
  SysUtils,
  Infra.DBConfig,
  Infra.DBEngine.Contract;

type
  TDBConfigEnvironmentVar = class(TDBConfigDef)
  protected
    function Driver: TDBDriver; override;
    function Host: string; override;
    function Port: Integer; override;
    function Database: string; override;
    function CharSet: string; override;
    function User: string; override;
    function Password: string; override;
    function BuildDatabase: Boolean; override;
  public
    constructor Create(const APrefixVariable: string); override;
    class function New(const APrefixVariable: string): IDbEngineConfig; override;
  end;

implementation

uses
  Infra.SysInfo;

function TDBConfigEnvironmentVar.BuildDatabase: Boolean;
begin
  Result := StrToBoolDef(GetEnvironmentVariable(FPrefixVariable + SConfigBuildDB), False);
end;

function TDBConfigEnvironmentVar.CharSet: string;
begin
  Result := GetEnvironmentVariable(FPrefixVariable + SConfigDriver);
  if Result.IsEmpty then
    Result := 'utf8';
end;

constructor TDBConfigEnvironmentVar.Create(const APrefixVariable: string);
begin
  FPrefixVariable := APrefixVariable;
end;

function TDBConfigEnvironmentVar.Database: string;
var
  LDir: string;
begin
  Result := GetEnvironmentVariable(FPrefixVariable + SConfigDatabase);
  if Result.IsEmpty then
  begin
    LDir := SystemInfo.AppPath + 'data' + PathDelim;
    Result := LDir + SystemInfo.AppName;
  end;
  if not DirectoryExists(LDir) then
    CreateDir(LDir);
end;

function TDBConfigEnvironmentVar.Driver: TDBDriver;
begin
  Result := StrToDBDriver(GetEnvironmentVariable(FPrefixVariable + SConfigDriver));
  if Result = TDBDriver.unknown then
    Result := TDBDriver.Firebird;
end;

function TDBConfigEnvironmentVar.Host: string;
begin
  Result := GetEnvironmentVariable(FPrefixVariable + SConfigHost);
  if Result.IsEmpty then
    Result := '127.0.0.1';
end;

class function TDBConfigEnvironmentVar.New(
  const APrefixVariable: string): IDbEngineConfig;
begin
  Result := Self.Create(APrefixVariable);
end;

function TDBConfigEnvironmentVar.Password: string;
begin
  Result := GetEnvironmentVariable(FPrefixVariable + SConfigPassword);
  if Result.IsEmpty then
    Result := 'masterkey';
end;

function TDBConfigEnvironmentVar.Port: Integer;
begin
  Result := StrToIntDef(GetEnvironmentVariable(FPrefixVariable + SConfigPort), 3053);
end;

function TDBConfigEnvironmentVar.User: string;
begin
  Result := GetEnvironmentVariable(FPrefixVariable + SConfigUser);
  if Result.IsEmpty then
    Result := 'SYSDBA';
end;

end.
