unit Infra.DBEngine.Contract;

interface

uses
  {$IF DEFINED(INFRA_ORMBR)}
  dbebr.factory.interfaces,
  {$ENDIF}
  DB,
  Classes;

type

  IDbEngineConfig = interface
    ['{E3DB667A-5693-467E-97A1-28ED96AA402C}']
    function Driver: string;
    function Host: string;
    function Port: Word;
    function Database: string;
    function CharSet: string;
    function User: string;
    function Password: string;
  end;

  IDbEngineFactory = interface
    ['{53515CD9-9EA4-43F3-B275-D2C1FDAC30C3}']
    {$IF DEFINED(INFRA_ORMBR)}
    function Connection: IDBConnection;
    function BuildDatabase: IDbEngineFactory;
    {$ENDIF}
    function ConnectionComponent: TComponent;
    function Connect: IDbEngineFactory;
    function ExecSQL(const ASQL: string): IDbEngineFactory;
    function ExceSQL(const ASQL: string; var AResultDataSet: TDataSet ): IDbEngineFactory;
    function OpenSQL(const ASQL: string; var AResultDataSet: TDataSet ): IDbEngineFactory;
    function StartTx: IDbEngineFactory;
    function CommitTX: IDbEngineFactory;
    function RollbackTx: IDbEngineFactory;
    function InTransaction: Boolean;
    function InjectConnection(AConn: TComponent; ATransactionObject: TObject): IDbEngineFactory;
  end;

  {$IF DEFINED(INFRA_ORMBR)}

const

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


implementation

end.
