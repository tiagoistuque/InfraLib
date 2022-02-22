unit Infra.DBEngine.Contract;

interface

uses
  {$IF DEFINED(INFRA_ORMBR)}
  dbebr.factory.interfaces,
  {$ENDIF}
  DB,
  StrUtils,
  Classes;

type
  {$SCOPEDENUMS ON}
  TDBDriver = (
    unknown,
    MSSQL,
    MySQL,
    Firebird,
    SQLite,
    Interbase,
    Oracle,
    PostgreSQL);
  {$SCOPEDENUMS OFF}

  TDBDriverHelper = record helper for TDBDriver
  public
    function ToString: string;
  end;

  IDbEngineConfig = interface
    ['{E3DB667A-5693-467E-97A1-28ED96AA402C}']
    function Driver: TDBDriver; overload;
    function Host: string; overload;
    function Port: Integer; overload;
    function Database: string; overload;
    function CharSet: string; overload;
    function User: string; overload;
    function Password: string; overload;
    function Driver(const AValue: TDBDriver): IDbEngineConfig; overload;
    function Host(const AValue: string): IDbEngineConfig; overload;
    function Port(const AValue: Integer): IDbEngineConfig; overload;
    function Database(const AValue: string): IDbEngineConfig; overload;
    function CharSet(const AValue: string): IDbEngineConfig; overload;
    function User(const AValue: string): IDbEngineConfig; overload;
    function Password(const AValue: string): IDbEngineConfig; overload;
  end;

  IDbEngineFactory = interface
    ['{53515CD9-9EA4-43F3-B275-D2C1FDAC30C3}']

    {$IF DEFINED(INFRA_ORMBR)}
    function Connection: IDBConnection;
    function BuildDatabase: IDbEngineFactory;
    {$ENDIF}
    function ConnectionComponent: TComponent;
    function Connect: IDbEngineFactory;
    function Disconnect: IDbEngineFactory;
    function ExecSQL(const ASQL: string): IDbEngineFactory; overload;
    function ExceSQL(const ASQL: string; var AResultDataSet: TDataSet): IDbEngineFactory; overload;
    function OpenSQL(const ASQL: string; var AResultDataSet: TDataSet): IDbEngineFactory;
    function StartTx: IDbEngineFactory;
    function CommitTX: IDbEngineFactory;
    function RollbackTx: IDbEngineFactory;
    function InTransaction: Boolean;
    function IsConnected: Boolean;
    function InjectConnection(AConn: TComponent; ATransactionObject: TObject): IDbEngineFactory;
  end;

const
  SConfigDriver = 'DBCONFIG_DRIVER';
  SConfigHost = 'DBCONFIG_HOST';
  SConfigPort = 'DBCONFIG_PORT';
  SConfigDatabase = 'DBCONFIG_DATABASE';
  SConfigCharSet = 'DBCONFIG_CHARSET';
  SConfigUser = 'DBCONFIG_USER';
  SConfigPassword = 'DBCONFIG_PASSWORD';

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
  {$ENDIF}

function StrToDBDriver(const AValue: string): TDBDriver;

implementation

{ TDBDriverHelper }

function TDBDriverHelper.ToString: string;
begin
  case Self of
    TDBDriver.unknown:
      Result := 'Unknown';
    TDBDriver.MSSQL:
      Result := 'MSSQL';
    TDBDriver.MySQL:
      Result := 'MySQL';
    TDBDriver.Firebird:
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

function StrToDBDriver(const AValue: string): TDBDriver;
begin
  case AnsiIndexStr(AValue,
    [TDBDriver.MSSQL.ToString, TDBDriver.MySQL.ToString,
    TDBDriver.Firebird.ToString, TDBDriver.SQLite.ToString,
    TDBDriver.Interbase.ToString, TDBDriver.Oracle.ToString,
    TDBDriver.PostgreSQL.ToString, TDBDriver.unknown.ToString]) of
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
  else
    Result := TDBDriver.unknown;
  end;
end;

end.
