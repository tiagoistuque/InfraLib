unit InfraLib.Tests.DbEngine.FirebirdEmbedded;

interface

uses
  DUnitX.TestFramework,
  SysUtils,
  DB,
  Infra.DbEngine;

type

  [TestFixture]
  TTestDBEngineFirebidEmbedded = class(TObject)
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

uses Infra.DbEngine.Contract;

const
  SELECT_WITH_ERROR = 'SELECT CAST(CURRENT_TIMESTAMP AS INTEGER)  FROM RDB$DATABASE';
  SELECT_WITHOUT_ERROR = 'SELECT CURRENT_TIMESTAMP as DATAHORA, CURRENT_USER, CURRENT_CONNECTION FROM RDB$DATABASE';

procedure TTestDBEngineFirebidEmbedded.Setup;
begin
  FConfig := TDBConfigFactory.CreateConfig(TTypeConfig.IniFile);
  FConfig
    .Driver(TDbDriver.FirebirdEmbedded)
    .Database(ExtractFilePath(ParamStr(0)) + 'data\TESTE.FDB')
    .CharSet('UTF8')
//    .User('SYSDBA')
    .SaveTrace(True);
  FEngine := TDBEngineFactory.New(FConfig);
end;

procedure TTestDBEngineFirebidEmbedded.TearDown;
begin
  FreeAndNil(FDataSet);
end;

procedure TTestDBEngineFirebidEmbedded.TestIsConnected;
begin
  FEngine.Connect;
  Assert.IsTrue(FEngine.IsConnected);
end;

procedure TTestDBEngineFirebidEmbedded.TestRollbackTransaction;
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

procedure TTestDBEngineFirebidEmbedded.TestStartTransaction;
begin
  FEngine.StartTx;
  Assert.IsTrue(FEngine.InTransaction);
  FEngine.RollbackTx;
end;

procedure TTestDBEngineFirebidEmbedded.TestStartTransaction2;
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

procedure TTestDBEngineFirebidEmbedded.TestCommitTransaction;
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

procedure TTestDBEngineFirebidEmbedded.TestExecuteDirectSQL;
begin
  FEngine.OpenSQL(SELECT_WITHOUT_ERROR, FDataSet);
  Assert.IsTrue(FDataSet.RecordCount > 0);
  FEngine.Disconnect;
end;

initialization

 TDUnitX.RegisterTestFixture(TTestDBEngineFirebidEmbedded);

end.
