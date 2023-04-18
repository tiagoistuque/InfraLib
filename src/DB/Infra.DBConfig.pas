unit Infra.DBConfig;

interface

uses
  SysUtils,
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
    function VendorLib(const AValue: string): IDbEngineConfig; overload; virtual; abstract;
    function SetExecuteMigrations(const AValue: Boolean): IDbEngineConfig; overload; virtual; abstract;
    function ConfigFileName: TFileName; virtual; abstract;
  public
    constructor Create(const APrefixVariable: string); virtual; abstract;
    class function New(const APrefixVariable: string): IDbEngineConfig; virtual; abstract;
  end;

implementation

end.
