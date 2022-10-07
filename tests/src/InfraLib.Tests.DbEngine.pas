unit InfraLib.Tests.DbEngine;

interface

uses
  DUnitX.TestFramework,
  SysUtils,
  DB,
  Infra.DbEngine;

type

  [TestFixture]
  TTestDBEngine = class(TObject)
  private
    FConfig: IDbEngineConfig;
    FEngine: IDBEngine;
    FDataSet: TDataSet;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestIsConnected;

    [Test]
    procedure TestExecuteDirectSQL;

    [Test]
    procedure TestStartTransaction;

    [Test]
    procedure TestCommitTransaction;

    [Test]
    procedure TestRollbackTransaction;

    [Test]
    procedure TestStartTransaction2;
  end;

implementation

uses Infra.DBEngine.Contract;

const
  SELECT_WITH_ERROR = 'SELECT CAST(CURRENT_TIMESTAMP AS INTEGER)  FROM RDB$DATABASE';
  SELECT_WITHOUT_ERROR = 'SELECT CURRENT_TIMESTAMP as DATAHORA, CURRENT_USER, CURRENT_CONNECTION FROM RDB$DATABASE';

procedure TTestDBEngine.Setup;
begin
  FConfig := TDBConfigFactory.CreateConfig(TTypeConfig.IniFile);
  FConfig
    .Driver(TDbDriver.Firebird)
    .Host('localhost')
    .Port(3053)
    .Database(ExtractFilePath(ParamStr(0)) + 'data\TESTE.FDB')
    .CharSet('UTF8')
    .User('SYSDBA')
    .Password('masterkey');
  FEngine := TDBEngineFactory.New(FConfig);
end;

procedure TTestDBEngine.TearDown;
begin
  FreeAndNil(FDataSet);
end;

procedure TTestDBEngine.TestIsConnected;
begin
  FEngine.Connect;
  Assert.IsTrue(FEngine.IsConnected);
end;

procedure TTestDBEngine.TestRollbackTransaction;
begin
  try
    FEngine.StartTx;

    FEngine.OpenSQL(SELECT_WITH_ERROR, FDataSet);
    FEngine.CommitTX;
  except
    on E: Exception do
      FEngine.RollbackTx;
  end;
  Assert.IsTrue(not FEngine.InTransaction);
end;

procedure TTestDBEngine.TestStartTransaction;
begin
  FEngine.StartTx;
  Assert.IsTrue(FEngine.InTransaction);
  FEngine.RollbackTx;
end;

procedure TTestDBEngine.TestStartTransaction2;
var
  LProc: TProc;
begin
  LProc := procedure
  begin
    FEngine.StartTx;
    FEngine.StartTx;
  end;
  Assert.WillRaise(LProc, EStartTransactionException);
end;

procedure TTestDBEngine.TestCommitTransaction;
var
  LTransactionCompleted: Boolean;
begin
  try
    FEngine.StartTx;
    FEngine.OpenSQL(SELECT_WITHOUT_ERROR, FDataSet);
    FEngine.CommitTX;
    LTransactionCompleted := True;
  except
    on E: Exception do
    begin
      LTransactionCompleted := False;
      FEngine.RollbackTx;
    end;
  end;
  Assert.IsTrue(LTransactionCompleted);
end;

procedure TTestDBEngine.TestExecuteDirectSQL;
begin
  FEngine.OpenSQL(SELECT_WITHOUT_ERROR, FDataSet);
  Assert.IsTrue(FDataSet.RecordCount > 0);
  FEngine.Disconnect;
end;

initialization

TDUnitX.RegisterTestFixture(TTestDBEngine);

end.
