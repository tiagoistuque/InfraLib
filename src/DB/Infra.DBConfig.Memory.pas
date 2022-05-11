unit Infra.DBConfig.Memory;

interface

uses
  Classes,
  SysUtils,
  Infra.DBConfig,
  Infra.DBEngine.Contract;

type
  TDBConfigMemory = class(TDBConfigDef)
  private
    FBuildDatabase: Boolean;
    FCharSet: string;
    FDatabase: string;
    FDriver: TDBDriver;
    FHost: string;
    FPort: Integer;
    FUser: string;
    FPassword: string;
  protected
    function Driver: TDBDriver; override;
    function Host: string; override;
    function Port: Integer; override;
    function Database: string; override;
    function CharSet: string; override;
    function User: string; override;
    function Password: string; override;
    function GetExecuteMigrations: Boolean; override;
    function Driver(const AValue: TDBDriver): IDbEngineConfig; overload; override;
    function Host(const AValue: string): IDbEngineConfig; overload; override;
    function Port(const AValue: Integer): IDbEngineConfig; overload; override;
    function Database(const AValue: string): IDbEngineConfig; overload; override;
    function CharSet(const AValue: string): IDbEngineConfig; overload; override;
    function User(const AValue: string): IDbEngineConfig; overload; override;
    function Password(const AValue: string): IDbEngineConfig; overload; override;
    function SetExecuteMigrations(const AValue: Boolean): IDbEngineConfig; overload; override;
  public
    constructor Create(const APrefixVariable: string); override;
    class function New(const APrefixVariable: string): IDbEngineConfig; override;
  end;

implementation

{ TDBConfigMemory }

function TDBConfigMemory.SetExecuteMigrations(
  const AValue: Boolean): IDbEngineConfig;
begin
  Result := Self;
  FBuildDatabase := AValue;
end;

function TDBConfigMemory.GetExecuteMigrations: Boolean;
begin
  Result := FBuildDatabase;
end;

function TDBConfigMemory.CharSet(const AValue: string): IDbEngineConfig;
begin
  Result := Self;
  FCharSet := AValue;
end;

function TDBConfigMemory.CharSet: string;
begin
  Result := FCharSet;
end;

constructor TDBConfigMemory.Create(const APrefixVariable: string);
begin
  inherited;

end;

function TDBConfigMemory.Database(const AValue: string): IDbEngineConfig;
begin
  Result := Self;
  FDatabase := AValue;
end;

function TDBConfigMemory.Database: string;
begin
  Result := FDatabase;
end;

function TDBConfigMemory.Driver: TDBDriver;
begin
  Result := FDriver;
end;

function TDBConfigMemory.Driver(const AValue: TDBDriver): IDbEngineConfig;
begin
  Result := Self;
  FDriver := AValue;
end;

function TDBConfigMemory.Host(const AValue: string): IDbEngineConfig;
begin
  Result := Self;
  FHost := AValue;
end;

function TDBConfigMemory.Host: string;
begin
  Result := FHost;
end;

class function TDBConfigMemory.New(
  const APrefixVariable: string): IDbEngineConfig;
begin
  Result := Self.Create(APrefixVariable);
end;

function TDBConfigMemory.Password: string;
begin
  Result := FPassword;
end;

function TDBConfigMemory.Password(const AValue: string): IDbEngineConfig;
begin
  Result := Self;
  FPassword := AValue;
end;

function TDBConfigMemory.Port(const AValue: Integer): IDbEngineConfig;
begin
  Result := Self;
  FPort := AValue;
end;

function TDBConfigMemory.Port: Integer;
begin
  Result := FPort;
end;

function TDBConfigMemory.User: string;
begin
  Result := FUser;
end;

function TDBConfigMemory.User(const AValue: string): IDbEngineConfig;
begin
  Result := Self;
  FUser := AValue;
end;

end.
