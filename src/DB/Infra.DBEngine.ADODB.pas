unit Infra.DBEngine.ADODB;

interface

uses
  DB,
  Classes,
  SysUtils,

  ADODB,

  Infra.DBEngine.Abstract,
  Infra.DBEngine.Contract;

type
  TDbEngineADO = class(TDbEngineAbstract)
  private
    FConnectionComponent: TADOConnection;
    FInjectedConnection: Boolean;
    FRowsAffected: Integer;
  public
    function ConnectionComponent: TComponent; override;
    procedure Connect; override;
    procedure Disconnect; override;
    function ExecSQL(const ASQL: string): Integer; override;
    function ExceSQL(const ASQL: string; var AResultDataSet: TDataSet): Integer; override;
    function OpenSQL(const ASQL: string; var AResultDataSet: TDataSet): Integer; override;
    procedure StartTx; override;
    procedure CommitTX; override;
    procedure RollbackTx; override;
    function InTransaction: Boolean; override;
    function IsConnected: Boolean; override;
    function RowsAffected: Integer; override;
    procedure InjectConnection(AConn: TComponent; ATransactionObject: TObject); override;

  public
    constructor Create(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = ''); override;
    destructor Destroy; override;

  end;

implementation

uses
  {$IF DEFINED(INFRA_ORMBR)}dbebr.factory.ado, {$IFEND}
  Infra.DBEngine.Trace, Infra.DBEngine.Context,
  Infra.DBDriver.Register, Infra.DBEngine.Error;

procedure TDbEngineADO.CommitTX;
begin
  FConnectionComponent.CommitTrans;
end;

procedure TDbEngineADO.Connect;
begin
  FConnectionComponent.Connected := True;
  inherited;
end;

function TDbEngineADO.ConnectionComponent: TComponent;
begin
  Result := FConnectionComponent;
end;

constructor TDbEngineADO.Create(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = '');
begin
  inherited;
  if Assigned(ADbConfig) then
  begin
    FConnectionComponent := TADOConnection.Create(nil);
    FConnectionComponent.LoginPrompt := False;
    FConnectionComponent.IsolationLevel := ilReadCommitted;
    FConnectionComponent.Mode := cmShareDenyNone;
    FConnectionComponent.CursorLocation := clUseServer;
    FConnectionComponent.KeepConnection := True;
    FConnectionComponent.ConnectionString := Format('Provider=SQLOLEDB.1; Persist Security Info=False; User ID=%s; Password=%s; Data Source=%s; Initial Catalog=%s', [ADBconfig.User, ADBConfig.Password, ADBConfig.Host, ADBConfig.Database]);

    {$IF DEFINED(INFRA_ORMBR)}
    FDBConnection := TFactoryADO.Create(FConnectionComponent, TDBDriverRegister.GetDriverName(ADbConfig.Driver));
    {$IFEND}
  end;
end;

destructor TDbEngineADO.Destroy;
begin
  if (not FInjectedConnection) then
  begin
    FConnectionComponent.Free;
  end;
  inherited;
end;

procedure TDbEngineADO.Disconnect;
begin
  FConnectionComponent.Connected := False;
  inherited;
end;

function TDbEngineADO.ExceSQL(const ASQL: string;
  var AResultDataSet: TDataSet): Integer;
var
  LQuery: TADOQuery;
begin
  LQuery := TADOQuery.Create(nil);
  try
    LQuery.Connection := FConnectionComponent;
    LQuery.SQL.Text := ASQL;
    LQuery.Open;
    Result := LQuery.RecordCount
  finally
    AResultDataSet := LQuery;
  end;
end;

function TDbEngineADO.ExecSQL(const ASQL: string): Integer;
begin
  FConnectionComponent.Execute(ASQL, FRowsAffected);
  Result := FRowsAffected;
end;

procedure TDbEngineADO.InjectConnection(AConn: TComponent;
  ATransactionObject: TObject);
begin
  if not(AConn is TADOConnection) then
    raise Exception.Create('Invalid connection component instance for ADOConnectino. ' + Self.UnitName);
  if Assigned(FConnectionComponent) then
    FreeAndNil(FConnectionComponent);
  FConnectionComponent := TADOConnection(AConn);
  FInjectedConnection := True;
end;

function TDbEngineADO.InTransaction: Boolean;
begin
  Result := FConnectionComponent.InTransaction;
end;

function TDbEngineADO.IsConnected: Boolean;
begin
  Result := Assigned(FConnectionComponent) and FConnectionComponent.Connected;
end;

function TDbEngineADO.OpenSQL(const ASQL: string;
  var AResultDataSet: TDataSet): Integer;
var
  LQuery: TADOQuery;
begin
  LQuery := TADOQuery.Create(nil);
  try
    LQuery.Connection := FConnectionComponent;
    LQuery.SQL.Text := ASQL;
    LQuery.Open;
    Result := LQuery.RecordCount;
  finally
    AResultDataSet := LQuery;
  end;
end;

procedure TDbEngineADO.RollbackTx;
begin
  FConnectionComponent.RollbackTrans;
end;

function TDbEngineADO.RowsAffected: Integer;
begin
  Result := FRowsAffected;
end;

procedure TDbEngineADO.StartTx;
begin
  if InTransaction then
    raise EStartTransactionException.Create('Necessário commit ou rollback da transação anterior para iniciar uma nova transação.');
  FConnectionComponent.BeginTrans;
end;

end.
