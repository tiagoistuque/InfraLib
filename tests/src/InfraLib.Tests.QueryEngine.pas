unit InfraLib.Tests.QueryEngine;

interface

uses
  DUnitX.TestFramework,
  SysUtils,
  Infra.DBEngine,
  Infra.QueryEngine;

type

  [TestFixture]
  TTestQueryEngine = class(TObject)
  private
    FConfig: IDbEngineConfig;
    FEngine: IDBEngine;
    FQueryEngine: IQueryEngine;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestSelectDataTypes;
  end;

implementation


uses
  DB;

procedure TTestQueryEngine.Setup;
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
  FQueryEngine := TQueryEngine.New(TDbEngine(FEngine));
end;

procedure TTestQueryEngine.TearDown;
begin
end;

procedure TTestQueryEngine.TestSelectDataTypes;
const
  CEXPECTED_RESULT_INTEGER: Integer = 100;
  CEXPECTED_RESULT_CURRENCY: Currency = 100.55;
  CEXPECTED_RESULT_VARCHAR: string = 'MY INFO VARCHAR';
  CEXPECTED_RESULT_CHAR: string = 'MY INFO CHAR';
  CEXPECTED_CHAR_FIELD_SIZE = {$IF DEFINED(INFRA_DBEXPRESS)} 120 {$ELSE} 30{$IFEND};
  CRESULT_INTEGER: string = '100';
  CRESULT_CURRENCY: string = '100.55';
  CRESULT_VARCHAR: string = 'MY INFO VARCHAR';
  CRESULT_CHAR: string = 'MY INFO CHAR';

var
  LResultInteger: Integer;
  LResultCurrency: Currency;
  LResultVarChar: string;
  LResultChar: string;
  select_return_datatypes: string;
  LIsFixedChar: Boolean;
  LFieldSize: Integer;
begin
  select_return_datatypes := 'SELECT CAST(' + CRESULT_INTEGER + ' AS INTEGER) AS RESULT_INTEGER, ' +
    'CAST(' + CRESULT_CURRENCY + ' AS NUMERIC(10,2)) AS RESULT_CURRENCY, ' +
    'CAST(' + QuotedStr(CRESULT_VARCHAR) + ' AS VARCHAR(30)) AS RESULT_VARCHAR, ' +
    'CAST(' + QuotedStr(CRESULT_CHAR) + ' AS CHAR(30)) AS RESULT_CHAR' +
    ' FROM RDB$DATABASE';

  FQueryEngine.Reset
    .Add(select_return_datatypes)
    .Open;

  LResultInteger := FQueryEngine.DataSet.FieldByName('RESULT_INTEGER').AsInteger;
  LResultCurrency := FQueryEngine.DataSet.FieldByName('RESULT_CURRENCY').AsCurrency;
  LResultVarChar := FQueryEngine.DataSet.FieldByName('RESULT_VARCHAR').AsString;
  LResultChar := Trim(FQueryEngine.DataSet.FieldByName('RESULT_CHAR').AsString);
  LIsFixedChar := TStringField(FQueryEngine.DataSet.FieldByName('RESULT_CHAR')).FixedChar;
  LFieldSize := TStringField(FQueryEngine.DataSet.FieldByName('RESULT_CHAR')).Size;

  Assert.AreEqual(CEXPECTED_RESULT_INTEGER, LResultInteger);
  Assert.AreEqual(CEXPECTED_RESULT_CURRENCY, LResultCurrency);
  Assert.AreEqual(CEXPECTED_RESULT_VARCHAR, LResultVarChar);
  Assert.AreEqual(CEXPECTED_RESULT_CHAR, LResultChar);
  Assert.IsTrue(LIsFixedChar);
  Assert.AreEqual(LFieldSize, CEXPECTED_CHAR_FIELD_SIZE);
end;

initialization

TDUnitX.RegisterTestFixture(TTestQueryEngine);

end.
