unit Infra.DBConfig.IniFile;

interface

uses
  Classes,
  SysUtils,
  IniFiles,
  Infra.DBConfig,
  Infra.DBEngine.Contract;

type
  TDBConfigIniFile = class(TDBConfigDef)
  private
    FIniFile: TIniFile;

  const
    ASECTIONDB = 'DBCONFIG';

  protected
    function Driver: TDBDriver; override;
    function Host: string; override;
    function Port: Integer; override;
    function Database: string; override;
    function CharSet: string; override;
    function User: string; override;
    function Password: string; override;
    function Driver(const AValue: TDBDriver): IDbEngineConfig; overload; override;
    function Host(const AValue: string): IDbEngineConfig; overload; override;
    function Port(const AValue: Integer): IDbEngineConfig; overload; override;
    function Database(const AValue: string): IDbEngineConfig; overload; override;
    function CharSet(const AValue: string): IDbEngineConfig; overload; override;
    function User(const AValue: string): IDbEngineConfig; overload; override;
    function Password(const AValue: string): IDbEngineConfig; overload; override;
  public
    constructor Create(const APrefixVariable: string); override;
    destructor Destroy; override;

    class function New(const APrefixVariable: string): IDbEngineConfig; override;
  end;

implementation

uses
  Infra.SysInfo;

function TDBConfigIniFile.CharSet: string;
begin
  Result := FIniFile.ReadString(ASECTIONDB, SConfigCharSet, '');
end;

function TDBConfigIniFile.CharSet(const AValue: string): IDbEngineConfig;
begin
  Result := Self;
  FIniFile.WriteString(ASECTIONDB, SConfigCharSet, AValue);
end;

constructor TDBConfigIniFile.Create(const APrefixVariable: string);
begin
  inherited;
  FIniFile := TIniFile.Create(SystemInfo.AppPath + APrefixVariable + SystemInfo.AppName + '.ini');
end;

function TDBConfigIniFile.Database: string;
begin
  Result := FIniFile.ReadString(ASECTIONDB, SConfigDatabase, '');
end;

function TDBConfigIniFile.Database(const AValue: string): IDbEngineConfig;
begin
  Result := Self;
  FIniFile.WriteString(ASECTIONDB, SConfigDatabase, AValue);
end;

destructor TDBConfigIniFile.Destroy;
begin
  FIniFile.Free;
  inherited;
end;

function TDBConfigIniFile.Driver(const AValue: TDBDriver): IDbEngineConfig;
begin
  Result := Self;
  FIniFile.WriteString(ASECTIONDB, SConfigDriver, AValue.ToString);
end;

function TDBConfigIniFile.Driver: TDBDriver;
begin
  Result := StrToDBDriver(FIniFile.ReadString(ASECTIONDB, SConfigDriver, ''));
end;

function TDBConfigIniFile.Host: string;
begin
  Result := FIniFile.ReadString(ASECTIONDB, SConfigHost, '');
end;

class function TDBConfigIniFile.New(
  const APrefixVariable: string): IDbEngineConfig;
begin
  Result := Self.Create(APrefixVariable);
end;

function TDBConfigIniFile.Password: string;
begin
  Result := FIniFile.ReadString(ASECTIONDB, SConfigPassword, '');
end;

function TDBConfigIniFile.Port: Integer;
begin
  Result := FIniFile.ReadInteger(ASECTIONDB, SConfigPort, 0);
end;

function TDBConfigIniFile.User: string;
begin
  Result := FIniFile.ReadString(ASECTIONDB, SConfigUser, '');
end;

function TDBConfigIniFile.Host(const AValue: string): IDbEngineConfig;
begin
  Result := Self;
  FIniFile.WriteString(ASECTIONDB, SConfigHost, AValue);
end;

function TDBConfigIniFile.Password(const AValue: string): IDbEngineConfig;
begin
  Result := Self;
  FIniFile.WriteString(ASECTIONDB, SConfigPassword, AValue);
end;

function TDBConfigIniFile.Port(const AValue: Integer): IDbEngineConfig;
begin
  Result := Self;
  FIniFile.WriteInteger(ASECTIONDB, SConfigPort, AValue);
end;

function TDBConfigIniFile.User(const AValue: string): IDbEngineConfig;
begin
  Result := Self;
  FIniFile.WriteString(ASECTIONDB, SConfigUser, AValue);
end;

end.
