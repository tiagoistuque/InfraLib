unit Infra.DBConfig;

interface

uses
  System.SysUtils,
  System.JSON,
  Infra.DBEngine.Contract;

type
  TDBConfigDef = class abstract(TInterfacedObject, IDbEngineConfig)
  protected
    FPrefixVariable: string;
  protected
    function Driver: TDBDriver; overload; virtual; abstract;
    function Host: string; overload; virtual; abstract;
    function Port: Integer; overload; virtual; abstract;
    function Database: string; overload; virtual; abstract;
    function CharSet: string; overload; virtual; abstract;
    function User: string; overload; virtual; abstract;
    function Password: string; overload; virtual; abstract;
    function SaveTrace: Boolean; overload; virtual; abstract;
    function VendorHome: string; overload; virtual; abstract;
    function VendorLib: string; overload; virtual; abstract;
    function GetExecuteMigrations: Boolean; overload; virtual; abstract;
    function Driver(const AValue: TDBDriver): IDbEngineConfig; overload; virtual; abstract;
    function Host(const AValue: string): IDbEngineConfig; overload; virtual; abstract;
    function Port(const AValue: Integer): IDbEngineConfig; overload; virtual; abstract;
    function Database(const AValue: string): IDbEngineConfig; overload; virtual; abstract;
    function CharSet(const AValue: string): IDbEngineConfig; overload; virtual; abstract;
    function User(const AValue: string): IDbEngineConfig; overload; virtual; abstract;
    function Password(const AValue: string): IDbEngineConfig; overload; virtual; abstract;
    function SaveTrace(const AValue: Boolean): IDbEngineConfig; overload; virtual; abstract;
    function VendorHome(const AValue: string): IDbEngineConfig; overload; virtual; abstract;
    function VendorLib(const AValue: string): IDbEngineConfig; overload; virtual; abstract;
    function SetExecuteMigrations(const AValue: Boolean): IDbEngineConfig; overload; virtual; abstract;
    function ConfigFileName: TFileName; virtual; abstract;
    function ToJson: string; virtual;
  public
    constructor Create(const APrefixVariable: string); virtual; abstract;
    class function New(const APrefixVariable: string): IDbEngineConfig; virtual; abstract;
  end;

implementation

{ TDBConfigDef }

function TDBConfigDef.ToJson: string;
var
  LJson: TJSONObject;
begin
  LJson := TJSONObject.Create;
  try
    LJson
      .AddPair('Driver', TJSONString.Create(Self.Driver.ToString))
      .AddPair('Host', TJSONString.Create(Self.Host))
      .AddPair('Port', TJSONNumber.Create(Self.Port))
      .AddPair('Database', TJSONString.Create(Self.Database))
      .AddPair('CharSet', TJSONString.Create(Self.CharSet));
    Result := LJson.ToJSON;
  finally
    LJson.Free;
  end;
end;

end.

