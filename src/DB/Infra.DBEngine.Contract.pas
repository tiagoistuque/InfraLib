unit Infra.DBEngine.Contract;

interface

uses
  {$IF DEFINED(INFRA_ORMBR)}
  dbebr.factory.interfaces,
  {$IFEND}
  DB,
  SysUtils,
  StrUtils,
  Classes, Infra.DBEngine.Context;

type
  {$SCOPEDENUMS ON}
  TDBDriver = (
    unknown,
    MSSQL,
    MSAcc,
    MySQL,
    Firebird,
    FirebirdEmbedded,
    SQLite,
    Interbase,
    Oracle,
    PostgreSQL);
  {$SCOPEDENUMS OFF}
  {$IF CompilerVersion > 23}

  TDBDriverHelper = record helper for TDBDriver
  public
    function ToString: string;
  end;
  {$IFEND}

  IDbEngineConfig = interface
    ['{E3DB667A-5693-467E-97A1-28ED96AA402C}']
    function Driver: TDBDriver; overload;
    function Host: string; overload;
    function Port: Integer; overload;
    function Database: string; overload;
    function CharSet: string; overload;
    function User: string; overload;
    function Password: string; overload;
    function SaveTrace: Boolean; overload;
    function VendorHome: string; overload;
    function VendorLib: string; overload;
    function GetExecuteMigrations: Boolean; overload;
    function Driver(const AValue: TDBDriver): IDbEngineConfig; overload;
    function Host(const AValue: string): IDbEngineConfig; overload;
    function Port(const AValue: Integer): IDbEngineConfig; overload;
    function Database(const AValue: string): IDbEngineConfig; overload;
    function CharSet(const AValue: string): IDbEngineConfig; overload;
    function User(const AValue: string): IDbEngineConfig; overload;
    function Password(const AValue: string): IDbEngineConfig; overload;
    function SaveTrace(const aValue: Boolean): IDbEngineConfig; overload;
    function VendorHome(const AValue: string): IDbEngineConfig; overload;
    function VendorLib(const AValue: string): IDbEngineConfig; overload;
    function SetExecuteMigrations(const AValue: Boolean): IDbEngineConfig; overload;
    function ConfigFileName: TFileName;
  end;

  IDbEngine = interface
    ['{53515CD9-9EA4-43F3-B275-D2C1FDAC30C3}']
    {$IF DEFINED(INFRA_ORMBR)}
    function Connection: IDBConnection;
    procedure ExecuteMigrations;
    {$IFEND}
    function ConnectionComponent: TComponent;
    procedure Connect;
    procedure Disconnect;
    function ExecSQL(const ASQL: string): Integer; overload;
    function ExecSQL(const ASQL: string; var AResultDataSet: TDataSet): Integer; overload;
    function OpenSQL(const ASQL: string; var AResultDataSet: TDataSet): Integer; overload;
    function OpenSQL(const ASQL: string; var AResultDataSet: TDataSet; const APage: Integer; const ARowsPerPage: Integer): Integer; overload;
    procedure StartTx;
    procedure CommitTX;
    procedure RollbackTx;
    function InTransaction: Boolean;
    function IsConnected: Boolean;
    function RowsAffected: Integer;
    procedure InjectConnection(AConn: TComponent; ATransactionObject: TObject);
    function DbDriver: TDBDriver;
  end;

const
  SConfigDriver = 'DBCONFIG_DRIVER';
  SConfigHost = 'DBCONFIG_HOST';
  SConfigPort = 'DBCONFIG_PORT';
  SConfigDatabase = 'DBCONFIG_DATABASE';
  SConfigCharSet = 'DBCONFIG_CHARSET';
  SConfigUser = 'DBCONFIG_USER';
  SConfigPassword = 'DBCONFIG_PASSWORD';
  SConfigSaveTrace = 'DBCONFIG_SAVETRACE';
  SConfigVendorHome = 'DBCONFIG_VENDORHOME';
  SConfigVendorLib = 'DBCONFIG_VENDORLIB';
  SConfigBuildDB = 'DBCONFIG_BUILD_DB';

  {$IF DEFINED(INFRA_ORMBR)}
  dnMSSQL = TDriverName.dnMSSQL;
  dnMySQL = TDriverName.dnMySQL;
  dnFirebird = TDriverName.dnFirebird;
  dnSQLite = TDriverName.dnSQLite;
  dnInterbase = TDriverName.dnInterbase;
  dnDB2 = TDriverName.dnDB2;
  dnOracle = TDriverName.dnOracle;
  dnInformix = TDriverName.dnInformix;
  dnPostgreSQL = TDriverName.dnPostgreSQL;
  dnADS = TDriverName.dnADS;
  dnASA = TDriverName.dnASA;
  dnAbsoluteDB = TDriverName.dnAbsoluteDB;
  dnMongoDB = TDriverName.dnMongoDB;
  dnElevateDB = TDriverName.dnElevateDB;
  dnNexusDB = TDriverName.dnNexusDB;
  dnFirebase = TDriverName.dnFirebase;
  {$IFEND}

function StrToDBDriver(const AValue: string): TDBDriver;
function DBDriverToStr(const AValue: TDBDriver): string;

implementation

{ TDBDriverHelper }

{$IF CompilerVersion > 23}
function TDBDriverHelper.ToString: string;
begin
  case Self of
    TDBDriver.unknown:
      Result := 'Unknown';
    TDBDriver.MSSQL:
      Result := 'MSSQL';
    TDBDriver.MSAcc:
      Result := 'MSAcc';
    TDBDriver.MySQL:
      Result := 'MySQL';
    TDBDriver.Firebird, TDBDriver.FirebirdEmbedded:
      Result := 'Firebird';
    TDBDriver.SQLite:
      Result := 'SQLite';
    TDBDriver.Interbase:
      Result := 'Interbase';
    TDBDriver.Oracle:
      Result := 'Oracle';
    TDBDriver.PostgreSQL:
      Result := 'PostgreSQL';
  end;
end;
{$IFEND}

function StrToDBDriver(const AValue: string): TDBDriver;
begin
  case AnsiIndexStr(AValue,
    ['MSSQL', 'MySQL','Firebird', 'SQLite',
    'Interbase', 'Oracle', 'PostgreSQL', 'Unknown',
    'MSAcc', 'FirebirdEmbedded']) of
    0:
      Result := TDBDriver.MSSQL;
    1:
      Result := TDBDriver.MySQL;
    2:
      Result := TDBDriver.Firebird;
    3:
      Result := TDBDriver.SQLite;
    4:
      Result := TDBDriver.Interbase;
    5:
      Result := TDBDriver.Oracle;
    6:
      Result := TDBDriver.PostgreSQL;
    7:
      Result := TDBDriver.unknown;
    8:
      Result := TDBDriver.MSAcc;
    9:
      Result := TDBDriver.FirebirdEmbedded;
  else
    Result := TDBDriver.unknown;
  end;
end;

function DBDriverToStr(const AValue: TDBDriver): string;
begin
  case AValue of
    TDBDriver.unknown:
      Result := 'Unknown';
    TDBDriver.MSSQL:
      Result := 'MSSQL';
    TDBDriver.MSAcc:
      Result := 'MSAcc';
    TDBDriver.MySQL:
      Result := 'MySQL';
    TDBDriver.Firebird:
      Result := 'Firebird';
    TDBDriver.FirebirdEmbedded:
      Result := 'FirebirdEmbedded';
    TDBDriver.SQLite:
      Result := 'SQLite';
    TDBDriver.Interbase:
      Result := 'Interbase';
    TDBDriver.Oracle:
      Result := 'Oracle';
    TDBDriver.PostgreSQL:
      Result := 'PostgreSQL';
  end;
end;

end.
