unit Infra.DBConfig;

interface

uses
  SysUtils,
  Infra.DBEngine.Contract;

type

  TDBConfig = class(TInterfacedObject, IDbEngineConfig)
  private
    FPrefixVariable: string;
    function Driver: string;
    function Host: string;
    function Port: Word;
    function Database: string;
    function CharSet: string;
    function User: string;
    function Password: string;
  public
    constructor Create(const APrefixVariable: string);
    class function New(const APrefixVariable: string): IDbEngineConfig;
  end;

implementation

uses
  Infra.SysInfo;

function TDBConfig.CharSet: string;
begin
  Result := GetEnvironmentVariable(FPrefixVariable + 'DBCONFIG_CHARSET');
  if Result.IsEmpty then
    Result := 'utf8';
end;

constructor TDBConfig.Create(const APrefixVariable: string);
begin
  FPrefixVariable := APrefixVariable;
end;

function TDBConfig.Database: string;
var
  LDir: string;
begin
  Result := GetEnvironmentVariable(FPrefixVariable + 'DBCONFIG_DATABASE');
  if Result.IsEmpty then
  begin
    LDir := SystemInfo.AppPath + 'data' + PathDelim;
    Result := LDir + SystemInfo.AppName;
  end;
  if not DirectoryExists(LDir) then
    CreateDir(LDir);
end;

function TDBConfig.Driver: string;
begin
  Result := GetEnvironmentVariable(FPrefixVariable + 'DBCONFIG_DRIVER');
  if Result.IsEmpty then
    Result := 'FB';
end;

function TDBConfig.Host: string;
begin
  Result := GetEnvironmentVariable(FPrefixVariable + 'DBCONFIG_HOST');
  if Result.IsEmpty then
    Result := '127.0.0.1';
end;

class function TDBConfig.New(
  const APrefixVariable: string): IDbEngineConfig;
begin
  Result := Self.Create(APrefixVariable);
end;

function TDBConfig.Password: string;
begin
  Result := GetEnvironmentVariable(FPrefixVariable + 'DBCONFIG_PASSWORD');
  if Result.IsEmpty then
    Result := 'masterkey';
end;

function TDBConfig.Port: Word;
begin
  Result := StrToIntDef(GetEnvironmentVariable(FPrefixVariable + 'DBCONFIG_PORT'), 3053);
end;

function TDBConfig.User: string;
begin
  Result := GetEnvironmentVariable(FPrefixVariable + 'DBCONFIG_USER');
  if Result.IsEmpty then
    Result := 'SYSDBA';
end;

end.
